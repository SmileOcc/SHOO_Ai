import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shoo/core/notifications/hos_flash_sale_reminder_service.dart';
import 'package:shoo/features/flash_sale/data/datasources/local/hos_flash_sale_follow_storage.dart';
import 'package:shoo/features/flash_sale/data/repositories/hos_flash_sale_repository_impl.dart';
import 'package:shoo/features/flash_sale/domain/entities/hos_flash_sale_follow.dart';
import 'package:shoo/features/flash_sale/domain/entities/hos_flash_sale_product.dart';

// 用户关注本地存储状态
final flashSaleFollowStorageProvider =
    FutureProvider<SHOFlashSaleFollowStorage>((ref) async {
      final prefs = await SharedPreferences.getInstance();
      return SHOFlashSaleFollowStorage(prefs);
    });

// 用户关注的闪购商品列表
final flashSaleFollowControllerProvider =
    StateNotifierProvider<
      SHOFlashSaleFollowController,
      AsyncValue<List<SHOFlashSaleFollow>>
    >((ref) => SHOFlashSaleFollowController(ref));

class SHOFlashSaleFollowController
    extends StateNotifier<AsyncValue<List<SHOFlashSaleFollow>>> {
  SHOFlashSaleFollowController(this._ref) : super(const AsyncValue.loading()) {
    _bootstrap();
  }

  final Ref _ref;

  Future<void> _bootstrap() async {
    await _hydrateFromStorage();
    await syncFromServer();
  }

  Future<void> _hydrateFromStorage() async {
    try {
      final storage = await _ref.read(flashSaleFollowStorageProvider.future);
      final cached = storage.readAll();
      if (cached.isNotEmpty) {
        state = AsyncValue.data(cached);
      }
    } catch (_) {}
  }

  /// 与服务器同步；保留本地缓存，合并远端结果，避免空响应覆盖已关注数据。
  Future<void> syncFromServer() async {
    final hadData = state.valueOrNull?.isNotEmpty ?? false;
    if (!hadData) {
      state = const AsyncValue.loading();
    }

    try {
      final storage = await _ref.read(flashSaleFollowStorageProvider.future);
      final local = storage.readAll();
      final repo = _ref.read(flashSaleRepositoryProvider);
      final remote = await repo.getFollows();
      final merged = _mergeFollowLists(local, remote);

      for (final follow in merged) {
        final onServer = remote.any(
          (r) =>
              r.sessionId == follow.sessionId &&
              r.productId == follow.productId,
        );
        if (!onServer) {
          await repo.follow(follow: follow);
        }
      }

      await storage.writeAll(merged);
      state = AsyncValue.data(merged);
      await _ref.read(flashSaleReminderServiceProvider).rescheduleAll(merged);
    } catch (error, stack) {
      try {
        final storage = await _ref.read(flashSaleFollowStorageProvider.future);
        final cached = storage.readAll();
        if (cached.isNotEmpty) {
          state = AsyncValue.data(cached);
        } else {
          state = AsyncValue.error(error, stack);
        }
      } catch (_) {
        state = AsyncValue.error(error, stack);
      }
    }
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
          (f) => f.sessionId == sessionId && f.productId == productId,
        ) ??
        false;
  }

  // 关注/取消
  Future<bool> toggleFollow({
    required SHOFlashSaleProduct product,
    required String sessionStartAt,
  }) async {
    final current = state.valueOrNull ?? const <SHOFlashSaleFollow>[];
    final exists = current.any(
      (f) => f.sessionId == product.sessionId && f.productId == product.id,
    );

    final repo = _ref.read(flashSaleRepositoryProvider);
    final reminder = _ref.read(flashSaleReminderServiceProvider);

    if (exists) {
      await repo.unfollow(sessionId: product.sessionId, productId: product.id);
      await reminder.cancelReminder(
        sessionId: product.sessionId,
        productId: product.id,
      );
      final next = current
          .where(
            (f) =>
                !(f.sessionId == product.sessionId &&
                    f.productId == product.id),
          )
          .toList();
      state = AsyncValue.data(next);
      final storage = await _ref.read(flashSaleFollowStorageProvider.future);
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
    state = AsyncValue.data(next);
    final storage = await _ref.read(flashSaleFollowStorageProvider.future);
    await storage.writeAll(next);
    return true;
  }

  // 本地数据推送到服务器
  Future<void> pushLocalToServer() async {
    final storage = await _ref.read(flashSaleFollowStorageProvider.future);
    final local = storage.readAll();
    final repo = _ref.read(flashSaleRepositoryProvider);
    for (final follow in local) {
      await repo.follow(follow: follow);
    }
    await syncFromServer();
  }
}
