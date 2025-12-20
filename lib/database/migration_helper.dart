import 'package:celechron/database/database_helper.dart';
import 'package:celechron/model/task.dart';
import 'package:celechron/model/todo_item.dart';

class TodoMigration {
  /// 将旧的Task系统迁移到新的TodoItem系统
  /// 只迁移DDL类型的任务,fixed类型的任务将被丢弃
  static Future<void> migrateTasksToTodoItems(DatabaseHelper db) async {
    // 检查是否已经迁移过
    if (db.optionsBox.get('todoMigrationCompleted') == true) {
      return;
    }

    // 获取现有的Task列表
    List<Task> oldTasks = db.getTaskList();
    List<TodoItem> newTodoItems = [];

    // 遍历所有任务
    for (Task task in oldTasks) {
      // 只迁移deadline类型的任务
      if (task.type == TaskType.deadline) {
        newTodoItems.add(TodoItem(
          uid: task.uid, // 保留原来的UID
          title: task.summary,
          deadline: task.endTime,
          isCompleted: task.status == TaskStatus.completed,
          createdAt: DateTime.now(), // 没有原始创建时间,使用当前时间
          completedAt: task.status == TaskStatus.completed ? DateTime.now() : null,
          sourceId: null, // 旧任务都是用户创建的,不是课程作业
          courseName: null,
          notes: task.description.isNotEmpty ? task.description : null,
        ));
      }
      // fixed和fixedlegacy类型的任务:直接忽略(完全移除)
      // 不进行任何操作,它们不会被迁移到新系统
    }

    // 保存新的TodoItem列表
    await db.setTodoItemList(newTodoItems);
    await db.setTodoItemListUpdateTime(DateTime.now());

    // 标记迁移已完成
    await db.optionsBox.put('todoMigrationCompleted', true);

    // 可选:保存旧数据的备份,以便回滚
    // await db.taskBox.put('backupBeforeMigration', oldTasks);

    // ignore: avoid_print
    print('任务迁移完成: ${newTodoItems.length} 个DDL任务已迁移到新系统');
  }

  /// 回滚迁移(紧急情况下使用)
  static Future<void> rollbackMigration(DatabaseHelper db) async {
    // 清空TodoItem
    await db.setTodoItemList([]);

    // 重置迁移标志
    await db.optionsBox.delete('todoMigrationCompleted');

    // 如果有备份,可以恢复
    // var backup = db.taskBox.get('backupBeforeMigration');
    // if (backup != null) {
    //   await db.setTaskList(backup);
    // }

    // ignore: avoid_print
    print('迁移已回滚');
  }
}
