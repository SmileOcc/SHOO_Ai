import 'package:shoo/features/toolbox/domain/entities/hos_contact.dart';

/// 联系人列表行：分组头或联系人项。
sealed class SHOContactListRow {
  const SHOContactListRow();
}

final class SHOContactSectionHeaderRow extends SHOContactListRow {
  const SHOContactSectionHeaderRow(this.letter);

  final String letter;
}

final class SHOContactItemRow extends SHOContactListRow {
  const SHOContactItemRow(this.contact);

  final SHOContact contact;
}

/// 联系人分组与索引工具（仿微信 A-Z 列表）。
abstract final class SHOContactGroupUtils {
  static const sectionHeaderHeight = 32.0;
  static const itemHeight = 72.0;

  static const indexLetters = [
    '#',
    'A',
    'B',
    'C',
    'D',
    'E',
    'F',
    'G',
    'H',
    'I',
    'J',
    'K',
    'L',
    'M',
    'N',
    'O',
    'P',
    'Q',
    'R',
    'S',
    'T',
    'U',
    'V',
    'W',
    'X',
    'Y',
    'Z',
  ];

  static List<SHOContactListRow> buildRows(List<SHOContact> contacts) {
    if (contacts.isEmpty) return const [];

    // ..级联调用 在列表上调用 sort，但返回列表本身
    final sorted = [...contacts]
      ..sort((a, b) {
        final la = a.letter.toUpperCase();
        final lb = b.letter.toUpperCase();
        final ai = indexLetters.indexOf(la);
        final bi = indexLetters.indexOf(lb);
        final orderA = ai < 0 ? indexLetters.length : ai;
        final orderB = bi < 0 ? indexLetters.length : bi;
        if (orderA != orderB) return orderA.compareTo(orderB);
        return a.pinyin.compareTo(b.pinyin);
      });

    final rows = <SHOContactListRow>[];
    String? currentLetter;
    for (final contact in sorted) {
      final letter = contact.letter.toUpperCase();
      if (letter != currentLetter) {
        currentLetter = letter;
        rows.add(SHOContactSectionHeaderRow(letter));
      }
      rows.add(SHOContactItemRow(contact));
    }
    return rows;
  }

  static List<String> availableIndexLetters(List<SHOContactListRow> rows) {
    return rows
        .whereType<SHOContactSectionHeaderRow>()
        .map((r) => r.letter)
        .toList();
  }

  static Map<String, int> letterToRowIndex(List<SHOContactListRow> rows) {
    final map = <String, int>{};
    for (var i = 0; i < rows.length; i++) {
      final row = rows[i];
      if (row is SHOContactSectionHeaderRow) {
        map[row.letter] = i;
      }
    }
    return map;
  }

  static double offsetForRowIndex(List<SHOContactListRow> rows, int index) {
    var offset = 0.0;
    for (var i = 0; i < index && i < rows.length; i++) {
      offset += rowHeight(rows[i]);
    }
    return offset;
  }

  static double rowHeight(SHOContactListRow row) {
    return row is SHOContactSectionHeaderRow
        ? sectionHeaderHeight
        : itemHeight;
  }

  static double totalHeight(List<SHOContactListRow> rows) {
    return rows.fold<double>(0, (sum, row) => sum + rowHeight(row));
  }

  /// 根据滚动偏移推断当前分组字母（取最后一个 offset 不超过滚动位置的 section）。
  static String? letterForScrollOffset(
    List<SHOContactListRow> rows,
    double offset,
  ) {
    if (rows.isEmpty) return null;

    String? activeLetter;
    var accumulated = 0.0;

    for (final row in rows) {
      if (row is SHOContactSectionHeaderRow) {
        if (accumulated <= offset + 1) {
          activeLetter = row.letter;
        }
      }
      accumulated += rowHeight(row);
    }

    return activeLetter;
  }

  static int rowIndexForLetter(
    List<SHOContactListRow> rows,
    String letter,
  ) {
    return letterToRowIndex(rows)[letter.toUpperCase()] ?? 0;
  }
}
