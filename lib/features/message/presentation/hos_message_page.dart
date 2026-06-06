import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/hos_spacing.dart';
import '../../../core/utils/hos_async_value_ui.dart';
import '../../../core/widgets/hos_error_view.dart';
import '../../../l10n/app_localizations.dart';
import 'hos_message_controller.dart';

class SHOMessagePage extends ConsumerWidget {
  const SHOMessagePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final messagesAsync = ref.watch(messagesProvider);

    return Scaffold(
      appBar: AppBar(title: Text(l10n.messageTitle)),
      body: messagesAsync.whenWidget(
        data: (messages) {
          if (messages.isEmpty) {
            return Center(child: Text(l10n.messageEmpty));
          }
          return ListView.separated(
            padding: const EdgeInsets.all(SHOAppSpacing.pagePadding),
            itemCount: messages.length,
            separatorBuilder: (_, __) => const Divider(height: 1),
            itemBuilder: (context, index) {
              final msg = messages[index];
              return ListTile(
                contentPadding: EdgeInsets.zero,
                leading: Icon(
                  msg.isRead ? Icons.mail_outline : Icons.mark_email_unread,
                ),
                title: Text(msg.title, style: const TextStyle(fontSize: 13)),
                subtitle: Text(msg.body, maxLines: 2, overflow: TextOverflow.ellipsis),
                trailing: Text(msg.type, style: Theme.of(context).textTheme.bodySmall),
              );
            },
          );
        },
        error: (e, _) => SHOAppErrorView(
          message: e.toString(),
          onRetry: () => ref.invalidate(messagesProvider),
        ),
      ),
    );
  }
}
