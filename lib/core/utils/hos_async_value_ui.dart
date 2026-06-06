import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../errors/hos_exception.dart';
import '../errors/hos_error_mapper.dart';
import '../widgets/hos_error_view.dart';
import '../widgets/hos_loading_state.dart';

extension SHOAsyncValueUI<T> on AsyncValue<T> {
  Widget whenWidget({
    required Widget Function(T data) data,
    Widget? loading,
    Widget Function(Object error, StackTrace stack)? error,
  }) {
    return when(
      data: data,
      loading: () =>
          loading ??
          const SHOAppLoadingState(
            state: SHOLoadingState.loading,
          ),
      error: (err, stack) {
        if (error != null) return error(err, stack);
        final message = err is SHOAppException
            ? userFacingMessage(err)
            : err.toString();
        return SHOAppErrorView(
          message: message,
          onRetry: null,
        );
      },
    );
  }
}
