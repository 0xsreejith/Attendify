import 'dart:math';
import 'package:hive_flutter/hive_flutter.dart';
import '../models/student.dart';
import '../models/attendance.dart';

class HiveDatabaseHelper {
  static final HiveDatabaseHelper _instance = HiveDatabaseHelper._internal();
  static const String _studentsBox = 'students_box';
  static const String _attendanceBox = 'attendance_box';

  factory HiveDatabaseHelper() => _instance;

  HiveDatabaseHelper._internal();

  late Box<Student> _students;
  late Box<AttendanceRecord> _attendance;

  Future<void> init() async {
    // Register adapters if not already registered
    if (!Hive.isAdapterRegistered(0)) {
      Hive.registerAdapter(StudentAdapter());
    }
    if (!Hive.isAdapterRegistered(1)) {
      Hive.registerAdapter(AttendanceRecordAdapter());
    }
    
    // Initialize boxes
    _students = await Hive.openBox<Student>(_studentsBox);
    _attendance = await Hive.openBox<AttendanceRecord>(_attendanceBox);
    
    // Add dummy data if no students exist
    if (_students.isEmpty) {
      await _addDummyData();
    }
  }
  
  Future<void> _addDummyData() async {
    // Add some dummy students
    final dummyStudents = [
      Student.create(name: 'John Doe', rollNumber: 'S001', className: 'Class A'),
      Student.create(name: 'Jane Smith', rollNumber: 'S002', className: 'Class A'),
      Student.create(name: 'Mike Johnson', rollNumber: 'S003', className: 'Class B'),
      Student.create(name: 'Sarah Williams', rollNumber: 'S004', className: 'Class B'),
      Student.create(name: 'David Brown', rollNumber: 'S005', className: 'Class A'),
    ];
    
    // Save students
    for (var student in dummyStudents) {
      await _students.put(student.id, student);
    }
    
    // Add attendance records for the past 30 days
    final now = DateTime.now();
    final random = Random();
    
    for (var i = 0; i < 30; i++) {
      final date = now.subtract(Duration(days: 30 - i));
      
      for (var student in dummyStudents) {
        // 80% chance of being present
        final isPresent = random.nextDouble() < 0.8;
        
        final record = AttendanceRecord(
          id: '${student.id}_${date.toIso8601String().split('T')[0]}',
          studentId: student.id,
          date: date,
          isPresent: isPresent,
        );
        
        await _attendance.put(record.id, record);
      }
    }
  }

  // Student CRUD operations
  Future<String> insertStudent(Student student) async {
    await _students.put(student.id, student);
    return student.id;
  }

  Future<List<Student>> getStudents() async {
    return _students.values.toList();
  }

  Future<Student?> getStudent(String id) async {
    return _students.get(id);
  }

  Future<void> updateStudent(Student student) async {
    await _students.put(student.id, student);
  }

  Future<void> deleteStudent(String id) async {
    // Delete student
    await _students.delete(id);
    
    // Delete all attendance records for this student
    final recordsToDelete = _attendance.values
        .where((record) => record.studentId == id)
        .map((record) => record.id)
        .toList();
        
    await _attendance.deleteAll(recordsToDelete);
  }

  // Attendance CRUD operations
  Future<void> markAttendance(AttendanceRecord record) async {
    await _attendance.put(record.id, record);
  }

  Future<List<AttendanceRecord>> getAttendanceByDate(DateTime date) async {
    final startOfDay = DateTime(date.year, date.month, date.day);
    final endOfDay = startOfDay.add(const Duration(days: 1));
    
    return _attendance.values.where((record) => 
      record.date.isAfter(startOfDay) && record.date.isBefore(endOfDay)
    ).toList();
  }
  
  Future<List<AttendanceRecord>> getAttendanceInDateRange(DateTime start, DateTime end) async {
    return _attendance.values.where((record) => 
      !record.date.isBefore(start) && 
      !record.date.isAfter(end)
    ).toList();
  }

  Future<Map<String, bool>> getAttendanceForDate(DateTime date) async {
    final dateStr = date.toIso8601String().split('T')[0];
    final records = _attendance.values
        .where((record) => record.date.toIso8601String().startsWith(dateStr));
    
    final Map<String, bool> result = {};
    for (var record in records) {
      result[record.studentId] = record.isPresent;
    }
    return result;
  }

  Future<List<AttendanceRecord>> getStudentAttendance(String studentId) async {
    return _attendance.values
        .where((record) => record.studentId == studentId)
        .toList();
  }

  // Close all boxes
  Future<void> close() async {
    await _students.close();
    await _attendance.close();
  }

  // Clear all data (for testing)
  Future<void> clearAll() async {
    await _students.clear();
    await _attendance.clear();
  }
}
