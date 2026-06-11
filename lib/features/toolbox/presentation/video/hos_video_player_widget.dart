import 'dart:async';

import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

import '../../../../l10n/app_localizations.dart';
import 'hos_video_danmaku_overlay.dart';

/// 控制条相对底部的额外下移量（像素）。
const kVideoPlayerControlsBottomOffset = 15.0;

enum SHOVideoPlayerMoreAction {
  share,
  download,
}

String formatVideoDuration(Duration duration) {
  final totalSeconds = duration.inSeconds;
  final hours = totalSeconds ~/ 3600;
  final minutes = (totalSeconds % 3600) ~/ 60;
  final seconds = totalSeconds % 60;
  if (hours > 0) {
    return '${hours.toString().padLeft(2, '0')}:'
        '${minutes.toString().padLeft(2, '0')}:'
        '${seconds.toString().padLeft(2, '0')}';
  }
  return '${minutes.toString().padLeft(2, '0')}:'
      '${seconds.toString().padLeft(2, '0')}';
}

class SHOVideoPlayerWidget extends StatefulWidget {
  const SHOVideoPlayerWidget({
    super.key,
    required this.controller,
    required this.title,
    required this.isFullscreen,
    required this.showDanmaku,
    required this.danmakuController,
    required this.onToggleFullscreen,
    required this.onToggleDanmaku,
    this.onBack,
    this.aspectRatio,
    this.embedded = false,
    this.topSafeInset = 0,
    this.showNetworkMoreMenu = false,
    this.onMoreMenuAction,
  });

  final VideoPlayerController controller;
  final String title;
  final bool isFullscreen;
  final bool showDanmaku;
  final SHOVideoDanmakuController danmakuController;
  final VoidCallback onToggleFullscreen;
  final VoidCallback onToggleDanmaku;
  final VoidCallback? onBack;
  final double? aspectRatio;
  final bool embedded;

  /// 视频区域顶部留白（不侵入状态栏安全区）。
  final double topSafeInset;

  /// 网络视频播放时右上角显示更多菜单。
  final bool showNetworkMoreMenu;
  final ValueChanged<SHOVideoPlayerMoreAction>? onMoreMenuAction;

  @override
  State<SHOVideoPlayerWidget> createState() => _SHOVideoPlayerWidgetState();
}

class _SHOVideoPlayerWidgetState extends State<SHOVideoPlayerWidget> {
  var _showControls = true;
  var _isDragging = false;
  var _dragValue = 0.0;
  var _wasPlayingBeforeDrag = false;
  var _showVolumePanel = false;
  var _volume = 1.0;
  Timer? _hideControlsTimer;
  var _seekToken = 0;

  bool get _isControllerReady {
    if (!mounted) return false;
    final value = widget.controller.value;
    return value.isInitialized && value.duration.inMilliseconds > 0;
  }

  @override
  void initState() {
    super.initState();
    widget.controller.addListener(_onTick);
    _volume = widget.controller.value.volume;
    _bumpControlsVisible();
  }

  @override
  void didUpdateWidget(covariant SHOVideoPlayerWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.controller != widget.controller) {
      oldWidget.controller.removeListener(_onTick);
      widget.controller.addListener(_onTick);
      _volume = widget.controller.value.volume;
    }
  }

  @override
  void deactivate() {
    _seekToken++;
    _isDragging = false;
    _hideControlsTimer?.cancel();
    super.deactivate();
  }

  @override
  void dispose() {
    _seekToken++;
    _hideControlsTimer?.cancel();
    widget.controller.removeListener(_onTick);
    super.dispose();
  }

  void _onTick() {
    if (!mounted || _isDragging) return;
    setState(() {});
  }

  void _bumpControlsVisible() {
    _hideControlsTimer?.cancel();
    setState(() => _showControls = true);
    if (widget.controller.value.isPlaying) {
      _hideControlsTimer = Timer(const Duration(seconds: 3), () {
        if (!mounted || _isDragging) return;
        setState(() => _showControls = false);
      });
    }
  }

  Future<void> _togglePlay() async {
    if (!_isControllerReady) return;
    try {
      final playing = widget.controller.value.isPlaying;
      if (playing) {
        await widget.controller.pause();
      } else {
        await widget.controller.play();
      }
    } catch (_) {
      return;
    }
    if (!mounted) return;
    _bumpControlsVisible();
    setState(() {});
  }

  Future<void> _setVolume(double value) async {
    if (!mounted) return;
    _volume = value;
    try {
      await widget.controller.setVolume(value);
    } catch (_) {
      return;
    }
    if (!mounted) return;
    setState(() {});
  }

  void _onSeekDragStart() {
    if (!_isControllerReady) return;
    _seekToken++;
    _wasPlayingBeforeDrag = widget.controller.value.isPlaying;
    if (_wasPlayingBeforeDrag) {
      unawaited(widget.controller.pause().catchError((_) {}));
    }
    setState(() {
      _isDragging = true;
      _dragValue = _sliderValue;
    });
  }

  Future<void> _onSeekDragEnd(double value) async {
    if (!_isDragging) return;
    final token = _seekToken;
    try {
      if (_isControllerReady) {
        await widget.controller
            .seekTo(Duration(milliseconds: value.round()));
      }
      if (!mounted || token != _seekToken || !_isControllerReady) return;
      if (_wasPlayingBeforeDrag) {
        await widget.controller.play();
      }
    } catch (_) {
      // seek/play may fail if the controller was disposed mid-drag.
    }
    if (!mounted || token != _seekToken) return;
    setState(() => _isDragging = false);
    _bumpControlsVisible();
  }

  void _onSurfaceTap() {
    setState(() {
      _showControls = !_showControls;
      _showVolumePanel = false;
    });
    if (_showControls) _bumpControlsVisible();
  }

  double get _sliderMax {
    final ms = widget.controller.value.duration.inMilliseconds;
    return ms > 0 ? ms.toDouble() : 1;
  }

  double get _sliderValue {
    if (_isDragging) return _dragValue;
    return widget.controller.value.position.inMilliseconds
        .clamp(0, _sliderMax.toInt())
        .toDouble();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final initialized = widget.controller.value.isInitialized;
    final ratio = widget.aspectRatio ??
        (initialized ? widget.controller.value.aspectRatio : 16 / 9);
    final topInset = widget.topSafeInset;

    final playerBody = ColoredBox(
      color: Colors.black,
      child: initialized
          ? Center(
              child: AspectRatio(
                aspectRatio: ratio,
                child: VideoPlayer(widget.controller),
              ),
            )
          : const Center(
              child: CircularProgressIndicator(color: Colors.white70),
            ),
    );

    final content = GestureDetector(
      onTap: _onSurfaceTap,
      behavior: HitTestBehavior.opaque,
      child: Stack(
        fit: StackFit.expand,
        clipBehavior: Clip.none,
        children: [
          Positioned(
            top: topInset,
            left: 0,
            right: 0,
            bottom: 0,
            child: playerBody,
          ),
          if (topInset > 0)
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              height: topInset,
              child: const ColoredBox(color: Colors.black),
            ),
          if (widget.isFullscreen)
            Positioned(
              top: topInset,
              left: 0,
              right: 0,
              bottom: 0,
              child: SHOVideoDanmakuOverlay(
                enabled: widget.showDanmaku,
                controller: widget.danmakuController,
              ),
            ),
          if (_showControls) ...[
            Positioned(
              top: topInset,
              left: 0,
              right: 0,
              bottom: 0,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.black.withValues(alpha: 0.55),
                      Colors.transparent,
                      Colors.transparent,
                      Colors.black.withValues(alpha: 0.65),
                    ],
                    stops: const [0, 0.12, 0.78, 1],
                  ),
                ),
              ),
            ),
            if (widget.onBack != null)
              Positioned(
                top: topInset + 2,
                left: 0,
                child: _CompactControlButton(
                  icon: Icons.arrow_back_ios_new,
                  size: 20,
                  onPressed: widget.onBack,
                ),
              ),
            if (widget.showNetworkMoreMenu &&
                widget.onMoreMenuAction != null)
              Positioned(
                top: topInset + 2,
                right: 0,
                child: PopupMenuButton<SHOVideoPlayerMoreAction>(
                  icon: const Icon(Icons.more_vert, color: Colors.white),
                  color: const Color(0xFF1E1E1E),
                  onSelected: widget.onMoreMenuAction,
                  itemBuilder: (context) => [
                    PopupMenuItem(
                      value: SHOVideoPlayerMoreAction.share,
                      child: Text(l10n.videoPlayerShare),
                    ),
                    PopupMenuItem(
                      value: SHOVideoPlayerMoreAction.download,
                      child: Text(l10n.videoPlayerDownload),
                    ),
                  ],
                ),
              ),
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: Transform.translate(
                offset: const Offset(0, kVideoPlayerControlsBottomOffset),
                child: _ControlsBar(
                  l10n: l10n,
                  controller: widget.controller,
                  isFullscreen: widget.isFullscreen,
                  showDanmaku: widget.showDanmaku,
                  isDragging: _isDragging,
                  showVolumePanel: _showVolumePanel,
                  volume: _volume,
                  sliderValue: _sliderValue,
                  sliderMax: _sliderMax,
                  onTogglePlay: _togglePlay,
                  onToggleDanmaku: widget.onToggleDanmaku,
                  onToggleVolumePanel: () {
                    setState(() => _showVolumePanel = !_showVolumePanel);
                    _bumpControlsVisible();
                  },
                  onVolumeChanged: _setVolume,
                  onToggleFullscreen: widget.onToggleFullscreen,
                  onChangeStart: _onSeekDragStart,
                  onChanged: (value) {
                    if (!_isDragging) return;
                    setState(() => _dragValue = value);
                  },
                  onChangeEnd: (value) => unawaited(_onSeekDragEnd(value)),
                ),
              ),
            ),
          ],
        ],
      ),
    );

    if (widget.isFullscreen || widget.embedded) {
      return content;
    }

    return AspectRatio(aspectRatio: 16 / 9, child: content);
  }
}

class _ScalingSliderThumbShape extends SliderComponentShape {
  const _ScalingSliderThumbShape({
    required this.isDragging,
    this.normalRadius = 5,
    this.draggingRadius = 9,
  });

  final bool isDragging;
  final double normalRadius;
  final double draggingRadius;

  @override
  Size getPreferredSize(bool isEnabled, bool isDiscrete) {
    final radius = isDragging ? draggingRadius : normalRadius;
    return Size.fromRadius(radius);
  }

  @override
  void paint(
    PaintingContext context,
    Offset center, {
    required Animation<double> activationAnimation,
    required Animation<double> enableAnimation,
    required bool isDiscrete,
    required TextPainter labelPainter,
    required RenderBox parentBox,
    required SliderThemeData sliderTheme,
    required TextDirection textDirection,
    required double value,
    required double textScaleFactor,
    required Size sizeWithOverflow,
  }) {
    final radius = isDragging ? draggingRadius : normalRadius;
    final color = sliderTheme.thumbColor ?? const Color(0xFFFF4657);
    context.canvas.drawCircle(center, radius, Paint()..color = color);
  }
}

class _CompactControlButton extends StatelessWidget {
  const _CompactControlButton({
    required this.icon,
    required this.onPressed,
    this.tooltip,
    this.size = 24,
  });

  final IconData icon;
  final VoidCallback? onPressed;
  final String? tooltip;
  final double size;

  @override
  Widget build(BuildContext context) {
    return IconButton(
      tooltip: tooltip,
      onPressed: onPressed,
      padding: const EdgeInsets.all(8),
      constraints: const BoxConstraints(minWidth: 36, minHeight: 36),
      icon: Icon(icon, color: Colors.white, size: size),
    );
  }
}

class _ControlsBar extends StatelessWidget {
  const _ControlsBar({
    required this.l10n,
    required this.controller,
    required this.isFullscreen,
    required this.showDanmaku,
    required this.isDragging,
    required this.showVolumePanel,
    required this.volume,
    required this.sliderValue,
    required this.sliderMax,
    required this.onTogglePlay,
    required this.onToggleDanmaku,
    required this.onToggleVolumePanel,
    required this.onVolumeChanged,
    required this.onToggleFullscreen,
    required this.onChangeStart,
    required this.onChanged,
    required this.onChangeEnd,
  });

  final AppLocalizations l10n;
  final VideoPlayerController controller;
  final bool isFullscreen;
  final bool showDanmaku;
  final bool isDragging;
  final bool showVolumePanel;
  final double volume;
  final double sliderValue;
  final double sliderMax;
  final VoidCallback onTogglePlay;
  final VoidCallback onToggleDanmaku;
  final VoidCallback onToggleVolumePanel;
  final ValueChanged<double> onVolumeChanged;
  final VoidCallback onToggleFullscreen;
  final VoidCallback onChangeStart;
  final ValueChanged<double> onChanged;
  final ValueChanged<double> onChangeEnd;

  @override
  Widget build(BuildContext context) {
    final initialized = controller.value.isInitialized;
    final duration = initialized
        ? controller.value.duration
        : Duration.zero;
    final canSeek = initialized && duration.inMilliseconds > 0;
    final position = initialized
        ? controller.value.position
        : Duration.zero;
    final sliderTheme = SliderTheme.of(context).copyWith(
      trackHeight: 2,
      thumbShape: _ScalingSliderThumbShape(isDragging: isDragging),
      overlayShape: SliderComponentShape.noOverlay,
      activeTrackColor: const Color(0xFFFF4657),
      inactiveTrackColor: Colors.white24,
      thumbColor: const Color(0xFFFF4657),
    );

    return SafeArea(
      top: false,
      minimum: EdgeInsets.zero,
      child: Padding(
        padding: EdgeInsets.fromLTRB(
          2,
          0,
          2,
          MediaQuery.paddingOf(context).bottom > 0 ? 2 : 6,
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            _CompactControlButton(
              icon: controller.value.isPlaying ? Icons.pause : Icons.play_arrow,
              size: 28,
              onPressed: initialized ? onTogglePlay : null,
            ),
            Expanded(
              child: Row(
                children: [
                  SizedBox(
                    width: 42,
                    child: Text(
                      formatVideoDuration(position),
                      textAlign: TextAlign.right,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 11,
                        fontFeatures: [FontFeature.tabularFigures()],
                      ),
                    ),
                  ),
                  Expanded(
                    child: SliderTheme(
                      data: sliderTheme,
                      child: Slider(
                        value: sliderValue.clamp(0, sliderMax),
                        max: sliderMax,
                        onChangeStart:
                            canSeek ? (_) => onChangeStart() : null,
                        onChanged: canSeek ? onChanged : null,
                        onChangeEnd: canSeek ? onChangeEnd : null,
                      ),
                    ),
                  ),
                  SizedBox(
                    width: 42,
                    child: Text(
                      formatVideoDuration(duration),
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 11,
                        fontFeatures: [FontFeature.tabularFigures()],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            if (isFullscreen)
              _CompactControlButton(
                tooltip: showDanmaku
                    ? l10n.videoPlayerDanmakuOff
                    : l10n.videoPlayerDanmakuOn,
                icon: showDanmaku ? Icons.subtitles : Icons.subtitles_off_outlined,
                onPressed: onToggleDanmaku,
              ),
            Stack(
              clipBehavior: Clip.none,
              alignment: Alignment.center,
              children: [
                if (showVolumePanel)
                  Positioned(
                    bottom: 40,
                    child: Material(
                      color: Colors.black.withValues(alpha: 0.82),
                      borderRadius: BorderRadius.circular(8),
                      child: SizedBox(
                        height: 108,
                        width: 36,
                        child: RotatedBox(
                          quarterTurns: 3,
                          child: Slider(
                            value: volume,
                            onChanged: onVolumeChanged,
                            activeColor: Colors.white,
                            inactiveColor: Colors.white24,
                          ),
                        ),
                      ),
                    ),
                  ),
                _CompactControlButton(
                  tooltip: l10n.videoPlayerVolume,
                  icon: volume == 0
                      ? Icons.volume_off
                      : volume < 0.5
                          ? Icons.volume_down
                          : Icons.volume_up,
                  onPressed: onToggleVolumePanel,
                ),
              ],
            ),
            _CompactControlButton(
              tooltip: isFullscreen
                  ? l10n.videoPlayerExitFullscreen
                  : l10n.videoPlayerFullscreen,
              icon: isFullscreen ? Icons.fullscreen_exit : Icons.fullscreen,
              onPressed: onToggleFullscreen,
            ),
          ],
        ),
      ),
    );
  }
}
