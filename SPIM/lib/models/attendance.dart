import 'package:json_annotation/json_annotation.dart';

part 'attendance.g.dart';

@JsonSerializable()
class Attendance {
  final int id;
  @JsonKey(name: 'subject_id')
  final int subjectId;
  final String status;
  final DateTime date;

  Attendance({
    required this.id,
    required this.subjectId,
    required this.status,
    required this.date,
  });

  factory Attendance.fromJson(Map<String, dynamic> json) =>
      _$AttendanceFromJson(json);

  Map<String, dynamic> toJson() => _$AttendanceToJson(this);
}

@JsonSerializable()
class AttendanceStats {
  @JsonKey(name: 'total_classes')
  final int totalClasses;
  final int present;
  final int absent;
  final double percentage;

  AttendanceStats({
    required this.totalClasses,
    required this.present,
    required this.absent,
    required this.percentage,
  });

  factory AttendanceStats.fromJson(Map<String, dynamic> json) =>
      _$AttendanceStatsFromJson(json);

  Map<String, dynamic> toJson() => _$AttendanceStatsToJson(this);
}
