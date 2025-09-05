// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'attendance.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Attendance _$AttendanceFromJson(Map<String, dynamic> json) => Attendance(
  id: (json['id'] as num).toInt(),
  subjectId: (json['subject_id'] as num).toInt(),
  status: json['status'] as String,
  date: DateTime.parse(json['date'] as String),
);

Map<String, dynamic> _$AttendanceToJson(Attendance instance) =>
    <String, dynamic>{
      'id': instance.id,
      'subject_id': instance.subjectId,
      'status': instance.status,
      'date': instance.date.toIso8601String(),
    };

AttendanceStats _$AttendanceStatsFromJson(Map<String, dynamic> json) =>
    AttendanceStats(
      totalClasses: (json['total_classes'] as num).toInt(),
      present: (json['present'] as num).toInt(),
      absent: (json['absent'] as num).toInt(),
      percentage: (json['percentage'] as num).toDouble(),
    );

Map<String, dynamic> _$AttendanceStatsToJson(AttendanceStats instance) =>
    <String, dynamic>{
      'total_classes': instance.totalClasses,
      'present': instance.present,
      'absent': instance.absent,
      'percentage': instance.percentage,
    };
