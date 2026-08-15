import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:shoo/core/deeplink/hos_deeplink_config.dart';
import 'package:shoo/core/deeplink/hos_deeplink_listener.dart';
import 'package:shoo/core/deeplink/hos_deeplink_resolver.dart';
import 'package:shoo/core/theme/hos_spacing.dart';

/// Debug：模拟系统 App Links / Custom Scheme 唤起。
class SHODebugDeepLinkPage extends ConsumerStatefulWidget {
  const SHODebugDeepLinkPage({super.key});

  @override
  ConsumerState<SHODebugDeepLinkPage> createState() =>
      _SHODebugDeepLinkPageState();
}

class _SHODebugDeepLinkPageState extends ConsumerState<SHODebugDeepLinkPage> {
  late final TextEditingController _customUriCtrl;

  @override
  void initState() {
    super.initState();
    _customUriCtrl = TextEditingController(
      text: SHODeepLinkConfig.productLink('c1-g1-l1-p1').toString(),
    );
  }

  @override
  void dispose() {
    _customUriCtrl.dispose();
    super.dispose();
  }

  void _simulateUri(String raw) {
    final trimmed = raw.trim();
    if (trimmed.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('请输入 Deep Link 或 App Link')),
      );
      return;
    }

    final Uri uri;
    if (trimmed.startsWith('http://') ||
        trimmed.startsWith('https://') ||
        trimmed.startsWith('${SHODeepLinkConfig.scheme}://')) {
      final parsed = Uri.tryParse(trimmed);
      if (parsed == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('无效链接: $trimmed')),
        );
        return;
      }
      uri = parsed;
    } else {
      final path = trimmed.startsWith('/') ? trimmed : '/$trimmed';
      uri = Uri(path: path);
    }

    final listener = ref.read(deepLinkListenerProvider);
    final kind = SHODeepLinkResolver.linkKindOf(uri);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('模拟 ${kind.name}: $trimmed')),
    );
    listener.handleUriForDebug(uri);
  }

  @override
  Widget build(BuildContext context) {
    final samples = <_Sample>[
      _Sample(
        'App Link · 商品详情',
        SHODeepLinkConfig.productLink('c1-g1-l1-p1').toString(),
      ),
      _Sample(
        'App Link · 商品列表',
        SHODeepLinkConfig.productListLink(
          leafId: 'c1-g1-l1',
          title: '调试商品列表',
        ).toString(),
      ),
      _Sample('App Link · 个人中心', SHODeepLinkConfig.profileLink().toString()),
      _Sample('App Link · 我的订单(需登录)', SHODeepLinkConfig.ordersLink().toString()),
      _Sample('Custom Scheme · 商品', 'shoo://product/c1-g1-l1-p2'),
      _Sample('Custom Scheme · open host', 'shoo://open/cart'),
      _Sample('In-App 路径', '/flash-sale'),
    ];

    return Scaffold(
      appBar: AppBar(title: const Text('Deep Link / App Links')),
      body: ListView(
        padding: const EdgeInsets.all(SHOAppSpacing.pagePadding),
        children: [
          Text(
            '模拟系统唤起 https://shoo.app（App Links）与 shoo://，统一走 '
            'SHODeepLinkListener → Resolver → Navigator。',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(height: SHOAppSpacing.sm),
          Text(
            '配置约定：${SHODeepLinkConfig.associatedDomains.join(', ')}\n'
            'iOS Associated Domains 暂未接入；Android Manifest 已声明 https App Links。',
            style: Theme.of(context).textTheme.bodySmall,
          ),
          const SizedBox(height: SHOAppSpacing.lg),
          TextField(
            controller: _customUriCtrl,
            decoration: const InputDecoration(
              labelText: '自定义 Deep Link / App Link',
              hintText: 'https://shoo.app/... 或 shoo://... 或 /path',
              border: OutlineInputBorder(),
              isDense: true,
            ),
            keyboardType: TextInputType.url,
            textInputAction: TextInputAction.go,
            onSubmitted: _simulateUri,
          ),
          const SizedBox(height: SHOAppSpacing.sm),
          Align(
            alignment: Alignment.centerRight,
            child: FilledButton.icon(
              onPressed: () => _simulateUri(_customUriCtrl.text),
              icon: const Icon(Icons.play_arrow),
              label: const Text('模拟唤起'),
            ),
          ),
          const SizedBox(height: SHOAppSpacing.lg),
          for (final sample in samples)
            Card(
              margin: const EdgeInsets.only(bottom: SHOAppSpacing.sm),
              child: ListTile(
                title: Text(sample.title),
                subtitle: Text(
                  sample.uri,
                  style: const TextStyle(fontSize: 12),
                ),
                trailing: const Icon(Icons.play_arrow),
                onTap: () {
                  _customUriCtrl.text = sample.uri;
                  _simulateUri(sample.uri);
                },
              ),
            ),
        ],
      ),
    );
  }
}

class _Sample {
  const _Sample(this.title, this.uri);
  final String title;
  final String uri;
}
