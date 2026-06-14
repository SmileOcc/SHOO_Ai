import 'dart:io';

import 'package:flutter/material.dart';
import 'package:pdfx/pdfx.dart';
import 'package:video_player/video_player.dart';

import '../../../core/theme/hos_spacing.dart';
import '../data/hos_download_paths.dart';
import '../domain/hos_download_task.dart';
import '../domain/hos_txt_novel_parser.dart';

class SHODownloadPreviewPage extends StatefulWidget {
  const SHODownloadPreviewPage({
    super.key,
    required this.fileName,
    required this.localPath,
    required this.kind,
  });

  final String fileName;
  final String localPath;
  final SHODownloadPreviewKind kind;

  static Future<bool> open({
    required BuildContext context,
    required SHODownloadTask task,
  }) async {
    final kind = previewKindForFileName(task.fileName);
    if (kind == null) return false;

    final localPath = await SHODownloadPaths.resolveExistingFilePath(task);
    if (localPath == null) return false;

    if (!context.mounted) return false;
    await Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => SHODownloadPreviewPage(
          fileName: task.fileName,
          localPath: localPath,
          kind: kind,
        ),
      ),
    );
    return true;
  }

  @override
  State<SHODownloadPreviewPage> createState() => _SHODownloadPreviewPageState();
}

class _SHODownloadPreviewPageState extends State<SHODownloadPreviewPage> {
  VideoPlayerController? _videoController;
  PdfControllerPinch? _pdfController;
  var _videoReady = false;
  var _pdfReady = false;
  String? _textContent;
  String? _error;

  @override
  void initState() {
    super.initState();
    _initPreview();
  }

  Future<void> _initPreview() async {
    try {
      switch (widget.kind) {
        case SHODownloadPreviewKind.image:
          return;
        case SHODownloadPreviewKind.text:
          final bytes = await File(widget.localPath).readAsBytes();
          final content = decodeTxtBytes(bytes);
          if (content.trim().isEmpty) {
            throw StateError('empty text');
          }
          if (mounted) setState(() => _textContent = content);
        case SHODownloadPreviewKind.video:
          final controller = VideoPlayerController.file(File(widget.localPath));
          await controller.initialize();
          if (!mounted) {
            await controller.dispose();
            return;
          }
          setState(() {
            _videoController = controller;
            _videoReady = true;
          });
        case SHODownloadPreviewKind.pdf:
          final controller = PdfControllerPinch(
            document: PdfDocument.openFile(widget.localPath),
          );
          if (mounted) {
            setState(() {
              _pdfController = controller;
              _pdfReady = true;
            });
          }
      }
    } catch (error) {
      if (mounted) setState(() => _error = error.toString());
    }
  }

  @override
  void dispose() {
    _videoController?.dispose();
    _pdfController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.fileName,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(fontWeight: FontWeight.w800),
        ),
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_error != null) {
      return Center(child: Text(_error!));
    }

    return switch (widget.kind) {
      SHODownloadPreviewKind.image => InteractiveViewer(
          minScale: 0.5,
          maxScale: 4,
          child: Center(
            child: Image.file(
              File(widget.localPath),
              fit: BoxFit.contain,
            ),
          ),
        ),
      SHODownloadPreviewKind.text => _textContent == null
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(SHOAppSpacing.pagePadding),
              child: SelectableText(_textContent!),
            ),
      SHODownloadPreviewKind.video => !_videoReady || _videoController == null
          ? const Center(child: CircularProgressIndicator())
          : Center(
              child: AspectRatio(
                aspectRatio: _videoController!.value.aspectRatio,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    VideoPlayer(_videoController!),
                    IconButton(
                      iconSize: 56,
                      color: Colors.white70,
                      icon: Icon(
                        _videoController!.value.isPlaying
                            ? Icons.pause_circle_filled
                            : Icons.play_circle_filled,
                      ),
                      onPressed: () {
                        setState(() {
                          if (_videoController!.value.isPlaying) {
                            _videoController!.pause();
                          } else {
                            _videoController!.play();
                          }
                        });
                      },
                    ),
                  ],
                ),
              ),
            ),
      SHODownloadPreviewKind.pdf => !_pdfReady || _pdfController == null
          ? const Center(child: CircularProgressIndicator())
          : PdfViewPinch(controller: _pdfController!),
    };
  }
}
