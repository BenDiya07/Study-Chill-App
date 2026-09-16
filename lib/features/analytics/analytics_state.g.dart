// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'analytics_state.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class SessionRecordAdapter extends TypeAdapter<SessionRecord> {
  @override
  final int typeId = 1;

  @override
  SessionRecord read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return SessionRecord(
      id: fields[0] as String,
      taskId: fields[1] as String,
      category: fields[2] as String,
      durationSeconds: fields[3] as int,
      mode: fields[4] as TimerMode,
      timestamp: fields[5] as DateTime,
      completed: fields[6] as bool,
    );
  }

  @override
  void write(BinaryWriter writer, SessionRecord obj) {
    writer
      ..writeByte(7)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.taskId)
      ..writeByte(2)
      ..write(obj.category)
      ..writeByte(3)
      ..write(obj.durationSeconds)
      ..writeByte(4)
      ..write(obj.mode)
      ..writeByte(5)
      ..write(obj.timestamp)
      ..writeByte(6)
      ..write(obj.completed);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SessionRecordAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
