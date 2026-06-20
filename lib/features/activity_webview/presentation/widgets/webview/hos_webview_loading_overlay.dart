import 'package:flutter/material.dart';

class SHOWebViewLoadingOverlay extends StatelessWidget {
  const SHOWebViewLoadingOverlay({super.key});

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: Colors.black.withValues(alpha: 0.08),
      child: const Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 12),
            Text('正在加载...'),
          ],
        ),
      ),
    );
  }
}
