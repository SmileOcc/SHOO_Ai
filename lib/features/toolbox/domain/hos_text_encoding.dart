import 'dart:convert';

import 'package:fast_gbk/fast_gbk.dart';

/// 解码 TXT 字节流，优先 UTF-8，失败或乱码时回退 GBK。
String decodeTxtBytes(List<int> bytes) {
  if (bytes.isEmpty) return '';

  if (bytes.length >= 3 &&
      bytes[0] == 0xEF &&
      bytes[1] == 0xBB &&
      bytes[2] == 0xBF) {
    return utf8.decode(bytes.sublist(3), allowMalformed: false);
  }

  final expectCjk = _bytesLookLikeGbk(bytes);

  if (!expectCjk) {
    try {
      final utf8Text = utf8.decode(bytes, allowMalformed: false);
      if (!looksLikeGarbledText(utf8Text)) return utf8Text;
    } catch (_) {}
  }

  try {
    final gbkText = gbk.decode(bytes);
    if (gbkText.trim().isNotEmpty &&
        !looksLikeGarbledText(gbkText, expectCjk: expectCjk)) {
      return gbkText;
    }
  } catch (_) {}

  if (!expectCjk) {
    final looseUtf8 = utf8.decode(bytes, allowMalformed: true);
    if (!looksLikeGarbledText(looseUtf8)) return looseUtf8;
  }

  try {
    return gbk.decode(bytes);
  } catch (_) {
    return latin1.decode(bytes, allowInvalid: true);
  }
}

/// 抽样判断文本是否明显乱码（大量替换符、不可见字符或 GBK 误解码拉丁乱码）。
bool looksLikeGarbledText(String text, {bool expectCjk = false}) {
  if (text.trim().isEmpty) return true;
  if (_looksLikeLatinMojibake(text)) return true;
  if (expectCjk && !_hasSignificantCjk(text)) return true;

  var suspicious = 0;
  var meaningful = 0;

  for (final code in text.runes) {
    if (code == 0xFFFD) {
      suspicious++;
      meaningful++;
      continue;
    }
    if (code == 0x00) {
      suspicious++;
      continue;
    }
    if (code < 0x20 && code != 0x09 && code != 0x0A && code != 0x0D) {
      suspicious++;
      continue;
    }
    meaningful++;
  }

  if (meaningful == 0) return true;
  return suspicious / meaningful > 0.12;
}

/// 字节流是否像 GBK/双字节中文文本。
bool _bytesLookLikeGbk(List<int> bytes) {
  if (bytes.isEmpty) return false;

  final sampleLen = bytes.length > 4096 ? 4096 : bytes.length;
  var highBytes = 0;
  for (var i = 0; i < sampleLen; i++) {
    if (bytes[i] >= 0x80) highBytes++;
  }
  return highBytes > sampleLen * 0.05;
}

/// GBK 被错误解码后常见：大量 U+00C0–U+00FF 拉丁扩展字符。
bool _looksLikeLatinMojibake(String text) {
  var latinExt = 0;
  var total = 0;

  for (final code in text.runes) {
    if (code < 0x20 && code != 0x09 && code != 0x0A && code != 0x0D) continue;
    total++;
    if (code >= 0xC0 && code <= 0xFF) latinExt++;
  }

  if (total == 0) return false;
  return latinExt / total > 0.12;
}

bool _hasSignificantCjk(String text) {
  var cjk = 0;
  var total = 0;

  for (final code in text.runes) {
    if (code == 0x0A || code == 0x0D || code == 0x09 || code == 0x20) continue;
    total++;
    final isCjk = (code >= 0x4E00 && code <= 0x9FFF) ||
        (code >= 0x3400 && code <= 0x4DBF) ||
        (code >= 0x3000 && code <= 0x303F) ||
        (code >= 0xFF00 && code <= 0xFFEF);
    if (isCjk) cjk++;
  }

  if (total == 0) return false;
  return cjk / total > 0.04;
}

/// 单章允许分页的最大字符数，防止章节识别失败时整文件分页卡死。
const txtReaderMaxChapterChars = 800000;

bool isChapterContentTooLarge(String content) =>
    content.length > txtReaderMaxChapterChars;
