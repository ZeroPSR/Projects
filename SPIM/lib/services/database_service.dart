import 'dart:async';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/group.dart';
import '../models/subject.dart';
import '../models/attendance.dart';
import '../models/marks.dart';

class DatabaseService {
  static final DatabaseService _instance = DatabaseService._internal();
  factory DatabaseService() => _instance;
  DatabaseService._internal();

  static Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    try {
      String path = join(await getDatabasesPath(), 'spim_local.db');
      print('Database path: $path');

      return await openDatabase(
        path,
        version: 2, // Increment version to trigger migration
        onCreate: _createTables,
        onUpgrade: _onUpgrade,
      );
    } catch (e) {
      print('Database initialization error: $e');
      rethrow;
    }
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      // Drop users table and update groups table
      await db.execute('DROP TABLE IF EXISTS users');
      await db.execute('ALTER TABLE groups DROP COLUMN user_id');
    }
  }

  Future<void> _createTables(Database db, int version) async {
    // No users table needed anymore

    // Groups table (simplified without user_id)
    await db.execute('''
      CREATE TABLE groups(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        created_at TEXT NOT NULL
      )
    ''');

    // Subjects table
    await db.execute('''
      CREATE TABLE subjects(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        group_id INTEGER NOT NULL,
        min_attendance REAL NOT NULL,
        created_at TEXT NOT NULL,
        FOREIGN KEY (group_id) REFERENCES groups (id) ON DELETE CASCADE
      )
    ''');

    // Attendance table
    await db.execute('''
      CREATE TABLE attendance(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        subject_id INTEGER NOT NULL,
        status TEXT NOT NULL,
        date TEXT NOT NULL,
        FOREIGN KEY (subject_id) REFERENCES subjects (id) ON DELETE CASCADE
      )
    ''');

    // Marks table
    await db.execute('''
      CREATE TABLE marks(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        subject_id INTEGER NOT NULL,
        category TEXT NOT NULL,
        marks_scored REAL NOT NULL,
        total_marks REAL NOT NULL,
        created_at TEXT NOT NULL,
        FOREIGN KEY (subject_id) REFERENCES subjects (id) ON DELETE CASCADE
      )
    ''');
  }

  // User Authentication Methods - REMOVED (no longer needed)

  // Group Methods
  Future<List<Group>> getGroups() async {
    try {
      final db = await database;
      final List<Map<String, dynamic>> maps = await db.query(
        'groups',
        orderBy: 'created_at DESC',
      );

      return List.generate(maps.length, (i) {
        return Group(
          id: maps[i]['id'],
          name: maps[i]['name'],
          userId: 0, // No longer used, but kept for model compatibility
          createdAt: DateTime.parse(maps[i]['created_at']),
        );
      });
    } catch (e) {
      print('Error getting groups: $e');
      return []; // Return empty list on error
    }
  }

  Future<Group?> createGroup(String name) async {
    final db = await database;
    final now = DateTime.now();

    try {
      final id = await db.insert('groups', {
        'name': name,
        'created_at': now.toIso8601String(),
      });

      return Group(
        id: id,
        name: name,
        userId: 0, // No longer used, but kept for model compatibility
        createdAt: now,
      );
    } catch (e) {
      print('Create group error: $e');
      return null;
    }
  }

  Future<bool> updateGroup(int groupId, String name) async {
    final db = await database;

    try {
      final count = await db.update(
        'groups',
        {'name': name},
        where: 'id = ?',
        whereArgs: [groupId],
      );
      return count > 0;
    } catch (e) {
      print('Update group error: $e');
      return false;
    }
  }

  Future<bool> deleteGroup(int groupId) async {
    final db = await database;

    try {
      final count = await db.delete(
        'groups',
        where: 'id = ?',
        whereArgs: [groupId],
      );
      return count > 0;
    } catch (e) {
      print('Delete group error: $e');
      return false;
    }
  }

  // Subject Methods
  Future<List<Subject>> getSubjects(int groupId) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'subjects',
      where: 'group_id = ?',
      whereArgs: [groupId],
      orderBy: 'created_at DESC',
    );

    return List.generate(maps.length, (i) {
      return Subject(
        id: maps[i]['id'],
        name: maps[i]['name'],
        groupId: maps[i]['group_id'],
        minAttendance: maps[i]['min_attendance'],
        createdAt: DateTime.parse(maps[i]['created_at']),
      );
    });
  }

  Future<Subject?> createSubject(
    int groupId,
    String name,
    double minAttendance,
  ) async {
    final db = await database;
    final now = DateTime.now();

    try {
      final id = await db.insert('subjects', {
        'name': name,
        'group_id': groupId,
        'min_attendance': minAttendance,
        'created_at': now.toIso8601String(),
      });

      return Subject(
        id: id,
        name: name,
        groupId: groupId,
        minAttendance: minAttendance,
        createdAt: now,
      );
    } catch (e) {
      print('Create subject error: $e');
      return null;
    }
  }

  Future<bool> updateSubject(
    int subjectId,
    String name,
    double minAttendance,
  ) async {
    final db = await database;

    try {
      final count = await db.update(
        'subjects',
        {'name': name, 'min_attendance': minAttendance},
        where: 'id = ?',
        whereArgs: [subjectId],
      );
      return count > 0;
    } catch (e) {
      print('Update subject error: $e');
      return false;
    }
  }

  Future<bool> deleteSubject(int subjectId) async {
    final db = await database;

    try {
      final count = await db.delete(
        'subjects',
        where: 'id = ?',
        whereArgs: [subjectId],
      );
      return count > 0;
    } catch (e) {
      print('Delete subject error: $e');
      return false;
    }
  }

  // Attendance Methods
  Future<List<Attendance>> getAttendance(int subjectId) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'attendance',
      where: 'subject_id = ?',
      whereArgs: [subjectId],
      orderBy: 'date DESC',
    );

    return List.generate(maps.length, (i) {
      return Attendance(
        id: maps[i]['id'],
        subjectId: maps[i]['subject_id'],
        status: maps[i]['status'],
        date: DateTime.parse(maps[i]['date']),
      );
    });
  }

  Future<AttendanceStats> getAttendanceStats(int subjectId) async {
    final db = await database;

    final List<Map<String, dynamic>> maps = await db.rawQuery(
      '''
      SELECT 
        COUNT(*) as total_classes,
        SUM(CASE WHEN status = 'present' THEN 1 ELSE 0 END) as present,
        SUM(CASE WHEN status = 'absent' THEN 1 ELSE 0 END) as absent
      FROM attendance 
      WHERE subject_id = ?
    ''',
      [subjectId],
    );

    final result = maps.first;
    final totalClasses = result['total_classes'] as int;
    final present = result['present'] as int;
    final absent = result['absent'] as int;
    final percentage = totalClasses > 0 ? (present / totalClasses) * 100 : 0.0;

    return AttendanceStats(
      totalClasses: totalClasses,
      present: present,
      absent: absent,
      percentage: percentage,
    );
  }

  Future<Attendance?> createAttendance(
    int subjectId,
    String status,
    DateTime date,
  ) async {
    final db = await database;

    try {
      final id = await db.insert('attendance', {
        'subject_id': subjectId,
        'status': status,
        'date': date.toIso8601String(),
      });

      return Attendance(
        id: id,
        subjectId: subjectId,
        status: status,
        date: date,
      );
    } catch (e) {
      print('Create attendance error: $e');
      return null;
    }
  }

  Future<Attendance?> updateAttendance(
    int attendanceId,
    int subjectId,
    String status,
    DateTime date,
  ) async {
    final db = await database;

    try {
      final count = await db.update(
        'attendance',
        {
          'subject_id': subjectId,
          'status': status,
          'date': date.toIso8601String(),
        },
        where: 'id = ?',
        whereArgs: [attendanceId],
      );

      if (count > 0) {
        return Attendance(
          id: attendanceId,
          subjectId: subjectId,
          status: status,
          date: date,
        );
      }
      return null;
    } catch (e) {
      print('Update attendance error: $e');
      return null;
    }
  }

  Future<bool> deleteAttendance(int attendanceId) async {
    final db = await database;

    try {
      final count = await db.delete(
        'attendance',
        where: 'id = ?',
        whereArgs: [attendanceId],
      );
      return count > 0;
    } catch (e) {
      print('Delete attendance error: $e');
      return false;
    }
  }

  // Marks Methods
  Future<List<Marks>> getMarks(int subjectId) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'marks',
      where: 'subject_id = ?',
      whereArgs: [subjectId],
      orderBy: 'created_at DESC',
    );

    return List.generate(maps.length, (i) {
      return Marks(
        id: maps[i]['id'],
        subjectId: maps[i]['subject_id'],
        category: maps[i]['category'],
        marksScored: maps[i]['marks_scored'],
        totalMarks: maps[i]['total_marks'],
        createdAt: DateTime.parse(maps[i]['created_at']),
      );
    });
  }

  Future<MarksStats> getMarksStats(int subjectId) async {
    final db = await database;

    final List<Map<String, dynamic>> maps = await db.rawQuery(
      '''
      SELECT 
        COUNT(*) as entries_count,
        SUM(marks_scored) as total_marks_scored,
        SUM(total_marks) as total_marks_possible
      FROM marks 
      WHERE subject_id = ?
    ''',
      [subjectId],
    );

    final result = maps.first;
    final entriesCount = result['entries_count'] as int;
    final totalMarksScored = (result['total_marks_scored'] ?? 0.0) as double;
    final totalMarksPossible =
        (result['total_marks_possible'] ?? 0.0) as double;
    final percentage = totalMarksPossible > 0
        ? (totalMarksScored / totalMarksPossible) * 100
        : 0.0;

    return MarksStats(
      entriesCount: entriesCount,
      totalMarksScored: totalMarksScored,
      totalMarksPossible: totalMarksPossible,
      percentage: percentage,
    );
  }

  Future<Marks?> createMarks(
    int subjectId,
    String category,
    double marksScored,
    double totalMarks,
  ) async {
    final db = await database;
    final now = DateTime.now();

    try {
      final id = await db.insert('marks', {
        'subject_id': subjectId,
        'category': category,
        'marks_scored': marksScored,
        'total_marks': totalMarks,
        'created_at': now.toIso8601String(),
      });

      return Marks(
        id: id,
        subjectId: subjectId,
        category: category,
        marksScored: marksScored,
        totalMarks: totalMarks,
        createdAt: now,
      );
    } catch (e) {
      print('Create marks error: $e');
      return null;
    }
  }

  Future<Marks?> updateMarks(
    int marksId,
    int subjectId,
    String category,
    double marksScored,
    double totalMarks,
  ) async {
    final db = await database;

    try {
      final count = await db.update(
        'marks',
        {
          'subject_id': subjectId,
          'category': category,
          'marks_scored': marksScored,
          'total_marks': totalMarks,
        },
        where: 'id = ?',
        whereArgs: [marksId],
      );

      if (count > 0) {
        return Marks(
          id: marksId,
          subjectId: subjectId,
          category: category,
          marksScored: marksScored,
          totalMarks: totalMarks,
          createdAt:
              DateTime.now(), // We could fetch the actual created_at if needed
        );
      }
      return null;
    } catch (e) {
      print('Update marks error: $e');
      return null;
    }
  }

  Future<bool> deleteMarks(int marksId) async {
    final db = await database;

    try {
      final count = await db.delete(
        'marks',
        where: 'id = ?',
        whereArgs: [marksId],
      );
      return count > 0;
    } catch (e) {
      print('Delete marks error: $e');
      return false;
    }
  }
}
