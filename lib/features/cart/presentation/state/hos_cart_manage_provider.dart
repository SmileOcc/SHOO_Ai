import 'package:flutter_riverpod/flutter_riverpod.dart';

/// 购物袋「管理」模式：由 Shell / Stack AppBar 与购物车页共享。
final cartManageModeProvider = StateProvider<bool>((ref) => false);
