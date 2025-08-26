import 'package:hive/hive.dart';

part 'student.g.dart';

@HiveType(typeId: 0)
class Student extends HiveObject {
  @HiveField(0)
  String id;
  @HiveField(1)
  String name;
  @HiveField(2)
  String rollNumber;
  @HiveField(3)
  String className;

  Student({
    required this.id,
    required this.name,
    required this.rollNumber,
    required this.className,
  });

  // Add a named constructor for creating a Student without an ID
  Student.create({
    required this.name,
    required this.rollNumber,
    required this.className,
  }) : id = DateTime.now().millisecondsSinceEpoch.toString();

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'rollNumber': rollNumber,
      'className': className,
    };
  }

  factory Student.fromMap(Map<String, dynamic> map) {
    return Student(
      id: map['id'],
      name: map['name'],
      rollNumber: map['rollNumber'],
      className: map['className'],
    );
  }
}
