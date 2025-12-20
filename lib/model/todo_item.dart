import 'package:hive/hive.dart';
import 'package:uuid/uuid.dart';

@HiveType(typeId: 16)
class TodoItem {
  @HiveField(0)
  String uid;

  @HiveField(1)
  String title;

  @HiveField(2)
  DateTime? deadline;

  @HiveField(3)
  bool isCompleted;

  @HiveField(4)
  DateTime createdAt;

  @HiveField(5)
  DateTime? completedAt;

  @HiveField(6)
  String? sourceId; // 课程作业的来源ID（从"学在浙大"获取）

  @HiveField(7)
  String? courseName; // 课程名称

  @HiveField(8)
  String? notes; // 备注

  TodoItem({
    required this.uid,
    required this.title,
    this.deadline,
    this.isCompleted = false,
    required this.createdAt,
    this.completedAt,
    this.sourceId,
    this.courseName,
    this.notes,
  });

  // 生成新的UUID
  void genUid() {
    uid = const Uuid().v4();
  }

  // 是否已逾期
  bool get isOverdue {
    if (isCompleted || deadline == null) return false;
    return DateTime.now().isAfter(deadline!);
  }

  // 是否今天截止
  bool get isDueToday {
    if (isCompleted || deadline == null) return false;
    final now = DateTime.now();
    final deadlineDate = DateTime(deadline!.year, deadline!.month, deadline!.day);
    final today = DateTime(now.year, now.month, now.day);
    return deadlineDate == today;
  }

  // 是否是课程作业
  bool get isCourseAssignment => sourceId != null;

  // 切换完成状态
  void toggleCompleted() {
    isCompleted = !isCompleted;
    completedAt = isCompleted ? DateTime.now() : null;
  }

  // 复制对象
  TodoItem copyWith({
    String? uid,
    String? title,
    DateTime? deadline,
    bool? isCompleted,
    DateTime? createdAt,
    DateTime? completedAt,
    String? sourceId,
    String? courseName,
    String? notes,
  }) {
    return TodoItem(
      uid: uid ?? this.uid,
      title: title ?? this.title,
      deadline: deadline ?? this.deadline,
      isCompleted: isCompleted ?? this.isCompleted,
      createdAt: createdAt ?? this.createdAt,
      completedAt: completedAt ?? this.completedAt,
      sourceId: sourceId ?? this.sourceId,
      courseName: courseName ?? this.courseName,
      notes: notes ?? this.notes,
    );
  }
}
