import 'package:flutter/material.dart';
import '../models/subject.dart';
import '../models/marks.dart';
import '../models/attendance.dart';
import '../services/local_api_service.dart';

class TestScreen extends StatefulWidget {
  final Subject subject;

  const TestScreen({Key? key, required this.subject}) : super(key: key);

  @override
  _TestScreenState createState() => _TestScreenState();
}

class _TestScreenState extends State<TestScreen> {
  List<Marks> marks = [];
  List<Attendance> attendanceList = [];
  MarksStats? marksStats;
  bool isLoading = true;
  bool isMarksLoading = true;
  bool isAttendanceLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    await Future.wait([_loadMarks(), _loadAttendance()]);
    setState(() {
      isLoading = false;
    });
  }

  Future<void> _loadMarks() async {
    try {
      setState(() {
        isMarksLoading = true;
      });

      final apiService = LocalApiService();
      final loadedMarks = await apiService.getMarks(widget.subject.id);
      final stats = await apiService.getMarksStats(widget.subject.id);

      setState(() {
        marks = loadedMarks;
        marksStats = stats;
        isMarksLoading = false;
      });
    } catch (e) {
      print('Error loading marks: $e');
      setState(() {
        isMarksLoading = false;
      });
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error loading marks: $e')));
    }
  }

  Future<void> _loadAttendance() async {
    try {
      setState(() {
        isAttendanceLoading = true;
      });

      final apiService = LocalApiService();
      final loadedAttendance = await apiService.getAttendance(
        widget.subject.id,
      );

      setState(() {
        attendanceList = loadedAttendance;
        isAttendanceLoading = false;
      });
    } catch (e) {
      print('Error loading attendance: $e');
      setState(() {
        isAttendanceLoading = false;
      });
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error loading attendance: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.subject.name),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Subject Info Card
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.subject.name,
                            style: Theme.of(context).textTheme.headlineSmall,
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Marksheet Section
                  _buildMarksheetSection(),
                  const SizedBox(height: 20),

                  // Attendance Section
                  _buildAttendanceSection(),
                ],
              ),
            ),
    );
  }

  Widget _buildMarksheetSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Marksheet',
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                IconButton(
                  icon: const Icon(Icons.add),
                  onPressed: _showAddMarksDialog,
                ),
              ],
            ),
            const SizedBox(height: 16),

            if (isMarksLoading)
              const Center(child: CircularProgressIndicator())
            else if (marks.isEmpty)
              const Center(
                child: Padding(
                  padding: EdgeInsets.all(20.0),
                  child: Text('No marks recorded yet'),
                ),
              )
            else
              Column(
                children: [
                  // Marks Table
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: DataTable(
                      border: TableBorder.all(
                        color: Theme.of(context).dividerColor,
                        width: 1,
                      ),
                      headingRowColor: MaterialStateProperty.all(
                        Theme.of(context).colorScheme.surfaceVariant,
                      ),
                      dataRowMaxHeight: 60,
                      headingRowHeight: 50,
                      columnSpacing: 20,
                      columns: [
                        DataColumn(
                          label: SizedBox(
                            width: 80,
                            child: FittedBox(
                              fit: BoxFit.scaleDown,
                              child: Text(
                                'Category',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Theme.of(
                                    context,
                                  ).colorScheme.onSurfaceVariant,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ),
                          ),
                        ),
                        DataColumn(
                          label: SizedBox(
                            width: 60,
                            child: FittedBox(
                              fit: BoxFit.scaleDown,
                              child: Text(
                                'Scored',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Theme.of(
                                    context,
                                  ).colorScheme.onSurfaceVariant,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ),
                          ),
                        ),
                        DataColumn(
                          label: SizedBox(
                            width: 60,
                            child: FittedBox(
                              fit: BoxFit.scaleDown,
                              child: Text(
                                'Total',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Theme.of(
                                    context,
                                  ).colorScheme.onSurfaceVariant,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ),
                          ),
                        ),
                        DataColumn(
                          label: SizedBox(
                            width: 80,
                            child: FittedBox(
                              fit: BoxFit.scaleDown,
                              child: Text(
                                'Percentage',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Theme.of(
                                    context,
                                  ).colorScheme.onSurfaceVariant,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ),
                          ),
                        ),
                        DataColumn(
                          label: SizedBox(
                            width: 100,
                            child: FittedBox(
                              fit: BoxFit.scaleDown,
                              child: Text(
                                'Actions',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Theme.of(
                                    context,
                                  ).colorScheme.onSurfaceVariant,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ),
                          ),
                        ),
                      ],
                      rows: marks.asMap().entries.map((entry) {
                        final mark = entry.value;
                        final isEvenRow = entry.key % 2 == 0;
                        final percentage = mark.totalMarks > 0
                            ? (mark.marksScored / mark.totalMarks * 100)
                            : 0.0;

                        return DataRow(
                          color: MaterialStateProperty.all(
                            isEvenRow
                                ? Theme.of(context).colorScheme.surface
                                : Theme.of(
                                    context,
                                  ).colorScheme.surfaceVariant.withOpacity(0.3),
                          ),
                          cells: [
                            DataCell(
                              SizedBox(
                                width: 80,
                                child: FittedBox(
                                  fit: BoxFit.scaleDown,
                                  child: Text(
                                    mark.category,
                                    style: TextStyle(
                                      color: Theme.of(
                                        context,
                                      ).colorScheme.onSurface,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                              ),
                            ),
                            DataCell(
                              SizedBox(
                                width: 60,
                                child: FittedBox(
                                  fit: BoxFit.scaleDown,
                                  child: Text(
                                    '${mark.marksScored}',
                                    style: TextStyle(
                                      color: Theme.of(
                                        context,
                                      ).colorScheme.onSurface,
                                      fontWeight: FontWeight.w500,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                              ),
                            ),
                            DataCell(
                              SizedBox(
                                width: 60,
                                child: FittedBox(
                                  fit: BoxFit.scaleDown,
                                  child: Text(
                                    '${mark.totalMarks}',
                                    style: TextStyle(
                                      color: Theme.of(
                                        context,
                                      ).colorScheme.onSurface,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                              ),
                            ),
                            DataCell(
                              SizedBox(
                                width: 80,
                                child: FittedBox(
                                  fit: BoxFit.scaleDown,
                                  child: Text(
                                    '${percentage.toStringAsFixed(1)}%',
                                    style: TextStyle(
                                      color: Theme.of(
                                        context,
                                      ).colorScheme.primary,
                                      fontWeight: FontWeight.bold,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                              ),
                            ),
                            DataCell(
                              SizedBox(
                                width: 100,
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceEvenly,
                                  children: [
                                    SizedBox(
                                      width: 40,
                                      height: 40,
                                      child: IconButton(
                                        icon: Icon(
                                          Icons.edit,
                                          size: 16,
                                          color: Theme.of(
                                            context,
                                          ).colorScheme.primary,
                                        ),
                                        onPressed: () =>
                                            _showEditMarksDialog(mark),
                                        padding: EdgeInsets.zero,
                                        constraints: const BoxConstraints(),
                                      ),
                                    ),
                                    SizedBox(
                                      width: 40,
                                      height: 40,
                                      child: IconButton(
                                        icon: Icon(
                                          Icons.delete,
                                          size: 16,
                                          color: Theme.of(
                                            context,
                                          ).colorScheme.error,
                                        ),
                                        onPressed: () => _deleteMarks(mark),
                                        padding: EdgeInsets.zero,
                                        constraints: const BoxConstraints(),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        );
                      }).toList(),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Overall Stats
                  if (marksStats != null)
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.primaryContainer,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: Theme.of(context).colorScheme.primary,
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          _buildStatItem(
                            'Total Scored',
                            '${marksStats!.totalMarksScored}',
                          ),
                          _buildStatItem(
                            'Total Marks',
                            '${marksStats!.totalMarksPossible}',
                          ),
                          _buildStatItem(
                            'Overall %',
                            '${marksStats!.percentage.toStringAsFixed(1)}%',
                          ),
                        ],
                      ),
                    ),
                ],
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildAttendanceSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Attendance',
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                IconButton(
                  icon: const Icon(Icons.add),
                  onPressed: _showAddAttendanceDialog,
                ),
              ],
            ),
            const SizedBox(height: 16),

            if (isAttendanceLoading)
              const Center(child: CircularProgressIndicator())
            else if (attendanceList.isEmpty)
              const Center(
                child: Padding(
                  padding: EdgeInsets.all(20.0),
                  child: Text('No attendance records yet'),
                ),
              )
            else
              Column(
                children: [
                  // Attendance percentage
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: _getAttendanceColor(),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.school, color: Colors.white, size: 24),
                        const SizedBox(width: 8),
                        Text(
                          'Attendance: ${_calculateAttendancePercentage()}%',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Attendance list
                  ...attendanceList.map(
                    (attendance) => _buildAttendanceItem(attendance),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem(String label, String value) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Theme.of(context).colorScheme.onPrimaryContainer,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Theme.of(
              context,
            ).colorScheme.onPrimaryContainer.withOpacity(0.7),
          ),
        ),
      ],
    );
  }

  Widget _buildAttendanceItem(Attendance attendance) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 4),
      child: ListTile(
        leading: Icon(
          attendance.status == 'present' ? Icons.check_circle : Icons.cancel,
          color: attendance.status == 'present' ? Colors.green : Colors.red,
        ),
        title: Text(attendance.date.toIso8601String().split('T')[0]),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: const Icon(Icons.edit),
              onPressed: () => _showEditAttendanceDialog(attendance),
            ),
            IconButton(
              icon: const Icon(Icons.delete, color: Colors.red),
              onPressed: () => _deleteAttendance(attendance),
            ),
          ],
        ),
      ),
    );
  }

  double _calculateAttendancePercentage() {
    if (attendanceList.isEmpty) return 0.0;

    final presentCount = attendanceList
        .where((a) => a.status == 'present')
        .length;
    return double.parse(
      (presentCount / attendanceList.length * 100).toStringAsFixed(1),
    );
  }

  Color _getAttendanceColor() {
    final percentage = _calculateAttendancePercentage();
    if (percentage >= 75) return Colors.green;
    if (percentage >= 50) return Colors.orange;
    return Colors.red;
  }

  // Marks Dialog Methods
  void _showAddMarksDialog() {
    _showMarksDialog();
  }

  void _showEditMarksDialog(Marks marks) {
    _showMarksDialog(marks: marks);
  }

  void _showMarksDialog({Marks? marks}) {
    final categoryController = TextEditingController(
      text: marks?.category ?? '',
    );
    final scoredController = TextEditingController(
      text: marks?.marksScored.toString() ?? '',
    );
    final totalController = TextEditingController(
      text: marks?.totalMarks.toString() ?? '',
    );

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(marks == null ? 'Add Marks' : 'Edit Marks'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: categoryController,
              decoration: const InputDecoration(labelText: 'Category'),
            ),
            TextField(
              controller: scoredController,
              decoration: const InputDecoration(labelText: 'Marks Scored'),
              keyboardType: TextInputType.number,
            ),
            TextField(
              controller: totalController,
              decoration: const InputDecoration(labelText: 'Total Marks'),
              keyboardType: TextInputType.number,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              final category = categoryController.text.trim();
              final scored = double.tryParse(scoredController.text) ?? 0.0;
              final total = double.tryParse(totalController.text) ?? 0.0;

              if (category.isEmpty || total <= 0) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Please fill all fields correctly'),
                  ),
                );
                return;
              }

              try {
                final apiService = LocalApiService();
                if (marks == null) {
                  await apiService.createMarks(
                    widget.subject.id,
                    category,
                    scored,
                    total,
                  );
                } else {
                  await apiService.updateMarks(
                    marks.id,
                    widget.subject.id,
                    category,
                    scored,
                    total,
                  );
                }

                Navigator.pop(context);
                await _loadMarks();
              } catch (e) {
                ScaffoldMessenger.of(
                  context,
                ).showSnackBar(SnackBar(content: Text('Error: $e')));
              }
            },
            child: Text(marks == null ? 'Add' : 'Update'),
          ),
        ],
      ),
    );
  }

  Future<void> _deleteMarks(Marks marks) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Marks'),
        content: Text(
          'Are you sure you want to delete marks for "${marks.category}"?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        final apiService = LocalApiService();
        await apiService.deleteMarks(marks.id);
        await _loadMarks();
      } catch (e) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error deleting marks: $e')));
      }
    }
  }

  // Attendance Dialog Methods
  void _showAddAttendanceDialog() {
    _showAttendanceDialog();
  }

  void _showEditAttendanceDialog(Attendance attendance) {
    _showAttendanceDialog(attendance: attendance);
  }

  void _showAttendanceDialog({Attendance? attendance}) {
    DateTime selectedDate = attendance?.date ?? DateTime.now();
    String status = attendance?.status ?? 'present';

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: Text(
            attendance == null ? 'Add Attendance' : 'Edit Attendance',
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                title: Text(
                  'Date: ${selectedDate.toIso8601String().split('T')[0]}',
                ),
                trailing: const Icon(Icons.calendar_today),
                onTap: () async {
                  final date = await showDatePicker(
                    context: context,
                    initialDate: selectedDate,
                    firstDate: DateTime(2020),
                    lastDate: DateTime.now(),
                  );
                  if (date != null) {
                    setDialogState(() {
                      selectedDate = date;
                    });
                  }
                },
              ),
              SwitchListTile(
                title: const Text('Present'),
                value: status == 'present',
                onChanged: (value) {
                  setDialogState(() {
                    status = value ? 'present' : 'absent';
                  });
                },
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                try {
                  final apiService = LocalApiService();

                  if (attendance == null) {
                    await apiService.createAttendance(
                      widget.subject.id,
                      status,
                      selectedDate,
                    );
                  } else {
                    await apiService.updateAttendance(
                      attendance.id,
                      widget.subject.id,
                      status,
                      selectedDate,
                    );
                  }

                  Navigator.pop(context);
                  await _loadAttendance();
                } catch (e) {
                  ScaffoldMessenger.of(
                    context,
                  ).showSnackBar(SnackBar(content: Text('Error: $e')));
                }
              },
              child: Text(attendance == null ? 'Add' : 'Update'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _deleteAttendance(Attendance attendance) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Attendance'),
        content: Text(
          'Are you sure you want to delete attendance for ${attendance.date.toIso8601String().split('T')[0]}?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        final apiService = LocalApiService();
        await apiService.deleteAttendance(attendance.id);
        await _loadAttendance();
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error deleting attendance: $e')),
        );
      }
    }
  }
}
