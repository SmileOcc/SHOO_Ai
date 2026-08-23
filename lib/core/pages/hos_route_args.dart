import 'package:go_router/go_router.dart';

import 'package:shoo/core/navigation/hos_payment_flow_navigation.dart';
import 'package:shoo/core/platform/webview/hos_webview_config.dart';
import 'package:shoo/features/flash_sale/domain/hos_flash_sale_activities.dart';

/// 路由参数解析失败。
class SHORouteArgsException implements Exception {
  SHORouteArgsException(this.message);

  final String message;

  factory SHORouteArgsException.missing(String name) =>
      SHORouteArgsException('Missing route parameter: $name');

  @override
  String toString() => 'SHORouteArgsException: $message';
}

/// 路由参数解析标记接口。
abstract interface class SHORouteArgs {
  const SHORouteArgs();
}

/// `?select=1` 选择器模式。
class SHOSelectRouteArgs implements SHORouteArgs {
  const SHOSelectRouteArgs({this.selectMode = false});

  final bool selectMode;

  factory SHOSelectRouteArgs.fromState(GoRouterState state) {
    return SHOSelectRouteArgs(
      selectMode: state.uri.queryParameters['select'] == '1',
    );
  }
}

/// 路径参数 ID，例如 `/product/:id`。
class SHOPathIdRouteArgs implements SHORouteArgs {
  const SHOPathIdRouteArgs({required this.id});

  final String id;

  factory SHOPathIdRouteArgs.fromState(
    GoRouterState state, {
    String key = 'id',
  }) {
    final id = state.pathParameters[key];
    if (id == null || id.isEmpty) {
      throw SHORouteArgsException.missing(key);
    }
    return SHOPathIdRouteArgs(id: id);
  }
}

/// Query 参数 ID，例如 `/addresses/form?id=xxx`。
class SHOQueryIdRouteArgs implements SHORouteArgs {
  const SHOQueryIdRouteArgs({this.id});

  final String? id;

  bool get isEdit => id != null && id!.isNotEmpty;

  factory SHOQueryIdRouteArgs.fromState(
    GoRouterState state, {
    String key = 'id',
  }) {
    final raw = state.uri.queryParameters[key];
    if (raw == null || raw.isEmpty) {
      return const SHOQueryIdRouteArgs();
    }
    return SHOQueryIdRouteArgs(id: raw);
  }
}

/// `/theme-activity/:activityId` 主题活动参数。
class SHOThemeActivityRouteArgs implements SHORouteArgs {
  const SHOThemeActivityRouteArgs({
    required this.activityId,
    this.channel,
  });

  final String activityId;
  final String? channel;

  factory SHOThemeActivityRouteArgs.fromState(GoRouterState state) {
    return SHOThemeActivityRouteArgs(
      activityId: SHOPathIdRouteArgs.fromState(
        state,
        key: 'activityId',
      ).id,
      channel: state.uri.queryParameters['channel'],
    );
  }
}

/// `/flash-sale?activityId=` 活动页参数。
class SHOFlashSaleRouteArgs implements SHORouteArgs {
  const SHOFlashSaleRouteArgs({required this.activityId});

  final String activityId;

  factory SHOFlashSaleRouteArgs.fromState(GoRouterState state) {
    return SHOFlashSaleRouteArgs(
      activityId:
          state.uri.queryParameters['activityId'] ??
          SHOFlashSaleActivities.defaults,
    );
  }
}

/// `/product/:id?sessionId=` 商品详情参数。
class SHOProductRouteArgs implements SHORouteArgs {
  const SHOProductRouteArgs({required this.productId, this.sessionId});

  final String productId;
  final String? sessionId;

  factory SHOProductRouteArgs.fromState(GoRouterState state) {
    return SHOProductRouteArgs(
      productId: SHOPathIdRouteArgs.fromState(state).id,
      sessionId: state.queryParam('sessionId'),
    );
  }
}

/// `/orders?status=` 订单列表筛选。
class SHOOrderListRouteArgs implements SHORouteArgs {
  const SHOOrderListRouteArgs({this.status});

  final String? status;

  factory SHOOrderListRouteArgs.fromState(GoRouterState state) {
    return SHOOrderListRouteArgs(status: state.queryParam('status'));
  }
}

/// `/orders/:id` 订单详情；[extra] 标记支付成功栈内进入。
class SHOOrderDetailRouteArgs implements SHORouteArgs {
  const SHOOrderDetailRouteArgs({
    required this.orderId,
    this.skipPaymentFlowOnPop = false,
  });

  final String orderId;
  final bool skipPaymentFlowOnPop;

  factory SHOOrderDetailRouteArgs.fromState(GoRouterState state) {
    return SHOOrderDetailRouteArgs(
      orderId: SHOPathIdRouteArgs.fromState(state).id,
      skipPaymentFlowOnPop: isOrderDetailFromPaymentSuccess(state.extra),
    );
  }
}

/// `/search?q=` 搜索初始词。
class SHOSearchRouteArgs implements SHORouteArgs {
  const SHOSearchRouteArgs({this.query});

  final String? query;

  factory SHOSearchRouteArgs.fromState(GoRouterState state) {
    return SHOSearchRouteArgs(query: state.queryParam('q'));
  }
}

/// `/payment/:orderId?fromCartStack=1` 收银台参数。
class SHOPaymentRouteArgs implements SHORouteArgs {
  const SHOPaymentRouteArgs({
    required this.orderId,
    this.fromCartStack = false,
  });

  final String orderId;
  final bool fromCartStack;

  factory SHOPaymentRouteArgs.fromState(GoRouterState state) {
    return SHOPaymentRouteArgs(
      orderId: SHOPathIdRouteArgs.fromState(state, key: 'orderId').id,
      fromCartStack: state.queryFlag('fromCartStack'),
    );
  }
}

/// `/login?redirect=` 登录后回跳。
class SHOAuthRouteArgs implements SHORouteArgs {
  const SHOAuthRouteArgs({this.redirectTo});

  final String? redirectTo;

  factory SHOAuthRouteArgs.fromState(GoRouterState state) {
    return SHOAuthRouteArgs(redirectTo: state.queryParam('redirect'));
  }
}

/// `/category/products?leafId=&title=` 类目商品列表。
class SHOCategoryProductsRouteArgs implements SHORouteArgs {
  const SHOCategoryProductsRouteArgs({
    required this.leafCategoryId,
    required this.title,
  });

  final String leafCategoryId;
  final String title;

  factory SHOCategoryProductsRouteArgs.fromState(GoRouterState state) {
    return SHOCategoryProductsRouteArgs(
      leafCategoryId: state.queryString('leafId'),
      title: state.queryString('title'),
    );
  }
}

/// 个人中心音乐库 `?fromDownload=1`。
class SHOMusicLibraryRouteArgs implements SHORouteArgs {
  const SHOMusicLibraryRouteArgs({this.fromDownload = false});

  final bool fromDownload;

  factory SHOMusicLibraryRouteArgs.fromState(GoRouterState state) {
    return SHOMusicLibraryRouteArgs(
      fromDownload: state.queryFlag('fromDownload'),
    );
  }
}

/// Study 文章 `?slug=`。
class SHOStudyArticleRouteArgs implements SHORouteArgs {
  const SHOStudyArticleRouteArgs({required this.articleId});

  final String articleId;

  factory SHOStudyArticleRouteArgs.fromState(GoRouterState state) {
    return SHOStudyArticleRouteArgs(articleId: state.queryString('slug'));
  }
}

/// 工具箱 TXT 阅读器 `?taskId=`。
class SHOToolboxReaderRouteArgs implements SHORouteArgs {
  const SHOToolboxReaderRouteArgs({required this.taskId});

  final String taskId;

  factory SHOToolboxReaderRouteArgs.fromState(GoRouterState state) {
    return SHOToolboxReaderRouteArgs(taskId: state.queryString('taskId'));
  }
}

/// 工具箱视频播放 `?entryId=&taskId=`。
class SHOToolboxVideoRouteArgs implements SHORouteArgs {
  const SHOToolboxVideoRouteArgs({required this.entryId, required this.taskId});

  final String entryId;
  final String taskId;

  factory SHOToolboxVideoRouteArgs.fromState(GoRouterState state) {
    return SHOToolboxVideoRouteArgs(
      entryId: state.queryString('entryId'),
      taskId: state.queryString('taskId'),
    );
  }
}

/// 工具箱音乐播放 `?trackId=&index=&fromDownloadPack=1`。
class SHOMusicPlayerRouteArgs implements SHORouteArgs {
  const SHOMusicPlayerRouteArgs({
    required this.trackId,
    this.startIndex = 0,
    this.fromDownloadPack = false,
  });

  final String trackId;
  final int startIndex;
  final bool fromDownloadPack;

  factory SHOMusicPlayerRouteArgs.fromState(GoRouterState state) {
    return SHOMusicPlayerRouteArgs(
      trackId: state.queryString('trackId'),
      startIndex: state.queryInt('index'),
      fromDownloadPack: state.queryFlag('fromDownloadPack'),
    );
  }
}

/// 活动图片预览 `?index=`。
class SHOImagePreviewRouteArgs implements SHORouteArgs {
  const SHOImagePreviewRouteArgs({this.initialIndex = 0});

  final int initialIndex;

  factory SHOImagePreviewRouteArgs.fromState(GoRouterState state) {
    return SHOImagePreviewRouteArgs(initialIndex: state.queryInt('index'));
  }
}

/// 活动 H5 跳转 `?url=`（可选 [title]）。
class SHOActivityUrlRouteArgs implements SHORouteArgs {
  const SHOActivityUrlRouteArgs({this.url, this.title});

  final String? url;
  final String? title;

  factory SHOActivityUrlRouteArgs.fromState(GoRouterState state) {
    return SHOActivityUrlRouteArgs(
      url: state.queryParam('url'),
      title: state.queryParam('title'),
    );
  }

  String decodedUrl({String defaultValue = ''}) {
    final raw = url;
    if (raw == null || raw.isEmpty) return defaultValue;
    return Uri.decodeComponent(raw);
  }
}

/// `/webview?url=&title=` 通用 WebView 参数。
class SHOWebViewRouteArgs implements SHORouteArgs {
  const SHOWebViewRouteArgs({required this.config});

  final SHOWebViewConfig config;

  factory SHOWebViewRouteArgs.fromState(GoRouterState state) {
    return SHOWebViewRouteArgs(
      config: SHOWebViewConfig.fromQueryParameters(state.uri.queryParameters),
    );
  }
}

/// [GoRouterState] 快捷解析扩展。
extension SHORouteStateArgs on GoRouterState {
  SHOSelectRouteArgs get selectArgs => SHOSelectRouteArgs.fromState(this);

  SHOPathIdRouteArgs pathIdArgs({String key = 'id'}) =>
      SHOPathIdRouteArgs.fromState(this, key: key);

  SHOQueryIdRouteArgs queryIdArgs({String key = 'id'}) =>
      SHOQueryIdRouteArgs.fromState(this, key: key);

  SHOProductRouteArgs get productArgs => SHOProductRouteArgs.fromState(this);

  SHOOrderListRouteArgs get orderListArgs =>
      SHOOrderListRouteArgs.fromState(this);

  SHOOrderDetailRouteArgs get orderDetailArgs =>
      SHOOrderDetailRouteArgs.fromState(this);

  SHOSearchRouteArgs get searchArgs => SHOSearchRouteArgs.fromState(this);

  SHOPaymentRouteArgs get paymentArgs => SHOPaymentRouteArgs.fromState(this);

  SHOAuthRouteArgs get authArgs => SHOAuthRouteArgs.fromState(this);

  SHOCategoryProductsRouteArgs get categoryProductsArgs =>
      SHOCategoryProductsRouteArgs.fromState(this);

  SHOMusicLibraryRouteArgs get musicLibraryArgs =>
      SHOMusicLibraryRouteArgs.fromState(this);

  SHOStudyArticleRouteArgs get studyArticleArgs =>
      SHOStudyArticleRouteArgs.fromState(this);

  SHOToolboxReaderRouteArgs get toolboxReaderArgs =>
      SHOToolboxReaderRouteArgs.fromState(this);

  SHOToolboxVideoRouteArgs get toolboxVideoArgs =>
      SHOToolboxVideoRouteArgs.fromState(this);

  SHOMusicPlayerRouteArgs get musicPlayerArgs =>
      SHOMusicPlayerRouteArgs.fromState(this);

  SHOImagePreviewRouteArgs get imagePreviewArgs =>
      SHOImagePreviewRouteArgs.fromState(this);

  SHOActivityUrlRouteArgs get activityUrlArgs =>
      SHOActivityUrlRouteArgs.fromState(this);

  SHOFlashSaleRouteArgs get flashSaleArgs =>
      SHOFlashSaleRouteArgs.fromState(this);

  SHOThemeActivityRouteArgs get themeActivityArgs =>
      SHOThemeActivityRouteArgs.fromState(this);

  SHOWebViewRouteArgs get webViewArgs => SHOWebViewRouteArgs.fromState(this);

  String requirePathParam(String key) {
    final value = pathParameters[key];
    if (value == null || value.isEmpty) {
      throw SHORouteArgsException.missing(key);
    }
    return value;
  }

  String? queryParam(String key) {
    final value = uri.queryParameters[key];
    if (value == null || value.isEmpty) return null;
    return value;
  }

  bool queryFlag(String key) => uri.queryParameters[key] == '1';

  String queryString(String key, {String defaultValue = ''}) =>
      uri.queryParameters[key] ?? defaultValue;

  int queryInt(String key, {int defaultValue = 0}) =>
      int.tryParse(uri.queryParameters[key] ?? '') ?? defaultValue;
}
