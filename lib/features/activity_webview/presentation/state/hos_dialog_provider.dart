import 'package:flutter_riverpod/flutter_riverpod.dart';

final activityDialogProvider = StateProvider<String?>((ref) => null);

void showActivityDialog(WidgetRef ref, String kind) {
  ref.read(activityDialogProvider.notifier).state = kind;
}

void hideActivityDialog(WidgetRef ref) {
  ref.read(activityDialogProvider.notifier).state = null;
}
