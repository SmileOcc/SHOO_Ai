import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:shoo/app/router/hos_routes.dart';
import 'package:shoo/core/analytics/hos_page_analytics.dart';
import 'package:shoo/core/feedback/hos_toast.dart';
import 'package:shoo/core/pages/hos_pages.dart';
import 'package:shoo/core/theme/hos_spacing.dart';

/// 百宝箱 → 通用 Web：输入 URL 后打开 [SHOWebViewPage]。
class SHOToolboxWebPage extends ConsumerStatefulWidget {
  const SHOToolboxWebPage({super.key});

  @override
  ConsumerState<SHOToolboxWebPage> createState() => _SHOToolboxWebPageState();
}

class _SHOToolboxWebPageState extends ConsumerState<SHOToolboxWebPage>
    with SHOPageRouteAnalyticsMixin, SHOAppPageMixin, SHOAppTrackedPageMixin {
  late final TextEditingController _urlController;
  final _presets = const [
    _WebPreset('Flutter 官网', 'https://flutter.dev'),
    _WebPreset('SHOO Mock 活动', 'http://127.0.0.1:3847/activity'),
    _WebPreset('本地 Mock API 文档', 'http://127.0.0.1:3847/'),
  ];

  @override
  String get pageName => 'toolbox_web';

  @override
  void initState() {
    super.initState();
    _urlController = TextEditingController(text: _presets.first.url);
  }

  @override
  void dispose() {
    _urlController.dispose();
    super.dispose();
  }

  void _openWebView({String? url}) {
    final raw = (url ?? _urlController.text).trim();
    if (raw.isEmpty) {
      context.showToast('请输入网址');
      return;
    }
    final normalized = _normalizeUrl(raw);
    context.push(SHOAppRoutes.webviewFor(normalized));
  }

  String _normalizeUrl(String raw) {
    if (raw.startsWith('http://') || raw.startsWith('https://')) return raw;
    return 'https://$raw';
  }

  @override
  Widget build(BuildContext context) {
    return buildTrackedPage(
      Scaffold(
        appBar: AppBar(title: const Text('通用 Web')),
        body: ListView(
          padding: const EdgeInsets.all(SHOAppSpacing.pagePadding),
          children: [
            Text(
              '输入网址，使用通用 WebView 在应用内打开网页。',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: SHOAppSpacing.lg),
            TextField(
              controller: _urlController,
              decoration: const InputDecoration(
                labelText: '网址 URL',
                hintText: 'https://example.com',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.url,
              textInputAction: TextInputAction.go,
              onSubmitted: (_) => _openWebView(),
            ),
            const SizedBox(height: SHOAppSpacing.md),
            FilledButton.icon(
              onPressed: () => _openWebView(),
              icon: const Icon(Icons.open_in_browser),
              label: const Text('打开网页'),
            ),
            const SizedBox(height: SHOAppSpacing.lg),
            Text(
              '快捷入口',
              style: Theme.of(context).textTheme.titleSmall,
            ),
            const SizedBox(height: SHOAppSpacing.sm),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                for (final preset in _presets)
                  ActionChip(
                    label: Text(preset.label),
                    onPressed: () {
                      _urlController.text = preset.url;
                      _openWebView(url: preset.url);
                    },
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _WebPreset {
  const _WebPreset(this.label, this.url);

  final String label;
  final String url;
}
