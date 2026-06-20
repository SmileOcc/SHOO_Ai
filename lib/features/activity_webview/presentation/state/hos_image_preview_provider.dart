import 'package:flutter_riverpod/flutter_riverpod.dart';

class SHOImagePreviewItem {
  const SHOImagePreviewItem({
    required this.url,
    this.title = '',
  });

  final String url;
  final String title;
}

class SHOImagePreviewState {
  const SHOImagePreviewState({
    this.images = const [],
    this.currentIndex = 0,
  });

  final List<SHOImagePreviewItem> images;
  final int currentIndex;

  SHOImagePreviewState copyWith({
    List<SHOImagePreviewItem>? images,
    int? currentIndex,
  }) {
    return SHOImagePreviewState(
      images: images ?? this.images,
      currentIndex: currentIndex ?? this.currentIndex,
    );
  }
}

class SHOImagePreviewNotifier extends Notifier<SHOImagePreviewState> {
  @override
  SHOImagePreviewState build() => const SHOImagePreviewState();

  void setImages(List<SHOImagePreviewItem> images, {int index = 0}) {
    state = SHOImagePreviewState(
      images: images,
      currentIndex: images.isEmpty ? 0 : index.clamp(0, images.length - 1),
    );
  }

  void setIndex(int index) {
    if (state.images.isEmpty) return;
    state = state.copyWith(
      currentIndex: index.clamp(0, state.images.length - 1),
    );
  }
}

final imagePreviewProvider =
    NotifierProvider<SHOImagePreviewNotifier, SHOImagePreviewState>(
  SHOImagePreviewNotifier.new,
);
