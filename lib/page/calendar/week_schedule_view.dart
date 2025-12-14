import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:celechron/model/period.dart';
import 'package:celechron/design/custom_colors.dart';
import 'package:celechron/page/scholar/course_detail/course_detail_view.dart';
import 'package:celechron/model/task.dart';
import 'package:celechron/page/task/task_edit_page.dart';
import 'package:celechron/page/task/task_controller.dart';
import 'calendar_controller.dart';

/// 周视图日程表
/// 类似 Google Calendar 的周视图，显示一周内的所有日程
class WeekScheduleView extends StatefulWidget {
  const WeekScheduleView({super.key});

  @override
  State<WeekScheduleView> createState() => _WeekScheduleViewState();
}

class _WeekScheduleViewState extends State<WeekScheduleView> {
  final CalendarController _calendarController = Get.find<CalendarController>();
  final TaskController _taskController = Get.find<TaskController>();
  final RxList<Task> _taskList = Get.find<RxList<Task>>(tag: 'taskList');

  late PageController _pageController;
  late DateTime _baseDate;
  static const int _initialPage = 1000;

  // 时间轴配置
  static const double _hourHeight = 60.0;
  static const double _timeAxisWidth = 50.0;
  static const int _startHour = 7;
  static const int _endHour = 23;

  @override
  void initState() {
    super.initState();
    _baseDate = _getWeekStart(DateTime.now());
    _pageController = PageController(initialPage: _initialPage);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  /// 获取某一周的周一日期
  DateTime _getWeekStart(DateTime date) {
    final weekday = date.weekday;
    return DateTime(date.year, date.month, date.day - (weekday - 1));
  }

  /// 根据页面索引获取周起始日期
  DateTime _getWeekStartForPage(int pageIndex) {
    final offset = pageIndex - _initialPage;
    return _baseDate.add(Duration(days: offset * 7));
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // 周导航栏
        _buildWeekNavigator(context),
        // 周视图主体
        Expanded(
          child: PageView.builder(
            controller: _pageController,
            onPageChanged: (index) {
              final weekStart = _getWeekStartForPage(index);
              _calendarController.focusedDay.value = weekStart;
            },
            itemBuilder: (context, index) {
              final weekStart = _getWeekStartForPage(index);
              return _buildWeekView(context, weekStart);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildWeekNavigator(BuildContext context) {
    return Obx(() {
      final focusedDay = _calendarController.focusedDay.value;
      final weekStart = _getWeekStart(focusedDay);

      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            CupertinoButton(
              padding: EdgeInsets.zero,
              child: const Icon(CupertinoIcons.chevron_left),
              onPressed: () {
                _pageController.previousPage(
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeInOut,
                );
              },
            ),
            Text(
              '${weekStart.month}/${weekStart.day} - ${weekStart.add(const Duration(days: 6)).month}/${weekStart.add(const Duration(days: 6)).day}',
              style: CupertinoTheme.of(context).textTheme.textStyle.copyWith(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
            ),
            CupertinoButton(
              padding: EdgeInsets.zero,
              child: const Icon(CupertinoIcons.chevron_right),
              onPressed: () {
                _pageController.nextPage(
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeInOut,
                );
              },
            ),
          ],
        ),
      );
    });
  }

  Widget _buildWeekView(BuildContext context, DateTime weekStart) {
    return Row(
      children: [
        // 时间轴
        SizedBox(
          width: _timeAxisWidth,
          child: _buildTimeAxis(context),
        ),
        // 7天的日程列
        Expanded(
          child: SingleChildScrollView(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: List.generate(7, (dayIndex) {
                final day = weekStart.add(Duration(days: dayIndex));
                return Expanded(
                  child: _buildDayColumn(context, day, dayIndex),
                );
              }),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTimeAxis(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        children: [
          // 日期头部占位
          const SizedBox(height: 50),
          // 时间刻度
          ...List.generate(_endHour - _startHour + 1, (index) {
            final hour = _startHour + index;
            return SizedBox(
              height: _hourHeight,
              child: Align(
                alignment: Alignment.topRight,
                child: Padding(
                  padding: const EdgeInsets.only(right: 4),
                  child: Text(
                    '${hour.toString().padLeft(2, '0')}:00',
                    style: CupertinoTheme.of(context)
                        .textTheme
                        .textStyle
                        .copyWith(
                          fontSize: 10,
                          color: CupertinoDynamicColor.resolve(
                              CupertinoColors.secondaryLabel, context),
                        ),
                  ),
                ),
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildDayColumn(BuildContext context, DateTime day, int dayIndex) {
    final isToday = _isSameDay(day, DateTime.now());
    final isSelected = _isSameDay(day, _calendarController.selectedDay.value);
    final weekDays = ['一', '二', '三', '四', '五', '六', '日'];

    return Column(
      children: [
        // 日期头部
        GestureDetector(
          onTap: () {
            _calendarController.selectedDay.value = day;
          },
          child: Container(
            height: 50,
            decoration: BoxDecoration(
              color: isSelected
                  ? CupertinoDynamicColor.resolve(
                      CupertinoColors.activeBlue.withValues(alpha: 0.2),
                      context)
                  : null,
              border: Border(
                bottom: BorderSide(
                  color: CupertinoDynamicColor.resolve(
                      CupertinoColors.separator, context),
                ),
              ),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  weekDays[dayIndex],
                  style:
                      CupertinoTheme.of(context).textTheme.textStyle.copyWith(
                            fontSize: 12,
                            color: isToday
                                ? CupertinoColors.activeBlue
                                : CupertinoDynamicColor.resolve(
                                    CupertinoColors.secondaryLabel, context),
                          ),
                ),
                const SizedBox(height: 2),
                Container(
                  width: 28,
                  height: 28,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: isToday ? CupertinoColors.activeBlue : null,
                  ),
                  child: Center(
                    child: Text(
                      '${day.day}',
                      style: CupertinoTheme.of(context)
                          .textTheme
                          .textStyle
                          .copyWith(
                            fontSize: 14,
                            fontWeight:
                                isToday ? FontWeight.bold : FontWeight.normal,
                            color: isToday
                                ? CupertinoColors.white
                                : CupertinoDynamicColor.resolve(
                                    CupertinoColors.label, context),
                          ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        // 日程区域
        SizedBox(
          height: (_endHour - _startHour + 1) * _hourHeight,
          child: Stack(
            children: [
              // 背景网格线
              ..._buildGridLines(context),
              // 日程事件
              ..._buildEventsForDay(context, day),
            ],
          ),
        ),
      ],
    );
  }

  List<Widget> _buildGridLines(BuildContext context) {
    return List.generate(_endHour - _startHour + 1, (index) {
      return Positioned(
        top: index * _hourHeight,
        left: 0,
        right: 0,
        child: Container(
          height: 1,
          color: CupertinoDynamicColor.resolve(
              CupertinoColors.separator.withValues(alpha: 0.3), context),
        ),
      );
    });
  }

  List<Widget> _buildEventsForDay(BuildContext context, DateTime day) {
    final events = _calendarController.getEventsForDay(day);
    final List<Widget> eventWidgets = [];

    for (var event in events) {
      // 计算事件位置
      final startMinutes =
          (event.startTime.hour - _startHour) * 60 + event.startTime.minute;
      final endMinutes =
          (event.endTime.hour - _startHour) * 60 + event.endTime.minute;

      // 跳过不在显示范围内的事件
      if (endMinutes < 0 ||
          startMinutes > (_endHour - _startHour + 1) * 60) {
        continue;
      }

      final top = (startMinutes / 60) * _hourHeight;
      final height =
          ((endMinutes - startMinutes) / 60) * _hourHeight;

      eventWidgets.add(
        Positioned(
          top: top.clamp(0, double.infinity),
          left: 1,
          right: 1,
          height: height.clamp(20, double.infinity),
          child: _buildEventBlock(context, event),
        ),
      );
    }

    return eventWidgets;
  }

  Widget _buildEventBlock(BuildContext context, Period event) {
    Color backgroundColor;
    if (event.type == PeriodType.classes) {
      backgroundColor = TimeColors.colorFromHour(event.startTime.hour);
    } else if (event.type == PeriodType.test) {
      backgroundColor = CupertinoColors.systemPink;
    } else if (event.type == PeriodType.user) {
      backgroundColor =
          UidColors.colorFromUid(event.fromFromUid ?? event.fromUid);
    } else {
      backgroundColor = CupertinoColors.systemGrey;
    }

    return GestureDetector(
      onTap: () => _onEventTap(context, event),
      child: Container(
        margin: const EdgeInsets.all(1),
        padding: const EdgeInsets.all(2),
        decoration: BoxDecoration(
          color: backgroundColor.withValues(alpha: 0.9),
          borderRadius: BorderRadius.circular(4),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '${event.startTime.hour.toString().padLeft(2, '0')}:${event.startTime.minute.toString().padLeft(2, '0')}',
              style: const TextStyle(
                fontSize: 8,
                color: CupertinoColors.white,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            Expanded(
              child: Text(
                event.summary,
                style: const TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  color: CupertinoColors.white,
                ),
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            if (event.location.isNotEmpty)
              Text(
                event.location,
                style: const TextStyle(
                  fontSize: 8,
                  color: CupertinoColors.white,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
          ],
        ),
      ),
    );
  }

  void _onEventTap(BuildContext context, Period event) {
    if (event.type == PeriodType.classes || event.type == PeriodType.test) {
      Navigator.of(context, rootNavigator: true).push(
        CupertinoPageRoute(
          builder: (context) => CourseDetailPage(courseId: event.fromUid),
        ),
      );
    } else if (event.type == PeriodType.user) {
      Task? task;
      for (var t in _taskList) {
        if (t.uid == event.fromUid) {
          task = t;
          break;
        }
      }
      if (task != null) {
        _showTaskDialog(context, task);
      }
    }
  }

  Future<void> _showTaskDialog(BuildContext context, Task task) async {
    await showCupertinoDialog(
      context: context,
      builder: (context) => CupertinoAlertDialog(
        title: Text(task.summary),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('开始：${_formatDateTime(task.startTime)}'),
            Text('结束：${_formatDateTime(task.endTime)}'),
            if (task.location.isNotEmpty) Text('地点：${task.location}'),
            if (task.description.isNotEmpty) Text('说明：${task.description}'),
          ],
        ),
        actions: [
          CupertinoDialogAction(
            child: const Text('返回'),
            onPressed: () => Navigator.of(context).pop(),
          ),
          if (task.type == TaskType.fixed)
            CupertinoDialogAction(
              child: const Text('编辑'),
              onPressed: () async {
                Navigator.of(context).pop();
                final result = await showCupertinoModalPopup<Task>(
                  context: context,
                  builder: (context) => TaskEditPage(task),
                );
                if (result != null) {
                  task.copy(result);
                  _taskController.updateDeadlineList();
                  _taskController.taskList.refresh();
                }
              },
            ),
        ],
      ),
    );
  }

  String _formatDateTime(DateTime dt) {
    return '${dt.month}/${dt.day} ${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
  }

  bool _isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }
}
