import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:shoo/core/pages/hos_pages.dart';
import 'package:shoo/core/theme/hos_spacing.dart';
import 'package:shoo/l10n/app_localizations.dart';
import 'package:shoo/features/message/domain/entities/hos_message.dart';
import 'package:shoo/features/message/presentation/state/hos_message_controller.dart';

class SHOMessagePage extends SHODataPage<List<SHOAppMessage>> {
  const SHOMessagePage({super.key});

  @override
  SHODataPageState<List<SHOAppMessage>, SHOMessagePage> createState() =>
      _SHOMessagePageState();
}

class _SHOMessagePageState
    extends SHODataPageState<List<SHOAppMessage>, SHOMessagePage> {
  @override
  ProviderListenable<AsyncValue<List<SHOAppMessage>>> get dataProvider =>
      messagesProvider;

  @override
  void invalidateData(WidgetRef ref) => ref.invalidate(messagesProvider);

  @override
  String get pageName => 'message';

  @override
  bool isEmptyData(List<SHOAppMessage> data) => data.isEmpty;

  @override
  PreferredSizeWidget? buildPageAppBar(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    return AppBar(title: Text(l10n.messageTitle));
  }

  @override
  Widget buildContent(
    BuildContext context,
    WidgetRef ref,
    List<SHOAppMessage> messages,
  ) {
    final l10n = AppLocalizations.of(context);
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
          subtitle: Text(
            msg.body,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          trailing: Text(
            msg.type,
            style: Theme.of(context).textTheme.bodySmall,
          ),
        );
      },
    );
  }
}
