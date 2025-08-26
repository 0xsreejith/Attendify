import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/student.dart';
import '../models/attendance.dart';
import '../services/hive_database_helper.dart';
import 'add_student_screen.dart';
import 'attendance_report_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late HiveDatabaseHelper _databaseHelper;
  List<Student> _students = [];
  Map<String, bool> _attendanceStatus = {};
  DateTime _selectedDate = DateTime.now();
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _databaseHelper = Provider.of<HiveDatabaseHelper>(context, listen: false);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadData();
    });
  }

  Future<void> _loadData() async {
    if (mounted) {
      setState(() => _isLoading = true);
    }
    
    try {
      // Load students
      _students = await _databaseHelper.getStudents();
      
      // Load today's attendance
      _attendanceStatus = await _databaseHelper.getAttendanceForDate(_selectedDate);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading data: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _markAttendance(String studentId, bool isPresent) async {
    final record = AttendanceRecord(
      id: '${studentId}_${_selectedDate.toIso8601String()}',
      studentId: studentId,
      date: _selectedDate,
      isPresent: isPresent,
    );

    await _databaseHelper.markAttendance(record);
    setState(() {
      _attendanceStatus[studentId] = isPresent;
    });

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Attendance ${isPresent ? 'marked' : 'updated'}!')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Student Attendance'),
        actions: [
          IconButton(
            icon: const Icon(Icons.calendar_today),
            onPressed: _showDatePicker,
          ),
          IconButton(
            icon: const Icon(Icons.bar_chart),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const AttendanceReportScreen(),
                ),
              );
            },
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _students.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text('No students added yet!'),
                      const SizedBox(height: 10),
                      ElevatedButton(
                        onPressed: _navigateToAddStudent,
                        child: const Text('Add First Student'),
                      ),
                    ],
                  ),
                )
              : ListView.builder(
                  itemCount: _students.length,
                  itemBuilder: (context, index) {
                    final student = _students[index];
                    final isPresent = _attendanceStatus[student.id] ?? false;

                    return Card(
                      margin: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 5,
                      ),
                      child: ListTile(
                        title: Text(student.name),
                        subtitle: Text('Roll No: ${student.rollNumber} | ${student.className}'),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(isPresent ? 'Present' : 'Absent',
                                style: TextStyle(
                                    color: isPresent ? Colors.green : Colors.red)),
                            Checkbox(
                              value: isPresent,
                              onChanged: (value) {
                                _markAttendance(student.id, value ?? false);
                              },
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
      floatingActionButton: FloatingActionButton(
        onPressed: _navigateToAddStudent,
        child: const Icon(Icons.person_add),
      ),
    );
  }

  Future<void> _showDatePicker() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );

    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
      _loadData();
    }
  }

  void _navigateToAddStudent() async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const AddStudentScreen()),
    );
    _loadData();
  }
}
