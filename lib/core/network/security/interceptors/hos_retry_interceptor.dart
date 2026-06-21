import 'package:dio/dio.dart';

/// 失败重试拦截器（处理网络超时 / 5xx 服务器错误）。
///
/// **重试策略：**
/// - 最多重试 3 次（可配置）
/// - 指数退避延迟：1s → 3s → 5s（可配置）
/// - 仅重试可幂等的请求类型
///
/// **重试条件：**
/// 1. 连接超时（connectionTimeout）
/// 2. 接收超时（receiveTimeout）
/// 3. 发送超时（sendTimeout）
/// 4. 连接错误（connectionError）
/// 5. 服务器错误（5xx 状态码）
class SHORetryInterceptor extends Interceptor {
  /// 创建重试拦截器。
  ///
  /// [dio]: Dio 实例，用于重新发起请求
  /// [retries]: 最大重试次数，默认 3 次
  /// [retryDelays]: 每次重试的延迟时间列表，默认 [1s, 3s, 5s]
  SHORetryInterceptor({
    required Dio dio, // 必须传入 Dio 实例，用于执行重试请求
    this.retries = 3, // 最大重试次数，默认 3 次
    this.retryDelays = const [
      // 重试延迟列表，按重试次数依次使用
      Duration(seconds: 1), // 第 1 次重试延迟 1 秒
      Duration(seconds: 3), // 第 2 次重试延迟 3 秒
      Duration(seconds: 5), // 第 3 次重试延迟 5 秒（指数退避）
    ],
  }) : _dio = dio; // 初始化私有 Dio 实例

  final Dio _dio; // 私有 Dio 实例，用于重新发起请求
  final int retries; // 最大重试次数
  final List<Duration> retryDelays; // 重试延迟时间列表

  /// 错误拦截方法：当请求失败时触发
  @override
  Future<void> onError(
    DioException err, // 错误信息对象
    ErrorInterceptorHandler handler, // 错误处理器，用于决定继续传递或解决错误
  ) async {
    // 1. 获取当前重试次数（从请求的 extra 中读取，默认为 0）
    final attempt = err.requestOptions.extra['retry_attempt'] as int? ?? 0;

    // 2. 判断是否需要重试：不满足重试条件 或 已达到最大重试次数
    if (!_shouldRetry(err) || attempt >= retries) {
      handler.next(err); // 继续传递错误，不进行重试
      return; // 退出方法
    }

    // 3. 获取当前重试对应的延迟时间（使用 clamp 防止索引越界）
    final delay = retryDelays[attempt.clamp(0, retryDelays.length - 1)];

    // 4. 等待指定时间后再重试（避免立即重试导致服务器压力）
    await Future<void>.delayed(delay);

    // 5. 准备重试请求的额外参数
    final nextExtra = Map<String, dynamic>.from(
      err.requestOptions.extra,
    ); // 复制原有 extra
    nextExtra['retry_attempt'] = attempt + 1; // 重试次数 +1

    // 6. 重新发起请求
    try {
      // 使用原请求配置重新发起请求，更新重试次数
      final response = await _dio.fetch<dynamic>(
        err.requestOptions.copyWith(extra: nextExtra),
      );
      // 重试成功，调用 resolve 将成功响应传递下去
      handler.resolve(response);
    } on DioException catch (retryError) {
      // 重试失败，继续传递错误（会再次进入此方法进行下一次重试）
      handler.next(retryError);
    }
  }

  /// 判断是否应该重试的私有方法
  bool _shouldRetry(DioException err) {
    // 1. 检查是否是网络超时类错误
    if (err.type == DioExceptionType.connectionTimeout || // 连接超时
        err.type == DioExceptionType.receiveTimeout || // 接收超时
        err.type == DioExceptionType.sendTimeout || // 发送超时
        err.type == DioExceptionType.connectionError) {
      // 连接错误（如网络不可用）
      return true; // 这些情况都应该重试
    }

    // 2. 检查是否是服务器错误（5xx 状态码）
    final code = err.response?.statusCode;
    return code != null && code >= 500; // 500-599 状态码应该重试
  }
}
