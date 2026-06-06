/// 常用数组/List 工具。
abstract final class SHOListUtils {
  static bool isEmpty<T>(List<T>? list) => list == null || list.isEmpty;

  static bool isNotEmpty<T>(List<T>? list) => !isEmpty(list);

  static List<T> safe<T>(List<T>? list) => list ?? [];

  static T? firstOrNull<T>(List<T> list) => list.isEmpty ? null : list.first;

  static T? lastOrNull<T>(List<T> list) => list.isEmpty ? null : list.last;

  static List<T> distinct<T>(List<T> list) => list.toSet().toList();

  static List<T> distinctBy<T, K>(List<T> list, K Function(T item) key) {
    final seen = <K>{};
    return list.where((e) => seen.add(key(e))).toList();
  }

  static List<T> paginate<T>(List<T> list, {required int page, required int pageSize}) {
    final start = (page - 1) * pageSize;
    if (start >= list.length) return [];
    final end = (start + pageSize).clamp(0, list.length);
    return list.sublist(start, end);
  }

  static List<List<T>> chunk<T>(List<T> list, int size) {
    if (size <= 0) return [list];
    final result = <List<T>>[];
    for (var i = 0; i < list.length; i += size) {
      result.add(list.sublist(i, (i + size).clamp(0, list.length)));
    }
    return result;
  }
}
