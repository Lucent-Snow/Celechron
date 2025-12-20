import 'package:get/get.dart';
import 'package:celechron/database/database_helper.dart';
import 'package:celechron/model/todo_item.dart';

class TodoController extends GetxController {
  final todoList = Get.find<RxList<TodoItem>>(tag: 'todoList');
  final _db = Get.find<DatabaseHelper>(tag: 'db');

  // 获取待办列表（未完成的）
  List<TodoItem> get activeTodoList =>
      todoList.where((item) => !item.isCompleted).toList();

  // 获取已完成列表
  List<TodoItem> get completedTodoList =>
      todoList.where((item) => item.isCompleted).toList();

  // 获取已逾期的待办（红色高亮）
  List<TodoItem> get overdueTodoList =>
      activeTodoList.where((item) => item.isOverdue).toList();

  // 获取今天截止的待办（橙色高亮）
  List<TodoItem> get dueTodayTodoList =>
      activeTodoList.where((item) => item.isDueToday && !item.isOverdue).toList();

  // 获取未来的待办
  List<TodoItem> get upcomingTodoList => activeTodoList
      .where((item) => !item.isOverdue && !item.isDueToday && item.deadline != null)
      .toList();

  // 获取没有截止时间的待办
  List<TodoItem> get noDeadlineTodoList =>
      activeTodoList.where((item) => item.deadline == null).toList();

  /// 保存TodoList到数据库
  Future<void> saveTodoList() async {
    await _db.setTodoItemList(todoList);
    await _db.setTodoItemListUpdateTime(DateTime.now());
  }

  /// 切换任务完成状态
  void toggleTodoCompletion(TodoItem item) {
    item.toggleCompleted();
    todoList.refresh();
    saveTodoList();
  }

  /// 添加新任务
  Future<void> addTodo(TodoItem item) async {
    todoList.add(item);
    todoList.refresh();
    await saveTodoList();
  }

  /// 更新任务
  Future<void> updateTodo(TodoItem item) async {
    int index = todoList.indexWhere((e) => e.uid == item.uid);
    if (index != -1) {
      todoList[index] = item;
      todoList.refresh();
      await saveTodoList();
    }
  }

  /// 删除任务
  Future<void> deleteTodo(TodoItem item) async {
    todoList.removeWhere((e) => e.uid == item.uid);
    todoList.refresh();
    await saveTodoList();
  }

  /// 排序TodoList
  /// 按优先级排序：逾期 > 今天 > 即将到来 > 无截止时间
  List<TodoItem> getSortedActiveTodoList() {
    var list = activeTodoList.toList();
    list.sort((a, b) {
      // 逾期的排最前
      if (a.isOverdue && !b.isOverdue) return -1;
      if (!a.isOverdue && b.isOverdue) return 1;

      // 今天截止的排第二
      if (a.isDueToday && !b.isDueToday) return -1;
      if (!a.isDueToday && b.isDueToday) return 1;

      // 有截止时间的比没有截止时间的优先
      if (a.deadline != null && b.deadline == null) return -1;
      if (a.deadline == null && b.deadline != null) return 1;

      // 都有截止时间，按时间排序
      if (a.deadline != null && b.deadline != null) {
        return a.deadline!.compareTo(b.deadline!);
      }

      // 都没有截止时间，按创建时间倒序
      return b.createdAt.compareTo(a.createdAt);
    });
    return list;
  }

  /// 获取已完成列表（按完成时间倒序）
  List<TodoItem> getSortedCompletedTodoList() {
    var list = completedTodoList.toList();
    list.sort((a, b) {
      if (a.completedAt != null && b.completedAt != null) {
        return b.completedAt!.compareTo(a.completedAt!);
      }
      return 0;
    });
    return list;
  }
}
