import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:share_plus/share_plus.dart';

import 'package:shoo/features/activity_webview/domain/entities/hos_activity_config.dart';
import 'package:shoo/features/activity_webview/presentation/state/hos_share_provider.dart';

class SHOShareDialog extends ConsumerWidget {
  const SHOShareDialog({super.key, required this.config});

  final SHOActivityConfig config;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final share = ref.watch(shareProvider);
    return Material(
      color: Theme.of(context).colorScheme.surface,
      borderRadius: BorderRadius.circular(12),
      clipBehavior: Clip.antiAlias,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('分享活动', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800)),
            const SizedBox(height: 16),
            _ScreenshotPreview(share: share),
            const SizedBox(height: 12),
            Text(config.shareTitle, style: const TextStyle(fontWeight: FontWeight.w700)),
            Text(config.shareDesc, style: const TextStyle(color: Colors.grey)),
            const SizedBox(height: 16),
            Wrap(
              spacing: 16,
              children: [
                _ShareChip(
                  label: '微信好友',
                  color: const Color(0xFF07C160),
                  onTap: () => ref.read(shareProvider.notifier).shareTo(context, ref, 'wechat', config),
                ),
                _ShareChip(
                  label: '朋友圈',
                  color: const Color(0xFF4A90E2),
                  onTap: () => ref.read(shareProvider.notifier).shareTo(context, ref, 'moments', config),
                ),
                _ShareChip(
                  label: '复制链接',
                  color: const Color(0xFFFF8A3D),
                  onTap: () => Share.share(config.shareUrl),
                ),
                _ShareChip(
                  label: '保存图片',
                  color: const Color(0xFF9B59B6),
                  onTap: () => ref.read(shareProvider.notifier).shareTo(context, ref, 'save', config),
                ),
              ],
            ),
            TextButton(
              onPressed: () => ref.read(shareProvider.notifier).hide(),
              child: const Text('取消'),
            ),
          ],
        ),
      ),
    );
  }
}

class _ScreenshotPreview extends StatelessWidget {
  const _ScreenshotPreview({required this.share});

  final SHOShareState share;

  @override
  Widget build(BuildContext context) {
    if (share.capturing) {
      return Container(
        height: 200,
        decoration: BoxDecoration(
          color: Colors.grey.shade200,
          borderRadius: BorderRadius.circular(12),
        ),
        alignment: Alignment.center,
        child: const Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 12),
            Text('正在生成网页截图...'),
          ],
        ),
      );
    }

    if (share.imageBytes != null) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxHeight: 240),
          child: Image.memory(
            share.imageBytes!,
            width: double.infinity,
            fit: BoxFit.contain,
          ),
        ),
      );
    }

    return Container(
      height: 160,
      decoration: BoxDecoration(
        color: Colors.grey.shade200,
        borderRadius: BorderRadius.circular(12),
      ),
      alignment: Alignment.center,
      child: const Text('暂无截图预览'),
    );
  }
}

class _ShareChip extends StatelessWidget {
  const _ShareChip({
    required this.label,
    required this.color,
    required this.onTap,
  });

  final String label;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Column(
        children: [
          CircleAvatar(backgroundColor: color, child: const Icon(Icons.share, color: Colors.white, size: 18)),
          const SizedBox(height: 4),
          Text(label, style: const TextStyle(fontSize: 12)),
        ],
      ),
    );
  }
}
