import 'package:intl/intl.dart';

import 'package:hive/hive.dart';

part 'attendance.g.dart';

@HiveType(typeId: 1)
class AttendanceRecord extends HiveObject {
  @HiveField(0)
  String id;
  @HiveField(1)
  String studentId;
  @HiveField(2)
  final DateTime date;
  @HiveField(3)
  bool isPresent;

  AttendanceRecord({
    required this.id,
    required this.studentId,
    required this.date,
    required this.isPresent,
  });

  // Helper constructor for creating a new attendance record
  AttendanceRecord.create({
    required this.studentId,
    required this.date,
    required this.isPresent,
  }) : id = '${studentId}_${date.toIso8601String()}';

  String get formattedDate => DateFormat('yyyy-MM-dd').format(date);

  // Convert to a map for compatibility with existing code
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'studentId': studentId,
      'date': date.toIso8601String(),
      'isPresent': isPresent ? 1 : 0,
    };
  }

  // Factory to create from map for compatibility with existing code
  factory AttendanceRecord.fromMap(Map<String, dynamic> map) {
    return AttendanceRecord(
      id: map['id'],
      studentId: map['studentId'],
      date: DateTime.parse(map['date']),
      isPresent: map['isPresent'] == 1,
    );
  }
}

class DailyAttendance {
  final DateTime date;
  final Map<String, bool> attendanceStatus; // studentId -> isPresent

  DailyAttendance({
    required this.date,
    required this.attendanceStatus,
  });

  String get formattedDate => DateFormat('yyyy-MM-dd').format(date);
}
