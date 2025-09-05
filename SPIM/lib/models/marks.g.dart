// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'marks.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Marks _$MarksFromJson(Map<String, dynamic> json) => Marks(
  id: (json['id'] as num).toInt(),
  subjectId: (json['subject_id'] as num).toInt(),
  category: json['category'] as String,
  marksScored: (json['marks_scored'] as num).toDouble(),
  totalMarks: (json['total_marks'] as num).toDouble(),
  createdAt: DateTime.parse(json['created_at'] as String),
);

Map<String, dynamic> _$MarksToJson(Marks instance) => <String, dynamic>{
  'id': instance.id,
  'subject_id': instance.subjectId,
  'category': instance.category,
  'marks_scored': instance.marksScored,
  'total_marks': instance.totalMarks,
  'created_at': instance.createdAt.toIso8601String(),
};

MarksStats _$MarksStatsFromJson(Map<String, dynamic> json) => MarksStats(
  totalMarksScored: (json['total_marks_scored'] as num).toDouble(),
  totalMarksPossible: (json['total_marks_possible'] as num).toDouble(),
  percentage: (json['percentage'] as num).toDouble(),
  entriesCount: (json['entries_count'] as num).toInt(),
);

Map<String, dynamic> _$MarksStatsToJson(MarksStats instance) =>
    <String, dynamic>{
      'total_marks_scored': instance.totalMarksScored,
      'total_marks_possible': instance.totalMarksPossible,
      'percentage': instance.percentage,
      'entries_count': instance.entriesCount,
    };
