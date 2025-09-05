// This adapter maintains compatibility with existing code that uses ApiService
// while redirecting all calls to local database operations

import '../services/database_service.dart';
import '../models/group.dart';
import '../models/subject.dart';
import '../models/attendance.dart';
import '../models/marks.dart';

class LocalApiService {
  static final LocalApiService _instance = LocalApiService._internal();
  factory LocalApiService() => _instance;
  LocalApiService._internal();

  final DatabaseService _databaseService = DatabaseService();

  void setToken(String token) {
    // No-op for local storage, but maintains API compatibility
  }

  void clearToken() {
    // No-op for local storage, but maintains API compatibility
  }

  // Group methods
  Future<List<Group>> getGroups() async {
    return await _databaseService.getGroups();
  }

  Future<Group?> createGroup(String name) async {
    return await _databaseService.createGroup(name);
  }

  Future<bool> updateGroup(int groupId, String name) async {
    return await _databaseService.updateGroup(groupId, name);
  }

  Future<bool> deleteGroup(int groupId) async {
    return await _databaseService.deleteGroup(groupId);
  }

  // Subject methods
  Future<List<Subject>> getSubjects(int groupId) async {
    return await _databaseService.getSubjects(groupId);
  }

  Future<Subject?> createSubject(
    int groupId,
    String name,
    double minAttendance,
  ) async {
    return await _databaseService.createSubject(groupId, name, minAttendance);
  }

  Future<bool> updateSubject(
    int subjectId,
    String name,
    double minAttendance,
  ) async {
    return await _databaseService.updateSubject(subjectId, name, minAttendance);
  }

  Future<bool> deleteSubject(int subjectId) async {
    return await _databaseService.deleteSubject(subjectId);
  }

  // Attendance methods
  Future<List<Attendance>> getAttendance(int subjectId) async {
    return await _databaseService.getAttendance(subjectId);
  }

  Future<AttendanceStats> getAttendanceStats(int subjectId) async {
    return await _databaseService.getAttendanceStats(subjectId);
  }

  Future<Attendance?> createAttendance(
    int subjectId,
    String status,
    DateTime date,
  ) async {
    return await _databaseService.createAttendance(subjectId, status, date);
  }

  Future<Attendance?> updateAttendance(
    int attendanceId,
    int subjectId,
    String status,
    DateTime date,
  ) async {
    return await _databaseService.updateAttendance(
      attendanceId,
      subjectId,
      status,
      date,
    );
  }

  Future<bool> deleteAttendance(int attendanceId) async {
    return await _databaseService.deleteAttendance(attendanceId);
  }

  // Marks methods
  Future<List<Marks>> getMarks(int subjectId) async {
    return await _databaseService.getMarks(subjectId);
  }

  Future<MarksStats> getMarksStats(int subjectId) async {
    return await _databaseService.getMarksStats(subjectId);
  }

  Future<Marks?> createMarks(
    int subjectId,
    String category,
    double marksScored,
    double totalMarks,
  ) async {
    return await _databaseService.createMarks(
      subjectId,
      category,
      marksScored,
      totalMarks,
    );
  }

  Future<Marks?> updateMarks(
    int marksId,
    int subjectId,
    String category,
    double marksScored,
    double totalMarks,
  ) async {
    return await _databaseService.updateMarks(
      marksId,
      subjectId,
      category,
      marksScored,
      totalMarks,
    );
  }

  Future<bool> deleteMarks(int marksId) async {
    return await _databaseService.deleteMarks(marksId);
  }
}
