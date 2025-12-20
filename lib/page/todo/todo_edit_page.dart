import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:celechron/model/todo_item.dart';
import 'package:celechron/page/todo/todo_controller.dart';
import 'package:celechron/utils/utils.dart';
import 'package:uuid/uuid.dart';

class TodoEditPage extends StatefulWidget {
  final TodoItem? todoItem; // null表示新建，非null表示编辑

  const TodoEditPage({super.key, this.todoItem});

  @override
  State<TodoEditPage> createState() => _TodoEditPageState();
}

class _TodoEditPageState extends State<TodoEditPage> {
  final _todoController = Get.find<TodoController>();
  final _titleController = TextEditingController();
  final _notesController = TextEditingController();

  DateTime? _selectedDeadline;
  bool _isEditing = false;

  @override
  void initState() {
    super.initState();
    _isEditing = widget.todoItem != null;

    if (_isEditing) {
      _titleController.text = widget.todoItem!.title;
      _notesController.text = widget.todoItem!.notes ?? '';
      _selectedDeadline = widget.todoItem!.deadline;
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        middle: Text(_isEditing ? '编辑待办' : '新建待办'),
        leading: CupertinoButton(
          padding: EdgeInsets.zero,
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('取消'),
        ),
        trailing: CupertinoButton(
          padding: EdgeInsets.zero,
          onPressed: _canSave() ? _saveTodo : null,
          child: Text(
            '保存',
            style: TextStyle(
              color: _canSave()
                  ? CupertinoColors.activeBlue
                  : CupertinoColors.systemGrey,
            ),
          ),
        ),
      ),
      child: SafeArea(
        child: ListView(
          children: [
            const SizedBox(height: 20),

            // 如果是课程作业，显示来源信息
            if (_isEditing && widget.todoItem!.isCourseAssignment) ...[
              _buildInfoSection(),
              const SizedBox(height: 20),
            ],

            // 标题输入
            _buildSection(
              title: '标题',
              child: CupertinoTextField(
                controller: _titleController,
                placeholder: '输入任务标题',
                onChanged: (_) => setState(() {}),
              ),
            ),
            const SizedBox(height: 20),

            // 截止时间选择
            _buildSection(
              title: '截止时间（可选）',
              child: Column(
                children: [
                  CupertinoButton(
                    padding: EdgeInsets.zero,
                    onPressed: () => _showDatePicker(context),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: CupertinoColors.systemGrey6,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            _selectedDeadline == null
                                ? '设置截止时间'
                                : toStringHumanReadable(_selectedDeadline!),
                            style: TextStyle(
                              color: _selectedDeadline == null
                                  ? CupertinoColors.systemGrey
                                  : CupertinoColors.label,
                            ),
                          ),
                          const Icon(
                            CupertinoIcons.calendar,
                            size: 20,
                          ),
                        ],
                      ),
                    ),
                  ),
                  if (_selectedDeadline != null) ...[
                    const SizedBox(height: 8),
                    CupertinoButton(
                      padding: EdgeInsets.zero,
                      onPressed: () => setState(() => _selectedDeadline = null),
                      child: const Text(
                        '清除截止时间',
                        style: TextStyle(
                          color: CupertinoColors.systemRed,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 20),

            // 备注输入
            _buildSection(
              title: '备注（可选）',
              child: CupertinoTextField(
                controller: _notesController,
                placeholder: '添加备注',
                maxLines: 5,
                onChanged: (_) => setState(() {}),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildSection({required String title, required Widget child}) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: CupertinoColors.systemGrey,
            ),
          ),
          const SizedBox(height: 8),
          child,
        ],
      ),
    );
  }

  Widget _buildInfoSection() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: CupertinoColors.systemGrey6,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Text(
                  '📚 ',
                  style: TextStyle(fontSize: 16),
                ),
                Expanded(
                  child: Text(
                    widget.todoItem!.courseName ?? '课程作业',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            const Text(
              '此任务来自"学在浙大"系统',
              style: TextStyle(
                fontSize: 12,
                color: CupertinoColors.systemGrey,
              ),
            ),
          ],
        ),
      ),
    );
  }

  bool _canSave() {
    return _titleController.text.trim().isNotEmpty;
  }

  void _showDatePicker(BuildContext context) {
    DateTime initialDate = _selectedDeadline ?? DateTime.now();

    showCupertinoModalPopup(
      context: context,
      builder: (BuildContext context) {
        DateTime tempDate = initialDate;
        return Container(
          height: 300,
          color: CupertinoColors.systemBackground.resolveFrom(context),
          child: Column(
            children: [
              Container(
                height: 50,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    CupertinoButton(
                      padding: EdgeInsets.zero,
                      onPressed: () => Navigator.of(context).pop(),
                      child: const Text('取消'),
                    ),
                    CupertinoButton(
                      padding: EdgeInsets.zero,
                      onPressed: () {
                        setState(() => _selectedDeadline = tempDate);
                        Navigator.of(context).pop();
                      },
                      child: const Text('确定'),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: CupertinoDatePicker(
                  mode: CupertinoDatePickerMode.dateAndTime,
                  initialDateTime: initialDate,
                  minimumDate: DateTime.now().subtract(const Duration(days: 1)),
                  onDateTimeChanged: (DateTime newDate) {
                    tempDate = newDate;
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _saveTodo() {
    if (!_canSave()) return;

    if (_isEditing) {
      // 更新现有待办
      final updatedTodo = widget.todoItem!.copyWith(
        title: _titleController.text.trim(),
        deadline: _selectedDeadline,
        notes: _notesController.text.trim().isEmpty
            ? null
            : _notesController.text.trim(),
      );
      _todoController.updateTodo(updatedTodo);
    } else {
      // 创建新待办
      final newTodo = TodoItem(
        uid: const Uuid().v4(),
        title: _titleController.text.trim(),
        deadline: _selectedDeadline,
        isCompleted: false,
        createdAt: DateTime.now(),
        completedAt: null,
        sourceId: null,
        courseName: null,
        notes: _notesController.text.trim().isEmpty
            ? null
            : _notesController.text.trim(),
      );
      _todoController.addTodo(newTodo);
    }

    Navigator.of(context).pop();
  }
}
