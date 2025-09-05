// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'subject.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Subject _$SubjectFromJson(Map<String, dynamic> json) => Subject(
  id: (json['id'] as num).toInt(),
  name: json['name'] as String,
  groupId: (json['group_id'] as num).toInt(),
  minAttendance: (json['min_attendance'] as num).toDouble(),
  createdAt: DateTime.parse(json['created_at'] as String),
);

Map<String, dynamic> _$SubjectToJson(Subject instance) => <String, dynamic>{
  'id': instance.id,
  'name': instance.name,
  'group_id': instance.groupId,
  'min_attendance': instance.minAttendance,
  'created_at': instance.createdAt.toIso8601String(),
};
