import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:celechron/model/custom_session.dart';
import 'package:celechron/model/scholar.dart';
import 'package:celechron/model/semester.dart';

/// 课程编辑页面
/// 用于创建新课程或编辑现有课程
class CourseEditPage extends StatefulWidget {
  /// 要编辑的课程，如果为 null 则创建新课程
  final CustomSession? session;

  /// 当前学期名称（用于新建课程时的默认值）
  final String? defaultSemesterName;

  const CourseEditPage({
    super.key,
    this.session,
    this.defaultSemesterName,
  });

  @override
  State<CourseEditPage> createState() => _CourseEditPageState();
}

class _CourseEditPageState extends State<CourseEditPage> {
  late CustomSession _session;
  late TextEditingController _nameController;
  late TextEditingController _teacherController;
  late TextEditingController _locationController;
  bool _isInitialized = false;

  // 获取学期列表
  List<Semester> get _semesters {
    final scholar = Get.find<Rx<Scholar>>(tag: 'scholar').value;
    return scholar.semesters;
  }

  // 获取当前选中学期
  Semester? get _currentSemester {
    return _semesters.firstWhereOrNull((s) => s.name == _session.semesterName);
  }

  @override
  void initState() {
    super.initState();
    _initSession();
  }

  void _initSession() {
    if (widget.session != null) {
      // 编辑现有课程
      _session = widget.session!.copyWith();
    } else {
      // 创建新课程
      final defaultSemester = widget.defaultSemesterName ??
          (_semesters.isNotEmpty ? _semesters.first.name : '');
      _session = CustomSession(
        name: '',
        dayOfWeek: 1,
        time: [1, 2],
        semesterName: defaultSemester,
      );
    }

    _nameController = TextEditingController(text: _session.name);
    _teacherController = TextEditingController(text: _session.teacher);
    _locationController = TextEditingController(text: _session.location ?? '');
    _isInitialized = true;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _teacherController.dispose();
    _locationController.dispose();
    super.dispose();
  }

  void _saveAndExit() {
    // 验证必填字段
    if (_session.name.trim().isEmpty) {
      _showAlert('请输入课程名称');
      return;
    }

    if (_session.semesterName.isEmpty) {
      _showAlert('请选择学期');
      return;
    }

    if (_session.time.isEmpty) {
      _showAlert('请选择上课节次');
      return;
    }

    // 更新最后修改时间
    _session = _session.copyWith(lastModifiedTime: DateTime.now());

    Navigator.of(context).pop(_session);
  }

  void _deleteAndExit() {
    showCupertinoDialog(
      context: context,
      builder: (context) => CupertinoAlertDialog(
        title: const Text('确认删除'),
        content: const Text('删除后无法恢复，是否继续？'),
        actions: [
          CupertinoDialogAction(
            child: const Text('取消'),
            onPressed: () => Navigator.of(context).pop(),
          ),
          CupertinoDialogAction(
            isDestructiveAction: true,
            child: const Text('删除'),
            onPressed: () {
              Navigator.of(context).pop();
              // 返回 null 表示删除
              Navigator.of(this.context).pop(null);
            },
          ),
        ],
      ),
    );
  }

  void _exitWithoutSave() {
    Navigator.of(context).pop();
  }

  void _showAlert(String message) {
    showCupertinoDialog(
      context: context,
      builder: (context) => CupertinoAlertDialog(
        title: Text(message),
        actions: [
          CupertinoDialogAction(
            child: const Text('确定'),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (!_isInitialized) {
      return const CupertinoPageScaffold(
        child: Center(child: CupertinoActivityIndicator()),
      );
    }

    final isEditing = widget.session != null;
    final weekDays = ['', '周一', '周二', '周三', '周四', '周五', '周六', '周日'];

    return CupertinoPageScaffold(
      backgroundColor: CupertinoColors.systemGroupedBackground,
      navigationBar: CupertinoNavigationBar(
        backgroundColor: CupertinoDynamicColor.resolve(
            CupertinoColors.systemGroupedBackground, context),
        leading: CupertinoButton(
          padding: EdgeInsets.zero,
          onPressed: _exitWithoutSave,
          child: const Icon(CupertinoIcons.xmark),
        ),
        middle: Text(isEditing ? '编辑课程' : '新建课程'),
        trailing: CupertinoButton(
          padding: EdgeInsets.zero,
          onPressed: _saveAndExit,
          child: const Icon(CupertinoIcons.check_mark),
        ),
        border: null,
      ),
      child: SafeArea(
        child: CustomScrollView(
          slivers: [
            SliverList(
              delegate: SliverChildListDelegate([
                // 基本信息
                CupertinoListSection.insetGrouped(
                  header: const Text('基本信息'),
                  children: [
                    CupertinoTextFormFieldRow(
                      placeholder: '课程名称',
                      controller: _nameController,
                      onChanged: (value) {
                        _session = _session.copyWith(name: value);
                      },
                    ),
                    CupertinoTextFormFieldRow(
                      placeholder: '教师',
                      controller: _teacherController,
                      onChanged: (value) {
                        _session = _session.copyWith(teacher: value);
                      },
                    ),
                    CupertinoTextFormFieldRow(
                      placeholder: '地点',
                      controller: _locationController,
                      onChanged: (value) {
                        _session = _session.copyWith(
                            location: value.isEmpty ? null : value);
                      },
                    ),
                  ],
                ),

                // 学期选择
                CupertinoListSection.insetGrouped(
                  header: const Text('学期'),
                  children: [
                    CupertinoListTile(
                      title: const Text('所属学期'),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            _session.semesterName.isNotEmpty
                                ? _session.semesterName
                                : '请选择',
                            style: TextStyle(
                              color: CupertinoDynamicColor.resolve(
                                  CupertinoColors.secondaryLabel, context),
                            ),
                          ),
                          const SizedBox(width: 4),
                          Icon(
                            CupertinoIcons.chevron_right,
                            size: 16,
                            color: CupertinoDynamicColor.resolve(
                                CupertinoColors.tertiaryLabel, context),
                          ),
                        ],
                      ),
                      onTap: () => _showSemesterPicker(),
                    ),
                  ],
                ),

                // 时间设置
                CupertinoListSection.insetGrouped(
                  header: const Text('上课时间'),
                  children: [
                    CupertinoListTile(
                      title: const Text('星期'),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            weekDays[_session.dayOfWeek],
                            style: TextStyle(
                              color: CupertinoDynamicColor.resolve(
                                  CupertinoColors.secondaryLabel, context),
                            ),
                          ),
                          const SizedBox(width: 4),
                          Icon(
                            CupertinoIcons.chevron_right,
                            size: 16,
                            color: CupertinoDynamicColor.resolve(
                                CupertinoColors.tertiaryLabel, context),
                          ),
                        ],
                      ),
                      onTap: () => _showDayOfWeekPicker(),
                    ),
                    CupertinoListTile(
                      title: const Text('节次'),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            _session.time.length == 1
                                ? '第${_session.time.first}节'
                                : '第${_session.time.first}-${_session.time.last}节',
                            style: TextStyle(
                              color: CupertinoDynamicColor.resolve(
                                  CupertinoColors.secondaryLabel, context),
                            ),
                          ),
                          const SizedBox(width: 4),
                          Icon(
                            CupertinoIcons.chevron_right,
                            size: 16,
                            color: CupertinoDynamicColor.resolve(
                                CupertinoColors.tertiaryLabel, context),
                          ),
                        ],
                      ),
                      onTap: () => _showTimePicker(),
                    ),
                  ],
                ),

                // 周次设置
                CupertinoListSection.insetGrouped(
                  header: const Text('周次设置'),
                  children: [
                    CupertinoListTile(
                      title: const Text('单周'),
                      trailing: CupertinoSwitch(
                        value: _session.oddWeek,
                        onChanged: (value) {
                          setState(() {
                            _session = _session.copyWith(oddWeek: value);
                          });
                        },
                      ),
                    ),
                    CupertinoListTile(
                      title: const Text('双周'),
                      trailing: CupertinoSwitch(
                        value: _session.evenWeek,
                        onChanged: (value) {
                          setState(() {
                            _session = _session.copyWith(evenWeek: value);
                          });
                        },
                      ),
                    ),
                  ],
                ),

                // 学期半段设置
                CupertinoListSection.insetGrouped(
                  header: const Text('学期半段'),
                  footer: const Text('选择课程在学期的哪个半段上课'),
                  children: [
                    CupertinoListTile(
                      title: Text(_currentSemester != null
                          ? '${_currentSemester!.firstHalfName}学期'
                          : '上半学期'),
                      trailing: CupertinoSwitch(
                        value: _session.firstHalf,
                        onChanged: (value) {
                          setState(() {
                            _session = _session.copyWith(firstHalf: value);
                          });
                        },
                      ),
                    ),
                    CupertinoListTile(
                      title: Text(_currentSemester != null
                          ? '${_currentSemester!.secondHalfName}学期'
                          : '下半学期'),
                      trailing: CupertinoSwitch(
                        value: _session.secondHalf,
                        onChanged: (value) {
                          setState(() {
                            _session = _session.copyWith(secondHalf: value);
                          });
                        },
                      ),
                    ),
                  ],
                ),

                // 删除按钮（仅编辑模式）
                if (isEditing)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 20),
                    child: CupertinoButton(
                      onPressed: _deleteAndExit,
                      child: const Text(
                        '删除课程',
                        style: TextStyle(
                          color: CupertinoColors.systemPink,
                        ),
                      ),
                    ),
                  ),

                const SizedBox(height: 40),
              ]),
            ),
          ],
        ),
      ),
    );
  }

  void _showSemesterPicker() {
    final semesters = _semesters;
    if (semesters.isEmpty) {
      _showAlert('暂无学期数据，请先刷新教务数据');
      return;
    }

    int selectedIndex =
        semesters.indexWhere((s) => s.name == _session.semesterName);
    if (selectedIndex < 0) selectedIndex = 0;

    showCupertinoModalPopup(
      context: context,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height / 3,
        color: CupertinoDynamicColor.resolve(
            CupertinoColors.systemBackground, context),
        child: CupertinoPicker(
          itemExtent: 32,
          scrollController:
              FixedExtentScrollController(initialItem: selectedIndex),
          onSelectedItemChanged: (index) {
            setState(() {
              _session = _session.copyWith(semesterName: semesters[index].name);
            });
          },
          children: semesters
              .map((s) => Center(child: Text(s.name)))
              .toList(),
        ),
      ),
    );
  }

  void _showDayOfWeekPicker() {
    final weekDays = ['周一', '周二', '周三', '周四', '周五', '周六', '周日'];

    showCupertinoModalPopup(
      context: context,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height / 3,
        color: CupertinoDynamicColor.resolve(
            CupertinoColors.systemBackground, context),
        child: CupertinoPicker(
          itemExtent: 32,
          scrollController:
              FixedExtentScrollController(initialItem: _session.dayOfWeek - 1),
          onSelectedItemChanged: (index) {
            setState(() {
              _session = _session.copyWith(dayOfWeek: index + 1);
            });
          },
          children: weekDays.map((d) => Center(child: Text(d))).toList(),
        ),
      ),
    );
  }

  void _showTimePicker() {
    int startTime = _session.time.isNotEmpty ? _session.time.first : 1;
    int endTime = _session.time.isNotEmpty ? _session.time.last : 2;

    showCupertinoModalPopup(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) => Container(
          height: MediaQuery.of(context).size.height / 3,
          color: CupertinoDynamicColor.resolve(
              CupertinoColors.systemBackground, context),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  children: [
                    const Padding(
                      padding: EdgeInsets.all(8.0),
                      child: Text('开始节次'),
                    ),
                    Expanded(
                      child: CupertinoPicker(
                        itemExtent: 32,
                        scrollController: FixedExtentScrollController(
                            initialItem: startTime - 1),
                        onSelectedItemChanged: (index) {
                          setModalState(() {
                            startTime = index + 1;
                            if (endTime < startTime) {
                              endTime = startTime;
                            }
                          });
                          setState(() {
                            _session = _session.copyWith(
                              time: List.generate(
                                  endTime - startTime + 1, (i) => startTime + i),
                            );
                          });
                        },
                        children: List.generate(
                          13,
                          (index) => Center(child: Text('第${index + 1}节')),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Column(
                  children: [
                    const Padding(
                      padding: EdgeInsets.all(8.0),
                      child: Text('结束节次'),
                    ),
                    Expanded(
                      child: CupertinoPicker(
                        itemExtent: 32,
                        scrollController: FixedExtentScrollController(
                            initialItem: endTime - 1),
                        onSelectedItemChanged: (index) {
                          setModalState(() {
                            endTime = index + 1;
                            if (endTime < startTime) {
                              startTime = endTime;
                            }
                          });
                          setState(() {
                            _session = _session.copyWith(
                              time: List.generate(
                                  endTime - startTime + 1, (i) => startTime + i),
                            );
                          });
                        },
                        children: List.generate(
                          13,
                          (index) => Center(child: Text('第${index + 1}节')),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
