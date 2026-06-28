import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:shoo/core/feedback/hos_toast.dart';
import 'package:shoo/core/pages/hos_pages.dart';
import 'package:shoo/core/theme/hos_spacing.dart';
import 'package:shoo/core/utils/hos_validators.dart';
import 'package:shoo/core/widgets/hos_button.dart';
import 'package:shoo/l10n/app_localizations.dart';
import 'package:shoo/features/address/domain/entities/hos_address.dart';
import 'package:shoo/features/address/presentation/state/hos_address_controller.dart';
import 'package:shoo/features/address/presentation/widgets/hos_address_text_field.dart';

final _addressFormCreateProvider = Provider<AsyncValue<SHOAddress?>>(
  (ref) => const AsyncData(null),
);

class SHOAddressFormPage extends SHODataPage<SHOAddress?> {
  const SHOAddressFormPage({super.key, this.addressId});

  final String? addressId;

  @override
  SHODataPageState<SHOAddress?, SHOAddressFormPage> createState() =>
      _SHOAddressFormPageState();
}

class _SHOAddressFormPageState
    extends SHODataPageState<SHOAddress?, SHOAddressFormPage> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameCtrl;
  late final TextEditingController _phoneCtrl;
  late final TextEditingController _line1Ctrl;
  late final TextEditingController _line2Ctrl;
  late final TextEditingController _cityCtrl;
  late final TextEditingController _regionCtrl;
  late final TextEditingController _postalCtrl;
  var _isDefault = false;
  var _saving = false;
  var _addressInitialized = false;

  bool get _isEditing => widget.addressId != null;

  @override
  ProviderListenable<AsyncValue<SHOAddress?>> get dataProvider {
    final id = widget.addressId;
    if (id == null) return _addressFormCreateProvider;
    return addressByIdProvider(id);
  }

  @override
  void invalidateData(WidgetRef ref) =>
      ref.read(addressesProvider.notifier).refresh();

  @override
  String get pageName => 'address_form';

  @override
  Map<String, Object?> get pageAnalyticsExtra => {
    if (widget.addressId != null) 'address_id': widget.addressId,
    'is_edit': _isEditing,
  };

  @override
  bool isEmptyData(SHOAddress? data) => _isEditing && data == null;

  @override
  void initState() {
    super.initState();
    _nameCtrl = TextEditingController();
    _phoneCtrl = TextEditingController();
    _line1Ctrl = TextEditingController();
    _line2Ctrl = TextEditingController();
    _cityCtrl = TextEditingController();
    _regionCtrl = TextEditingController();
    _postalCtrl = TextEditingController();
  }

  void _populateFromAddress(SHOAddress? address) {
    if (address == null || _addressInitialized) return;
    _addressInitialized = true;
    _nameCtrl.text = address.name;
    _phoneCtrl.text = address.phone;
    _line1Ctrl.text = address.line1;
    _line2Ctrl.text = address.line2;
    _cityCtrl.text = address.city;
    _regionCtrl.text = address.region;
    _postalCtrl.text = address.postalCode;
    _isDefault = address.isDefault;
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _phoneCtrl.dispose();
    _line1Ctrl.dispose();
    _line2Ctrl.dispose();
    _cityCtrl.dispose();
    _regionCtrl.dispose();
    _postalCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!SHOFormHelper.validateAndFocus(_formKey)) return;

    setState(() => _saving = true);
    try {
      final addresses =
          ref.read(addressesProvider).valueOrNull ?? const <SHOAddress>[];
      final id =
          widget.addressId ?? 'addr_${DateTime.now().millisecondsSinceEpoch}';
      final shouldDefault = _isDefault || addresses.isEmpty;

      final address = SHOAddress(
        id: id,
        name: _nameCtrl.text.trim(),
        phone: _phoneCtrl.text.trim(),
        line1: _line1Ctrl.text.trim(),
        line2: _line2Ctrl.text.trim(),
        city: _cityCtrl.text.trim(),
        region: _regionCtrl.text.trim(),
        postalCode: _postalCtrl.text.trim(),
        isDefault: shouldDefault,
      );

      await ref.read(addressesProvider.notifier).save(address);
      if (!mounted) return;
      SHOAppToast.success(AppLocalizations.of(context).addressSaved);
      context.pop();
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  PreferredSizeWidget? buildPageAppBar(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    return AppBar(
      title: Text(
        _isEditing ? l10n.addressFormEditTitle : l10n.addressFormAddTitle,
        style: const TextStyle(fontWeight: FontWeight.w800),
      ),
    );
  }

  @override
  Widget buildContent(
    BuildContext context,
    WidgetRef ref,
    SHOAddress? address,
  ) {
    if (_isEditing) {
      _populateFromAddress(address);
    }

    final l10n = AppLocalizations.of(context);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(SHOAppSpacing.pagePadding),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            SHOAddressTextField(
              label: l10n.addressNameLabel,
              controller: _nameCtrl,
              required: true,
              validator: SHOValidators.required(l10n),
            ),
            const SizedBox(height: SHOAppSpacing.lg),
            SHOAddressTextField(
              label: l10n.addressPhoneLabel,
              controller: _phoneCtrl,
              required: true,
              keyboardType: TextInputType.phone,
              validator: SHOValidators.compose([
                SHOValidators.required(l10n),
                SHOValidators.phone(l10n),
              ]),
            ),
            const SizedBox(height: SHOAppSpacing.lg),
            SHOAddressTextField(
              label: l10n.addressLine1Label,
              controller: _line1Ctrl,
              required: true,
              validator: SHOValidators.required(l10n),
            ),
            const SizedBox(height: SHOAppSpacing.lg),
            SHOAddressTextField(
              label: l10n.addressLine2Label,
              controller: _line2Ctrl,
            ),
            const SizedBox(height: SHOAppSpacing.lg),
            SHOAddressTextField(
              label: l10n.addressCityLabel,
              controller: _cityCtrl,
              required: true,
              validator: SHOValidators.required(l10n),
            ),
            const SizedBox(height: SHOAppSpacing.lg),
            SHOAddressTextField(
              label: l10n.addressRegionLabel,
              controller: _regionCtrl,
              required: true,
              validator: SHOValidators.required(l10n),
            ),
            const SizedBox(height: SHOAppSpacing.lg),
            SHOAddressTextField(
              label: l10n.addressPostalCodeLabel,
              controller: _postalCtrl,
            ),
            const SizedBox(height: SHOAppSpacing.lg),
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: Text(l10n.addressSetDefault),
              value: _isDefault,
              onChanged: (value) => setState(() => _isDefault = value),
            ),
            const SizedBox(height: SHOAppSpacing.xl),
            SHOAppButton(
              label: l10n.dialogConfirm,
              onPressed: _submit,
              isLoading: _saving,
              fullWidth: true,
            ),
          ],
        ),
      ),
    );
  }
}
