import 'package:flutter/material.dart';

class SHOWebViewErrorWidget extends StatelessWidget {
  const SHOWebViewErrorWidget({
    super.key,
    required this.errorCode,
    required this.message,
    required this.onRetry,
    required this.onBack,
  });

  final int? errorCode;
  final String message;
  final VoidCallback onRetry;
  final VoidCallback onBack;

  ({IconData icon, String title}) _resolve() {
    final code = errorCode;
    if (code == -2) {
      return (icon: Icons.wifi_off_outlined, title: '网络连接已断开，请检查网络设置');
    }
    if (code == -8) {
      return (icon: Icons.schedule_outlined, title: '加载超时，请稍后重试');
    }
    if (code != null && code >= 500 && code < 600) {
      return (icon: Icons.dns_outlined, title: '服务器繁忙，请稍后重试');
    }
    if (code == 404) {
      return (icon: Icons.description_outlined, title: '页面不存在');
    }
    if (code == -200) {
      return (icon: Icons.lock_outline, title: '连接不安全');
    }
    return (
      icon: Icons.error_outline,
      title: message.isNotEmpty ? message : '加载失败，请重试',
    );
  }

  @override
  Widget build(BuildContext context) {
    final info = _resolve();
    return Material(
      color: Theme.of(context).scaffoldBackgroundColor,
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(info.icon, size: 56, color: Colors.grey),
              const SizedBox(height: 16),
              Text(
                info.title,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  OutlinedButton(onPressed: onBack, child: const Text('返回')),
                  const SizedBox(width: 12),
                  FilledButton(onPressed: onRetry, child: const Text('重试')),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
