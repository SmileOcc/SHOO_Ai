import 'dart:io';

import '../domain/hos_txt_novel_models.dart';
import '../domain/hos_txt_novel_parser.dart';
import 'hos_txt_reader_pagination.dart';

class SHOTxtReaderSession {
  SHOTxtReaderSession({
    required this.file,
    required this.chapterMetas,
  });

  final File file;
  final List<SHONovelChapterMeta> chapterMetas;

  final List<SHONovelPage> flatPages = [];
  final Set<int> loadedChapters = {};
  var switchingChapter = false;

  int currentFlatIndex = 0;

  SHONovelPage? get currentPage {
    if (flatPages.isEmpty) return null;
    final idx = currentFlatIndex.clamp(0, flatPages.length - 1);
    return flatPages[idx];
  }

  int get currentChapterIndex => currentPage?.chapterIndex ?? 0;

  double _firstPageBodyHeight(
    String chapterTitle,
    SHOTxtReaderPagination pagination,
  ) {
    final titleHeight = measureTextBlockHeight(
      text: '$chapterTitle\n\n',
      style: pagination.titleStyle,
      maxWidth: pagination.pageWidth,
      textScaler: pagination.textScaler,
    );
    return (pagination.pageHeight - titleHeight)
        .clamp(0, pagination.pageHeight);
  }

  Future<List<SHONovelPage>> loadChapter({
    required int chapterIndex,
    required SHOTxtReaderPagination pagination,
    bool append = false,
    bool prepend = false,
    int? jumpToPageInChapter,
  }) async {
    if (chapterIndex < 0 || chapterIndex >= chapterMetas.length) {
      return const [];
    }

    final existingInFlat = flatPages
        .where((page) => page.chapterIndex == chapterIndex)
        .toList();
    if (existingInFlat.isNotEmpty) {
      return existingInFlat;
    }

    final meta = chapterMetas[chapterIndex];
    final content = await readChapterContent(file, meta);
    if (isChapterContentTooLarge(content)) {
      throw StateError('chapter_too_large');
    }
    final pageTexts = paginateChapterContent(
      content: content.isEmpty ? '' : content,
      width: pagination.pageWidth,
      height: pagination.pageHeight,
      style: pagination.textStyle,
      textScaler: pagination.textScaler,
      firstPageMaxHeight: content.isEmpty
          ? pagination.pageHeight
          : _firstPageBodyHeight(meta.title, pagination),
    );

    final globalStart = prepend
        ? 0
        : append
            ? flatPages.length
            : 0;
    final pages = buildPagesForChapter(
      meta: meta,
      pageTexts: pageTexts,
      globalStartIndex: globalStart,
    );

    if (prepend) {
      flatPages.insertAll(0, pages);
      for (var i = pages.length; i < flatPages.length; i++) {
        final old = flatPages[i];
        flatPages[i] = SHONovelPage(
          globalIndex: i,
          chapterIndex: old.chapterIndex,
          pageIndexInChapter: old.pageIndexInChapter,
          chapterTitle: old.chapterTitle,
          text: old.text,
        );
      }
      currentFlatIndex += pages.length;
    } else if (append) {
      final start = flatPages.length;
      flatPages.addAll(
        pages
            .asMap()
            .entries
            .map(
              (entry) => SHONovelPage(
                globalIndex: start + entry.key,
                chapterIndex: entry.value.chapterIndex,
                pageIndexInChapter: entry.value.pageIndexInChapter,
                chapterTitle: entry.value.chapterTitle,
                text: entry.value.text,
              ),
            )
            .toList(),
      );
    } else {
      flatPages
        ..clear()
        ..addAll(pages);
      loadedChapters.clear();
      final target = (jumpToPageInChapter ?? 0).clamp(0, pages.length - 1);
      currentFlatIndex = target;
    }

    loadedChapters.add(chapterIndex);
    return pages;
  }

  Future<void> openAtChapter({
    required int chapterIndex,
    required int pageIndexInChapter,
    required SHOTxtReaderPagination pagination,
  }) async {
    await loadChapter(
      chapterIndex: chapterIndex,
      pagination: pagination,
      jumpToPageInChapter: pageIndexInChapter,
    );
  }

  Future<int?> tryAppendNextChapter({
    required SHOTxtReaderPagination pagination,
  }) async {
    final chapter = currentChapterIndex;
    if (chapter >= chapterMetas.length - 1) return null;
    if (flatPages.any((page) => page.chapterIndex == chapter + 1)) {
      return null;
    }

    final before = flatPages.length;
    await loadChapter(
      chapterIndex: chapter + 1,
      pagination: pagination,
      append: true,
    );
    return before;
  }

  Future<int?> tryPrependPreviousChapter({
    required SHOTxtReaderPagination pagination,
  }) async {
    final chapter = currentChapterIndex;
    if (chapter <= 0) return null;
    if (flatPages.any((page) => page.chapterIndex == chapter - 1)) {
      return null;
    }

    final added = await loadChapter(
      chapterIndex: chapter - 1,
      pagination: pagination,
      prepend: true,
    );
    return added.length;
  }

  Future<void> jumpToChapter({
    required int chapterIndex,
    required SHOTxtReaderPagination pagination,
    int pageIndexInChapter = 0,
  }) async {
    for (var i = 0; i < flatPages.length; i++) {
      final page = flatPages[i];
      if (page.chapterIndex == chapterIndex &&
          page.pageIndexInChapter == pageIndexInChapter) {
        currentFlatIndex = i;
        return;
      }
    }

    await openAtChapter(
      chapterIndex: chapterIndex,
      pageIndexInChapter: pageIndexInChapter,
      pagination: pagination,
    );
  }

  SHOTxtReaderProgress snapshotProgress({
    required double fontSize,
    required bool darkMode,
    required int textColorArgb,
    required int backgroundColorArgb,
  }) {
    final page = currentPage;
    return SHOTxtReaderProgress(
      chapterIndex: page?.chapterIndex ?? 0,
      pageIndexInChapter: page?.pageIndexInChapter ?? 0,
      fontSize: fontSize,
      darkMode: darkMode,
      textColorArgb: textColorArgb,
      backgroundColorArgb: backgroundColorArgb,
    );
  }

  Future<void> repaginateAllLoaded({
    required SHOTxtReaderPagination pagination,
  }) async {
    final chapter = currentChapterIndex;
    final pageInChapter = currentPage?.pageIndexInChapter ?? 0;
    final loaded = loadedChapters.toList()..sort();
    flatPages.clear();
    loadedChapters.clear();

    for (final index in loaded) {
      await loadChapter(
        chapterIndex: index,
        pagination: pagination,
        append: flatPages.isNotEmpty,
      );
    }

    await jumpToChapter(
      chapterIndex: chapter,
      pagination: pagination,
      pageIndexInChapter: pageInChapter,
    );
  }
}
