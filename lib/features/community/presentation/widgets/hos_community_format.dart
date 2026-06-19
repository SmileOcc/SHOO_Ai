String shoCommunityFormatCount(int value) {
  if (value >= 10000) {
    final k = value / 10000;
    return k >= 10 ? '${k.toStringAsFixed(0)}w' : '${k.toStringAsFixed(1)}w';
  }
  if (value >= 1000) {
    final k = value / 1000;
    return k >= 10 ? '${k.toStringAsFixed(0)}k' : '${k.toStringAsFixed(1)}k';
  }
  return value.toString();
}

String shoCommunityFormatRelativeTime(String iso) {
  if (iso.isEmpty) return '';
  final parsed = DateTime.tryParse(iso);
  if (parsed == null) return iso;

  final now = DateTime.now();
  final diff = now.difference(parsed.toLocal());
  if (diff.inMinutes < 1) return '刚刚';
  if (diff.inHours < 1) return '${diff.inMinutes}分钟前';
  if (diff.inHours < 24) return '${diff.inHours}小时前';
  if (diff.inDays < 7) return '${diff.inDays}天前';
  return '${parsed.month.toString().padLeft(2, '0')}-${parsed.day.toString().padLeft(2, '0')}';
}
