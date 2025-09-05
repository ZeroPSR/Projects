import 'package:json_annotation/json_annotation.dart';

part 'subject.g.dart';

@JsonSerializable()
class Subject {
  final int id;
  final String name;
  @JsonKey(name: 'group_id')
  final int groupId;
  @JsonKey(name: 'min_attendance')
  final double minAttendance;
  @JsonKey(name: 'created_at')
  final DateTime createdAt;

  Subject({
    required this.id,
    required this.name,
    required this.groupId,
    required this.minAttendance,
    required this.createdAt,
  });

  factory Subject.fromJson(Map<String, dynamic> json) =>
      _$SubjectFromJson(json);
  Map<String, dynamic> toJson() => _$SubjectToJson(this);
}
