import 'package:flutter_riverpod/flutter_riverpod.dart';

class SHOWebViewLoadingState {
  const SHOWebViewLoadingState({
    this.isLoading = true,
    this.progress = 0,
    this.error,
    this.errorCode,
    this.retryCount = 0,
    this.pageTitle,
    this.canGoBack = false,
  });

  final bool isLoading;
  final int progress;
  final String? error;
  final int? errorCode;
  final int retryCount;
  final String? pageTitle;
  final bool canGoBack;

  SHOWebViewLoadingState copyWith({
    bool? isLoading,
    int? progress,
    String? error,
    int? errorCode,
    int? retryCount,
    String? pageTitle,
    bool? canGoBack,
    bool clearError = false,
  }) {
    return SHOWebViewLoadingState(
      isLoading: isLoading ?? this.isLoading,
      progress: progress ?? this.progress,
      error: clearError ? null : (error ?? this.error),
      errorCode: clearError ? null : (errorCode ?? this.errorCode),
      retryCount: retryCount ?? this.retryCount,
      pageTitle: pageTitle ?? this.pageTitle,
      canGoBack: canGoBack ?? this.canGoBack,
    );
  }
}

class SHOWebViewLoadingNotifier extends Notifier<SHOWebViewLoadingState> {
  @override
  SHOWebViewLoadingState build() => const SHOWebViewLoadingState();

  void updateProgress(int progress) {
    state = state.copyWith(
      progress: progress.clamp(0, 100),
      isLoading: progress < 100,
      clearError: true,
    );
  }

  void setError(String error, int code) {
    state = state.copyWith(
      error: error,
      errorCode: code,
      isLoading: false,
    );
  }

  void setPageTitle(String? title) {
    state = state.copyWith(pageTitle: title);
  }

  void setCanGoBack(bool value) {
    state = state.copyWith(canGoBack: value);
  }

  bool retry() {
    if (state.retryCount >= 3) return false;
    state = state.copyWith(
      retryCount: state.retryCount + 1,
      isLoading: true,
      progress: 0,
      clearError: true,
    );
    return true;
  }

  void clearError() {
    state = state.copyWith(clearError: true);
  }

  void reset() {
    state = const SHOWebViewLoadingState();
  }
}

final webviewLoadingProvider =
    NotifierProvider<SHOWebViewLoadingNotifier, SHOWebViewLoadingState>(
  SHOWebViewLoadingNotifier.new,
);
