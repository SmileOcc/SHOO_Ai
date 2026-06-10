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
  String get categorySortAll => '全部';

  @override
  String get categorySortHot => '热门';

  @override
  String get categorySortNewest => '最新';

  @override
  String get categoryFilter => '筛选';

  @override
  String get categoryFilterPriceRange => '价格区间';

  @override
  String get categoryFilterMinPrice => '最低价';

  @override
  String get categoryFilterMaxPrice => '最高价';

  @override
  String get categoryFilterPriceInvalid => '最高价必须大于最低价';

  @override
  String get categoryFilterSort => '排序';

  @override
  String get categoryFilterSortDefault => '默认排序';

  @override
  String get categoryFilterSortPriceHigh => '价格从高到低';

  @override
  String get categoryFilterSortPriceLow => '价格从低到高';

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
  String get localServerBanner =>
      '本地 Mock Server 未启动，请在终端执行：cd server && npm run dev';

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
  String get debugEnvRestarting => '正在切换环境并重启应用…';

  @override
  String get debugShowEnvBadge => '显示环境角标';

  @override
  String get debugShowEnvBadgeHint => '在应用窗口右上角显示当前环境（9号红字）';

  @override
  String envBadgeLabel(String env) {
    return '环境：$env';
  }

  @override
  String get dialogCancel => '取消';

  @override
  String get dialogConfirm => '确认';

  @override
  String get settingsGroupDiagnostics => '诊断与数据';

  @override
  String get settingsReportLogs => '上报日志';

  @override
  String get settingsReportLogsHint => '将本地缓存的日志通过系统分享导出';

  @override
  String get settingsReportLogsEmpty => '暂无可上报的日志';

  @override
  String get settingsReportLogsConfirmTitle => '上报日志';

  @override
  String get settingsReportLogsConfirmMessage => '将通过系统分享导出本地日志文件，是否继续？';

  @override
  String get settingsReportLogsSuccess => '已打开分享面板';

  @override
  String get settingsClearCache => '清除缓存';

  @override
  String get settingsClearCacheHint => '按类别查看并清理本地缓存';

  @override
  String get settingsCacheTitle => '清除缓存';

  @override
  String get settingsCacheTotal => '缓存总大小';

  @override
  String get settingsCacheLogs => '应用日志';

  @override
  String get settingsCacheLogsHint => '本地缓存的运行日志';

  @override
  String get settingsCacheImages => '图片缓存';

  @override
  String get settingsCacheImagesHint => '网络图片磁盘缓存';

  @override
  String get settingsCacheSearch => '搜索历史';

  @override
  String get settingsCacheSearchHint => '最近搜索关键词';

  @override
  String get settingsCacheCart => '购物车快照';

  @override
  String get settingsCacheCartHint => '本地购物车数据';

  @override
  String get settingsCacheActivity => '活动预拉取';

  @override
  String get settingsCacheActivityHint => '营销活动配置与图片';

  @override
  String get settingsCachePreferences => '其他偏好';

  @override
  String get settingsCachePreferencesHint => '除主题与语言外的本地偏好';

  @override
  String get settingsCacheClearTitle => '清除缓存';

  @override
  String settingsCacheClearMessage(String name) {
    return '确定清除「$name」？';
  }

  @override
  String get settingsCacheClearConfirm => '清除';

  @override
  String get settingsCacheClearAll => '清除全部缓存';

  @override
  String get settingsCacheClearAllTitle => '清除全部缓存';

  @override
  String get settingsCacheClearAllMessage => '将清除所有类别的本地缓存，此操作不可撤销。';

  @override
  String get settingsCacheCleared => '缓存已清除';

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
  String get debugNetworkLogEntry => '日志调试';

  @override
  String get debugNetworkLogEntryHint => '配置请求/响应参数打印与接口筛选';

  @override
  String get debugNetworkLogTitle => '网络日志调试';

  @override
  String get debugNetworkLogHint => '配置后即时生效，日志输出到控制台并写入本地日志缓存（DEBUG 级别）。';

  @override
  String get debugNetworkLogEnabled => '启用网络日志';

  @override
  String get debugNetworkLogEnabledHint => '关闭后不再打印任何接口日志';

  @override
  String get debugNetworkLogRequest => '打印请求参数';

  @override
  String get debugNetworkLogRequestHint => '包含 query 与 body';

  @override
  String get debugNetworkLogResponse => '打印返回参数';

  @override
  String get debugNetworkLogResponseHint => '包含响应 data 内容';

  @override
  String get debugNetworkLogMockRemote => 'Mock 远程上报';

  @override
  String get debugNetworkLogMockRemoteHint => '开启后业务埋点与网络日志仅本地模拟，不请求 server';

  @override
  String get debugNetworkLogRemoteHint =>
      '关闭 Mock 时上报至本地 server（127.0.0.1:3847）；业务走内置 Mock 时自动改打本地 server。Android 模拟器请在启动参数设置 API_BASE_URL=http://10.0.2.2:3847/api/v1';

  @override
  String get debugNetworkLogFilterEnabled => '仅打印指定接口';

  @override
  String get debugNetworkLogFilterEnabledHint => '开启后只打印路径包含下列关键词的接口';

  @override
  String get debugNetworkLogFilterPaths => '接口路径关键词';

  @override
  String get debugNetworkLogFilterPathsHint =>
      '每行一个或逗号分隔，如：/products, /banners';

  @override
  String get debugAnalyticsEntry => '业务上报';

  @override
  String get debugAnalyticsEntryHint => '查看上报 key、字段定义，预览各上报通道';

  @override
  String get debugAnalyticsTabEvents => '事件';

  @override
  String get debugAnalyticsTabBackends => '通道';

  @override
  String get debugAnalyticsTabHistory => '历史';

  @override
  String get debugAnalyticsEventKey => '上报 key';

  @override
  String get debugAnalyticsFields => '上报字段';

  @override
  String get debugAnalyticsFire => '试发';

  @override
  String debugAnalyticsFired(String key) {
    return '已试发：$key';
  }

  @override
  String get debugAnalyticsBackendsHint => '已注册上报通道，可通过 registerBackend 扩展';

  @override
  String get debugAnalyticsBackendOn => '启用';

  @override
  String get debugAnalyticsBackendOff => '关闭';

  @override
  String get debugAnalyticsMockRemoteQueue => 'Mock 远程队列';

  @override
  String get debugAnalyticsHistoryEmpty => '暂无上报记录';

  @override
  String get debugAnalyticsClearHistory => '清空历史';

  @override
  String get debugAnalyticsBackendsUsed => '通道';

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
  String get productDetailLoading => '正在加载商品，请稍候...';

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
  String get ordersToUse => '待使用';

  @override
  String get ordersAfterSalesShort => '退换/售后';

  @override
  String get profileFootprints => '足迹';

  @override
  String get profileFavorites => '收藏';

  @override
  String get profileFollowing => '关注';

  @override
  String get profileDiscover => '种草';

  @override
  String get profileDiscoverBadge => '发现';

  @override
  String get profileFootprintsHint => '足迹功能即将上线';

  @override
  String get profileFootprintsEmpty => '还没有浏览记录';

  @override
  String get profileActivityDelete => '删除';

  @override
  String get profileActivitySelectAll => '全选';

  @override
  String profileActivitySelected(int count) {
    return '已选 $count 件';
  }

  @override
  String profileActivityDeleteSelected(int count) {
    return '删除 ($count)';
  }

  @override
  String profileActivityDeleted(int count) {
    return '已删除 $count 件';
  }

  @override
  String get profileFollowingHint => '关注功能即将上线';

  @override
  String get profileCouponCenter => '领券中心';

  @override
  String get profileCouponMore => '更多';

  @override
  String get profileCouponClaim => '去领取';

  @override
  String get profileTabGuessYouLike => '猜你喜欢';

  @override
  String get profileTabMyFavorites => '我的收藏';

  @override
  String get profileTabMyReviews => '我的评价';

  @override
  String get profileServiceNovelReading => '小说阅读';

  @override
  String get profileServiceToolbox => '百宝箱';

  @override
  String get profileServiceCoupons => '领券';

  @override
  String get profileServiceAfterSale => '售后';

  @override
  String get profileServiceShare => '分享';

  @override
  String get profileServiceMessages => '消息';

  @override
  String get profileServiceSearch => '搜索';

  @override
  String get profileFavoritesEmpty => '还没有收藏商品';

  @override
  String get profileFavoriteAdded => '已加入收藏';

  @override
  String get profileFavoriteRemoved => '已取消收藏';

  @override
  String get profileReviewsHint => '查看待评价订单，分享你的购物体验';

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
  String get addressEmpty => '暂无收货地址';

  @override
  String get addressDefaultTag => '默认';

  @override
  String get addressAddNew => '新增地址';

  @override
  String get addressDelete => '删除';

  @override
  String get addressDeleteConfirmTitle => '删除地址';

  @override
  String get addressDeleteConfirmMessage => '确定要删除该收货地址吗？';

  @override
  String get addressFormAddTitle => '新增地址';

  @override
  String get addressFormEditTitle => '编辑地址';

  @override
  String get addressNameLabel => '收货人';

  @override
  String get addressPhoneLabel => '手机号';

  @override
  String get addressLine1Label => '详细地址';

  @override
  String get addressLine2Label => '门牌号 / 楼层（选填）';

  @override
  String get addressCityLabel => '城市';

  @override
  String get addressRegionLabel => '省 / 州';

  @override
  String get addressPostalCodeLabel => '邮编（选填）';

  @override
  String get addressSetDefault => '设为默认地址';

  @override
  String get addressSaved => '地址已保存';

  @override
  String get toolboxTitle => '百宝箱';

  @override
  String get toolboxGroupReading => '阅读';

  @override
  String get toolboxGroupTools => '常用工具';

  @override
  String get toolboxBookshelf => '我的书架';

  @override
  String get toolboxFileDownload => '文件下载';

  @override
  String get toolboxComingSoon => '敬请期待';

  @override
  String get downloadListTitle => '下载列表';

  @override
  String get downloadTabAll => '全部';

  @override
  String get downloadTabDownloading => '下载中';

  @override
  String get downloadTabPaused => '已暂停';

  @override
  String get downloadTabCompleted => '已完成';

  @override
  String get downloadAddTask => '新增任务';

  @override
  String get downloadEmpty => '暂无下载任务';

  @override
  String get downloadTaskDialogTitle => '新增下载任务';

  @override
  String get downloadUrlLabel => '下载地址';

  @override
  String get downloadFileNameLabel => '文件名称';

  @override
  String get downloadFileNameHint => '可选，不填则从链接自动识别';

  @override
  String get downloadPriorityLabel => '优先下载';

  @override
  String get downloadConfirmStart => '确认下载';

  @override
  String get downloadStatusDownloading => '下载中';

  @override
  String get downloadStatusPaused => '已暂停';

  @override
  String get downloadStatusCompleted => '已完成';

  @override
  String get downloadActionDelete => '删除';

  @override
  String get downloadActionPause => '暂停';

  @override
  String get downloadActionStart => '开始';

  @override
  String get downloadDeleteConfirmTitle => '删除下载任务';

  @override
  String get downloadDeleteConfirmMessage => '确定要删除该下载任务吗？本地已下载内容也会一并删除。';

  @override
  String get downloadTypeDoc => '文档';

  @override
  String get downloadTypePdf => 'PDF';

  @override
  String get downloadTypeExcel => '表格';

  @override
  String get downloadTypeZip => '压缩包';

  @override
  String get downloadTypeVideo => '视频';

  @override
  String get downloadTypeOther => '文件';

  @override
  String get downloadActionCopyUrl => '复制 URL';

  @override
  String get downloadUrlCopied => '下载地址已复制';

  @override
  String get downloadPreviewUnsupported => '该类型文件不支持查看';

  @override
  String get downloadPreviewNotCompleted => '文件未下载完成，请完成下载后可查看';

  @override
  String get downloadPreviewFailed => '无法打开该文件，请稍后重试';

  @override
  String get downloadPreviewOk => '知道了';

  @override
  String get txtReaderLoadingFile => '正在读取文件…';

  @override
  String get txtReaderParsingChapters => '正在解析章节…';

  @override
  String get txtReaderPaginating => '正在排版页面…';

  @override
  String get txtReaderChapters => '目录';

  @override
  String get txtReaderFontSize => '字体大小';

  @override
  String txtReaderPageProgress(int current, int total) {
    return '$current / $total';
  }

  @override
  String txtReaderChapterPageProgress(int current, int total) {
    return '第 $current / $total 页';
  }

  @override
  String get txtReaderLoadFailed => '文件加载失败，请稍后重试';

  @override
  String get txtReaderRetry => '重试';

  @override
  String get txtReaderRemoveBookshelf => '移出书架';

  @override
  String get txtReaderRemovedBookshelf => '已从书架移除';

  @override
  String get txtReaderTaskMissing => '找不到该下载任务，可能已被删除';

  @override
  String get txtReaderFontColor => '字体颜色';

  @override
  String get txtReaderDarkMode => '暗黑模式';

  @override
  String get txtReaderAddBookshelf => '加入书架';

  @override
  String get txtReaderAddedBookshelf => '已加入书架';

  @override
  String get txtReaderPrevChapter => '上一章';

  @override
  String get txtReaderNextChapter => '下一章';

  @override
  String get txtReaderNight => '夜间';

  @override
  String get txtReaderSettingsLabel => '设置';

  @override
  String get txtReaderShare => '分享';

  @override
  String get txtReaderBackground => '背景';

  @override
  String get bookshelfTitle => '我的书架';

  @override
  String get bookshelfEmpty => '书架还是空的，在阅读器里加入书架后会显示在这里';

  @override
  String get bookshelfUnread => '尚未开始阅读';

  @override
  String bookshelfReadingProgress(int chapter) {
    return '已读至第 $chapter 章';
  }

  @override
  String get bookshelfNotCompleted => '文件尚未下载完成';

  @override
  String get bookshelfFileMissing => '本地文件已删除';

  @override
  String get bookshelfUnknownTitle => '未知小说';

  @override
  String get bookshelfRemoveAction => '移出书架';

  @override
  String get bookshelfRemoveConfirmTitle => '移出书架';

  @override
  String get bookshelfRemoveConfirmMessage => '确定要将这本小说从书架移除吗？阅读进度会保留。';

  @override
  String get bookshelfCleanupOrphansTitle => '清理无效条目';

  @override
  String bookshelfCleanupOrphansMessage(int count) {
    return '有 $count 本小说对应的下载任务已不存在';
  }

  @override
  String get bookshelfCleanupOrphansAction => '全部清理';

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
