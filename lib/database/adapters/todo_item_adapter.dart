import 'package:hive/hive.dart';
import 'package:celechron/model/todo_item.dart';

class TodoItemAdapter extends TypeAdapter<TodoItem> {
  @override
  final typeId = 16;

  @override
  void write(BinaryWriter writer, TodoItem obj) {
    writer
      ..writeByte(9) // 9个字段
      ..writeByte(0)
      ..write(obj.uid)
      ..writeByte(1)
      ..write(obj.title)
      ..writeByte(2)
      ..write(obj.deadline)
      ..writeByte(3)
      ..write(obj.isCompleted)
      ..writeByte(4)
      ..write(obj.createdAt)
      ..writeByte(5)
      ..write(obj.completedAt)
      ..writeByte(6)
      ..write(obj.sourceId)
      ..writeByte(7)
      ..write(obj.courseName)
      ..writeByte(8)
      ..write(obj.notes);
  }

  @override
  TodoItem read(BinaryReader reader) {
    var numOfFields = reader.readByte();
    var fields = <int, dynamic>{
      for (var i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return TodoItem(
      uid: fields[0] as String,
      title: fields[1] as String,
      deadline: fields[2] as DateTime?,
      isCompleted: fields[3] as bool? ?? false,
      createdAt: fields[4] as DateTime,
      completedAt: fields[5] as DateTime?,
      sourceId: fields[6] as String?,
      courseName: fields[7] as String?,
      notes: fields[8] as String?,
    );
  }
}
