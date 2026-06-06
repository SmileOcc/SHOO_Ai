// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'hos_message.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$SHOAppMessageImpl _$$SHOAppMessageImplFromJson(Map<String, dynamic> json) =>
    _$SHOAppMessageImpl(
      id: json['id'] as String,
      title: json['title'] as String,
      body: json['body'] as String,
      type: json['type'] as String,
      createdAt: json['createdAt'] as String,
      isRead: json['isRead'] as bool? ?? false,
    );

Map<String, dynamic> _$$SHOAppMessageImplToJson(_$SHOAppMessageImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'title': instance.title,
      'body': instance.body,
      'type': instance.type,
      'createdAt': instance.createdAt,
      'isRead': instance.isRead,
    };
