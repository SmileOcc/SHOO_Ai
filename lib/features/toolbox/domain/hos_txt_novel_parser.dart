import 'dart:io';
import 'dart:math' as math;

import 'package:flutter/material.dart';

import 'hos_txt_novel_models.dart';
import 'hos_text_encoding.dart';

export 'hos_text_encoding.dart'
    show decodeTxtBytes, looksLikeGarbledText, isChapterContentTooLarge;

bool isTxtNovelFile(String fileName) {
  return fileName.split('.').last.toLowerCase() == 'txt';
}

final _chapterHeadingPattern = RegExp(
  r'^(?:'
  r'第[0-9一二三四五六七八九十百千零两]+章[^\n\r]*'
  r'|第\s*\d+\s*章[^\n\r]*'
  r'|Chapter\s+\d+[^\n\r]*'
  r'|CHAPTER\s+\d+[^\n\r]*'
  r'|【[^】\n\r]{1,24}】'
  r'|序章[^\n\r]*'
  r'|楔子[^\n\r]*'
  r'|番外[^\n\r]*'
  r'|终章[^\n\r]*'
  r'|后记[^\n\r]*'
  r')',
);

bool isChapterHeadingLine(String line) {
  return _chapterHeadingPattern.hasMatch(line.trim());
}

/// 流式扫描章节边界（按字节记录），不全量载入内存。
Future<List<SHONovelChapterMeta>> scanChapterMetas(
  File file,
  void Function(double progress) onProgress,
) async {
  final total = await file.length();
  if (total == 0) {
    return const [
      SHONovelChapterMeta(
        index: 0,
        title: '正文',
        startByte: 0,
        endByte: 0,
      ),
    ];
  }

  final raf = await file.open();
  try {
    final hits = <({int startByte, String title})>[];
    var offset = 0;
    var pending = <int>[];

    while (offset < total) {
      final chunk = await raf.read(math.min(512 * 1024, total - offset));
      if (chunk.isEmpty) break;
      offset += chunk.length;

      pending.addAll(chunk);
      final base = offset - pending.length;
      var lineStart = 0;

      for (var i = 0; i < pending.length; i++) {
        if (pending[i] != 10) continue;

        var end = i;
        if (end > lineStart && pending[end - 1] == 13) end--;

        final line = decodeTxtBytes(pending.sublist(lineStart, end)).trim();
        if (line.isNotEmpty && isChapterHeadingLine(line)) {
          hits.add((startByte: base + lineStart, title: line));
        }
        lineStart = i + 1;
      }

      pending = lineStart < pending.length
          ? pending.sublist(lineStart)
          : <int>[];

      onProgress(offset / total);
      await Future<void>.delayed(Duration.zero);
    }

    if (pending.isNotEmpty) {
      final line = decodeTxtBytes(pending).trim();
      if (line.isNotEmpty && isChapterHeadingLine(line)) {
        hits.add((startByte: offset - pending.length, title: line));
      }
    }

    if (hits.isEmpty) {
      return [
        SHONovelChapterMeta(
          index: 0,
          title: '正文',
          startByte: 0,
          endByte: total,
        ),
      ];
    }

    final metas = <SHONovelChapterMeta>[];
    if (hits.first.startByte > 0) {
      metas.add(
        SHONovelChapterMeta(
          index: 0,
          title: '前言',
          startByte: 0,
          endByte: hits.first.startByte,
        ),
      );
    }

    final chapterHits = hits;
    for (var i = 0; i < chapterHits.length; i++) {
      final hit = chapterHits[i];
      final end = i + 1 < chapterHits.length
          ? chapterHits[i + 1].startByte
          : total;
      metas.add(
        SHONovelChapterMeta(
          index: metas.length,
          title: hit.title,
          startByte: hit.startByte,
          endByte: end,
        ),
      );
    }

    return metas;
  } finally {
    await raf.close();
  }
}

Future<String> readChapterContent(
  File file,
  SHONovelChapterMeta meta,
) async {
  final length = meta.endByte - meta.startByte;
  if (length <= 0) return '';

  final raf = await file.open();
  try {
    await raf.setPosition(meta.startByte);
    final bytes = await raf.read(length);
    var text = decodeTxtBytes(bytes).replaceAll('\r\n', '\n').trim();
    if (text.isEmpty) return '';

    final firstBreak = text.indexOf('\n');
    if (firstBreak != -1) {
      final firstLine = text.substring(0, firstBreak).trim();
      if (isChapterHeadingLine(firstLine)) {
        text = text.substring(firstBreak + 1).trim();
      }
    } else if (isChapterHeadingLine(text)) {
      return '';
    }

    return text;
  } finally {
    await raf.close();
  }
}

const _paginationHeightTolerance = 0.5;

const _readerTextHeightBehavior = TextHeightBehavior(
  applyHeightToFirstAscent: true,
  applyHeightToLastDescent: false,
);

TextPainter layoutTextPainter({
  required String text,
  required TextStyle style,
  required double maxWidth,
  TextScaler textScaler = TextScaler.noScaling,
}) {
  final painter = TextPainter(
    text: TextSpan(text: text, style: style),
    textDirection: TextDirection.ltr,
    textScaler: textScaler,
    strutStyle: StrutStyle(
      fontSize: style.fontSize,
      height: style.height,
      leadingDistribution: TextLeadingDistribution.proportional,
    ),
    textHeightBehavior: _readerTextHeightBehavior,
  );
  painter.layout(maxWidth: maxWidth);
  return painter;
}

double measureTextBlockHeight({
  required String text,
  required TextStyle style,
  required double maxWidth,
  TextScaler textScaler = TextScaler.noScaling,
}) {
  return layoutTextPainter(
    text: text,
    style: style,
    maxWidth: maxWidth,
    textScaler: textScaler,
  ).height;
}

bool _textFitsHeight({
  required String text,
  required TextStyle style,
  required double maxWidth,
  required double maxHeight,
  TextScaler textScaler = TextScaler.noScaling,
}) {
  if (text.isEmpty) return true;
  final height = measureTextBlockHeight(
    text: text,
    style: style,
    maxWidth: maxWidth,
    textScaler: textScaler,
  );
  return height <= maxHeight + _paginationHeightTolerance;
}

List<String> paginateChapterContent({
  required String content,
  required double width,
  required double height,
  required TextStyle style,
  TextScaler textScaler = TextScaler.noScaling,
  double? firstPageMaxHeight,
}) {
  final normalized = content.replaceAll('\r\n', '\n');
  if (normalized.isEmpty) return const [''];

  final pages = <String>[];
  var offset = 0;
  var pageIndex = 0;

  while (offset < normalized.length) {
    final maxHeight = pageIndex == 0 && firstPageMaxHeight != null
        ? firstPageMaxHeight
        : height;

    var low = offset + 1;
    var high = normalized.length;
    var best = offset;

    while (low <= high) {
      final mid = (low + high) ~/ 2;
      final candidate = normalized.substring(offset, mid);
      if (_textFitsHeight(
        text: candidate,
        style: style,
        maxWidth: width,
        maxHeight: maxHeight,
        textScaler: textScaler,
      )) {
        best = mid;
        low = mid + 1;
      } else {
        high = mid - 1;
      }
    }

    var end = best;
    if (end <= offset) {
      end = offset + 1;
    }

    if (end < normalized.length) {
      final slice = normalized.substring(offset, end);
      final paragraphBreak = slice.lastIndexOf('\n\n');
      if (paragraphBreak > 0) {
        final candidate = offset + paragraphBreak + 2;
        if (_textFitsHeight(
          text: normalized.substring(offset, candidate),
          style: style,
          maxWidth: width,
          maxHeight: maxHeight,
          textScaler: textScaler,
        )) {
          end = candidate;
        }
      } else {
        final lineBreak = slice.lastIndexOf('\n');
        if (lineBreak > 0) {
          final candidate = offset + lineBreak + 1;
          if (_textFitsHeight(
            text: normalized.substring(offset, candidate),
            style: style,
            maxWidth: width,
            maxHeight: maxHeight,
            textScaler: textScaler,
          )) {
            end = candidate;
          }
        }
      }
    }

    pages.add(normalized.substring(offset, end));
    offset = end;
    pageIndex++;
  }

  return pages.isEmpty ? const [''] : pages;
}

List<SHONovelPage> buildPagesForChapter({
  required SHONovelChapterMeta meta,
  required List<String> pageTexts,
  required int globalStartIndex,
}) {
  return [
    for (var i = 0; i < pageTexts.length; i++)
      SHONovelPage(
        globalIndex: globalStartIndex + i,
        chapterIndex: meta.index,
        pageIndexInChapter: i,
        chapterTitle: meta.title,
        text: pageTexts[i],
      ),
  ];
}
