import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shoo/core/utils/hos_validators.dart';
import 'package:shoo/l10n/app_localizations.dart';

void main() {
  late AppLocalizations l10n;

  setUpAll(() async {
    l10n = await AppLocalizations.delegate.load(const Locale('en'));
  });

  test('required validator rejects empty', () {
    final validator = SHOValidators.required(l10n);
    expect(validator(''), isNotNull);
    expect(validator('  '), isNotNull);
    expect(validator('ok'), isNull);
  });

  test('phone validator accepts CN mobile', () {
    final validator = SHOValidators.phone(l10n);
    expect(validator('13800138000'), isNull);
    expect(validator('123'), isNotNull);
  });
}
