import 'dart:io';

import 'package:flutter/material.dart';

import '../domain/hos_txt_novel_models.dart';
import '../domain/hos_txt_novel_parser.dart';

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

  Future<List<SHONovelPage>> loadChapter({
    required int chapterIndex,
    required TextStyle textStyle,
    required double pageWidth,
    required double pageHeight,
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
    final contentWithTitle = content.isEmpty
        ? meta.title
        : '${meta.title}\n\n$content';
    final pageTexts = paginateChapterContent(
      content: contentWithTitle,
      width: pageWidth,
      height: pageHeight,
      style: textStyle,
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
    required TextStyle textStyle,
    required double pageWidth,
    required double pageHeight,
  }) async {
    await loadChapter(
      chapterIndex: chapterIndex,
      textStyle: textStyle,
      pageWidth: pageWidth,
      pageHeight: pageHeight,
      jumpToPageInChapter: pageIndexInChapter,
    );
  }

  Future<int?> tryAppendNextChapter({
    required TextStyle textStyle,
    required double pageWidth,
    required double pageHeight,
  }) async {
    final chapter = currentChapterIndex;
    if (chapter >= chapterMetas.length - 1) return null;
    if (flatPages.any((page) => page.chapterIndex == chapter + 1)) {
      return null;
    }

    final before = flatPages.length;
    await loadChapter(
      chapterIndex: chapter + 1,
      textStyle: textStyle,
      pageWidth: pageWidth,
      pageHeight: pageHeight,
      append: true,
    );
    return before;
  }

  Future<int?> tryPrependPreviousChapter({
    required TextStyle textStyle,
    required double pageWidth,
    required double pageHeight,
  }) async {
    final chapter = currentChapterIndex;
    if (chapter <= 0) return null;
    if (flatPages.any((page) => page.chapterIndex == chapter - 1)) {
      return null;
    }

    final added = await loadChapter(
      chapterIndex: chapter - 1,
      textStyle: textStyle,
      pageWidth: pageWidth,
      pageHeight: pageHeight,
      prepend: true,
    );
    return added.length;
  }

  Future<void> jumpToChapter({
    required int chapterIndex,
    required TextStyle textStyle,
    required double pageWidth,
    required double pageHeight,
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
      textStyle: textStyle,
      pageWidth: pageWidth,
      pageHeight: pageHeight,
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
    required TextStyle textStyle,
    required double pageWidth,
    required double pageHeight,
  }) async {
    final chapter = currentChapterIndex;
    final pageInChapter = currentPage?.pageIndexInChapter ?? 0;
    final loaded = loadedChapters.toList()..sort();
    flatPages.clear();
    loadedChapters.clear();

    for (final index in loaded) {
      await loadChapter(
        chapterIndex: index,
        textStyle: textStyle,
        pageWidth: pageWidth,
        pageHeight: pageHeight,
        append: flatPages.isNotEmpty,
      );
    }

    await jumpToChapter(
      chapterIndex: chapter,
      textStyle: textStyle,
      pageWidth: pageWidth,
      pageHeight: pageHeight,
      pageIndexInChapter: pageInChapter,
    );
  }
}
