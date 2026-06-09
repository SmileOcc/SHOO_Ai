class SHONovelChapterMeta {
  const SHONovelChapterMeta({
    required this.index,
    required this.title,
    required this.startByte,
    required this.endByte,
  });

  final int index;
  final String title;
  final int startByte;
  final int endByte;
}

class SHONovelChapter {
  const SHONovelChapter({
    required this.index,
    required this.title,
    required this.content,
  });

  final int index;
  final String title;
  final String content;
}

class SHONovelPage {
  const SHONovelPage({
    required this.globalIndex,
    required this.chapterIndex,
    required this.pageIndexInChapter,
    required this.chapterTitle,
    required this.text,
  });

  final int globalIndex;
  final int chapterIndex;
  final int pageIndexInChapter;
  final String chapterTitle;
  final String text;
}

class SHOTxtReaderProgress {
  const SHOTxtReaderProgress({
    required this.chapterIndex,
    required this.pageIndexInChapter,
    required this.fontSize,
    this.darkMode = false,
    this.textColorArgb = 0xFF3D3024,
    this.backgroundColorArgb = 0xFFE8E3D3,
  });

  final int chapterIndex;
  final int pageIndexInChapter;
  final double fontSize;
  final bool darkMode;
  final int textColorArgb;
  final int backgroundColorArgb;

  Map<String, dynamic> toJson() => {
        'chapterIndex': chapterIndex,
        'pageIndexInChapter': pageIndexInChapter,
        'fontSize': fontSize,
        'darkMode': darkMode,
        'textColorArgb': textColorArgb,
        'backgroundColorArgb': backgroundColorArgb,
      };

  factory SHOTxtReaderProgress.fromJson(Map<String, dynamic> json) {
    return SHOTxtReaderProgress(
      chapterIndex: json['chapterIndex'] as int? ?? 0,
      pageIndexInChapter: json['pageIndexInChapter'] as int? ?? 0,
      fontSize: (json['fontSize'] as num?)?.toDouble() ?? 18,
      darkMode: json['darkMode'] as bool? ?? false,
      textColorArgb: json['textColorArgb'] as int? ?? 0xFF3D3024,
      backgroundColorArgb:
          json['backgroundColorArgb'] as int? ?? 0xFFE8E3D3,
    );
  }
}

enum SHOTxtReaderLoadPhase {
  indexing,
  paginating,
  ready,
  failed,
}
