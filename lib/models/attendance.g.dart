// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'attendance.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class AttendanceRecordAdapter extends TypeAdapter<AttendanceRecord> {
  @override
  final int typeId = 1;

  @override
  AttendanceRecord read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return AttendanceRecord(
      id: fields[0] as String,
      studentId: fields[1] as String,
      date: fields[2] as DateTime,
      isPresent: fields[3] as bool,
    );
  }

  @override
  void write(BinaryWriter writer, AttendanceRecord obj) {
    writer
      ..writeByte(4)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.studentId)
      ..writeByte(2)
      ..write(obj.date)
      ..writeByte(3)
      ..write(obj.isPresent);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AttendanceRecordAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
