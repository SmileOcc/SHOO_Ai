class SHOLrcLine {
  const SHOLrcLine({
    required this.time,
    required this.text,
  });

  final Duration time;
  final String text;
}

List<SHOLrcLine> parseLrc(String? raw) {
  if (raw == null || raw.trim().isEmpty) return const [];

  final lines = <SHOLrcLine>[];
  final pattern = RegExp(r'\[(\d+):(\d+)(?:\.(\d+))?\](.*)');

  for (final line in raw.split('\n')) {
    final trimmed = line.trim();
    if (trimmed.isEmpty) continue;

    final match = pattern.firstMatch(trimmed);
    if (match == null) continue;

    final minutes = int.tryParse(match.group(1) ?? '') ?? 0;
    final seconds = int.tryParse(match.group(2) ?? '') ?? 0;
    final fractionRaw = match.group(3) ?? '0';
    final fraction = int.tryParse(fractionRaw.padRight(3, '0').substring(0, 3)) ?? 0;
    final text = (match.group(4) ?? '').trim();
    if (text.isEmpty) continue;

    lines.add(
      SHOLrcLine(
        time: Duration(
          minutes: minutes,
          seconds: seconds,
          milliseconds: fraction,
        ),
        text: text,
      ),
    );
  }

  lines.sort((a, b) => a.time.compareTo(b.time));
  return lines;
}

int indexForPosition(List<SHOLrcLine> lines, Duration position) {
  if (lines.isEmpty) return -1;

  var index = -1;
  for (var i = 0; i < lines.length; i++) {
    if (lines[i].time <= position) {
      index = i;
    } else {
      break;
    }
  }
  return index;
}
