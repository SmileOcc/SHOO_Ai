import 'dart:convert';

import 'package:fast_gbk/fast_gbk.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shoo/features/toolbox/domain/entities/hos_text_encoding.dart';

void main() {
  const sample = '第一章 轮回乐园\n这是正文内容，用于测试编码识别。\n';

  group('decodeTxtBytes', () {
    test('decodes UTF-8 Chinese novel sample', () {
      final bytes = utf8.encode(sample * 50);
      final text = decodeTxtBytes(bytes);
      expect(text, contains('轮回乐园'));
      expect(looksLikeGarbledText(text), isFalse);
      expect(scoreDecodedText(text), greaterThan(0));
    });

    test('decodes GBK Chinese novel sample', () {
      final bytes = gbk.encode(sample * 50);
      final text = decodeTxtBytes(bytes);
      expect(text, contains('轮回乐园'));
      expect(looksLikeGarbledText(text), isFalse);
      expect(scoreDecodedText(text), greaterThan(0));
    });

    test('prefers UTF-8 over GBK misread for UTF-8 bytes', () {
      final utf8Bytes = utf8.encode('第二章 乐园轮回\n中文正文。' * 30);
      final text = decodeTxtBytes(utf8Bytes);
      expect(text, contains('乐园轮回'));
      expect(text, isNot(contains('锟')));
    });

    test('plain ASCII remains readable', () {
      final bytes = utf8.encode('Chapter 1\nHello world\n' * 20);
      final text = decodeTxtBytes(bytes);
      expect(text, contains('Hello world'));
      expect(scoreDecodedText(text), greaterThanOrEqualTo(0));
    });
  });
}
