import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shoo/core/config/hos_config.dart';
import 'package:shoo/core/errors/hos_error_mapper.dart';
import 'package:shoo/core/errors/hos_exception.dart';
import 'package:shoo/core/debug/modules/secure_network/hos_debug_fail_interceptor.dart';
import 'package:shoo/core/debug/modules/secure_network/hos_debug_network_lab_config.dart';
import 'package:shoo/core/debug/modules/secure_network/hos_debug_network_lab_provider.dart';
import 'package:shoo/core/network/hos_dio_client.dart';
import 'package:shoo/core/network/security/hos_encryption_policy.dart';
import 'package:shoo/core/network/security/hos_security_level.dart';
import 'package:shoo/core/pages/hos_pages.dart';
import 'package:shoo/core/theme/hos_spacing.dart';

/// 安全网络 / 加密调试页。
class SHODebugSecureNetworkPage extends ConsumerStatefulWidget {
  const SHODebugSecureNetworkPage({super.key});

  @override
  ConsumerState<SHODebugSecureNetworkPage> createState() =>
      _SHODebugSecureNetworkPageState();
}

class _SHODebugSecureNetworkPageState
    extends ConsumerState<SHODebugSecureNetworkPage>
    with SHOPageRouteAnalyticsMixin, SHOAppPageMixin, SHOAppTrackedPageMixin {
  @override
  String get pageName => 'debug_secure_network';

  final _getPathCtrl = TextEditingController(text: '/auth/profile');
  final _getQueryCtrl = TextEditingController(text: '');
  final _getHeadersCtrl = TextEditingController(text: '');
  final _postPathCtrl = TextEditingController(text: '/auth/login');
  final _postBodyCtrl = TextEditingController(
    text: '{"phone":"13800138000","password":"123456"}',
  );
  final _postHeadersCtrl = TextEditingController(text: '');
  final _encryptSampleCtrl = TextEditingController(
    text: '{"phone":"13800138000","password":"123456"}',
  );
  final _retryPathCtrl = TextEditingController(text: '/auth/profile');
  final _customPathCtrl = TextEditingController(text: '/auth/profile');
  final _customHeaderKeyCtrl = TextEditingController(text: 'X-Debug-Custom');
  final _customHeaderValueCtrl = TextEditingController(text: 'shoo-debug-lab');
  final _customDelayCtrl = TextEditingController(text: '200');

  final Map<String, String> _encryptResults = {};
  String? _getResult;
  String? _postResult;
  String? _retryResult;
  String? _customResult;
  String? _activeEncryptType;
  bool _getBusy = false;
  bool _postBusy = false;
  bool _retryBusy = false;
  bool _customBusy = false;
  int _retryFailCount = 2;
  bool _enableCustomInterceptor = false;
  bool _customInsertBeforeAuth = true;

  @override
  void dispose() {
    _getPathCtrl.dispose();
    _getQueryCtrl.dispose();
    _getHeadersCtrl.dispose();
    _postPathCtrl.dispose();
    _postBodyCtrl.dispose();
    _postHeadersCtrl.dispose();
    _encryptSampleCtrl.dispose();
    _retryPathCtrl.dispose();
    _customPathCtrl.dispose();
    _customHeaderKeyCtrl.dispose();
    _customHeaderValueCtrl.dispose();
    _customDelayCtrl.dispose();
    super.dispose();
  }

  Map<String, dynamic>? _parseJsonMap(String raw) {
    final trimmed = raw.trim();
    if (trimmed.isEmpty) return null;
    final decoded = jsonDecode(trimmed);
    if (decoded is! Map<String, dynamic>) {
      throw const FormatException('Expected JSON object');
    }
    return decoded;
  }

  Map<String, dynamic> _parseHeaders(String raw) {
    final trimmed = raw.trim();
    if (trimmed.isEmpty) return {};
    if (trimmed.startsWith('{')) {
      final map = _parseJsonMap(trimmed);
      return map?.map((k, v) => MapEntry(k, v.toString())) ?? {};
    }
    final headers = <String, dynamic>{};
    for (final line in trimmed.split('\n')) {
      final parts = line.split(':');
      if (parts.length >= 2) {
        headers[parts.first.trim()] = parts.sublist(1).join(':').trim();
      }
    }
    return headers;
  }

  Object _unwrapError(Object error) {
    if (error is DioException) {
      final inner = error.error;
      if (inner != null) return inner;
    }
    return error;
  }

  void _showErrorDialog(String title, Object error) {
    if (!mounted) return;
    final message = messageFromAny(_unwrapError(error));
    SchedulerBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      showDialog<void>(
        context: context,
        useRootNavigator: true,
        barrierDismissible: false,
        builder: (dialogContext) => AlertDialog(
          title: Text(title),
          content: SingleChildScrollView(child: Text(message)),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: const Text('确定'),
            ),
          ],
        ),
      );
    });
  }

  void _validateDebugEnvelope(dynamic data) {
    if (data is! Map<String, dynamic>) {
      throw const SHOServerException('Invalid response format');
    }
    final code = data['code'] as int? ?? -1;
    if (code != 0) {
      throw SHOServerException(
        data['message'] as String? ?? 'Request failed',
        code: code,
      );
    }
  }

  Future<void> _runEncrypt(String type) async {
    setState(() => _activeEncryptType = type);
    try {
      final crypto = ref.read(cryptoServiceProvider);
      final sample =
          _parseJsonMap(_encryptSampleCtrl.text) ??
          {'raw': _encryptSampleCtrl.text};
      final Map<String, dynamic> result;
      switch (type) {
        case 'rsa':
          result = await crypto.encryptRsa(sample);
        case 'aes':
          result = await crypto.encryptAes(sample);
        case 'hybrid':
          result = await crypto.encryptHybrid(sample);
        case 'sm4':
          result = await crypto.encryptSm4(sample);
        default:
          throw ArgumentError('Unknown encrypt type: $type');
      }
      setState(() {
        _encryptResults[type] = const JsonEncoder.withIndent(
          '  ',
        ).convert(result);
      });
    } catch (error) {
      _showErrorDialog('${type.toUpperCase()} 加密失败', error);
    } finally {
      if (mounted) setState(() => _activeEncryptType = null);
    }
  }

  Future<void> _runGetDebug() async {
    setState(() {
      _getBusy = true;
      _getResult = null;
    });
    try {
      final dio = ref.read(dioProvider);
      final path = _getPathCtrl.text.trim();
      if (path.isEmpty) {
        throw const SHOServerException('Path 不能为空');
      }
      final query = _parseJsonMap(_getQueryCtrl.text);
      final headers = _parseHeaders(_getHeadersCtrl.text);
      final response = await dio.get<dynamic>(
        path,
        queryParameters: query,
        options: Options(headers: headers.isEmpty ? null : headers),
      );
      _validateDebugEnvelope(response.data);
      setState(() {
        _getResult = const JsonEncoder.withIndent('  ').convert(response.data);
      });
    } catch (error) {
      _showErrorDialog('GET 请求异常', error);
    } finally {
      if (mounted) setState(() => _getBusy = false);
    }
  }

  Future<void> _runPostDebug() async {
    setState(() {
      _postBusy = true;
      _postResult = null;
    });
    try {
      final dio = ref.read(dioProvider);
      final path = _postPathCtrl.text.trim();
      if (path.isEmpty) {
        throw const SHOServerException('Path 不能为空');
      }
      final body = _parseJsonMap(_postBodyCtrl.text) ?? _postBodyCtrl.text;
      final headers = _parseHeaders(_postHeadersCtrl.text);
      final response = await dio.post<dynamic>(
        path,
        data: body,
        options: Options(headers: headers.isEmpty ? null : headers),
      );
      _validateDebugEnvelope(response.data);
      setState(() {
        _postResult = const JsonEncoder.withIndent('  ').convert(response.data);
      });
    } catch (error) {
      _showErrorDialog('POST 请求异常', error);
    } finally {
      if (mounted) setState(() => _postBusy = false);
    }
  }

  void _syncCustomInterceptorConfig() {
    ref.read(debugNetworkLabConfigProvider.notifier).state =
        SHODebugNetworkLabConfig(
      enableCustomInterceptor: _enableCustomInterceptor,
      customHeaderKey: _customHeaderKeyCtrl.text.trim(),
      customHeaderValue: _customHeaderValueCtrl.text.trim(),
      customDelayMs: int.tryParse(_customDelayCtrl.text.trim()) ?? 0,
      customInsertBeforeAuth: _customInsertBeforeAuth,
    );
  }

  Future<void> _runRetryDebug() async {
    setState(() {
      _retryBusy = true;
      _retryResult = null;
    });
    ref.read(debugNetworkLabLogProvider.notifier).clear();
    ref.read(debugNetworkLabLogProvider.notifier).add(
          '开始重试调试：先模拟 $_retryFailCount 次 503，再期望成功',
        );

    final stopwatch = Stopwatch()..start();
    try {
      final dio = ref.read(debugNetworkLabDioProvider);
      final path = _retryPathCtrl.text.trim();
      if (path.isEmpty) {
        throw const SHOServerException('Path 不能为空');
      }

      final response = await dio.get<dynamic>(
        path,
        options: Options(
          extra: {
            SHODebugFailInterceptor.failUntilSuccessExtraKey: _retryFailCount,
          },
        ),
      );
      _validateDebugEnvelope(response.data);
      final attempt = response.requestOptions.extra['retry_attempt'] as int? ?? 0;
      stopwatch.stop();
      ref.read(debugNetworkLabLogProvider.notifier).add(
            '重试成功：retry_attempt=$attempt，耗时 ${stopwatch.elapsedMilliseconds}ms',
          );
      setState(() {
        _retryResult =
            '重试成功\n'
            'retry_attempt: $attempt\n'
            '耗时: ${stopwatch.elapsedMilliseconds}ms\n\n'
            '${const JsonEncoder.withIndent('  ').convert(response.data)}';
      });
    } catch (error) {
      stopwatch.stop();
      ref.read(debugNetworkLabLogProvider.notifier).add(
            '重试失败：${messageFromAny(_unwrapError(error))}',
          );
      _showErrorDialog('重试调试最终失败', error);
    } finally {
      if (mounted) setState(() => _retryBusy = false);
    }
  }

  Future<void> _runCustomInterceptorDebug() async {
    setState(() {
      _customBusy = true;
      _customResult = null;
    });
    _syncCustomInterceptorConfig();
    ref.read(debugNetworkLabLogProvider.notifier).clear();
    ref.read(debugNetworkLabLogProvider.notifier).add(
          '自定义拦截器已${_enableCustomInterceptor ? "启用" : "禁用"}',
        );

    try {
      final dio = ref.refresh(debugNetworkLabDioProvider);
      final path = _customPathCtrl.text.trim();
      if (path.isEmpty) {
        throw const SHOServerException('Path 不能为空');
      }

      final response = await dio.get<dynamic>(path);
      _validateDebugEnvelope(response.data);
      final hasCustomFlag =
          response.requestOptions.extra['debug_custom_interceptor'] == true;
      setState(() {
        _customResult =
            '请求完成\n'
            'custom_interceptor_applied: $hasCustomFlag\n'
            'insert: ${_customInsertBeforeAuth ? "prepend" : "append"}\n\n'
            '${const JsonEncoder.withIndent('  ').convert(response.data)}';
      });
    } catch (error) {
      _showErrorDialog('自定义拦截器调试失败', error);
    } finally {
      if (mounted) setState(() => _customBusy = false);
    }
  }

  Widget _labLogPanel(List<String> logs) {
    if (logs.isEmpty) return const SizedBox.shrink();
    return _SHODebugJsonResult(
      title: '实验室日志',
      content: logs.join('\n'),
    );
  }

  Widget _encryptButton({
    required String type,
    required String label,
    required IconData icon,
  }) {
    final busy = _activeEncryptType == type;
    return FilledButton.tonalIcon(
      onPressed: _activeEncryptType != null ? null : () => _runEncrypt(type),
      icon: busy
          ? const SizedBox(
              width: 16,
              height: 16,
              child: CircularProgressIndicator(strokeWidth: 2),
            )
          : Icon(icon),
      label: Text(label),
    );
  }

  @override
  Widget build(BuildContext context) {
    final config = ref.watch(appConfigProvider);
    final labLogs = ref.watch(debugNetworkLabLogProvider);

    return buildTrackedPage(
      Scaffold(
      appBar: AppBar(title: const Text('安全网络 / 加密调试')),
      body: ListView(
        padding: const EdgeInsets.all(SHOAppSpacing.xl),
        children: [
          Text(
            '当前安全等级：${config.securityLevel.label}',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: SHOAppSpacing.xs),
          Text(
            'Mock 模式 ${config.useMockApi ? "已跳过载荷加密" : "已启用加密拦截器"}\n'
            'RSA 路径：${SHOEncryptionPolicy.rsaPaths.join(", ")} + POST /orders\n'
            '登录/注册/下单在 API 层显式 RSA 加密',
            style: Theme.of(context).textTheme.bodySmall,
          ),
          const Divider(height: SHOAppSpacing.xxxl),
          Text('加密调试', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: SHOAppSpacing.sm),
          TextField(
            controller: _encryptSampleCtrl,
            decoration: const InputDecoration(
              labelText: '样例 JSON 载荷',
              border: OutlineInputBorder(),
            ),
            maxLines: 4,
          ),
          const SizedBox(height: SHOAppSpacing.md),
          Wrap(
            spacing: SHOAppSpacing.sm,
            runSpacing: SHOAppSpacing.sm,
            children: [
              _encryptButton(type: 'rsa', label: 'RSA 加密', icon: Icons.vpn_key),
              _encryptButton(
                type: 'aes',
                label: 'AES 加密',
                icon: Icons.lock_outline,
              ),
              _encryptButton(
                type: 'hybrid',
                label: 'Hybrid 加密',
                icon: Icons.merge_type,
              ),
              _encryptButton(type: 'sm4', label: 'SM4 加密', icon: Icons.shield),
            ],
          ),
          for (final entry in _encryptResults.entries)
            _SHODebugJsonResult(
              key: ValueKey('encrypt-${entry.key}'),
              title: '${entry.key.toUpperCase()} 结果',
              content: entry.value,
            ),
          const Divider(height: SHOAppSpacing.xxxl),
          Text('AES 通用 GET 调试', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: SHOAppSpacing.sm),
          TextField(
            controller: _getPathCtrl,
            decoration: const InputDecoration(
              labelText: 'Path',
              border: OutlineInputBorder(),
              hintText: '错误测试可填 /not-found',
            ),
          ),
          const SizedBox(height: SHOAppSpacing.sm),
          TextField(
            controller: _getQueryCtrl,
            decoration: const InputDecoration(
              labelText: 'Query JSON（可选）',
              border: OutlineInputBorder(),
            ),
            maxLines: 2,
          ),
          const SizedBox(height: SHOAppSpacing.sm),
          TextField(
            controller: _getHeadersCtrl,
            decoration: const InputDecoration(
              labelText: 'Headers（JSON 或 Key: Value 每行）',
              border: OutlineInputBorder(),
            ),
            maxLines: 3,
          ),
          const SizedBox(height: SHOAppSpacing.md),
          FilledButton.icon(
            onPressed: _getBusy ? null : _runGetDebug,
            icon: _getBusy
                ? const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.download_outlined),
            label: const Text('发送 GET（失败弹窗提示）'),
          ),
          if (_getResult != null)
            _SHODebugJsonResult(title: 'GET 响应', content: _getResult!),
          const Divider(height: SHOAppSpacing.xxxl),
          Text(
            'AES 通用 POST 调试',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: SHOAppSpacing.sm),
          TextField(
            controller: _postPathCtrl,
            decoration: const InputDecoration(
              labelText: 'Path',
              border: OutlineInputBorder(),
              hintText: '登录 RSA：/auth/login；错误测试：/not-found',
            ),
          ),
          const SizedBox(height: SHOAppSpacing.sm),
          TextField(
            controller: _postBodyCtrl,
            decoration: const InputDecoration(
              labelText: 'Body JSON',
              border: OutlineInputBorder(),
            ),
            maxLines: 4,
          ),
          const SizedBox(height: SHOAppSpacing.sm),
          TextField(
            controller: _postHeadersCtrl,
            decoration: const InputDecoration(
              labelText: 'Headers（JSON 或 Key: Value 每行）',
              border: OutlineInputBorder(),
            ),
            maxLines: 3,
          ),
          const SizedBox(height: SHOAppSpacing.md),
          FilledButton.icon(
            onPressed: _postBusy ? null : _runPostDebug,
            icon: _postBusy
                ? const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.upload_outlined),
            label: const Text('发送 POST（失败弹窗提示）'),
          ),
          if (_postResult != null)
            _SHODebugJsonResult(title: 'POST 响应', content: _postResult!),
          const Divider(height: SHOAppSpacing.xxxl),
          Text('接口错误重试调试', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: SHOAppSpacing.xs),
          Text(
            '通过 SHODebugFailInterceptor 模拟 503，验证 SHORetryInterceptor '
            '（默认最多 3 次，延迟 1s/3s/5s）',
            style: Theme.of(context).textTheme.bodySmall,
          ),
          const SizedBox(height: SHOAppSpacing.sm),
          TextField(
            controller: _retryPathCtrl,
            decoration: const InputDecoration(
              labelText: 'Path',
              border: OutlineInputBorder(),
              hintText: '/auth/profile',
            ),
          ),
          const SizedBox(height: SHOAppSpacing.sm),
          Row(
            children: [
              Expanded(
                child: Text('模拟失败次数: $_retryFailCount'),
              ),
              Expanded(
                flex: 2,
                child: Slider(
                  value: _retryFailCount.toDouble(),
                  min: 1,
                  max: 3,
                  divisions: 2,
                  label: '$_retryFailCount',
                  onChanged: _retryBusy
                      ? null
                      : (v) => setState(() => _retryFailCount = v.round()),
                ),
              ),
            ],
          ),
          FilledButton.icon(
            onPressed: _retryBusy ? null : _runRetryDebug,
            icon: _retryBusy
                ? const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.replay_outlined),
            label: const Text('发送请求（模拟失败后重试）'),
          ),
          if (_retryResult != null)
            _SHODebugJsonResult(title: '重试结果', content: _retryResult!),
          const Divider(height: SHOAppSpacing.xxxl),
          Text('自定义拦截器调试', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: SHOAppSpacing.xs),
          Text(
            '配置 SHODebugCustomInterceptor：注入 Header、延迟、记录 onRequest/onResponse',
            style: Theme.of(context).textTheme.bodySmall,
          ),
          const SizedBox(height: SHOAppSpacing.sm),
          SwitchListTile(
            contentPadding: EdgeInsets.zero,
            title: const Text('启用自定义拦截器'),
            value: _enableCustomInterceptor,
            onChanged: _customBusy
                ? null
                : (v) => setState(() => _enableCustomInterceptor = v),
          ),
          SwitchListTile(
            contentPadding: EdgeInsets.zero,
            title: const Text('插入在 Auth 之前（prepend）'),
            subtitle: const Text('关闭则 append 到拦截器链末尾'),
            value: _customInsertBeforeAuth,
            onChanged: _customBusy
                ? null
                : (v) => setState(() => _customInsertBeforeAuth = v),
          ),
          TextField(
            controller: _customHeaderKeyCtrl,
            decoration: const InputDecoration(
              labelText: '注入 Header Key',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: SHOAppSpacing.sm),
          TextField(
            controller: _customHeaderValueCtrl,
            decoration: const InputDecoration(
              labelText: '注入 Header Value',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: SHOAppSpacing.sm),
          TextField(
            controller: _customDelayCtrl,
            decoration: const InputDecoration(
              labelText: 'onRequest 延迟 (ms)',
              border: OutlineInputBorder(),
            ),
            keyboardType: TextInputType.number,
          ),
          const SizedBox(height: SHOAppSpacing.sm),
          TextField(
            controller: _customPathCtrl,
            decoration: const InputDecoration(
              labelText: 'Path',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: SHOAppSpacing.md),
          FilledButton.icon(
            onPressed: _customBusy ? null : _runCustomInterceptorDebug,
            icon: _customBusy
                ? const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.filter_alt_outlined),
            label: const Text('发送请求（验证自定义拦截器）'),
          ),
          if (_customResult != null)
            _SHODebugJsonResult(title: '自定义拦截器响应', content: _customResult!),
          _labLogPanel(labLogs),
        ],
      ),
    ),
    );
  }
}

/// 调试结果展示（避免 SelectableText 在 macOS 触发 SystemContextMenu 断言）。
class _SHODebugJsonResult extends StatelessWidget {
  const _SHODebugJsonResult({
    super.key,
    required this.title,
    required this.content,
  });

  final String title;
  final String content;

  Future<void> _copy(BuildContext context) async {
    await Clipboard.setData(ClipboardData(text: content));
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('已复制到剪贴板')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final mono = Theme.of(context).textTheme.bodySmall?.copyWith(
          fontFamily: 'monospace',
          fontSize: 12,
        );

    return Padding(
      padding: const EdgeInsets.only(top: SHOAppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(title, style: Theme.of(context).textTheme.titleSmall),
              ),
              IconButton(
                icon: const Icon(Icons.copy_outlined, size: 20),
                tooltip: '复制',
                onPressed: () => _copy(context),
              ),
            ],
          ),
          const SizedBox(height: SHOAppSpacing.xs),
          Material(
            color: Theme.of(context).colorScheme.surfaceContainerHighest,
            borderRadius: BorderRadius.circular(8),
            child: Padding(
              padding: const EdgeInsets.all(SHOAppSpacing.md),
              child: Text(content, style: mono),
            ),
          ),
        ],
      ),
    );
  }
}
