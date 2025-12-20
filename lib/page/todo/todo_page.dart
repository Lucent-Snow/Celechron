import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:celechron/model/todo_item.dart';
import 'package:celechron/page/todo/todo_controller.dart';
import 'package:celechron/page/todo/todo_edit_page.dart';
import 'package:celechron/utils/utils.dart';

class TodoPage extends StatelessWidget {
  TodoPage({super.key});

  final _todoController = Get.put(TodoController());

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        middle: const Text('待办'),
        trailing: CupertinoButton(
          padding: EdgeInsets.zero,
          onPressed: () => _showAddTodoPage(context),
          child: const Icon(CupertinoIcons.add),
        ),
      ),
      child: SafeArea(
        child: Obx(() {
          var activeTodos = _todoController.getSortedActiveTodoList();
          var completedTodos = _todoController.getSortedCompletedTodoList();

          if (activeTodos.isEmpty && completedTodos.isEmpty) {
            return _buildEmptyState();
          }

          return CustomScrollView(
            slivers: [
              // 逾期任务
              if (_todoController.overdueTodoList.isNotEmpty) ...[
                _buildSectionHeader(context, '已逾期', CupertinoColors.systemRed),
                _buildTodoList(
                  context,
                  _todoController.overdueTodoList,
                  CupertinoColors.systemRed,
                ),
              ],

              // 今天截止
              if (_todoController.dueTodayTodoList.isNotEmpty) ...[
                _buildSectionHeader(context, '今天', CupertinoColors.systemOrange),
                _buildTodoList(
                  context,
                  _todoController.dueTodayTodoList,
                  CupertinoColors.systemOrange,
                ),
              ],

              // 即将到来
              if (_todoController.upcomingTodoList.isNotEmpty) ...[
                _buildSectionHeader(context, '即将到来', null),
                _buildTodoList(
                  context,
                  _todoController.upcomingTodoList,
                  null,
                ),
              ],

              // 无截止时间
              if (_todoController.noDeadlineTodoList.isNotEmpty) ...[
                _buildSectionHeader(context, '无截止时间', CupertinoColors.systemGrey),
                _buildTodoList(
                  context,
                  _todoController.noDeadlineTodoList,
                  CupertinoColors.systemGrey,
                ),
              ],

              // 已完成
              if (completedTodos.isNotEmpty) ...[
                _buildSectionHeader(context, '已完成', CupertinoColors.systemGrey),
                _buildTodoList(
                  context,
                  completedTodos,
                  CupertinoColors.systemGrey,
                  isCompleted: true,
                ),
              ],

              // 底部留白
              const SliverPadding(padding: EdgeInsets.only(bottom: 20)),
            ],
          );
        }),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            CupertinoIcons.checkmark_circle,
            size: 80,
            color: CupertinoColors.systemGrey,
          ),
          const SizedBox(height: 16),
          Text(
            '暂无待办事项',
            style: TextStyle(
              fontSize: 18,
              color: CupertinoColors.systemGrey,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(BuildContext context, String title, Color? color) {
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 20, 16, 8),
        child: Text(
          title,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: color ?? CupertinoDynamicColor.resolve(
              CupertinoColors.label,
              context,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTodoList(
    BuildContext context,
    List<TodoItem> todos,
    Color? accentColor, {
    bool isCompleted = false,
  }) {
    return SliverList(
      delegate: SliverChildBuilderDelegate(
        (context, index) {
          var todo = todos[index];
          return Dismissible(
            key: Key(todo.uid),
            direction: DismissDirection.endToStart, // 从右往左滑删除
            background: Container(
              color: CupertinoColors.systemRed,
              alignment: Alignment.centerRight,
              padding: const EdgeInsets.only(right: 20),
              child: const Icon(
                CupertinoIcons.delete,
                color: CupertinoColors.white,
              ),
            ),
            onDismissed: (direction) {
              _todoController.deleteTodo(todo);
            },
            child: _buildTodoCard(context, todo, accentColor, isCompleted),
          );
        },
        childCount: todos.length,
      ),
    );
  }

  Widget _buildTodoCard(
    BuildContext context,
    TodoItem todo,
    Color? accentColor,
    bool isCompleted,
  ) {
    return GestureDetector(
      onTap: () => _showTodoDetail(context, todo),
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: CupertinoDynamicColor.resolve(
            CupertinoColors.secondarySystemGroupedBackground,
            context,
          ),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          children: [
            // 完成状态圆圈
            GestureDetector(
              onTap: () => _todoController.toggleTodoCompletion(todo),
              child: Container(
                width: 24,
                height: 24,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: accentColor ?? CupertinoColors.systemGrey,
                    width: 2,
                  ),
                  color: isCompleted
                      ? (accentColor ?? CupertinoColors.systemGrey)
                      : Colors.transparent,
                ),
                child: isCompleted
                    ? const Icon(
                        CupertinoIcons.checkmark,
                        size: 14,
                        color: CupertinoColors.white,
                      )
                    : null,
              ),
            ),
            const SizedBox(width: 12),

            // 任务内容
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 标题
                  Text(
                    todo.title,
                    style: TextStyle(
                      fontSize: 16,
                      decoration: isCompleted
                          ? TextDecoration.lineThrough
                          : TextDecoration.none,
                      color: isCompleted
                          ? CupertinoColors.systemGrey
                          : CupertinoDynamicColor.resolve(
                              CupertinoColors.label,
                              context,
                            ),
                    ),
                  ),

                  // 课程名称（如果是课程作业）
                  if (todo.courseName != null) ...[
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        const Text(
                          '📚 ',
                          style: TextStyle(fontSize: 12),
                        ),
                        Flexible(
                          child: Text(
                            todo.courseName!,
                            style: TextStyle(
                              fontSize: 12,
                              color: CupertinoColors.systemGrey,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ],

                  // 截止时间或完成时间
                  if (todo.deadline != null || isCompleted) ...[
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(
                          isCompleted
                              ? CupertinoIcons.checkmark_alt
                              : CupertinoIcons.clock,
                          size: 12,
                          color: accentColor ?? CupertinoColors.systemGrey,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          isCompleted
                              ? (todo.completedAt != null
                                  ? _formatCompletedTime(todo.completedAt!)
                                  : '已完成')
                              : (todo.deadline != null
                                  ? _formatDeadline(todo.deadline!)
                                  : ''),
                          style: TextStyle(
                            fontSize: 12,
                            color: accentColor ?? CupertinoColors.systemGrey,
                          ),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatDeadline(DateTime deadline) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final deadlineDate = DateTime(deadline.year, deadline.month, deadline.day);

    final diff = deadlineDate.difference(today).inDays;

    if (diff < 0) {
      return '${-diff} 天前';
    } else if (diff == 0) {
      return '今天 ${deadline.hour.toString().padLeft(2, '0')}:${deadline.minute.toString().padLeft(2, '0')}';
    } else if (diff == 1) {
      return '明天 ${deadline.hour.toString().padLeft(2, '0')}:${deadline.minute.toString().padLeft(2, '0')}';
    } else if (diff <= 7) {
      return '$diff 天后';
    } else {
      return toStringHumanReadable(deadline);
    }
  }

  String _formatCompletedTime(DateTime completedAt) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final completedDate =
        DateTime(completedAt.year, completedAt.month, completedAt.day);

    final diff = today.difference(completedDate).inDays;

    if (diff == 0) {
      return '今天完成';
    } else if (diff == 1) {
      return '昨天完成';
    } else if (diff <= 7) {
      return '$diff 天前完成';
    } else {
      return toStringHumanReadable(completedAt);
    }
  }

  void _showAddTodoPage(BuildContext context) {
    Navigator.of(context).push(
      CupertinoPageRoute(
        builder: (context) => const TodoEditPage(),
      ),
    );
  }

  void _showTodoDetail(BuildContext context, TodoItem todo) {
    Navigator.of(context).push(
      CupertinoPageRoute(
        builder: (context) => TodoEditPage(todoItem: todo),
      ),
    );
  }
}
