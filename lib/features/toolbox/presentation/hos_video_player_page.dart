import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:video_player/video_player.dart';

import '../../../app/router/hos_routes.dart';
import '../../../core/dialogs/hos_confirm_card_dialog.dart';
import '../../../core/feedback/hos_toast.dart';
import '../../../core/share/hos_share_panel.dart';
import '../../../core/theme/hos_colors.dart';
import '../../../core/theme/hos_spacing.dart';
import '../../../core/theme/hos_theme_extension.dart';
import '../../../core/utils/hos_screen_orientation.dart';
import '../../../l10n/app_localizations.dart';
import '../data/hos_video_playback_storage.dart' show SHOVideoPlaybackStorage, videoPlaybackStorageProvider;
import '../domain/hos_download_task.dart';
import '../domain/hos_video_library_entry.dart';
import '../domain/hos_video_playback_progress.dart';
import '../domain/hos_video_url_utils.dart';
import '../domain/hos_video_comment.dart';
import 'hos_download_controller.dart';
import 'video/hos_video_comment_controller.dart';
import 'video/hos_video_danmaku_overlay.dart';
import 'video/hos_video_library_controller.dart';
import 'video/hos_video_player_widget.dart';

class SHOVideoPlayerPage extends ConsumerStatefulWidget {
  const SHOVideoPlayerPage({
    super.key,
    required this.entry,
    this.filePath,
  });

  final SHOVideoLibraryEntry entry;
  final String? filePath;

  static Future<void> open({
    required BuildContext context,
    required SHOVideoLibraryEntry entry,
  }) {
    return context.push(
      SHOAppRoutes.toolboxVideoForEntry(
        entry.id,
        taskId: entry.taskId,
      ),
    );
  }

  static Future<void> openWithTask({
    required BuildContext context,
    required String taskId,
  }) {
    return context.push(SHOAppRoutes.toolboxVideoFor(taskId));
  }

  static Widget loadingShell({required String title}) {
    return const Scaffold(
      backgroundColor: Colors.black,
      body: Column(
        children: [
          AspectRatio(
            aspectRatio: 16 / 9,
            child: ColoredBox(
              color: Colors.black,
              child: Center(
                child: CircularProgressIndicator(color: Colors.white70),
              ),
            ),
          ),
          Expanded(child: SizedBox.shrink()),
        ],
      ),
    );
  }

  @override
  ConsumerState<SHOVideoPlayerPage> createState() => _SHOVideoPlayerPageState();
}

class _SHOVideoPlayerPageState extends ConsumerState<SHOVideoPlayerPage> {
  VideoPlayerController? _controller;
  final _danmakuController = SHOVideoDanmakuController();
  final _commentController = TextEditingController();
  final _commentScrollController = ScrollController();
  var _showDanmaku = true;
  String? _error;
  Orientation? _lastOrientation;
  var _danmakuBurstScheduled = false;
  Timer? _progressSaveTimer;
  var _resumeApplied = false;
  late final SHOVideoPlaybackStorage _playbackStorage;

  String get _entryId => widget.entry.id;

  @override
  void initState() {
    super.initState();
    _playbackStorage = ref.read(videoPlaybackStorageProvider);
    _initPlayer();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      unawaited(SHOScreenOrientation.enableDeviceRotation());
    });
  }

  Future<void> _initPlayer() async {
    try {
      final VideoPlayerController controller;
      final localPath = widget.filePath;
      if (localPath != null && localPath.isNotEmpty) {
        controller = VideoPlayerController.file(File(localPath));
      } else if (widget.entry.isNetwork) {
        final url = widget.entry.url;
        if (url == null || url.isEmpty) {
          throw StateError('Missing network video URL');
        }
        controller = VideoPlayerController.networkUrl(Uri.parse(url));
      } else {
        throw StateError('Missing local video file path');
      }

      await controller.initialize();
      if (!mounted) {
        await controller.dispose();
        return;
      }

      await _applyResumePosition(controller);
      setState(() => _controller = controller);
      _startProgressSaveTimer();
    } catch (error) {
      if (!mounted) return;
      setState(() => _error = error.toString());
    }
  }

  Future<void> _applyResumePosition(VideoPlayerController controller) async {
    if (_resumeApplied) return;
    _resumeApplied = true;

    final saved = ref.read(videoPlaybackStorageProvider).read(_entryId);
    if (saved == null || saved.positionMs <= 0) return;

    final durationMs = controller.value.duration.inMilliseconds;
    var targetMs = saved.positionMs;
    if (durationMs > 0 && targetMs >= durationMs - 1500) {
      targetMs = 0;
    }
    try {
      await controller.seekTo(Duration(milliseconds: targetMs));
    } catch (_) {
      // Ignore if seek races with dispose or the source is not ready.
    }
  }

  void _startProgressSaveTimer() {
    _progressSaveTimer?.cancel();
    _progressSaveTimer = Timer.periodic(const Duration(seconds: 3), (_) {
      if (!mounted) return;
      unawaited(_saveProgress());
    });
  }

  Future<void> _flushProgress({bool bumpRevision = true}) async {
    final controller = _controller;
    if (controller == null || !controller.value.isInitialized) return;

    final durationMs = controller.value.duration.inMilliseconds;
    final progress = SHOVideoPlaybackProgress(
      entryId: _entryId,
      positionMs: controller.value.position.inMilliseconds,
      durationMs: durationMs > 0 ? durationMs : null,
      updatedAt: DateTime.now(),
    );
    await _playbackStorage.write(progress);
    if (bumpRevision && mounted) {
      ref.read(videoPlaybackRevisionProvider.notifier).state++;
    }
  }

  Future<void> _saveProgress() async {
    if (!mounted) return;
    await _flushProgress();
  }

  Future<void> _handleShare() async {
    final url = widget.entry.url;
    if (url == null || url.isEmpty) return;
    await SHOSharePanel.show(
      context,
      ref,
      title: widget.entry.displayName,
      link: url,
    );
  }

  Future<void> _handleDownload() async {
    final l10n = AppLocalizations.of(context);
    final url = widget.entry.url;
    if (url == null || url.isEmpty) return;

    if (!isDirectVideoDownloadUrl(url)) {
      await SHOConfirmCardDialog.show(
        context,
        title: l10n.videoPlayerDownloadUnsupported,
        confirmLabel: l10n.downloadPreviewOk,
      );
      return;
    }

    final trimmedUrl = url.trim();
    await ref.read(downloadTasksProvider.notifier).addTask(
          url: trimmedUrl,
          fileName: widget.entry.displayName,
        );

    final tasks = ref.read(downloadTasksProvider);
    SHODownloadTask? task;
    for (final item in tasks) {
      if (normalizeVideoUrl(item.url) == normalizeVideoUrl(trimmedUrl)) {
        task = item;
        break;
      }
    }
    if (task != null) {
      await ref.read(videoLibraryEntriesProvider.notifier).linkDownloadTask(
            entryId: _entryId,
            taskId: task.id,
          );
    }

    if (!mounted) return;
    SHOAppToast.success(l10n.videoPlayerDownloadStarted);
  }

  @override
  void dispose() {
    _progressSaveTimer?.cancel();
    unawaited(_flushProgress(bumpRevision: false));
    _commentController.dispose();
    _commentScrollController.dispose();
    _controller?.dispose();
    unawaited(SHOScreenOrientation.restoreOnLeave());
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final orientation = MediaQuery.orientationOf(context);
    if (_lastOrientation == orientation) return;

    final wasLandscape = _lastOrientation == Orientation.landscape;
    _lastOrientation = orientation;

    if (orientation == Orientation.landscape) {
      unawaited(SHOScreenOrientation.setImmersive(true));
      _scheduleDanmakuBurst();
      return;
    }

    unawaited(SHOScreenOrientation.setImmersive(false));
    if (wasLandscape &&
        SHOScreenOrientation.allowsDeviceRotation &&
        !SHOScreenOrientation.isLockedToLandscape) {
      return;
    }
  }

  void _scheduleDanmakuBurst() {
    if (_danmakuBurstScheduled || !_showDanmaku) return;
    _danmakuBurstScheduled = true;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _danmakuBurstScheduled = false;
      if (!mounted) return;
      if (MediaQuery.orientationOf(context) != Orientation.landscape) return;
      _replayDanmakuBurst();
    });
  }

  bool _isLandscapeLayout(BuildContext context) {
    return MediaQuery.orientationOf(context) == Orientation.landscape;
  }

  Future<void> _waitForPortraitLayout() async {
    for (var i = 0; i < 40; i++) {
      await Future<void>.delayed(const Duration(milliseconds: 50));
      if (!mounted) return;
      if (MediaQuery.orientationOf(context) == Orientation.portrait) return;
    }
  }

  Future<void> _exitLandscapeMode() async {
    await SHOScreenOrientation.exitLandscapePlayback();
    await _waitForPortraitLayout();
    if (!mounted) return;
    await SHOScreenOrientation.enableDeviceRotation();
  }

  Future<void> _toggleFullscreen() async {
    final landscape = _isLandscapeLayout(context);
    if (landscape) {
      await _exitLandscapeMode();
      return;
    }

    await SHOScreenOrientation.enterLandscapePlayback();
    _scheduleDanmakuBurst();
  }

  void _replayDanmakuBurst() {
    if (!_showDanmaku) return;
    final comments = ref.read(videoCommentsProvider(_entryId));
    final recent = comments.length <= 12
        ? comments
        : comments.sublist(comments.length - 12);
    for (var i = 0; i < recent.length; i++) {
      final text = recent[i].content;
      Future<void>.delayed(Duration(milliseconds: i * 420), () {
        if (!mounted || !_isLandscapeLayout(context)) return;
        if (!_showDanmaku) return;
        _danmakuController.spawn(text);
      });
    }
  }

  Future<void> _submitComment() async {
    final l10n = AppLocalizations.of(context);
    final comment = await ref
        .read(videoCommentsProvider(_entryId).notifier)
        .add(_commentController.text, authorName: l10n.videoPlayerCommentAuthorMe);
    if (comment == null || !mounted) return;

    _commentController.clear();
    FocusManager.instance.primaryFocus?.unfocus();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_commentScrollController.hasClients) return;
      _commentScrollController.animateTo(
        _commentScrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 240),
        curve: Curves.easeOut,
      );
    });

    if (_isLandscapeLayout(context) && _showDanmaku) {
      _danmakuController.spawn(comment.content);
    }
  }

  Future<void> _handlePop() async {
    await _saveProgress();
    if (!mounted) return;
    if (_isLandscapeLayout(context)) {
      await _exitLandscapeMode();
      return;
    }
    await SHOScreenOrientation.restoreOnLeave();
    if (mounted) context.pop();
  }

  Widget _buildPlayer({
    required BuildContext context,
    required VideoPlayerController controller,
    required bool landscapeShell,
  }) {
    final topInset = MediaQuery.paddingOf(context).top;

    return SHOVideoPlayerWidget(
      controller: controller,
      title: widget.entry.displayName,
      isFullscreen: landscapeShell,
      showDanmaku: _showDanmaku,
      danmakuController: _danmakuController,
      embedded: !landscapeShell,
      topSafeInset: topInset,
      showNetworkMoreMenu:
          widget.entry.isNetwork && (widget.filePath == null || widget.filePath!.isEmpty),
      onMoreMenuAction: widget.entry.isNetwork
          ? (action) {
              switch (action) {
                case SHOVideoPlayerMoreAction.share:
                  unawaited(_handleShare());
                case SHOVideoPlayerMoreAction.download:
                  unawaited(_handleDownload());
              }
            }
          : null,
      onToggleFullscreen: () => unawaited(_toggleFullscreen()),
      onToggleDanmaku: () {
        setState(() => _showDanmaku = !_showDanmaku);
        if (_showDanmaku && _isLandscapeLayout(context)) {
          _replayDanmakuBurst();
        }
      },
      onBack: () => unawaited(_handlePop()),
    );
  }

  Widget _buildPortraitPlayerSlot(BuildContext context, Widget player) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        final topInset = MediaQuery.paddingOf(context).top;
        return SizedBox(
          width: width,
          height: topInset + width * 9 / 16,
          child: player,
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final comments = ref.watch(videoCommentsProvider(_entryId));
    final controller = _controller;

    return OrientationBuilder(
      builder: (context, orientation) {
        final landscapeShell = orientation == Orientation.landscape;

        if (_error != null) {
          return Scaffold(
            appBar: AppBar(),
            body: Center(child: Text(_error!)),
          );
        }

        final playerWidget = controller == null
            ? ColoredBox(
                color: Colors.black,
                child: Center(
                  child: Padding(
                    padding: EdgeInsets.only(
                      top: MediaQuery.paddingOf(context).top,
                    ),
                    child: const CircularProgressIndicator(
                      color: Colors.white70,
                    ),
                  ),
                ),
              )
            : _buildPlayer(
                context: context,
                controller: controller,
                landscapeShell: landscapeShell,
              );

        if (landscapeShell) {
          return PopScope(
            canPop: false,
            onPopInvokedWithResult: (didPop, _) {
              if (!didPop) unawaited(_handlePop());
            },
            child: Scaffold(
              backgroundColor: Colors.black,
              body: playerWidget,
            ),
          );
        }

        return PopScope(
          onPopInvokedWithResult: (didPop, _) {
            if (didPop) {
              unawaited(_flushProgress(bumpRevision: false));
              unawaited(SHOScreenOrientation.restoreOnLeave());
            }
          },
          child: Scaffold(
            backgroundColor: Theme.of(context).scaffoldBackgroundColor,
            body: Column(
              children: [
                _buildPortraitPlayerSlot(context, playerWidget),
                Padding(
                  padding: const EdgeInsets.fromLTRB(
                    SHOAppSpacing.pagePadding,
                    SHOAppSpacing.md,
                    SHOAppSpacing.pagePadding,
                    SHOAppSpacing.sm,
                  ),
                  child: Row(
                    children: [
                      Text(
                        l10n.videoPlayerComments(comments.length),
                        style: Theme.of(context).textTheme.titleSmall?.copyWith(
                              fontWeight: FontWeight.w800,
                            ),
                      ),
                    ],
                  ),
                ),
                const Divider(height: 1),
                Expanded(
                  child: comments.isEmpty
                      ? Center(
                          child: Text(
                            l10n.videoPlayerCommentEmpty,
                            style: TextStyle(
                              color: context.shoTheme.textSecondary,
                            ),
                          ),
                        )
                      : ListView.separated(
                          controller: _commentScrollController,
                          padding:
                              const EdgeInsets.all(SHOAppSpacing.pagePadding),
                          itemCount: comments.length,
                          separatorBuilder: (_, __) =>
                              const SizedBox(height: SHOAppSpacing.md),
                          itemBuilder: (context, index) {
                            return _CommentTile(comment: comments[index]);
                          },
                        ),
                ),
                SafeArea(
                  top: false,
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(
                      SHOAppSpacing.pagePadding,
                      SHOAppSpacing.sm,
                      SHOAppSpacing.pagePadding,
                      SHOAppSpacing.md,
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: _commentController,
                            textInputAction: TextInputAction.send,
                            onSubmitted: (_) => _submitComment(),
                            decoration: InputDecoration(
                              hintText: l10n.videoPlayerCommentHint,
                              isDense: true,
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: SHOAppSpacing.lg,
                                vertical: SHOAppSpacing.md,
                              ),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(24),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: SHOAppSpacing.sm),
                        FilledButton(
                          onPressed: _submitComment,
                          style: FilledButton.styleFrom(
                            backgroundColor: SHOAppColors.accent,
                            padding: const EdgeInsets.symmetric(
                              horizontal: SHOAppSpacing.lg,
                              vertical: SHOAppSpacing.md,
                            ),
                          ),
                          child: Text(l10n.videoPlayerSendComment),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _CommentTile extends StatelessWidget {
  const _CommentTile({required this.comment});

  final SHOVideoComment comment;

  @override
  Widget build(BuildContext context) {
    final timeLabel =
        '${comment.createdAt.hour.toString().padLeft(2, '0')}:'
        '${comment.createdAt.minute.toString().padLeft(2, '0')}';

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CircleAvatar(
          radius: 18,
          backgroundColor: SHOAppColors.accent.withValues(alpha: 0.15),
          child: Text(
            comment.authorName.isNotEmpty ? comment.authorName[0] : '?',
            style: const TextStyle(
              color: SHOAppColors.accent,
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
        const SizedBox(width: SHOAppSpacing.md),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(
                    comment.authorName,
                    style: const TextStyle(fontWeight: FontWeight.w700),
                  ),
                  const SizedBox(width: SHOAppSpacing.sm),
                  Text(
                    timeLabel,
                    style: TextStyle(
                      fontSize: 11,
                      color: context.shoTheme.textSecondary,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Text(comment.content),
            ],
          ),
        ),
      ],
    );
  }
}
