import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../core/storage/hos_local_storage.dart';

const _storageKey = 'profile_activity_v1';
const _maxFootprints = 50;

final profileActivityStorageProvider = Provider<SHOProfileActivityStorage>((ref) {
  return SHOProfileActivityStorage(ref.watch(sharedPreferencesProvider));
});

class SHOProfileProductCache {
  const SHOProfileProductCache({
    required this.title,
    required this.imageUrl,
    required this.price,
    this.originalPrice = 0,
    this.rating = 0,
    this.soldCount = 0,
  });

  final String title;
  final String imageUrl;
  final int price;
  final int originalPrice;
  final double rating;
  final int soldCount;

  factory SHOProfileProductCache.fromJson(Map<String, dynamic> json) {
    return SHOProfileProductCache(
      title: json['title'] as String? ?? '',
      imageUrl: json['imageUrl'] as String? ?? '',
      price: json['price'] as int? ?? 0,
      originalPrice: json['originalPrice'] as int? ?? 0,
      rating: (json['rating'] as num?)?.toDouble() ?? 0,
      soldCount: json['soldCount'] as int? ?? 0,
    );
  }

  Map<String, dynamic> toJson() => {
        'title': title,
        'imageUrl': imageUrl,
        'price': price,
        'originalPrice': originalPrice,
        'rating': rating,
        'soldCount': soldCount,
      };
}

class SHOProfileActivityStorage {
  SHOProfileActivityStorage(this._prefs);

  final SharedPreferences _prefs;

  SHOProfileActivitySnapshot read() {
    final raw = _prefs.getString(_storageKey);
    if (raw == null || raw.isEmpty) {
      return const SHOProfileActivitySnapshot();
    }
    try {
      final json = jsonDecode(raw) as Map<String, dynamic>;
      return SHOProfileActivitySnapshot.fromJson(json);
    } catch (_) {
      return const SHOProfileActivitySnapshot();
    }
  }

  Future<SHOProfileActivitySnapshot> save(
    SHOProfileActivitySnapshot snapshot,
  ) async {
    await _prefs.setString(_storageKey, jsonEncode(snapshot.toJson()));
    return snapshot;
  }

  Future<SHOProfileActivitySnapshot> recordFootprint(
    String productId, {
    SHOProfileProductCache? cache,
  }) async {
    final current = read();
    final next = [
      productId,
      ...current.footprints.where((id) => id != productId),
    ].take(_maxFootprints).toList();
    final caches = Map<String, SHOProfileProductCache>.from(current.productCache);
    if (cache != null) {
      caches[productId] = cache;
    }
    return save(current.copyWith(footprints: next, productCache: caches));
  }

  Future<SHOProfileActivitySnapshot> toggleFavorite(
    String productId, {
    SHOProfileProductCache? cache,
  }) async {
    final current = read();
    final favorites = [...current.favorites];
    final caches = Map<String, SHOProfileProductCache>.from(current.productCache);
    if (favorites.contains(productId)) {
      favorites.remove(productId);
    } else {
      favorites.insert(0, productId);
      if (cache != null) {
        caches[productId] = cache;
      }
    }
    return save(current.copyWith(favorites: favorites, productCache: caches));
  }

  Future<SHOProfileActivitySnapshot> removeFootprints(
    Iterable<String> productIds,
  ) async {
    final current = read();
    final removeSet = productIds.toSet();
    return save(
      current.copyWith(
        footprints: current.footprints.where((id) => !removeSet.contains(id)).toList(),
      ),
    );
  }

  Future<SHOProfileActivitySnapshot> removeFavorites(
    Iterable<String> productIds,
  ) async {
    final current = read();
    final removeSet = productIds.toSet();
    return save(
      current.copyWith(
        favorites: current.favorites.where((id) => !removeSet.contains(id)).toList(),
      ),
    );
  }

  Future<SHOProfileActivitySnapshot> recordFollowedCategory(
    String categoryId,
  ) async {
    final current = read();
    final next = {
      categoryId,
      ...current.followedCategories,
    }.toList();
    return save(current.copyWith(followedCategories: next));
  }
}

class SHOProfileActivitySnapshot {
  const SHOProfileActivitySnapshot({
    this.footprints = const [],
    this.favorites = const [],
    this.followedCategories = const [],
    this.productCache = const {},
  });

  final List<String> footprints;
  final List<String> favorites;
  final List<String> followedCategories;
  final Map<String, SHOProfileProductCache> productCache;

  int get footprintCount => footprints.length;
  int get favoriteCount => favorites.length;
  int get followingCount => followedCategories.length;

  SHOProfileActivitySnapshot copyWith({
    List<String>? footprints,
    List<String>? favorites,
    List<String>? followedCategories,
    Map<String, SHOProfileProductCache>? productCache,
  }) {
    return SHOProfileActivitySnapshot(
      footprints: footprints ?? this.footprints,
      favorites: favorites ?? this.favorites,
      followedCategories: followedCategories ?? this.followedCategories,
      productCache: productCache ?? this.productCache,
    );
  }

  factory SHOProfileActivitySnapshot.fromJson(Map<String, dynamic> json) {
    final cacheRaw = json['productCache'];
    final cache = <String, SHOProfileProductCache>{};
    if (cacheRaw is Map) {
      cacheRaw.forEach((key, value) {
        if (value is Map<String, dynamic>) {
          cache[key.toString()] = SHOProfileProductCache.fromJson(value);
        }
      });
    }
    return SHOProfileActivitySnapshot(
      footprints: _readStringList(json['footprints']),
      favorites: _readStringList(json['favorites']),
      followedCategories: _readStringList(json['followedCategories']),
      productCache: cache,
    );
  }

  Map<String, dynamic> toJson() => {
        'footprints': footprints,
        'favorites': favorites,
        'followedCategories': followedCategories,
        'productCache': productCache.map(
          (key, value) => MapEntry(key, value.toJson()),
        ),
      };

  static List<String> _readStringList(Object? raw) {
    if (raw is! List) return const [];
    return raw.map((e) => e.toString()).toList();
  }
}
