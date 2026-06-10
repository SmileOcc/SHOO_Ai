import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:share_plus/share_plus.dart';

import '../../../app/router/hos_routes.dart';
import '../../../core/dialogs/hos_confirm_card_dialog.dart';
import '../../../core/theme/hos_colors.dart';
import '../../../core/theme/hos_spacing.dart';
import '../../../l10n/app_localizations.dart';
import '../data/hos_download_paths.dart';
import '../data/hos_txt_reader_progress_storage.dart';
import 'hos_bookshelf_controller.dart';
import '../domain/hos_download_task.dart';
import '../domain/hos_txt_novel_models.dart';
import '../data/hos_txt_chapter_index_cache.dart';
import 'hos_txt_reader_pagination.dart';
import 'hos_txt_reader_session.dart';
import 'hos_txt_reader_theme.dart';

class SHOTxtReaderPage extends ConsumerStatefulWidget {
  const SHOTxtReaderPage({super.key, required this.task});

  final SHODownloadTask task;

  static Future<void> open({
    required BuildContext context,
    required SHODownloadTask task,
  }) {
    return context.push(SHOAppRoutes.toolboxReaderFor(task.id));
  }

  @override
  ConsumerState<SHOTxtReaderPage> createState() => _SHOTxtReaderPageState();
}

class _SHOTxtReaderPageState extends ConsumerState<SHOTxtReaderPage>
    with TickerProviderStateMixin {
  static const _fontSizes = [14.0, 16.0, 18.0, 20.0, 22.0, 24.0, 26.0, 28.0];
  static const _readerPadding = EdgeInsets.fromLTRB(20, 12, 20, 4);
  static const _settingsRadius = 16.0;
  static const _catalogWidthFactor = 0.72;
  static const _catalogScrimMaxOpacity = 0.54;
  static const _chromeBottomSlideHeight = 148.0;
  static const _chromeAnimDuration = Duration(milliseconds: 260);

  final _pageController = PageController();

  late final SHOTxtReaderProgressStorage _progressStorage;
  late final AnimationController _catalogController;
  late final AnimationController _chromeController;

  SHOTxtReaderSession? _session;
  SHOTxtReaderLoadPhase _phase = SHOTxtReaderLoadPhase.indexing;
  double _progress = 0;
  var _fontSize = 18.0;
  var _repaginating = false;
  var _showSettings = false;
  var _catalogVisible = false;
  var _showChrome = false;
  var _restoredFromProgress = false;
  var _hasUserNavigated = false;
  var _settingsChanged = false;
  int? _sliderPreviewChapterIndex;
  var _chapterMaskVisible = false;
  var _chapterMaskOpacity = 1.0;
  var _chapterMaskSpinner = false;
  var _chapterJumping = false;
  Timer? _chapterMaskSpinnerTimer;
  BoxConstraints? _latestContentConstraints;
  String? _lastLayoutSignature;
  var _pendingLayoutRepaginate = false;
  SHOTxtReaderTheme _readerTheme = SHOTxtReaderTheme.sepia();
  File? _file;

  @override
  void initState() {
    super.initState();
    _progressStorage = ref.read(txtReaderProgressStorageProvider);
    _catalogController = AnimationController(
      vsync: this,
      duration: _chromeAnimDuration,
    );
    _chromeController = AnimationController(
      vsync: this,
      duration: _chromeAnimDuration,
    );
    WidgetsBinding.instance.addPostFrameCallback((_) => _bootstrap());
  }

  @override
  void dispose() {
    _saveProgressSync();
    _chapterMaskSpinnerTimer?.cancel();
    _catalogController.dispose();
    _chromeController.dispose();
    _pageController.dispose();
    super.dispose();
  }

  bool _shouldPersistProgress() {
    if (_settingsChanged) return true;
    if (_hasUserNavigated) return true;
    if (_restoredFromProgress) return true;
    final session = _session;
    if (session == null) return false;
    final page = session.currentPage;
    if (page == null) return false;
    return page.chapterIndex > 0 || page.pageIndexInChapter > 0;
  }

  void _markUserNavigated() => _hasUserNavigated = true;

  void _markSettingsChanged() => _settingsChanged = true;

  void _saveProgressSync() {
    final session = _session;
    if (session == null || session.flatPages.isEmpty) return;
    if (!_shouldPersistProgress()) return;
    unawaited(
      _progressStorage.write(
        widget.task.id,
        session.snapshotProgress(
          fontSize: _fontSize,
          darkMode: _readerTheme.isDark,
          textColorArgb: _readerTheme.textColorArgb,
          backgroundColorArgb: _readerTheme.backgroundColorArgb,
        ),
      ),
    );
  }

  TextStyle _textStyle() {
    return TextStyle(
      fontSize: _fontSize,
      height: 1.75,
      color: _readerTheme.text,
      letterSpacing: 0.2,
    );
  }

  TextStyle _titleStyle() {
    return _textStyle().copyWith(
      fontWeight: FontWeight.w800,
      fontSize: _fontSize + 2,
    );
  }

  double get _chromeTopHeight => 52;

  double _contentAreaTop(BuildContext context) =>
      MediaQuery.paddingOf(context).top + _chromeTopHeight;

  double _contentAreaBottom(BuildContext context) =>
      MediaQuery.paddingOf(context).bottom;

  Widget _wrapContentArea(BuildContext context, Widget child) {
    return Positioned(
      top: _contentAreaTop(context),
      left: 0,
      right: 0,
      bottom: _contentAreaBottom(context),
      child: child,
    );
  }

  void _setShowChrome(bool value) {
    if (value) {
      if (_showChrome && _chromeController.status == AnimationStatus.completed) {
        return;
      }
      final opening = !_showChrome;
      if (opening) setState(() => _showChrome = true);
      if (opening) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) _chromeController.forward();
        });
      } else if (_chromeController.status == AnimationStatus.reverse) {
        _chromeController.forward();
      }
      return;
    }

    if (!_showChrome) return;
    _chromeController.reverse().then((_) {
      if (mounted) setState(() => _showChrome = false);
    });
  }

  String _novelDisplayName() {
    final name = widget.task.fileName;
    final lower = name.toLowerCase();
    if (lower.endsWith('.txt')) return name.substring(0, name.length - 4);
    return name;
  }

  String _navBarTitle(SHONovelPage? page) {
    if (page == null || page.pageIndexInChapter == 0) {
      return _novelDisplayName();
    }
    return page.chapterTitle;
  }

  TextStyle _navBarTitleStyle() {
    return TextStyle(
      color: _readerTheme.text,
      fontSize: 13,
    );
  }

  (double width, double height) _contentTextBounds(
    BuildContext context, {
    BoxConstraints? constraints,
  }) {
    final resolved = constraints ?? _latestContentConstraints;
    final widthBase =
        resolved?.maxWidth ?? MediaQuery.sizeOf(context).width;
    final heightBase = resolved?.maxHeight ??
        (MediaQuery.sizeOf(context).height -
            _contentAreaTop(context) -
            _contentAreaBottom(context));
    return (
      widthBase - _readerPadding.horizontal,
      heightBase - _readerPadding.vertical,
    );
  }

  double _paginationHeightBonus(TextStyle style) {
    final fontSize = style.fontSize ?? 16;
    final height = style.height ?? 1.75;
    return fontSize * height * 2;
  }

  SHOTxtReaderPagination _pagination(
    BuildContext context, {
    BoxConstraints? constraints,
  }) {
    final bounds = _contentTextBounds(context, constraints: constraints);
    final textStyle = _textStyle();
    return SHOTxtReaderPagination(
      pageWidth: bounds.$1,
      pageHeight: bounds.$2 + _paginationHeightBonus(textStyle),
      textStyle: textStyle,
      titleStyle: _titleStyle(),
      textScaler: MediaQuery.textScalerOf(context),
    );
  }

  Future<void> _persistProgress() async {
    _saveProgressSync();
  }

  Future<void> _bootstrap() async {
    final path = await SHODownloadPaths.resolveExistingFilePath(widget.task);
    if (path == null) {
      if (!mounted) return;
      setState(() => _phase = SHOTxtReaderLoadPhase.failed);
      return;
    }

    _file = File(path);
    final saved = _progressStorage.read(widget.task.id);
    if (saved != null) {
      if (_fontSizes.contains(saved.fontSize)) _fontSize = saved.fontSize;
      _readerTheme = SHOTxtReaderTheme.fromProgress(
        darkMode: saved.darkMode,
        textColorArgb: saved.textColorArgb,
        backgroundColorArgb: saved.backgroundColorArgb,
      );
    }

    setState(() {
      _phase = SHOTxtReaderLoadPhase.indexing;
      _progress = 0;
    });

    try {
      final metas = await scanChapterMetasWithCache(_file!, (value) {
        if (!mounted) return;
        setState(() {
          _progress = value * 0.85;
          _phase = SHOTxtReaderLoadPhase.indexing;
        });
      });

      if (!mounted) return;
      setState(() {
        _progress = 0.9;
        _phase = SHOTxtReaderLoadPhase.paginating;
      });

      final session = SHOTxtReaderSession(file: _file!, chapterMetas: metas);
      final pagination = _pagination(context);
      final chapterIndex =
          (saved?.chapterIndex ?? 0).clamp(0, metas.length - 1);
      final pageInChapter = saved?.pageIndexInChapter ?? 0;
      final restoreReadingPosition = saved != null &&
          (saved.chapterIndex > 0 || saved.pageIndexInChapter > 0);
      _restoredFromProgress = restoreReadingPosition;

      if (restoreReadingPosition) {
        await _beginChapterTransitionMask();
      }

      await session.openAtChapter(
        chapterIndex: chapterIndex,
        pageIndexInChapter: pageInChapter,
        pagination: pagination,
      );

      if (!mounted) return;
      setState(() {
        _session = session;
        _phase = SHOTxtReaderLoadPhase.ready;
        _progress = 1;
      });

      if (!mounted) return;

      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted || !_pageController.hasClients) return;
        _pageController.jumpToPage(session.currentFlatIndex);
        if (restoreReadingPosition) {
          unawaited(_endChapterTransitionMask());
        }
      });

      unawaited(_prefetchAdjacentChapters());
    } catch (_) {
      if (!mounted) return;
      setState(() => _phase = SHOTxtReaderLoadPhase.failed);
    }
  }

  Future<void> _prefetchAdjacentChapters() async {
    final session = _session;
    if (session == null || !mounted) return;
    final pagination = _pagination(context);
    final anchor = session.currentFlatIndex;

    await session.tryPrependPreviousChapter(pagination: pagination);
    final target = session.currentFlatIndex;

    await session.tryAppendNextChapter(pagination: pagination);

    if (!mounted) return;
    setState(() {});
    _syncPageController(target == anchor ? anchor : target);
  }

  void _syncPageController(int index) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted || !_pageController.hasClients) return;
      final session = _session;
      if (session == null) return;
      final clamped = index.clamp(0, session.flatPages.length - 1);
      session.currentFlatIndex = clamped;
      _pageController.jumpToPage(clamped);
    });
  }

  void _handlePageChanged(int index) {
    final session = _session;
    if (session == null) return;
    _markUserNavigated();
    setState(() => session.currentFlatIndex = index);
    _setShowChrome(false);
    unawaited(_handlePageChangedAsync(index));
  }

  Future<void> _handlePageChangedAsync(int index) async {
    final session = _session;
    if (session == null || !mounted) return;

    final pagination = _pagination(context);
    await _persistProgress();
    if (!mounted) return;

    final page = session.flatPages[index];
    final chapterPages = session.flatPages
        .where((item) => item.chapterIndex == page.chapterIndex)
        .toList();
    final isLastInChapter =
        page.pageIndexInChapter >= chapterPages.length - 1;
    final isFirstInChapter = page.pageIndexInChapter == 0;

    if (isLastInChapter) {
      final added = await session.tryAppendNextChapter(pagination: pagination);
      if (added != null && mounted) setState(() {});
    }

    if (isFirstInChapter && page.chapterIndex > 0) {
      final prepended = await session.tryPrependPreviousChapter(
        pagination: pagination,
      );
      if (prepended != null && prepended > 0 && mounted) {
        setState(() {});
        _syncPageController(session.currentFlatIndex);
      }
    }
  }

  Future<void> _repaginate({double? fontSize}) async {
    final session = _session;
    if (session == null) return;

    if (fontSize != null) _fontSize = fontSize;
    setState(() => _repaginating = true);

    final pagination = _pagination(context);
    await session.repaginateAllLoaded(pagination: pagination);

    if (!mounted) return;
    setState(() => _repaginating = false);
    await _persistProgress();
    if (_pageController.hasClients) {
      _pageController.jumpToPage(session.currentFlatIndex);
    }
  }

  Future<void> _onFontSizeChanged(double size) async {
    _markSettingsChanged();
    await _repaginate(fontSize: size);
  }

  void _stepFontSize(int direction) {
    const minSize = 14.0;
    const maxSize = 28.0;
    const step = 2.0;
    final next = (_fontSize + direction * step).clamp(minSize, maxSize);
    if (next == _fontSize) return;
    unawaited(_onFontSizeChanged(next));
  }

  Future<void> _onThemeChanged(SHOTxtReaderTheme theme) async {
    _markSettingsChanged();
    setState(() => _readerTheme = theme);
    await _repaginate();
  }

  bool _chapterNeedsLoad(SHOTxtReaderSession session, int chapterIndex) {
    return !session.flatPages.any((page) => page.chapterIndex == chapterIndex);
  }

  Future<void> _beginChapterTransitionMask() async {
    _chapterMaskSpinnerTimer?.cancel();
    setState(() {
      _chapterMaskVisible = true;
      _chapterMaskOpacity = 1.0;
      _chapterMaskSpinner = false;
      _chapterJumping = true;
    });
    _chapterMaskSpinnerTimer = Timer(const Duration(milliseconds: 320), () {
      if (!mounted || !_chapterJumping || !_chapterMaskVisible) return;
      setState(() => _chapterMaskSpinner = true);
    });
    await Future<void>.delayed(Duration.zero);
  }

  Future<void> _endChapterTransitionMask() async {
    _chapterJumping = false;
    _chapterMaskSpinnerTimer?.cancel();
    if (!_chapterMaskVisible || !mounted) return;
    setState(() => _chapterMaskOpacity = 0.0);
    await Future<void>.delayed(const Duration(milliseconds: 260));
    if (!mounted) return;
    setState(() {
      _chapterMaskVisible = false;
      _chapterMaskSpinner = false;
      _chapterMaskOpacity = 1.0;
    });
  }

  Future<void> _jumpToChapter(int chapterIndex, {bool closeCatalog = true}) async {
    final session = _session;
    if (session == null) return;

    final needsLoad = _chapterNeedsLoad(session, chapterIndex);
    final pagination = _pagination(context);

    if (needsLoad) {
      await _beginChapterTransitionMask();
    }

    if (closeCatalog) {
      await _closeCatalogAnimated();
    }

    if (!mounted) return;

    await session.jumpToChapter(
      chapterIndex: chapterIndex,
      pagination: pagination,
    );

    if (!mounted) return;
    _markUserNavigated();
    setState(() {});
    if (_pageController.hasClients) {
      _pageController.jumpToPage(session.currentFlatIndex);
    }

    if (needsLoad) {
      await _endChapterTransitionMask();
    }

    await _persistProgress();
    unawaited(_prefetchAdjacentChapters());
  }

  void _openCatalog() {
    setState(() {
      _showSettings = false;
      _catalogVisible = true;
    });
    _setShowChrome(true);
    _catalogController.forward();
  }

  void _closeCatalog() {
    unawaited(_closeCatalogAnimated());
  }

  Future<void> _closeCatalogAnimated() async {
    if (!_catalogVisible) return;
    await _catalogController.reverse();
    if (!mounted) return;
    setState(() => _catalogVisible = false);
  }

  void _openSettings() {
    setState(() {
      _catalogVisible = false;
      _showSettings = true;
    });
    _setShowChrome(true);
    _catalogController.reverse();
  }

  void _closeSettings() => setState(() => _showSettings = false);

  void _goPrevPage() {
    if (!_pageController.hasClients) return;
    final session = _session;
    if (session == null) return;
    if (session.currentFlatIndex <= 0) {
      unawaited(_goPrevPageAcrossChapter());
      return;
    }
    _pageController.previousPage(
      duration: const Duration(milliseconds: 220),
      curve: Curves.easeOut,
    );
  }

  Future<void> _goPrevPageAcrossChapter() async {
    final session = _session;
    if (session == null || !mounted) return;
    if (session.currentChapterIndex <= 0) return;

    final pagination = _pagination(context);
    final prepended = await session.tryPrependPreviousChapter(
      pagination: pagination,
    );
    if (prepended == null || prepended <= 0 || !mounted) return;

    final targetIndex = prepended - 1;
    setState(() {});
    session.currentFlatIndex = targetIndex;
    if (_pageController.hasClients) {
      await _pageController.animateToPage(
        targetIndex,
        duration: const Duration(milliseconds: 220),
        curve: Curves.easeOut,
      );
    }
    _markUserNavigated();
    await _persistProgress();
  }

  void _goNextPage() {
    if (!_pageController.hasClients) return;
    final session = _session;
    if (session == null) return;
    if (session.currentFlatIndex >= session.flatPages.length - 1) {
      unawaited(_goNextPageAcrossChapter());
      return;
    }
    _pageController.nextPage(
      duration: const Duration(milliseconds: 220),
      curve: Curves.easeOut,
    );
  }

  Future<void> _goNextPageAcrossChapter() async {
    final session = _session;
    if (session == null || !mounted) return;
    if (session.currentChapterIndex >= session.chapterMetas.length - 1) {
      return;
    }

    final pagination = _pagination(context);
    if (session.currentFlatIndex >= session.flatPages.length - 1) {
      final firstIndex =
          await session.tryAppendNextChapter(pagination: pagination);
      if (firstIndex != null && mounted) {
        setState(() {});
        session.currentFlatIndex = firstIndex;
        if (_pageController.hasClients) {
          await _pageController.animateToPage(
            firstIndex,
            duration: const Duration(milliseconds: 220),
            curve: Curves.easeOut,
          );
        }
        _markUserNavigated();
        await _persistProgress();
        return;
      }
    }

    await _jumpToChapter(session.currentChapterIndex + 1, closeCatalog: false);
  }

  Future<void> _goPrevChapter() async {
    final session = _session;
    if (session == null) return;
    final idx = session.currentChapterIndex;
    if (idx <= 0) return;
    await _jumpToChapter(idx - 1, closeCatalog: false);
  }

  Future<void> _goNextChapter() async {
    final session = _session;
    if (session == null) return;
    final idx = session.currentChapterIndex;
    if (idx >= session.chapterMetas.length - 1) return;
    await _jumpToChapter(idx + 1, closeCatalog: false);
  }

  void _handleReaderTapUp(TapUpDetails details) {
    if (_showSettings || _catalogVisible) return;

    final width = MediaQuery.sizeOf(context).width;
    final x = details.localPosition.dx;
    final isLeft = x < width * 0.33;
    final isRight = x > width * 0.67;

    if (_showChrome) {
      _setShowChrome(false);
      if (isLeft) {
        _goPrevPage();
      } else if (isRight) {
        _goNextPage();
      }
      return;
    }

    if (isLeft) {
      _goPrevPage();
    } else if (isRight) {
      _goNextPage();
    } else {
      _setShowChrome(true);
    }
  }

  Future<void> _onBookshelfAction(bool inBookshelf) async {
    final l10n = AppLocalizations.of(context);
    if (inBookshelf) {
      final ok = await SHOConfirmCardDialog.show(
        context,
        title: l10n.bookshelfRemoveConfirmTitle,
        message: l10n.bookshelfRemoveConfirmMessage,
        confirmLabel: l10n.txtReaderRemoveBookshelf,
        isDestructive: true,
      );
      if (!ok || !mounted) return;
      await ref.read(bookshelfEntriesProvider.notifier).remove(widget.task.id);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.txtReaderRemovedBookshelf)),
      );
      return;
    }

    await ref.read(bookshelfEntriesProvider.notifier).add(widget.task.id);
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(l10n.txtReaderAddedBookshelf)),
    );
  }

  void _showMoreMenu() {
    final l10n = AppLocalizations.of(context);
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: _readerTheme.background,
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.link),
              title: Text(l10n.downloadActionCopyUrl),
              onTap: () async {
                Navigator.pop(ctx);
                await Clipboard.setData(ClipboardData(text: widget.task.url));
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(l10n.downloadUrlCopied)),
                  );
                }
              },
            ),
            ListTile(
              leading: const Icon(Icons.share_outlined),
              title: Text(l10n.txtReaderShare),
              onTap: () {
                Navigator.pop(ctx);
                Share.share(
                  '${widget.task.fileName}\n${widget.task.url}',
                  subject: widget.task.fileName,
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  void _toggleDarkMode() {
    if (_readerTheme.isDark) {
      _onThemeChanged(
        SHOTxtReaderTheme.sepia(textColor: _readerTheme.text),
      );
    } else {
      _onThemeChanged(
        SHOTxtReaderTheme.dark(textColor: const Color(0xFFB8B8B8)),
      );
    }
  }

  void _onCatalogDragUpdate(DragUpdateDetails details) {
    final drawerWidth = MediaQuery.sizeOf(context).width * _catalogWidthFactor;
    _catalogController.value =
        (_catalogController.value + details.delta.dx / drawerWidth)
            .clamp(0.0, 1.0);
  }

  void _onCatalogDragEnd(DragEndDetails details) {
    final velocity = details.velocity.pixelsPerSecond.dx;
    if (velocity < -240 || _catalogController.value < 0.45) {
      _closeCatalog();
    } else {
      _catalogController.forward();
    }
  }

  double _chapterSliderValue(SHOTxtReaderSession session) {
    if (session.chapterMetas.length <= 1) return 0;
    final index = _sliderPreviewChapterIndex ?? session.currentChapterIndex;
    return index / (session.chapterMetas.length - 1);
  }

  String _bottomChromeChapterTitle(
    SHOTxtReaderSession session,
    SHONovelPage currentPage,
  ) {
    if (_sliderPreviewChapterIndex != null) {
      final idx = _sliderPreviewChapterIndex!.clamp(
        0,
        session.chapterMetas.length - 1,
      );
      return session.chapterMetas[idx].title;
    }
    return currentPage.chapterTitle;
  }

  static const _pageTextHeightBehavior = TextHeightBehavior(
    applyHeightToFirstAscent: true,
    applyHeightToLastDescent: false,
  );

  Widget _buildPageText(SHONovelPage page) {
    if (page.pageIndexInChapter == 0) {
      return RichText(
        textHeightBehavior: _pageTextHeightBehavior,
        text: TextSpan(
          style: _textStyle(),
          children: [
            TextSpan(text: '${page.chapterTitle}\n\n', style: _titleStyle()),
            TextSpan(text: page.text, style: _textStyle()),
          ],
        ),
      );
    }
    return Text(
      page.text,
      style: _textStyle(),
      textHeightBehavior: _pageTextHeightBehavior,
    );
  }

  Widget _buildPersistentNavBar(SHONovelPage? currentPage) {
    return Positioned(
      top: 0,
      left: 0,
      right: 0,
      child: Material(
        color: _readerTheme.background,
        child: SafeArea(
          bottom: false,
          child: SizedBox(
            height: _chromeTopHeight,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: SHOAppSpacing.sm),
              child: Row(
                children: [
                  IconButton(
                    visualDensity: VisualDensity.compact,
                    padding: const EdgeInsets.all(8),
                    constraints: const BoxConstraints(
                      minWidth: 34,
                      minHeight: 34,
                    ),
                    icon: Icon(
                      Icons.arrow_back_ios_new,
                      size: 16,
                      color: _readerTheme.text,
                    ),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                  Expanded(
                    child: Text(
                      _navBarTitle(currentPage),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: _navBarTitleStyle(),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTopChrome(AppLocalizations l10n, bool inBookshelf) {
    if (!_showChrome) return const SizedBox.shrink();

    return Positioned(
      top: 0,
      left: 0,
      right: 0,
      child: AnimatedBuilder(
        animation: _chromeController,
        builder: (context, child) {
          return Transform.translate(
            offset: Offset(
              0,
              -_chromeTopHeight * (1 - _chromeController.value),
            ),
            child: child,
          );
        },
        child: Material(
          color: _readerTheme.background,
          child: SafeArea(
            bottom: false,
            child: SizedBox(
              height: _chromeTopHeight,
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: SHOAppSpacing.sm),
                child: Row(
                  children: [
                    IconButton(
                      icon: Icon(
                        Icons.arrow_back_ios_new,
                        color: _readerTheme.text,
                      ),
                      onPressed: () => context.pop(),
                    ),
                    const Spacer(),
                    TextButton(
                      onPressed: () => _onBookshelfAction(inBookshelf),
                      child: Text(
                        inBookshelf
                            ? l10n.txtReaderRemoveBookshelf
                            : l10n.txtReaderAddBookshelf,
                        style: TextStyle(
                          color: _readerTheme.text,
                          fontSize: 13,
                        ),
                      ),
                    ),
                    IconButton(
                      icon: Icon(Icons.more_horiz, color: _readerTheme.text),
                      onPressed: _showMoreMenu,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBottomChrome(
    AppLocalizations l10n,
    SHOTxtReaderSession session,
    List<SHONovelPage> pages,
    SHONovelPage currentPage,
  ) {
    if (!_showChrome) return const SizedBox.shrink();

    final chapterPageCount = pages
        .where((p) => p.chapterIndex == currentPage.chapterIndex)
        .length;

    return Positioned(
      left: 0,
      right: 0,
      bottom: 0,
      child: AnimatedBuilder(
        animation: _chromeController,
        builder: (context, child) {
          return Transform.translate(
            offset: Offset(
              0,
              _chromeBottomSlideHeight * (1 - _chromeController.value),
            ),
            child: child,
          );
        },
        child: Material(
          color: _readerTheme.background,
          child: SafeArea(
            top: false,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(
                  SHOAppSpacing.lg,
                  SHOAppSpacing.sm,
                  SHOAppSpacing.lg,
                  0,
                ),
                child: Row(
                  children: [
                    GestureDetector(
                      onTap: _goPrevChapter,
                      child: Text(
                        l10n.txtReaderPrevChapter,
                        style: TextStyle(
                          color: _readerTheme.text.withValues(alpha: 0.75),
                          fontSize: 13,
                        ),
                      ),
                    ),
                    Expanded(
                      child: Slider(
                        value: _chapterSliderValue(session),
                        onChanged: session.chapterMetas.length <= 1
                            ? null
                            : (value) {
                                final idx = (value *
                                        (session.chapterMetas.length - 1))
                                    .round();
                                setState(() => _sliderPreviewChapterIndex = idx);
                              },
                        onChangeEnd: session.chapterMetas.length <= 1
                            ? null
                            : (value) {
                                final idx = (value *
                                        (session.chapterMetas.length - 1))
                                    .round();
                                setState(() => _sliderPreviewChapterIndex = null);
                                unawaited(
                                  _jumpToChapter(idx, closeCatalog: false),
                                );
                              },
                      ),
                    ),
                    GestureDetector(
                      onTap: _goNextChapter,
                      child: Text(
                        l10n.txtReaderNextChapter,
                        style: TextStyle(
                          color: _readerTheme.text.withValues(alpha: 0.75),
                          fontSize: 13,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: SHOAppSpacing.xl),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        _bottomChromeChapterTitle(session, currentPage),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: _readerTheme.text.withValues(alpha: 0.55),
                          fontSize: 12,
                        ),
                      ),
                    ),
                    Text(
                      l10n.txtReaderChapterPageProgress(
                        currentPage.pageIndexInChapter + 1,
                        chapterPageCount,
                      ),
                      style: TextStyle(
                        color: _readerTheme.text.withValues(alpha: 0.45),
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              const Divider(height: 1),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: SHOAppSpacing.sm),
                child: Row(
                  children: [
                    _buildToolbarItem(
                      icon: Icons.format_list_bulleted,
                      label: l10n.txtReaderChapters,
                      onTap: _openCatalog,
                    ),
                    _buildToolbarItem(
                      icon: _readerTheme.isDark
                          ? Icons.wb_sunny_outlined
                          : Icons.dark_mode_outlined,
                      label: l10n.txtReaderNight,
                      onTap: _toggleDarkMode,
                    ),
                    _buildToolbarItem(
                      icon: Icons.tune,
                      label: l10n.txtReaderSettingsLabel,
                      onTap: _openSettings,
                      highlighted: _showSettings,
                    ),
                  ],
                ),
              ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildToolbarItem({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    bool highlighted = false,
  }) {
    final color = highlighted
        ? SHOAppColors.accent
        : _readerTheme.text.withValues(alpha: 0.85);
    return Expanded(
      child: InkWell(
        onTap: onTap,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 22, color: color),
            const SizedBox(height: 2),
            Text(label, style: TextStyle(fontSize: 11, color: color)),
          ],
        ),
      ),
    );
  }

  Widget _buildChapterTransitionMask() {
    return Positioned.fill(
      child: IgnorePointer(
        child: AnimatedOpacity(
          opacity: _chapterMaskOpacity,
          duration: const Duration(milliseconds: 260),
          curve: Curves.easeOut,
          child: ColoredBox(
            color: _readerTheme.background,
            child: _chapterMaskSpinner
                ? Center(
                    child: SizedBox(
                      width: 22,
                      height: 22,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: _readerTheme.text.withValues(alpha: 0.35),
                      ),
                    ),
                  )
                : null,
          ),
        ),
      ),
    );
  }

  Widget _buildCatalogOverlay(AppLocalizations l10n) {
    final session = _session;
    if (!_catalogVisible || session == null) return const SizedBox.shrink();

    final screen = MediaQuery.sizeOf(context);
    final drawerWidth = screen.width * _catalogWidthFactor;

    final drawer = GestureDetector(
      onHorizontalDragUpdate: _onCatalogDragUpdate,
      onHorizontalDragEnd: _onCatalogDragEnd,
      child: SizedBox(
        width: drawerWidth,
        height: screen.height,
        child: Material(
          color: _readerTheme.background,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              SizedBox(height: MediaQuery.paddingOf(context).top),
              Padding(
                padding: const EdgeInsets.all(SHOAppSpacing.xl),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.task.fileName,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontWeight: FontWeight.w800,
                        fontSize: 16,
                        color: _readerTheme.text,
                      ),
                    ),
                    const SizedBox(height: SHOAppSpacing.xs),
                    Text(
                      l10n.txtReaderChapters,
                      style: TextStyle(
                        color: _readerTheme.text.withValues(alpha: 0.55),
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: ListView.separated(
                  itemCount: session.chapterMetas.length,
                  separatorBuilder: (_, __) => Divider(
                    height: 1,
                    color: _readerTheme.text.withValues(alpha: 0.1),
                  ),
                  itemBuilder: (context, index) {
                    final chapter = session.chapterMetas[index];
                    final selected = session.currentChapterIndex == index;
                    return ListTile(
                      dense: true,
                      title: Text(
                        chapter.title,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontWeight:
                              selected ? FontWeight.w700 : FontWeight.w500,
                          color: selected
                              ? SHOAppColors.accent
                              : _readerTheme.text.withValues(alpha: 0.8),
                        ),
                      ),
                      onTap: () => _jumpToChapter(index),
                    );
                  },
                ),
              ),
              SizedBox(height: MediaQuery.paddingOf(context).bottom),
            ],
          ),
        ),
      ),
    );

    return Positioned.fill(
      child: Material(
        type: MaterialType.transparency,
        child: AnimatedBuilder(
          animation: _catalogController,
          builder: (context, _) {
            final progress = _catalogController.value;
            final scrimOpacity = _catalogScrimMaxOpacity * progress;
            return Stack(
              children: [
                Positioned.fill(
                  child: IgnorePointer(
                    ignoring: progress <= 0,
                    child: GestureDetector(
                      onTap: _closeCatalog,
                      behavior: HitTestBehavior.opaque,
                      child: ColoredBox(
                        color: Colors.black.withValues(alpha: scrimOpacity),
                      ),
                    ),
                  ),
                ),
                Transform.translate(
                  offset: Offset(-drawerWidth * (1 - progress), 0),
                  child: drawer,
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildSettingsOverlay(AppLocalizations l10n) {
    if (!_showSettings) return const SizedBox.shrink();

    return Positioned.fill(
      child: Material(
        type: MaterialType.transparency,
        child: Stack(
          children: [
            Positioned.fill(
              child: GestureDetector(
                onTap: _closeSettings,
                child: Container(color: Colors.black45),
              ),
            ),
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  color: _readerTheme.background,
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(_settingsRadius),
                  ),
                  boxShadow: const [
                    BoxShadow(
                      color: Color(0x33000000),
                      blurRadius: 18,
                      offset: Offset(0, -6),
                    ),
                    BoxShadow(
                      color: Color(0x1A000000),
                      blurRadius: 6,
                      offset: Offset(0, -2),
                    ),
                  ],
                ),
                child: SafeArea(
                  top: false,
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(
                      SHOAppSpacing.xl,
                      SHOAppSpacing.lg,
                      SHOAppSpacing.xl,
                      SHOAppSpacing.xl,
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Text(
                          l10n.txtReaderFontSize,
                          style: TextStyle(
                            fontWeight: FontWeight.w800,
                            color: _readerTheme.text,
                          ),
                        ),
                        const SizedBox(height: SHOAppSpacing.md),
                        Row(
                          children: [
                            _fontSizeButton('A-', () => _stepFontSize(-1)),
                            Expanded(
                              child: Center(
                                child: Text(
                                  '${_fontSize.toInt()}',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w700,
                                    color: _readerTheme.text,
                                  ),
                                ),
                              ),
                            ),
                            _fontSizeButton('A+', () => _stepFontSize(1)),
                          ],
                        ),
                        const SizedBox(height: SHOAppSpacing.lg),
                        Text(
                          l10n.txtReaderBackground,
                          style: TextStyle(
                            fontWeight: FontWeight.w800,
                            color: _readerTheme.text,
                          ),
                        ),
                        const SizedBox(height: SHOAppSpacing.sm),
                        Row(
                          children: [
                            for (final bg in SHOTxtReaderTheme.backgroundPresets)
                              Padding(
                                padding: const EdgeInsets.only(
                                  right: SHOAppSpacing.md,
                                ),
                                child: GestureDetector(
                                  onTap: () {
                                    final isDark =
                                        bg == SHOTxtReaderTheme.darkBackground;
                                    _onThemeChanged(
                                      isDark
                                          ? SHOTxtReaderTheme.dark(
                                              textColor: _readerTheme.text,
                                            )
                                          : SHOTxtReaderTheme.light(
                                              background: bg,
                                              textColor: _readerTheme.text,
                                            ),
                                    );
                                  },
                                  child: Container(
                                    width: 32,
                                    height: 32,
                                    decoration: BoxDecoration(
                                      color: bg,
                                      shape: BoxShape.circle,
                                      border: Border.all(
                                        color: _readerTheme.background == bg
                                            ? SHOAppColors.accent
                                            : _readerTheme.text
                                                .withValues(alpha: 0.2),
                                        width: 2,
                                      ),
                                    ),
                                    child: bg ==
                                            SHOTxtReaderTheme.darkBackground
                                        ? Icon(
                                            Icons.dark_mode,
                                            size: 16,
                                            color: Colors.white
                                                .withValues(alpha: 0.8),
                                          )
                                        : null,
                                  ),
                                ),
                              ),
                          ],
                        ),
                        const SizedBox(height: SHOAppSpacing.lg),
                        Text(
                          l10n.txtReaderFontColor,
                          style: TextStyle(
                            fontWeight: FontWeight.w800,
                            color: _readerTheme.text,
                          ),
                        ),
                        const SizedBox(height: SHOAppSpacing.sm),
                        Row(
                          children: [
                            for (final color in SHOTxtReaderTheme.textPresets)
                              Padding(
                                padding: const EdgeInsets.only(
                                  right: SHOAppSpacing.md,
                                ),
                                child: GestureDetector(
                                  onTap: () => _onThemeChanged(
                                    _readerTheme.copyWith(text: color),
                                  ),
                                  child: Container(
                                    width: 28,
                                    height: 28,
                                    decoration: BoxDecoration(
                                      color: color,
                                      shape: BoxShape.circle,
                                      border: Border.all(
                                        color: _readerTheme.text == color
                                            ? SHOAppColors.accent
                                            : Colors.transparent,
                                        width: 2,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _fontSizeButton(String label, VoidCallback onTap) {
    return OutlinedButton(
      onPressed: _repaginating ? null : onTap,
      style: OutlinedButton.styleFrom(
        foregroundColor: _readerTheme.text,
        side: BorderSide(color: _readerTheme.text.withValues(alpha: 0.25)),
        minimumSize: const Size(56, 40),
      ),
      child: Text(label, style: const TextStyle(fontWeight: FontWeight.w700)),
    );
  }

  void _scheduleLayoutRepaginate(BoxConstraints constraints) {
    final signature =
        '${constraints.maxWidth.toStringAsFixed(1)}x${constraints.maxHeight.toStringAsFixed(1)}';
    if (_lastLayoutSignature == signature || _pendingLayoutRepaginate) return;
    _lastLayoutSignature = signature;
    _pendingLayoutRepaginate = true;
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      _pendingLayoutRepaginate = false;
      if (!mounted || _phase != SHOTxtReaderLoadPhase.ready) return;
      await _repaginate();
    });
  }

  Widget _buildReaderBody(List<SHONovelPage> pages) {
    return LayoutBuilder(
      builder: (context, constraints) {
        _latestContentConstraints = constraints;
        _scheduleLayoutRepaginate(constraints);
        return Stack(
          fit: StackFit.expand,
          children: [
            PageView.builder(
              controller: _pageController,
              scrollDirection: Axis.horizontal,
              pageSnapping: true,
              allowImplicitScrolling: true,
              itemCount: pages.length,
              onPageChanged: _handlePageChanged,
              itemBuilder: (context, index) {
                return Padding(
                  padding: _readerPadding,
                  child: _buildPageText(pages[index]),
                );
              },
            ),
            Positioned.fill(
              child: GestureDetector(
                onTapUp: _handleReaderTapUp,
                behavior: HitTestBehavior.translucent,
              ),
            ),
            if (_repaginating)
              ColoredBox(
                color: _readerTheme.background.withValues(alpha: 0.7),
                child: const Center(child: CircularProgressIndicator()),
              ),
          ],
        );
      },
    );
  }

  String _phaseLabel(AppLocalizations l10n) {
    return switch (_phase) {
      SHOTxtReaderLoadPhase.indexing => l10n.txtReaderParsingChapters,
      SHOTxtReaderLoadPhase.paginating => l10n.txtReaderPaginating,
      SHOTxtReaderLoadPhase.failed => l10n.txtReaderLoadFailed,
      SHOTxtReaderLoadPhase.ready => '',
    };
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final ready = _phase == SHOTxtReaderLoadPhase.ready && _session != null;
    final session = _session;
    final pages = session?.flatPages ?? const <SHONovelPage>[];
    final currentPage = session?.currentPage;
    final inBookshelf = ref
        .watch(bookshelfEntriesProvider)
        .any((entry) => entry.taskId == widget.task.id);

    return PopScope(
      onPopInvokedWithResult: (_, __) => _saveProgressSync(),
      child: ColoredBox(
        color: _readerTheme.background,
        child: Stack(
          fit: StackFit.expand,
          children: [
            Scaffold(
              backgroundColor: _readerTheme.background,
              body: Stack(
                fit: StackFit.expand,
                children: [
                  if (ready)
                    _wrapContentArea(context, _buildReaderBody(pages))
                  else
                    _wrapContentArea(context, _buildLoadingBody(l10n)),
                ],
              ),
            ),
            _buildPersistentNavBar(currentPage),
            if (ready && currentPage != null && session != null) ...[
              _buildTopChrome(l10n, inBookshelf),
              _buildBottomChrome(l10n, session, pages, currentPage),
            ],
            if (_chapterMaskVisible) _buildChapterTransitionMask(),
            _buildCatalogOverlay(l10n),
            _buildSettingsOverlay(l10n),
          ],
        ),
      ),
    );
  }

  Widget _buildLoadingBody(AppLocalizations l10n) {
    if (_phase == SHOTxtReaderLoadPhase.failed) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(SHOAppSpacing.xxxl),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                l10n.txtReaderLoadFailed,
                textAlign: TextAlign.center,
                style: TextStyle(color: _readerTheme.text),
              ),
              const SizedBox(height: SHOAppSpacing.xl),
              FilledButton(
                onPressed: () {
                  setState(() {
                    _phase = SHOTxtReaderLoadPhase.indexing;
                    _progress = 0;
                    _session = null;
                    _lastLayoutSignature = null;
                  });
                  unawaited(_bootstrap());
                },
                child: Text(l10n.txtReaderRetry),
              ),
            ],
          ),
        ),
      );
    }

    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 40),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              width: 220,
              child: LinearProgressIndicator(
                value: _progress > 0 ? _progress : null,
                minHeight: 4,
                backgroundColor: _readerTheme.isDark
                    ? const Color(0xFF333333)
                    : SHOAppColors.surfaceMuted,
                color: SHOAppColors.accent,
              ),
            ),
            const SizedBox(height: SHOAppSpacing.xl),
            Text(
              _phaseLabel(l10n),
              style: TextStyle(
                color: _readerTheme.text.withValues(alpha: 0.7),
              ),
            ),
            const SizedBox(height: SHOAppSpacing.sm),
            Text(
              '${(_progress * 100).clamp(0, 100).toInt()}%',
              style: TextStyle(
                color: _readerTheme.text.withValues(alpha: 0.5),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
