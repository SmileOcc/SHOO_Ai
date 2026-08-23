import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shoo/core/platform/webview/hos_webview_config.dart';
import 'package:shoo/core/widgets/hos_network_image.dart';
import 'package:shoo/features/activity_webview/presentation/widgets/webview/hos_generic_webview_container.dart';
import 'package:shoo/features/theme_activity/presentation/navigation/hos_theme_activity_link_handler.dart';
import 'package:shoo/features/theme_activity/presentation/style/hos_module_style.dart';

class SHOThemeWebModule extends ConsumerWidget {
  const SHOThemeWebModule({
    super.key,
    required this.raw,
    required this.style,
  });

  final Map<String, dynamic> raw;
  final Map<String, dynamic> style;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final url = raw['url'] as String? ?? '';
    if (url.isEmpty) return const SizedBox.shrink();

    final aspectRatio = raw['aspectRatio'];
    final fixedHeight = raw['height'];
    final bridgeEnabled = raw['bridgeEnabled'] as bool? ?? false;
    final fallbackImage = raw['fallbackImage'] as String?;

    double? height;
    if (fixedHeight is num) {
      height = fixedHeight.toDouble();
    } else if (aspectRatio is num) {
      final width = MediaQuery.sizeOf(context).width;
      height = width / aspectRatio.toDouble();
    } else {
      height = 240;
    }

    final config = SHOWebViewConfig(
      url: url,
      mode: SHOWebViewMode.inApp,
      bridgeMode: bridgeEnabled
          ? SHOWebViewBridgeMode.activity
          : SHOWebViewBridgeMode.standard,
      pullToRefresh: false,
      showAppBar: false,
    );

    return SizedBox(
      height: height,
      child: Stack(
        fit: StackFit.expand,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(
              themeNumber(style['borderRadius'], fallback: 0),
            ),
            child: SHOGenericWebViewContainer(config: config),
          ),
          if (fallbackImage != null && fallbackImage.isNotEmpty)
            Positioned.fill(
              child: IgnorePointer(
                child: Opacity(
                  opacity: 0,
                  child: SHOAppNetworkImage(url: fallbackImage),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class SHOThemeMenuModule extends StatelessWidget {
  const SHOThemeMenuModule({
    super.key,
    required this.child,
    required this.raw,
    required this.style,
  });

  final Widget child;
  final Map<String, dynamic> raw;
  final Map<String, dynamic> style;

  @override
  Widget build(BuildContext context) {
    final showTitleBar = raw['showTitleBar'] as bool? ?? false;
    if (!showTitleBar) return child;

    final titleBar = raw['titleBar'];
    if (titleBar is! Map<String, dynamic>) return child;

    final title = titleBar['title'] as String? ?? '';
    final moreText = titleBar['moreText'] as String?;
    final moreLink = titleBar['moreLink'] as String?;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(12, 8, 12, 4),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  title,
                  style: moduleTextStyle(
                    style,
                    colorKey: 'titleColor',
                    defaultWeight: FontWeight.w700,
                  ),
                ),
              ),
              if (moreText != null && moreText.isNotEmpty)
                TextButton(
                  onPressed: moreLink == null || moreLink.isEmpty
                      ? null
                      : () => SHOThemeActivityLinkHandler.open(
                          context,
                          moreLink,
                          moduleId: raw['moduleId'] as String?,
                        ),
                  child: Text(moreText),
                ),
            ],
          ),
        ),
        child,
      ],
    );
  }
}
