import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:photo_view/photo_view.dart';
import 'package:photo_view/photo_view_gallery.dart';
import 'package:share_plus/share_plus.dart';

import 'package:shoo/core/analytics/hos_page_analytics.dart';
import 'package:shoo/core/pages/hos_pages.dart';
import 'package:shoo/core/feedback/hos_toast.dart';
import 'package:shoo/core/media/hos_gallery_saver_service.dart';
import 'package:shoo/features/activity_webview/data/datasources/remote/hos_activity_remote_ds.dart';
import 'package:shoo/features/activity_webview/presentation/state/hos_image_preview_provider.dart';

class SHOImagePreviewPage extends ConsumerStatefulWidget {
  const SHOImagePreviewPage({super.key, this.initialIndex = 0});

  final int initialIndex;

  @override
  ConsumerState<SHOImagePreviewPage> createState() => _SHOImagePreviewPageState();
}

class _SHOImagePreviewPageState extends ConsumerState<SHOImagePreviewPage>
    with SHOPageRouteAnalyticsMixin, SHOAppPageMixin, SHOAppTrackedPageMixin {
  late final PageController _pageController;
  bool _immersive = false;

  @override
  String get pageName => 'image_preview';

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: widget.initialIndex);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(imagePreviewProvider.notifier).setIndex(widget.initialIndex);
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(imagePreviewProvider);
    final images = state.images;
    if (images.isEmpty) {
      return buildTrackedPage(
        const Scaffold(body: Center(child: Text('暂无图片'))),
      );
    }

    return buildTrackedPage(
      Scaffold(
      backgroundColor: Colors.black,
      appBar: _immersive
          ? null
          : AppBar(
              title: Text('图片 ${state.currentIndex + 1}/${images.length}'),
              actions: [
                IconButton(
                  icon: const Icon(Icons.download_outlined),
                  onPressed: () => context.showToast('请长按保存或使用分享'),
                ),
              ],
            ),
      body: Stack(
        children: [
          PhotoViewGallery.builder(
            pageController: _pageController,
            itemCount: images.length,
            onPageChanged: (index) {
              ref.read(imagePreviewProvider.notifier).setIndex(index);
            },
            builder: (context, index) {
              final item = images[index];
              return PhotoViewGalleryPageOptions(
                imageProvider: NetworkImage(item.url),
                minScale: PhotoViewComputedScale.contained * 0.5,
                maxScale: PhotoViewComputedScale.covered * 5,
                onTapUp: (_, __, ___) => setState(() => _immersive = !_immersive),
              );
            },
          ),
          if (!_immersive)
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: SafeArea(
                child: Container(
                  color: Colors.black54,
                  padding: const EdgeInsets.all(12),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      TextButton(
                        onPressed: () async {
                          final url = images[state.currentIndex].url;
                          final response = await ref
                              .read(activityApiProvider)
                              .downloadImageBytes(url);
                          if (!context.mounted) return;
                          if (response.isEmpty) {
                            context.showToast('图片下载失败');
                            return;
                          }
                          final result = await ref
                              .read(gallerySaverProvider)
                              .saveImageBytes(
                                Uint8List.fromList(response),
                                name: 'activity',
                              );
                          if (!context.mounted) return;
                          switch (result) {
                            case SHOGallerySaveResult.success:
                              context.showToast('已保存到相册');
                            case SHOGallerySaveResult.permissionDenied:
                              context.showToast('需要相册权限才能保存图片');
                            case SHOGallerySaveResult.pluginUnavailable:
                              context.showToast('保存功能未就绪，请完全退出后重新运行应用');
                            case SHOGallerySaveResult.failed:
                              context.showToast('保存失败，请稍后重试');
                          }
                        },
                        child: const Text('保存图片', style: TextStyle(color: Colors.white)),
                      ),
                      TextButton(
                        onPressed: () => Share.share(images[state.currentIndex].url),
                        child: const Text('分享图片', style: TextStyle(color: Colors.white)),
                      ),
                      TextButton(
                        onPressed: () => context.showToast(images[state.currentIndex].url),
                        child: const Text('查看原图', style: TextStyle(color: Colors.white)),
                      ),
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
    ),
    );
  }
}
