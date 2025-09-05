import 'package:json_annotation/json_annotation.dart';

part 'marks.g.dart';

@JsonSerializable()
class Marks {
  final int id;
  @JsonKey(name: 'subject_id')
  final int subjectId;
  final String category;
  @JsonKey(name: 'marks_scored')
  final double marksScored;
  @JsonKey(name: 'total_marks')
  final double totalMarks;
  @JsonKey(name: 'created_at')
  final DateTime createdAt;

  Marks({
    required this.id,
    required this.subjectId,
    required this.category,
    required this.marksScored,
    required this.totalMarks,
    required this.createdAt,
  });

  factory Marks.fromJson(Map<String, dynamic> json) => _$MarksFromJson(json);
  Map<String, dynamic> toJson() => _$MarksToJson(this);
}

@JsonSerializable()
class MarksStats {
  @JsonKey(name: 'total_marks_scored')
  final double totalMarksScored;
  @JsonKey(name: 'total_marks_possible')
  final double totalMarksPossible;
  final double percentage;
  @JsonKey(name: 'entries_count')
  final int entriesCount;

  MarksStats({
    required this.totalMarksScored,
    required this.totalMarksPossible,
    required this.percentage,
    required this.entriesCount,
  });

  factory MarksStats.fromJson(Map<String, dynamic> json) =>
      _$MarksStatsFromJson(json);
  Map<String, dynamic> toJson() => _$MarksStatsToJson(this);
}
