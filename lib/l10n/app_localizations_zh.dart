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
  String get cartLoginTitle => '请先登录';

  @override
  String get cartLoginSubtitle => '登录后即可查看和管理购物车商品';

  @override
  String get cartLoginAction => '去登录';

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
  String get settingsGroupGeneral => '通用';

  @override
  String get settingsGroupAccount => '账号';

  @override
  String get settingsGroupAbout => '关于';

  @override
  String get settingsAbout => '关于我们';

  @override
  String get settingsAboutDescription =>
      'SHOO 是一款面向年轻消费者的时尚电商应用，提供精选潮流商品、快捷结算与贴心售后服务。';

  @override
  String get settingsPrivacyPolicy => '隐私协议';

  @override
  String get settingsTermsOfService => '用户服务协议';

  @override
  String get settingsCompanyName => 'SHOO COMMERCE TECHNOLOGY PTE. LTD.';

  @override
  String get ordersAllShort => '全部';

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
    return '$appName v$version — Phase 3';
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
  String get shareProductCard => '分享商品卡片';

  @override
  String get shareLinkCopied => '链接已复制';

  @override
  String get imagePickerGallery => '相册';

  @override
  String get imagePickerCamera => '拍照';

  @override
  String imagePickerHint(int count) {
    return '最多 $count 张';
  }

  @override
  String get afterSaleEvidenceLabel => '上传凭证图片';

  @override
  String get reviewSubmitTitle => '发表评价';

  @override
  String get reviewSubmitContentLabel => '评价内容';

  @override
  String get reviewSubmitContentHint => '分享你对这件商品的使用感受';

  @override
  String get reviewSubmitPhotosLabel => '晒图';

  @override
  String get reviewSubmitAction => '提交评价';

  @override
  String get reviewSubmitContentRequired => '请填写评价内容';

  @override
  String reviewSubmitSuccess(int count) {
    return '评价已提交，含 $count 张图片';
  }

  @override
  String get logisticsLiveUpdates => '原生推送实时更新';

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
  String updateDownloadProgress(int percent) {
    return '正在下载更新... $percent%';
  }

  @override
  String get notFoundTitle => '页面不存在';

  @override
  String get notFoundMessage => '找不到你要访问的页面。';

  @override
  String notFoundLocation(String location) {
    return '未知路由：$location';
  }

  @override
  String get notFoundGoHome => '返回首页';

  @override
  String get dialogClose => '关闭';

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
  String get debugNativeEntry => '原生交互调试';

  @override
  String get debugNativeEntryHint =>
      '测试 MethodChannel / EventChannel / MessageChannel';

  @override
  String get debugNativeHubTitle => '原生交互调试';

  @override
  String get debugNativeHubHint => '点击示例调用原生代码并查看返回结果。';

  @override
  String get debugNativeCategoryMethod => 'MethodChannel — 单次调用';

  @override
  String get debugNativeCategoryMessage => 'BasicMessageChannel — 双向通信';

  @override
  String get debugNativeCategoryEvent => 'EventChannel — 持续事件流';

  @override
  String get debugNativeExamplePingTitle => 'Ping 连通性';

  @override
  String get debugNativeExamplePingDesc => '调用原生 `ping` 方法，验证 Channel 是否注册成功。';

  @override
  String get debugNativeExampleVersionTitle => '系统版本';

  @override
  String get debugNativeExampleVersionDesc => '从原生侧读取当前操作系统版本号。';

  @override
  String get debugNativeExampleMessageTitle => '消息回声';

  @override
  String get debugNativeExampleMessageDesc =>
      '通过 BasicMessageChannel 发送 Map，原生回传 echo。';

  @override
  String get debugNativeExampleEventTitle => 'Tick 事件流';

  @override
  String get debugNativeExampleEventDesc => '订阅 EventChannel，原生每秒推送一次 tick 事件。';

  @override
  String get debugNativeRun => '执行';

  @override
  String get debugNativeStartStream => '开始监听';

  @override
  String get debugNativeStopStream => '停止';

  @override
  String get debugNativeResult => '执行结果';

  @override
  String get debugNativeStreamLog => '事件日志';

  @override
  String get debugNativeWaiting => '执行中…';

  @override
  String get debugNativeNoResult => '点击「执行」调用原生代码';

  @override
  String get debugNativeStreamIdle => '点击「开始监听」订阅事件流';

  @override
  String get debugNativeInputHint => '消息内容';

  @override
  String get debugNativeCopy => '复制';

  @override
  String get debugNativeCopied => '已复制到剪贴板';

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
  String get searchHistoryTitle => '最近搜索';

  @override
  String get searchHistoryClear => '清空';

  @override
  String get searchHistoryCleared => '已清空搜索历史';

  @override
  String get searchNoResults => '没有找到相关商品';

  @override
  String get pagedListNoMore => '没有更多了';

  @override
  String reviewsCount(int count) {
    return '$count 条评价';
  }

  @override
  String cartIssuesUnavailable(int count) {
    return '$count 件商品已下架';
  }

  @override
  String cartIssuesPriceChanged(int count) {
    return '$count 件商品价格已更新';
  }

  @override
  String cartIssuesBoth(int unavailable, int changed) {
    return '$unavailable 件下架，$changed 件变价';
  }

  @override
  String get cartUnavailableBanner => '部分商品已失效，请移除后再结算';

  @override
  String get cartRemoveUnavailable => '移除失效商品';

  @override
  String get cartItemUnavailable => '已失效';

  @override
  String get cartItemPriceUpdated => '价格已更新';

  @override
  String get paymentPollingStatus => '正在确认支付状态...';

  @override
  String get productDetailTitle => '商品详情';

  @override
  String get productDescriptionTitle => '商品描述';

  @override
  String get productAddToBag => '加入购物袋';

  @override
  String get productBuyNow => '立即购买';

  @override
  String get productCustomerService => '客服';

  @override
  String get productCartShort => '购物车';

  @override
  String get productMore => '更多';

  @override
  String get productCustomerServiceHint => '客服功能即将上线（Mock）';

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
  String get ordersEmpty => '该分类下暂无订单';

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

  @override
  String get productAddToBagSuccess => '已加入购物袋';

  @override
  String get skuSelectSize => '选择尺码';

  @override
  String get skuSizeLabel => '尺码';

  @override
  String get skuQuantity => '数量';

  @override
  String get cartSelectAll => '全选';

  @override
  String get cartTotalLabel => '小计';

  @override
  String cartCheckout(int count) {
    return '结算 ($count)';
  }

  @override
  String get cartRemoveTitle => '移除商品？';

  @override
  String get cartRemoveMessage => '该商品将从购物袋中移除。';

  @override
  String get cartRemoveConfirm => '移除';

  @override
  String get checkoutTitle => '确认订单';

  @override
  String get checkoutAddressSection => '收货地址';

  @override
  String get checkoutAddAddress => '点击选择收货地址';

  @override
  String get checkoutNoAddress => '请选择收货地址';

  @override
  String get checkoutPlaceOrder => '提交订单';

  @override
  String get paymentTitle => '收银台';

  @override
  String get paymentMockTitle => '模拟支付';

  @override
  String get paymentMockHint => '此为模拟支付，不会产生真实扣款。';

  @override
  String get paymentPayNow => '立即支付';

  @override
  String get paymentSuccessTitle => '支付成功';

  @override
  String get paymentSuccessMessage => '订单已提交，感谢购物！';

  @override
  String get paymentViewOrder => '查看订单';

  @override
  String get paymentContinueShopping => '继续购物';

  @override
  String get addressListTitle => '收货地址';

  @override
  String get addressSelectTitle => '选择地址';

  @override
  String get profileAddresses => '收货地址';

  @override
  String get profileCoupons => '优惠券';

  @override
  String get profileAfterSales => '售后服务';

  @override
  String get checkoutCouponSection => '优惠券';

  @override
  String get couponSelectHint => '选择优惠券';

  @override
  String get couponListTitle => '我的优惠券';

  @override
  String get couponSelectTitle => '选择优惠券';

  @override
  String get couponNone => '不使用优惠券';

  @override
  String couponMinOrder(String amount) {
    return '满 $amount 可用';
  }

  @override
  String get couponNotEligible => '未满足使用门槛';

  @override
  String get priceSubtotal => '商品小计';

  @override
  String get priceDiscount => '优惠券抵扣';

  @override
  String get priceShipping => '运费';

  @override
  String get afterSaleListTitle => '售后服务';

  @override
  String get afterSaleApplyTitle => '申请售后';

  @override
  String get afterSaleApplyAction => '申请售后';

  @override
  String get afterSaleTypeLabel => '售后类型';

  @override
  String get afterSaleTypeRefund => '仅退款';

  @override
  String get afterSaleTypeReturnRefund => '退货退款';

  @override
  String get afterSaleReasonLabel => '申请原因';

  @override
  String get afterSaleReasonHint => '请描述问题...';

  @override
  String get afterSaleReasonRequired => '请填写申请原因';

  @override
  String get afterSaleSubmit => '提交申请';

  @override
  String get afterSaleSubmitSuccess => '售后申请已提交';

  @override
  String get afterSaleGoOrders => '查看订单';

  @override
  String get afterSaleStatusPending => '审核中';

  @override
  String get afterSaleStatusApproved => '已通过';

  @override
  String get afterSaleStatusRejected => '已拒绝';

  @override
  String get afterSaleStatusCompleted => '已完成';
}
