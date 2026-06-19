import 'dart:convert';

import 'package:fast_gbk/fast_gbk.dart';

/// 解码 TXT 字节流：对 UTF-8 / GBK 等候选结果打分，取最优（兼容网文常见双编码）。
String decodeTxtBytes(List<int> bytes) {
  if (bytes.isEmpty) return '';

  if (bytes.length >= 3 &&
      bytes[0] == 0xEF &&
      bytes[1] == 0xBB &&
      bytes[2] == 0xBF) {
    try {
      return utf8.decode(bytes.sublist(3), allowMalformed: false);
    } catch (_) {
      // BOM 声明 UTF-8 但内容损坏时继续走候选打分。
    }
  }

  final candidates = <String>[];

  void addCandidate(String text) {
    if (text.isNotEmpty) candidates.add(text);
  }

  try {
    addCandidate(utf8.decode(bytes, allowMalformed: false));
  } catch (_) {}

  try {
    addCandidate(gbk.decode(bytes));
  } catch (_) {}

  addCandidate(utf8.decode(bytes, allowMalformed: true));

  if (candidates.isEmpty) {
    return latin1.decode(bytes, allowInvalid: true);
  }

  var best = candidates.first;
  var bestScore = scoreDecodedText(best);
  for (var i = 1; i < candidates.length; i++) {
    final score = scoreDecodedText(candidates[i]);
    if (score > bestScore) {
      bestScore = score;
      best = candidates[i];
    }
  }
  return best;
}

/// 解码质量分（越高越可信）；用于挑选编码与预检可读性。
int scoreDecodedText(String text) {
  if (text.trim().isEmpty) return -1000000;

  var replacement = 0;
  var suspicious = 0;
  var meaningful = 0;
  var cjk = 0;
  var latinExt = 0;

  for (final code in text.runes) {
    if (code == 0xFFFD) {
      replacement++;
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
    if ((code >= 0x4E00 && code <= 0x9FFF) ||
        (code >= 0x3400 && code <= 0x4DBF) ||
        (code >= 0x3000 && code <= 0x303F) ||
        (code >= 0xFF00 && code <= 0xFFEF)) {
      cjk++;
    }
    if (code >= 0xC0 && code <= 0xFF) latinExt++;
  }

  if (meaningful == 0) return -1000000;

  var score = 0;
  score += cjk * 2;
  score -= replacement * 200;
  score -= (suspicious * 100) ~/ meaningful;
  if (latinExt / meaningful > 0.12) score -= 500;
  return score;
}

/// 抽样判断文本是否明显乱码（大量替换符、不可见字符或 GBK 误解码拉丁乱码）。
bool looksLikeGarbledText(String text, {bool expectCjk = false}) {
  if (text.trim().isEmpty) return true;
  final score = scoreDecodedText(text);
  if (score < 0) return true;
  // 仅当调用方明确期望中文、且样本足够长但仍几乎无 CJK 时才判乱码。
  if (expectCjk && text.length > 80 && !_hasSignificantCjk(text)) {
    return true;
  }
  return false;
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
