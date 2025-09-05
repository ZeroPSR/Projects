import 'package:flutter/material.dart';
import '../models/group.dart';
import '../models/subject.dart';
import '../services/local_api_service.dart';
import 'test_screen.dart';

class GroupDetailScreen extends StatefulWidget {
  final Group group;

  const GroupDetailScreen({super.key, required this.group});

  @override
  State<GroupDetailScreen> createState() => _GroupDetailScreenState();
}

class _GroupDetailScreenState extends State<GroupDetailScreen> {
  late Future<List<Subject>> _subjectsFuture;
  final _apiService = LocalApiService();
  late Group _currentGroup; // Add this to track current group state

  @override
  void initState() {
    super.initState();
    _currentGroup = widget.group; // Initialize with the passed group
    _loadSubjects();
  }

  void _loadSubjects() {
    _subjectsFuture = _apiService.getSubjects(_currentGroup.id);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_currentGroup.name),
        backgroundColor: Colors.green,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () => _showEditGroupDialog(),
          ),
        ],
      ),
      body: FutureBuilder<List<Subject>>(
        future: _subjectsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          final subjects = snapshot.data ?? [];

          if (subjects.isEmpty) {
            return const Center(child: Text('No subjects found'));
          }

          return ListView.builder(
            itemCount: subjects.length,
            itemBuilder: (context, index) {
              final subject = subjects[index];
              return ListTile(
                title: Text(subject.name),
                subtitle: Text('Min. Attendance: ${subject.minAttendance}%'),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.edit),
                      onPressed: () => _showEditSubjectDialog(subject),
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete),
                      onPressed: () => _deleteSubject(subject),
                    ),
                  ],
                ),
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => TestScreen(subject: subject),
                    ),
                  );
                },
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddSubjectDialog,
        child: const Icon(Icons.add),
      ),
    );
  }

  Future<void> _showAddSubjectDialog() async {
    final nameController = TextEditingController();
    final minAttendanceController = TextEditingController(text: '75.0');

    return showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add Subject'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              decoration: const InputDecoration(labelText: 'Subject Name'),
            ),
            TextField(
              controller: minAttendanceController,
              decoration: const InputDecoration(
                labelText: 'Minimum Attendance %',
              ),
              keyboardType: TextInputType.number,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              final name = nameController.text;
              final minAttendance =
                  double.tryParse(minAttendanceController.text) ?? 75.0;

              if (name.isNotEmpty) {
                await _apiService.createSubject(
                  _currentGroup.id,
                  name,
                  minAttendance,
                );
                if (mounted) {
                  Navigator.of(context).pop();
                  setState(() {
                    _loadSubjects();
                  });
                }
              }
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }

  Future<void> _showEditGroupDialog() async {
    final nameController = TextEditingController(text: _currentGroup.name);

    return showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Edit Group'),
        content: TextField(
          controller: nameController,
          decoration: const InputDecoration(labelText: 'Group Name'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              final name = nameController.text.trim();
              if (name.isNotEmpty && name != _currentGroup.name) {
                try {
                  final success = await _apiService.updateGroup(
                    _currentGroup.id,
                    name,
                  );
                  if (success && mounted) {
                    setState(() {
                      _currentGroup = Group(
                        id: _currentGroup.id,
                        name: name,
                        userId: _currentGroup.userId,
                        createdAt: _currentGroup.createdAt,
                      );
                    });
                    Navigator.of(context).pop();
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Group updated successfully'),
                      ),
                    );
                  } else if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Failed to update group')),
                    );
                  }
                } catch (e) {
                  if (mounted) {
                    ScaffoldMessenger.of(
                      context,
                    ).showSnackBar(SnackBar(content: Text('Error: $e')));
                  }
                }
              } else if (mounted) {
                Navigator.of(context).pop();
              }
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  Future<void> _showEditSubjectDialog(Subject subject) async {
    final nameController = TextEditingController(text: subject.name);
    final minAttendanceController = TextEditingController(
      text: subject.minAttendance.toString(),
    );

    return showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Edit Subject'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              decoration: const InputDecoration(labelText: 'Subject Name'),
            ),
            TextField(
              controller: minAttendanceController,
              decoration: const InputDecoration(
                labelText: 'Minimum Attendance %',
              ),
              keyboardType: TextInputType.number,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              final name = nameController.text;
              final minAttendance =
                  double.tryParse(minAttendanceController.text) ?? 75.0;

              if (name.isNotEmpty) {
                await _apiService.updateSubject(
                  subject.id,
                  name,
                  minAttendance,
                );
                if (mounted) {
                  Navigator.of(context).pop();
                  setState(() {
                    _loadSubjects();
                  });
                }
              }
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  Future<void> _deleteSubject(Subject subject) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Subject'),
        content: Text('Are you sure you want to delete ${subject.name}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      await _apiService.deleteSubject(subject.id);
      setState(() {
        _loadSubjects();
      });
    }
  }
}
