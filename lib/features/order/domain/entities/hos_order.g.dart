// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'hos_order.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$SHOOrderItemImpl _$$SHOOrderItemImplFromJson(Map<String, dynamic> json) =>
    _$SHOOrderItemImpl(
      productId: json['productId'] as String,
      title: json['title'] as String,
      imageUrl: json['imageUrl'] as String,
      price: (json['price'] as num).toInt(),
      quantity: (json['quantity'] as num?)?.toInt() ?? 1,
      variantLabel: json['variantLabel'] as String? ?? '',
    );

Map<String, dynamic> _$$SHOOrderItemImplToJson(_$SHOOrderItemImpl instance) =>
    <String, dynamic>{
      'productId': instance.productId,
      'title': instance.title,
      'imageUrl': instance.imageUrl,
      'price': instance.price,
      'quantity': instance.quantity,
      'variantLabel': instance.variantLabel,
    };

_$SHOOrderSummaryImpl _$$SHOOrderSummaryImplFromJson(
  Map<String, dynamic> json,
) => _$SHOOrderSummaryImpl(
  id: json['id'] as String,
  orderNo: json['orderNo'] as String,
  status: $enumDecode(_$SHOOrderStatusEnumMap, json['status']),
  totalCents: (json['totalCents'] as num).toInt(),
  createdAt: json['createdAt'] as String,
  items:
      (json['items'] as List<dynamic>?)
          ?.map((e) => SHOOrderItem.fromJson(e as Map<String, dynamic>))
          .toList() ??
      const <SHOOrderItem>[],
);

Map<String, dynamic> _$$SHOOrderSummaryImplToJson(
  _$SHOOrderSummaryImpl instance,
) => <String, dynamic>{
  'id': instance.id,
  'orderNo': instance.orderNo,
  'status': _$SHOOrderStatusEnumMap[instance.status]!,
  'totalCents': instance.totalCents,
  'createdAt': instance.createdAt,
  'items': instance.items,
};

const _$SHOOrderStatusEnumMap = {
  SHOOrderStatus.pendingPayment: 'pending_payment',
  SHOOrderStatus.paid: 'paid',
  SHOOrderStatus.shipped: 'shipped',
  SHOOrderStatus.delivered: 'delivered',
  SHOOrderStatus.cancelled: 'cancelled',
};

_$SHOOrderDetailImpl _$$SHOOrderDetailImplFromJson(Map<String, dynamic> json) =>
    _$SHOOrderDetailImpl(
      id: json['id'] as String,
      orderNo: json['orderNo'] as String,
      status: $enumDecode(_$SHOOrderStatusEnumMap, json['status']),
      totalCents: (json['totalCents'] as num).toInt(),
      createdAt: json['createdAt'] as String,
      shippingAddress: json['shippingAddress'] as String? ?? '',
      items:
          (json['items'] as List<dynamic>?)
              ?.map((e) => SHOOrderItem.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const <SHOOrderItem>[],
      hasLogistics: json['hasLogistics'] as bool? ?? false,
    );

Map<String, dynamic> _$$SHOOrderDetailImplToJson(
  _$SHOOrderDetailImpl instance,
) => <String, dynamic>{
  'id': instance.id,
  'orderNo': instance.orderNo,
  'status': _$SHOOrderStatusEnumMap[instance.status]!,
  'totalCents': instance.totalCents,
  'createdAt': instance.createdAt,
  'shippingAddress': instance.shippingAddress,
  'items': instance.items,
  'hasLogistics': instance.hasLogistics,
};

_$SHOLogisticsEventImpl _$$SHOLogisticsEventImplFromJson(
  Map<String, dynamic> json,
) => _$SHOLogisticsEventImpl(
  time: json['time'] as String,
  status: json['status'] as String,
  description: json['description'] as String,
  isActive: json['isActive'] as bool? ?? false,
);

Map<String, dynamic> _$$SHOLogisticsEventImplToJson(
  _$SHOLogisticsEventImpl instance,
) => <String, dynamic>{
  'time': instance.time,
  'status': instance.status,
  'description': instance.description,
  'isActive': instance.isActive,
};

_$SHOLogisticsTrackImpl _$$SHOLogisticsTrackImplFromJson(
  Map<String, dynamic> json,
) => _$SHOLogisticsTrackImpl(
  orderId: json['orderId'] as String,
  carrier: json['carrier'] as String,
  trackingNumber: json['trackingNumber'] as String,
  events:
      (json['events'] as List<dynamic>?)
          ?.map((e) => SHOLogisticsEvent.fromJson(e as Map<String, dynamic>))
          .toList() ??
      const <SHOLogisticsEvent>[],
);

Map<String, dynamic> _$$SHOLogisticsTrackImplToJson(
  _$SHOLogisticsTrackImpl instance,
) => <String, dynamic>{
  'orderId': instance.orderId,
  'carrier': instance.carrier,
  'trackingNumber': instance.trackingNumber,
  'events': instance.events,
};
