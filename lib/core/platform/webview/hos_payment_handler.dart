import 'package:url_launcher/url_launcher.dart';

enum SHOPaymentResult {
  launched,
  failed,
}

class SHOPaymentHandler {
  SHOPaymentHandler._();

  static Future<SHOPaymentResult> openPaymentUrl(String url) async {
    final uri = Uri.tryParse(url);
    if (uri == null) return SHOPaymentResult.failed;

    if (uri.scheme == 'weixin' || uri.scheme == 'alipays' || uri.scheme == 'alipay') {
      if (await canLaunchUrl(uri)) {
        final ok = await launchUrl(uri, mode: LaunchMode.externalApplication);
        return ok ? SHOPaymentResult.launched : SHOPaymentResult.failed;
      }
    }

    if (await canLaunchUrl(uri)) {
      final ok = await launchUrl(uri, mode: LaunchMode.externalApplication);
      return ok ? SHOPaymentResult.launched : SHOPaymentResult.failed;
    }
    return SHOPaymentResult.failed;
  }
}
