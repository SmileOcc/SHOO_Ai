import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path_provider/path_provider.dart';

import 'package:shoo/core/feedback/hos_toast.dart';
import 'package:shoo/core/media/hos_image_picker_service.dart';
import 'package:shoo/core/pages/hos_pages.dart';
import 'package:shoo/core/theme/hos_colors.dart';
import 'package:shoo/core/theme/hos_spacing.dart';
import 'package:shoo/core/theme/hos_theme_extension.dart';
import 'package:shoo/core/utils/hos_validators.dart';
import 'package:shoo/core/widgets/hos_button.dart';
import 'package:shoo/core/widgets/hos_user_avatar.dart';
import 'package:shoo/features/auth/presentation/state/hos_session_provider.dart';
import 'package:shoo/l10n/app_localizations.dart';

class SHOSettingsProfilePage extends ConsumerStatefulWidget {
  const SHOSettingsProfilePage({super.key});

  @override
  ConsumerState<SHOSettingsProfilePage> createState() =>
      _SHOSettingsProfilePageState();
}

class _SHOSettingsProfilePageState extends ConsumerState<SHOSettingsProfilePage>
    with SHOPageRouteAnalyticsMixin, SHOAppPageMixin, SHOAppTrackedPageMixin {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nicknameCtrl;
  var _saving = false;
  var _initialized = false;
  String? _localAvatarPath;

  @override
  String get pageName => 'settings_profile';

  @override
  void initState() {
    super.initState();
    _nicknameCtrl = TextEditingController();
  }

  @override
  void dispose() {
    _nicknameCtrl.dispose();
    super.dispose();
  }

  void _populateFromSession() {
    if (_initialized) return;
    final user = ref.read(sessionProvider).user;
    if (user == null) return;
    _initialized = true;
    _nicknameCtrl.text = user.nickname;
    _localAvatarPath = user.avatarUrl;
  }

  Future<String?> _persistAvatar(String sourcePath) async {
    final dir = await getApplicationDocumentsDirectory();
    final dest = File('${dir.path}/profile_avatar.jpg');
    await File(sourcePath).copy(dest.path);
    return dest.path;
  }

  Future<void> _pickAvatar() async {
    final l10n = AppLocalizations.of(context);
    final source = await showModalBottomSheet<ImageSourceChoice>(
      context: context,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.photo_library_outlined),
              title: Text(l10n.settingsProfilePickGallery),
              onTap: () => Navigator.pop(context, ImageSourceChoice.gallery),
            ),
            ListTile(
              leading: const Icon(Icons.photo_camera_outlined),
              title: Text(l10n.settingsProfilePickCamera),
              onTap: () => Navigator.pop(context, ImageSourceChoice.camera),
            ),
          ],
        ),
      ),
    );
    if (source == null || !mounted) return;

    final picker = ref.read(imagePickerServiceProvider);
    final file = switch (source) {
      ImageSourceChoice.gallery => await picker.pickFromGallery(),
      ImageSourceChoice.camera => await picker.pickFromCamera(),
    };
    if (file == null || !mounted) return;

    final savedPath = await _persistAvatar(file.path);
    if (!mounted || savedPath == null) return;
    setState(() => _localAvatarPath = savedPath);
  }

  Future<void> _submit() async {
    if (!SHOFormHelper.validateAndFocus(_formKey)) return;
    final user = ref.read(sessionProvider).user;
    if (user == null) return;

    setState(() => _saving = true);
    try {
      await ref.read(sessionProvider.notifier).updateProfile(
            user.copyWith(
              nickname: _nicknameCtrl.text.trim(),
              avatarUrl: _localAvatarPath,
            ),
          );
      if (!mounted) return;
      SHOAppToast.success(AppLocalizations.of(context).settingsProfileSaved);
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final session = ref.watch(sessionProvider);
    final user = session.user;

    if (!session.isAuthenticated || user == null) {
      return buildTrackedPage(
        Scaffold(
          appBar: AppBar(title: Text(l10n.settingsProfileTitle)),
          body: Center(child: Text(l10n.settingsProfileLoginRequired)),
        ),
      );
    }

    _populateFromSession();

    final initial =
        _nicknameCtrl.text.isNotEmpty ? _nicknameCtrl.text[0].toUpperCase() : '?';

    return buildTrackedPage(
      Scaffold(
        appBar: AppBar(title: Text(l10n.settingsProfileTitle)),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(SHOAppSpacing.pagePadding),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Center(
                  child: GestureDetector(
                    onTap: _pickAvatar,
                    child: Stack(
                      clipBehavior: Clip.none,
                      children: [
                        SHOUserAvatar(
                          avatarUrl: _localAvatarPath,
                          radius: 40,
                          backgroundColor: context.shoTheme.surfaceMuted,
                          foregroundColor: SHOAppColors.primary,
                          fallbackText: initial,
                        ),
                        Positioned(
                          right: -2,
                          bottom: -2,
                          child: DecoratedBox(
                            decoration: BoxDecoration(
                              color: SHOAppColors.primary,
                              shape: BoxShape.circle,
                              border: Border.all(color: Colors.white, width: 2),
                            ),
                            child: const Padding(
                              padding: EdgeInsets.all(4),
                              child: Icon(
                                Icons.camera_alt,
                                size: 16,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: SHOAppSpacing.sm),
                Center(
                  child: Text(
                    l10n.settingsProfileAvatarHint,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: context.shoTheme.textMuted,
                    ),
                  ),
                ),
                const SizedBox(height: SHOAppSpacing.xl),
                TextFormField(
                  controller: _nicknameCtrl,
                  decoration: InputDecoration(
                    labelText: l10n.settingsProfileNickname,
                    border: const OutlineInputBorder(),
                  ),
                  validator: SHOValidators.required(l10n),
                ),
                const SizedBox(height: SHOAppSpacing.lg),
                _ReadOnlyField(
                  label: l10n.loginPhoneHint,
                  value: user.phone ?? l10n.settingsProfileNotBound,
                ),
                const SizedBox(height: SHOAppSpacing.lg),
                _ReadOnlyField(
                  label: l10n.settingsProfileEmail,
                  value: user.email ?? l10n.settingsProfileNotBound,
                ),
                const SizedBox(height: SHOAppSpacing.xxxl),
                SHOAppButton(
                  label: l10n.dialogConfirm,
                  onPressed: _submit,
                  isLoading: _saving,
                  fullWidth: true,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

enum ImageSourceChoice { gallery, camera }

class _ReadOnlyField extends StatelessWidget {
  const _ReadOnlyField({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return InputDecorator(
      decoration: InputDecoration(
        labelText: label,
        border: const OutlineInputBorder(),
      ),
      child: Text(
        value,
        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
          color: context.shoTheme.textSecondary,
        ),
      ),
    );
  }
}
