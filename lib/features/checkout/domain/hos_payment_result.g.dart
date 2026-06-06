// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'hos_payment_result.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$SHOPaymentResultImpl _$$SHOPaymentResultImplFromJson(
  Map<String, dynamic> json,
) => _$SHOPaymentResultImpl(
  orderId: json['orderId'] as String,
  status: json['status'] as String,
  paidAt: json['paidAt'] as String,
  message: json['message'] as String? ?? '',
);

Map<String, dynamic> _$$SHOPaymentResultImplToJson(
  _$SHOPaymentResultImpl instance,
) => <String, dynamic>{
  'orderId': instance.orderId,
  'status': instance.status,
  'paidAt': instance.paidAt,
  'message': instance.message,
};
