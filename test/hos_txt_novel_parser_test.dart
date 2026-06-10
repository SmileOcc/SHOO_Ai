import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shoo/features/toolbox/domain/hos_txt_novel_parser.dart';

void main() {
  group('isChapterHeadingLine', () {
    test('matches common Chinese chapter headings', () {
      expect(isChapterHeadingLine('第一章 开端'), isTrue);
      expect(isChapterHeadingLine('第 12 章 试炼'), isTrue);
      expect(isChapterHeadingLine('序章'), isTrue);
      expect(isChapterHeadingLine('【番外】'), isTrue);
    });

    test('rejects normal prose lines', () {
      expect(isChapterHeadingLine('这是一段普通正文'), isFalse);
      expect(isChapterHeadingLine(''), isFalse);
    });
  });

  group('paginateChapterContent', () {
    test('splits long content into multiple pages', () {
      const style = TextStyle(fontSize: 16, height: 1.75);
      final content = List.filled(80, '这是一段用于测试分页的小说正文。').join('\n');

      final pages = paginateChapterContent(
        content: content,
        width: 280,
        height: 420,
        style: style,
      );

      expect(pages.length, greaterThan(1));
      expect(pages.join(), content);
    });

    test('returns single empty page for empty content', () {
      const style = TextStyle(fontSize: 16, height: 1.75);
      final pages = paginateChapterContent(
        content: '',
        width: 280,
        height: 420,
        style: style,
      );

      expect(pages, ['']);
    });
  });
}
