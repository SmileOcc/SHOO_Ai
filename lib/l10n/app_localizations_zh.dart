// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Chinese (`zh`).
class AppLocalizationsZh extends AppLocalizations {
  AppLocalizationsZh([String locale = 'zh']) : super(locale);

  @override
  String get appName => 'SHOO';

  @override
  String get tabShop => '首页';

  @override
  String get tabCategory => '分类';

  @override
  String get tabBag => '购物袋';

  @override
  String get tabMe => '我的';

  @override
  String get searchHint => '搜索款式、潮流...';

  @override
  String get recommendedTitle => '为你推荐';

  @override
  String get cartEmptyTitle => '购物袋是空的';

  @override
  String get cartEmptySubtitle => '快去挑选心仪的商品吧。';

  @override
  String get cartEmptyAction => '去逛逛';

  @override
  String get profileSignIn => '登录 / 注册';

  @override
  String get profileSignInHint => '登录享专属优惠与快捷结算';

  @override
  String get profileOrders => '订单';

  @override
  String get profileServices => '服务';

  @override
  String get profileSettings => '设置';

  @override
  String get settingsTitle => '设置';

  @override
  String get settingsTheme => '主题';

  @override
  String get settingsThemeSystem => '跟随系统';

  @override
  String get settingsThemeLight => '浅色';

  @override
  String get settingsThemeDark => '深色';

  @override
  String get settingsLanguage => '语言';

  @override
  String get settingsLanguageEn => 'English';

  @override
  String get settingsLanguageZh => '中文';

  @override
  String get loginTitle => '登录';

  @override
  String get loginPhoneHint => '手机号';

  @override
  String get loginPasswordHint => '密码';

  @override
  String get loginSubmit => '登录';

  @override
  String get loginMockHint => 'Mock 登录 — 任意手机号/密码均可';

  @override
  String get loading => '加载中...';

  @override
  String get retry => '重试';

  @override
  String get noData => '暂无数据';

  @override
  String get loadFailed => '加载失败，请重试';

  @override
  String get logout => '退出登录';

  @override
  String welcomeUser(String name) {
    return '你好，$name';
  }

  @override
  String versionLabel(String appName, String version) {
    return '$appName v$version — Phase 2';
  }

  @override
  String get validationRequired => '此项不能为空';

  @override
  String get validationPhone => '请输入有效的手机号';

  @override
  String get validationEmail => '请输入有效的邮箱';

  @override
  String validationMinLength(int length) {
    return '至少 $length 个字符';
  }

  @override
  String get offlineBanner => '当前无网络，部分功能可能不可用';

  @override
  String get splashTagline => '时尚，触手可及';

  @override
  String get onboardingTitle1 => '潮流精选';

  @override
  String get onboardingDesc1 => '发现为你推荐的最新款式。';

  @override
  String get onboardingTitle2 => '快速配送';

  @override
  String get onboardingDesc2 => '实时追踪订单，享受快捷物流。';

  @override
  String get onboardingTitle3 => '专属优惠';

  @override
  String get onboardingDesc3 => '优惠券与限时抢购，省钱更轻松。';

  @override
  String get onboardingSkip => '跳过';

  @override
  String get onboardingNext => '下一步';

  @override
  String get onboardingStart => '开始购物';

  @override
  String get registerTitle => '注册账号';

  @override
  String get registerConfirmPassword => '确认密码';

  @override
  String get registerSubmit => '注册';

  @override
  String get loginNoAccount => '没有账号？去注册';

  @override
  String get registerHasAccount => '已有账号？去登录';

  @override
  String get registerPasswordMismatch => '两次密码不一致';

  @override
  String get registerMockHint => 'Mock 注册 — 创建本地会话';

  @override
  String get messageTitle => '消息中心';

  @override
  String get messageEmpty => '暂无消息';

  @override
  String get profileMessages => '消息中心';

  @override
  String get profileShareDemo => '分享演示';

  @override
  String get profileCameraPermission => '相机权限';

  @override
  String get debugPanelTitle => '调试面板';

  @override
  String get debugPanelHint => '在顶部导航栏区域快速连点 5 次可进入，正式包已关闭。';

  @override
  String get debugEnvSection => '运行环境';

  @override
  String get debugResetEnv => '恢复构建默认环境';

  @override
  String get debugClearCache => '清除本地缓存';

  @override
  String get debugCacheCleared => '缓存已清除';

  @override
  String get sharePanelTitle => '分享';

  @override
  String get shareSystem => '系统分享';

  @override
  String get shareCopyLink => '复制链接';

  @override
  String get shareWechat => '微信';

  @override
  String get shareWechatMock => '微信分享（Mock）';

  @override
  String get shareMore => '更多';

  @override
  String get updateTitle => '发现新版本';

  @override
  String updateNewVersion(String version) {
    return '新版本 $version 可用';
  }

  @override
  String get updateLater => '稍后';

  @override
  String get updateNow => '立即更新';

  @override
  String get debugToolsSection => '调试工具';

  @override
  String get debugUpdateEntry => '版本更新调试';

  @override
  String get debugUpdateEntryHint => '配置版本号、升级说明、是否强更';

  @override
  String get debugActivityEntry => '活动广告调试';

  @override
  String get debugActivityEntryHint => '配置延时、排期、预拉取、每日次数';

  @override
  String get debugUpdateTitle => '版本更新调试';

  @override
  String get debugActivityTitle => '活动广告调试';

  @override
  String get debugOverrideEnabled => '启用调试覆盖';

  @override
  String get debugOverrideHint => '请先开启覆盖再预览';

  @override
  String get debugUpdateOverrideHint => '关闭时首页走正常 API 版本校验';

  @override
  String get debugActivityOverrideHint => '关闭时首页走正常 API 活动拉取';

  @override
  String get debugFlowNormal => '当前：正常 API 校验流程';

  @override
  String get debugFlowOverride => '当前：调试配置已生效';

  @override
  String get debugOverrideActiveNow => '已开启调试覆盖，首页将使用此配置';

  @override
  String get debugOverrideInactiveNow => '已关闭调试覆盖，首页走正常校验流程';

  @override
  String get debugUpdateVersion => '最新版本号';

  @override
  String get debugUpdateNotes => '升级描述信息';

  @override
  String get debugUpdateForce => '强制更新';

  @override
  String get debugUpdateUrl => '更新链接';

  @override
  String get debugActivityDelay => '弹窗延时（秒）';

  @override
  String get debugActivityPopupTitle => '活动标题';

  @override
  String get debugActivityDescription => '活动描述详情';

  @override
  String get debugActivityDescScrollHint => '弹窗内超过 5 行可滚动';

  @override
  String get debugActivityImageUrl => '活动图片链接';

  @override
  String get debugActivityId => '活动 ID';

  @override
  String get debugActivityLink => '跳转链接';

  @override
  String get debugActivityButton => '按钮文案';

  @override
  String get debugActivityStartAt => '活动开始时间';

  @override
  String get debugActivityEndAt => '活动结束时间';

  @override
  String get debugActivityDateUnset => '未设置 — 始终可展示';

  @override
  String get debugActivityPrefetch => '提前获取活动配置';

  @override
  String get debugActivityPrefetchHint => '提前下载图片并缓存活动信息到本地';

  @override
  String get debugActivityMaxDaily => '每日最多展示次数';

  @override
  String get debugSaveConfig => '保存配置';

  @override
  String get debugPreviewPopup => '预览弹窗';

  @override
  String get debugPreviewNoUpdate => '当前流程下无可用更新';

  @override
  String get debugPreviewNoActivity => '当前流程下无可用活动';

  @override
  String get debugConfigSaved => '调试配置已保存';

  @override
  String get searchHotTitle => '热门搜索';

  @override
  String get productDetailTitle => '商品详情';

  @override
  String get productDescriptionTitle => '商品描述';

  @override
  String get productAddToBag => '加入购物袋';

  @override
  String get productAddToBagHint => '已加入购物袋（Mock）';

  @override
  String get reviewsTitle => '评价';

  @override
  String get reviewsViewAll => '查看全部';

  @override
  String get reviewsEmpty => '暂无评价';

  @override
  String get ordersTitle => '我的订单';

  @override
  String get ordersAll => '全部订单';

  @override
  String get ordersPendingPayment => '待付款';

  @override
  String get ordersShipped => '待收货';

  @override
  String get ordersReviews => '待评价';

  @override
  String orderMoreItems(int count) {
    return '等 $count 件';
  }

  @override
  String get orderDetailTitle => '订单详情';

  @override
  String get orderNoLabel => '订单编号';

  @override
  String get orderStatusLabel => '订单状态';

  @override
  String get orderCreatedAtLabel => '下单时间';

  @override
  String get orderShippingAddress => '收货地址';

  @override
  String get orderItemsTitle => '商品清单';

  @override
  String get orderTotalLabel => '合计';

  @override
  String get orderStatusPendingPayment => '待付款';

  @override
  String get orderStatusPaid => '已付款';

  @override
  String get orderStatusShipped => '运输中';

  @override
  String get orderStatusDelivered => '已签收';

  @override
  String get orderStatusCancelled => '已取消';

  @override
  String get logisticsTitle => '物流追踪';

  @override
  String get logisticsCarrierLabel => '承运商';

  @override
  String get logisticsTrackingNoLabel => '运单号';

  @override
  String get logisticsTimelineTitle => '物流轨迹';

  @override
  String get logisticsTrackAction => '查看物流';

  @override
  String get logisticsCopied => '运单号已复制';
}
