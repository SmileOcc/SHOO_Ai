import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shoo/core/notifications/hos_flash_sale_reminder_service.dart';
import 'package:shoo/features/flash_sale/data/datasources/local/hos_flash_sale_follow_storage.dart';
import 'package:shoo/features/flash_sale/data/repositories/hos_flash_sale_repository_impl.dart';
import 'package:shoo/features/flash_sale/domain/entities/hos_flash_sale_follow.dart';
import 'package:shoo/features/flash_sale/domain/entities/hos_flash_sale_product.dart';

final flashSaleFollowStorageProvider =
    FutureProvider<SHOFlashSaleFollowStorage>((ref) async {
      final prefs = await SharedPreferences.getInstance();
      return SHOFlashSaleFollowStorage(prefs);
    });

final flashSaleFollowControllerProvider =
    AsyncNotifierProvider<SHOFlashSaleFollowNotifier, List<SHOFlashSaleFollow>>(
      SHOFlashSaleFollowNotifier.new,
    );

class SHOFlashSaleFollowNotifier
    extends AsyncNotifier<List<SHOFlashSaleFollow>> {
  @override
  Future<List<SHOFlashSaleFollow>> build() async {
    final cached = await _readCachedFollows();
    try {
      return await _syncFromServer(cached);
    } catch (_) {
      if (cached.isNotEmpty) return cached;
      rethrow;
    }
  }

  Future<List<SHOFlashSaleFollow>> _readCachedFollows() async {
    try {
      final storage = await ref.read(flashSaleFollowStorageProvider.future);
      return storage.readAll();
    } catch (_) {
      return const [];
    }
  }

  /// 与服务器同步；保留本地缓存，合并远端结果，避免空响应覆盖已关注数据。
  Future<void> syncFromServer() async {
    final cached = state.valueOrNull ?? await _readCachedFollows();
    state = const AsyncLoading();
    try {
      final merged = await _syncFromServer(cached);
      state = AsyncData(merged);
    } catch (error, stack) {
      if (cached.isNotEmpty) {
        state = AsyncData(cached);
      } else {
        state = AsyncError(error, stack);
      }
    }
  }

  Future<List<SHOFlashSaleFollow>> _syncFromServer(
    List<SHOFlashSaleFollow> local,
  ) async {
    final storage = await ref.read(flashSaleFollowStorageProvider.future);
    final repo = ref.read(flashSaleRepositoryProvider);
    final remote = await repo.getFollows();
    final merged = _mergeFollowLists(local, remote);

    for (final follow in merged) {
      final onServer = remote.any(
        (remoteFollow) =>
            remoteFollow.sessionId == follow.sessionId &&
            remoteFollow.productId == follow.productId,
      );
      if (!onServer) {
        await repo.follow(follow: follow);
      }
    }

    await storage.writeAll(merged);
    await ref.read(flashSaleReminderServiceProvider).rescheduleAll(merged);
    return merged;
  }

  static List<SHOFlashSaleFollow> _mergeFollowLists(
    List<SHOFlashSaleFollow> local,
    List<SHOFlashSaleFollow> remote,
  ) {
    final map = <String, SHOFlashSaleFollow>{};
    for (final follow in local) {
      map['${follow.sessionId}:${follow.productId}'] = follow;
    }
    for (final follow in remote) {
      map['${follow.sessionId}:${follow.productId}'] = follow;
    }
    final merged = map.values.toList()
      ..sort((a, b) => a.sessionStartAt.compareTo(b.sessionStartAt));
    return merged;
  }

  bool isFollowed({required String sessionId, required String productId}) {
    return state.valueOrNull?.any(
          (follow) =>
              follow.sessionId == sessionId && follow.productId == productId,
        ) ??
        false;
  }

  Future<bool> toggleFollow({
    required SHOFlashSaleProduct product,
    required String sessionStartAt,
  }) async {
    final current = state.valueOrNull ?? const <SHOFlashSaleFollow>[];
    final exists = current.any(
      (follow) =>
          follow.sessionId == product.sessionId && follow.productId == product.id,
    );

    final repo = ref.read(flashSaleRepositoryProvider);
    final reminder = ref.read(flashSaleReminderServiceProvider);

    if (exists) {
      await repo.unfollow(sessionId: product.sessionId, productId: product.id);
      await reminder.cancelReminder(
        sessionId: product.sessionId,
        productId: product.id,
      );
      final next = current
          .where(
            (follow) =>
                !(follow.sessionId == product.sessionId &&
                    follow.productId == product.id),
          )
          .toList();
      state = AsyncData(next);
      final storage = await ref.read(flashSaleFollowStorageProvider.future);
      await storage.writeAll(next);
      return false;
    }

    if (!product.canFollow) return false;

    final follow = SHOFlashSaleFollow(
      id: '${product.sessionId}:${product.id}',
      sessionId: product.sessionId,
      productId: product.id,
      title: product.title,
      imageUrl: product.imageUrl,
      sessionStartAt: sessionStartAt,
      status: product.status,
    );

    await repo.follow(follow: follow);
    await reminder.scheduleReminder(follow);
    final next = [...current, follow];
    state = AsyncData(next);
    final storage = await ref.read(flashSaleFollowStorageProvider.future);
    await storage.writeAll(next);
    return true;
  }

  Future<void> pushLocalToServer() async {
    final storage = await ref.read(flashSaleFollowStorageProvider.future);
    final local = storage.readAll();
    final repo = ref.read(flashSaleRepositoryProvider);
    for (final follow in local) {
      await repo.follow(follow: follow);
    }
    await syncFromServer();
  }
}
