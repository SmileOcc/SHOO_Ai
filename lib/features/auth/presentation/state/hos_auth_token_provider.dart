import 'package:flutter_riverpod/flutter_riverpod.dart';

/// 与 [sessionProvider] 解耦的 Token 持有者，供 Dio 拦截器读取，避免循环依赖。
final authTokenProvider = StateProvider<String?>((ref) => null);
