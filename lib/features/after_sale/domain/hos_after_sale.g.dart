// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'hos_after_sale.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$SHOAfterSaleRequestImpl _$$SHOAfterSaleRequestImplFromJson(
  Map<String, dynamic> json,
) => _$SHOAfterSaleRequestImpl(
  id: json['id'] as String,
  orderId: json['orderId'] as String,
  orderNo: json['orderNo'] as String,
  type: $enumDecode(_$SHOAfterSaleTypeEnumMap, json['type']),
  status: $enumDecode(_$SHOAfterSaleStatusEnumMap, json['status']),
  reason: json['reason'] as String,
  createdAt: json['createdAt'] as String,
  productTitle: json['productTitle'] as String? ?? '',
);

Map<String, dynamic> _$$SHOAfterSaleRequestImplToJson(
  _$SHOAfterSaleRequestImpl instance,
) => <String, dynamic>{
  'id': instance.id,
  'orderId': instance.orderId,
  'orderNo': instance.orderNo,
  'type': _$SHOAfterSaleTypeEnumMap[instance.type]!,
  'status': _$SHOAfterSaleStatusEnumMap[instance.status]!,
  'reason': instance.reason,
  'createdAt': instance.createdAt,
  'productTitle': instance.productTitle,
};

const _$SHOAfterSaleTypeEnumMap = {
  SHOAfterSaleType.refund: 'refund',
  SHOAfterSaleType.returnRefund: 'return_refund',
};

const _$SHOAfterSaleStatusEnumMap = {
  SHOAfterSaleStatus.pending: 'pending',
  SHOAfterSaleStatus.approved: 'approved',
  SHOAfterSaleStatus.rejected: 'rejected',
  SHOAfterSaleStatus.completed: 'completed',
};

_$SHOAfterSaleCreateRequestImpl _$$SHOAfterSaleCreateRequestImplFromJson(
  Map<String, dynamic> json,
) => _$SHOAfterSaleCreateRequestImpl(
  orderId: json['orderId'] as String,
  type: $enumDecode(_$SHOAfterSaleTypeEnumMap, json['type']),
  reason: json['reason'] as String,
);

Map<String, dynamic> _$$SHOAfterSaleCreateRequestImplToJson(
  _$SHOAfterSaleCreateRequestImpl instance,
) => <String, dynamic>{
  'orderId': instance.orderId,
  'type': _$SHOAfterSaleTypeEnumMap[instance.type]!,
  'reason': instance.reason,
};
