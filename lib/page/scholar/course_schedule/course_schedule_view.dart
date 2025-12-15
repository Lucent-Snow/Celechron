import 'dart:math';

import 'package:celechron/design/custom_colors.dart';
import 'package:celechron/utils/tuple.dart';
import 'package:celechron/model/session.dart';
import 'package:celechron/model/scholar.dart';
import 'package:celechron/model/custom_session.dart';
import 'package:celechron/model/period.dart';
import 'package:celechron/design/persistent_headers.dart';
import 'package:celechron/page/scholar/course_edit/course_edit_page.dart';
import 'package:celechron/database/database_helper.dart';
import 'course_schedule_controller.dart';
import 'package:get/get.dart';
import 'package:celechron/design/animate_button.dart';
import 'package:celechron/design/round_rectangle_card.dart';
import 'package:celechron/design/two_line_card.dart';
import 'course_card.dart';
import 'package:flutter/cupertino.dart';

class CourseSchedulePage extends StatelessWidget {
  late final CourseScheduleController _courseScheduleController;

  CourseSchedulePage(String name, bool first, {super.key}) {
    bool initialHideCourseInfomation = false;
    try {
      initialHideCourseInfomation =
          Get.find<CourseScheduleController>().hideCourseInfomation.value;
    } catch (e) {
      // not initialized
    }
    Get.delete<CourseScheduleController>();
    _courseScheduleController = Get.put(CourseScheduleController(
      initialName: name,
      initialFirstOrSecondSemester: first,
      initialHideCourseInfomation: initialHideCourseInfomation,
    ));
  }

  Widget _semesterPicker(BuildContext context) {
    return RoundRectangleCard(
      animate: false,
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: SizedBox(
                  height: 30,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: _courseScheduleController.semesters.length,
                    itemBuilder: (context, index) {
                      final semester =
                          _courseScheduleController.semesters[index];
                      return Obx(
                        () => Stack(
                          children: [
                            AnimateButton(
                              text:
                                  '${semester.name.substring(2, 5)}${semester.name.substring(7, 11)}',
                              onTap: () {
                                _courseScheduleController.semesterIndex.value =
                                    index;
                                _courseScheduleController.semesterIndex
                                    .refresh();
                              },
                              backgroundColor: _courseScheduleController
                                          .semesterIndex.value ==
                                      index
                                  ? CustomCupertinoDynamicColors.cyan
                                  : CupertinoColors.systemFill,
                            ),
                            const SizedBox(width: 90),
                          ],
                        ),
                      );
                    },
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Obx(
            () => Hero(
              tag: 'courseSchedule',
              child: Row(
                children: [
                  Expanded(
                    child: TwoLineCard(
                        animate: true,
                        onTap: () {
                          _courseScheduleController
                              .firstOrSecondSemester.value = true;
                        },
                        title:
                            '${_courseScheduleController.semester.firstHalfName}学期课时',
                        content:
                            '${_courseScheduleController.semester.firstHalfSessionCount}节/两周',
                        backgroundColor: _courseScheduleController
                                .firstOrSecondSemester.value
                            ? _courseScheduleController.semester.name[9] == '春'
                                ? CustomCupertinoDynamicColors.spring
                                : CustomCupertinoDynamicColors.autumn
                            : CupertinoColors.systemFill,
                        withColoredFont: true),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: TwoLineCard(
                        animate: true,
                        onTap: () {
                          _courseScheduleController
                              .firstOrSecondSemester.value = false;
                        },
                        title:
                            '${_courseScheduleController.semester.secondHalfName}学期课时',
                        content:
                            '${_courseScheduleController.semester.secondHalfSessionCount}节/两周',
                        backgroundColor: _courseScheduleController
                                .firstOrSecondSemester.value
                            ? CupertinoColors.systemFill
                            : _courseScheduleController.semester.name[9] == '春'
                                ? CustomCupertinoDynamicColors.summer
                                : CustomCupertinoDynamicColors.winter,
                        withColoredFont: true),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _courseSchedule(BuildContext context) {
    const List<String> courseStartTime = [
      "08:00",
      "08:50",
      "10:00",
      "10:50",
      "11:40",
      "13:25",
      "14:15",
      "15:05",
      "16:15",
      "17:05",
      "18:50",
      "19:40",
      "20:30"
    ];
    return RoundRectangleCard(
      child: Column(
        children: [
          Row(
            children: [
              const Spacer(flex: 1),
              Expanded(
                flex: 2,
                child: Center(
                  child: Text(
                    '一',
                    style:
                        CupertinoTheme.of(context).textTheme.textStyle.copyWith(
                              fontSize: 14,
                            ),
                  ),
                ),
              ),
              Expanded(
                flex: 2,
                child: Center(
                  child: Text(
                    '二',
                    style:
                        CupertinoTheme.of(context).textTheme.textStyle.copyWith(
                              fontSize: 14,
                            ),
                  ),
                ),
              ),
              Expanded(
                flex: 2,
                child: Center(
                  child: Text(
                    '三',
                    style:
                        CupertinoTheme.of(context).textTheme.textStyle.copyWith(
                              fontSize: 14,
                            ),
                  ),
                ),
              ),
              Expanded(
                flex: 2,
                child: Center(
                  child: Text(
                    '四',
                    style:
                        CupertinoTheme.of(context).textTheme.textStyle.copyWith(
                              fontSize: 14,
                            ),
                  ),
                ),
              ),
              Expanded(
                flex: 2,
                child: Center(
                  child: Text(
                    '五',
                    style:
                        CupertinoTheme.of(context).textTheme.textStyle.copyWith(
                              fontSize: 14,
                            ),
                  ),
                ),
              ),
              Expanded(
                flex: 2,
                child: Center(
                  child: Text(
                    '六',
                    style:
                        CupertinoTheme.of(context).textTheme.textStyle.copyWith(
                              fontSize: 14,
                            ),
                  ),
                ),
              ),
              Expanded(
                flex: 2,
                child: Center(
                  child: Text(
                    '日',
                    style:
                        CupertinoTheme.of(context).textTheme.textStyle.copyWith(
                              fontSize: 14,
                            ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          SizedBox(
            height: 560,
            child: Obx(
              () {
                var sessionsByDayOfWeek =
                    _courseScheduleController.sessionsByDayOfWeek;
                return Row(
                  children: [
                    Expanded(
                      flex: 1,
                      child: Column(
                        children: [
                          for (var i = 1; i <= 13; i++)
                            Expanded(
                              child: Center(
                                child: Column(
                                  // mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    FittedBox(
                                      fit: BoxFit.fitWidth,
                                      child: Text(
                                        courseStartTime[i - 1],
                                        style: CupertinoTheme.of(context)
                                            .textTheme
                                            .textStyle
                                            .copyWith(
                                              fontSize: 10,
                                            ),
                                      ),
                                    ),
                                    const SizedBox(
                                      height: 2,
                                    ),
                                    Text(
                                      i.toString(),
                                      style: CupertinoTheme.of(context)
                                          .textTheme
                                          .textStyle
                                          .copyWith(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 14,
                                          ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                    for (var i = 1; i <= 6; i++)
                      Expanded(
                        flex: 2,
                        child: LayoutBuilder(
                          builder: (context, constraints) => Stack(
                            children: [
                              Column(
                                children: [
                                  for (var j = 1; j <= 12; j++)
                                    Expanded(
                                      child: Container(
                                          // decoration: BoxDecoration(
                                          //   border: Border(
                                          //     bottom: BorderSide(
                                          //         color: CupertinoDynamicColor
                                          //             .resolve(
                                          //                 CupertinoColors
                                          //                     .systemGrey4,
                                          //                 context)),
                                          //     right: BorderSide(
                                          //       color:
                                          //           CupertinoDynamicColor.resolve(
                                          //               CupertinoColors
                                          //                   .systemGrey4,
                                          //               context),
                                          //     ),
                                          //   ),
                                          // ),
                                          ),
                                    ),
                                  Expanded(
                                    child: Container(
                                        // decoration: BoxDecoration(
                                        //   border: Border(
                                        //     right: BorderSide(
                                        //       color:
                                        //           CupertinoDynamicColor.resolve(
                                        //               CupertinoColors.systemGrey4,
                                        //               context),
                                        //     ),
                                        //   ),
                                        // ),
                                        ),
                                  ),
                                ],
                              ),
                              ..._buildCourseScheduleByDayOfWeek(
                                  sessionsByDayOfWeek, i, constraints)
                            ],
                          ),
                        ),
                      ),
                    Expanded(
                      flex: 2,
                      child: LayoutBuilder(
                        builder: (context, constraints) => Stack(
                          children: [
                            Column(
                              children: [
                                for (var j = 1; j <= 12; j++)
                                  Expanded(
                                    child: Container(
                                        // decoration: BoxDecoration(
                                        //   border: Border(
                                        //     bottom: BorderSide(
                                        //       color:
                                        //           CupertinoDynamicColor.resolve(
                                        //               CupertinoColors.systemGrey4,
                                        //               context),
                                        //     ),
                                        //   ),
                                        // ),
                                        ),
                                  ),
                                Expanded(child: Container())
                              ],
                            ),
                            ..._buildCourseScheduleByDayOfWeek(
                                sessionsByDayOfWeek, 7, constraints)
                          ],
                        ),
                      ),
                    )
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  List<Widget> _buildCourseScheduleByDayOfWeek(
      List<List<Session>> sessionsByDayOfWeek,
      int day,
      BoxConstraints constraints) {
    List<Tuple<int, int>> period = [];
    for (var i = 1; i <= 13; i++) {
      period.add(Tuple(i, i));
    }
    for (var s in sessionsByDayOfWeek[day]) {
      int sl = s.time.first, sr = s.time.last;
      int xl = sl, xr = sr;
      for (var i in period) {
        if (!(i.item2 < sl || sr < i.item1)) {
          xl = min(xl, i.item1);
          xr = max(xr, i.item2);
        }
      }
      period.removeWhere((x) => xl <= x.item1 && x.item2 <= xr);
      period.add(Tuple(xl, xr));
    }
    List<List<Session>> sessionList = [];
    for (var _ in period) {
      sessionList.add([]);
    }
    for (var s in sessionsByDayOfWeek[day]) {
      int sl = s.time.first, sr = s.time.last;
      for (int i = 0; i < period.length; i++) {
        if (!(period[i].item2 < sl || sr < period[i].item1)) {
          bool added = false;
          for (var t in sessionList[i]) {
            if (t.id == s.id) {
              added = true;
              Set<int> timeSet = Set.from(t.time);
              timeSet.addAll(s.time);
              t.time = List.from(timeSet);
              t.time.sort();
              break;
            }
          }
          if (!added) {
            sessionList[i].add(Session.fromJson(s.toJson()));
          }
        }
      }
    }

    List<Widget> cardList = [];
    for (int i = 0; i < period.length; i++) {
      if (sessionList[i].isNotEmpty) {
        cardList.add(
          Positioned.fromRelativeRect(
            rect: RelativeRect.fromLTRB(
              0,
              (period[i].item1 - 1) * constraints.maxHeight / 13,
              0,
              (13 - period[i].item2) * constraints.maxHeight / 13,
            ),
            child: Obx(
              () => SessionCard(
                sessionList: sessionList[i],
                hideInfomation:
                    _courseScheduleController.hideCourseInfomation.value,
              ),
            ),
          ),
        );
      }
    }

    return cardList;

    // return sessionsByDayOfWeek[day]
    //     .map((e) => Positioned.fromRelativeRect(
    //           rect: RelativeRect.fromLTRB(
    //             0,
    //             (e.time.first - 1) * constraints.maxHeight / 13,
    //             0,
    //             (13 - e.time.last) * constraints.maxHeight / 13,
    //           ),
    //           child: SessionCard(sessionList: [e]),
    //         ))
    //     .toList();
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      backgroundColor: CupertinoDynamicColor.resolve(
          CupertinoColors.systemGroupedBackground, context),
      child: CustomScrollView(
        slivers: [
          const CelechronSliverTextHeader(subtitle: '课表'),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                children: [
                  _semesterPicker(context),
                  const SizedBox(height: 8),
                  // Container(
                  //   padding: const EdgeInsets.only(left: 16, right: 16),
                  //   child: Text(
                  //     '请前往教务网查看冲突选课课表',
                  //     style: TextStyle(
                  //         color: CupertinoDynamicColor.resolve(
                  //             CupertinoColors.secondaryLabel, context),
                  //         fontSize: 14),
                  //   ),
                  // ),
                  // const SizedBox(height: 8),
                  _courseSchedule(context),
                  const SizedBox(height: 20),
                  Obx(
                    () => CupertinoListSection.insetGrouped(
                      margin: const EdgeInsetsDirectional.fromSTEB(
                          0.0, 0.0, 0.0, 10.0),
                      additionalDividerMargin: 2,
                      children: <CupertinoListTile>[
                        CupertinoListTile(
                            title: const Text('隐藏课程信息'),
                            trailing: CupertinoSwitch(
                              value: _courseScheduleController
                                  .hideCourseInfomation.value,
                              onChanged: (value) async {
                                _courseScheduleController
                                    .hideCourseInfomation.value = value;
                              },
                            )),
                      ],
                    ),
                  ),
                  // 课程管理区域
                  CupertinoListSection.insetGrouped(
                    header: const Text('课程管理'),
                    margin: const EdgeInsetsDirectional.fromSTEB(
                        0.0, 0.0, 0.0, 10.0),
                    additionalDividerMargin: 2,
                    children: <CupertinoListTile>[
                      CupertinoListTile(
                        title: const Text('添加自定义课程'),
                        leading: const Icon(CupertinoIcons.add_circled),
                        trailing: const CupertinoListTileChevron(),
                        onTap: () => _addCustomCourse(context),
                      ),
                      CupertinoListTile(
                        title: const Text('管理自定义课程'),
                        leading: const Icon(CupertinoIcons.pencil),
                        trailing: const CupertinoListTileChevron(),
                        onTap: () => _manageCustomCourses(context),
                      ),
                      CupertinoListTile(
                        title: const Text('管理隐藏的课程'),
                        leading: const Icon(CupertinoIcons.eye_slash),
                        trailing: const CupertinoListTileChevron(),
                        onTap: () => _manageHiddenCourses(context),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _addCustomCourse(BuildContext context) async {
    final scholar = Get.find<Rx<Scholar>>(tag: 'scholar');
    final db = Get.find<DatabaseHelper>(tag: 'db');

    final result = await Navigator.of(context).push<CustomSession>(
      CupertinoPageRoute(
        builder: (context) => CourseEditPage(
          defaultSemesterName: _courseScheduleController.semester.name,
        ),
      ),
    );

    if (result != null) {
      scholar.value.addCustomSession(result);
      await db.setScholar(scholar.value);
      scholar.refresh();
    }
  }

  void _manageCustomCourses(BuildContext context) {
    final scholar = Get.find<Rx<Scholar>>(tag: 'scholar');
    final db = Get.find<DatabaseHelper>(tag: 'db');

    showCupertinoModalPopup(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) {
          final customSessions = scholar.value.customSessions;

          return Container(
            height: MediaQuery.of(context).size.height * 0.6,
            decoration: BoxDecoration(
              color: CupertinoDynamicColor.resolve(
                  CupertinoColors.systemBackground, context),
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(12)),
            ),
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        '自定义课程',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      CupertinoButton(
                        padding: EdgeInsets.zero,
                        child: const Text('完成'),
                        onPressed: () => Navigator.of(context).pop(),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: customSessions.isEmpty
                      ? const Center(child: Text('暂无自定义课程'))
                      : ListView.builder(
                          itemCount: customSessions.length,
                          itemBuilder: (context, index) {
                            final session = customSessions[index];
                            return CupertinoListTile(
                              title: Text(session.name),
                              subtitle: Text(session.friendlyTimeDescription),
                              trailing: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  CupertinoButton(
                                    padding: EdgeInsets.zero,
                                    child: const Icon(CupertinoIcons.pencil),
                                    onPressed: () async {
                                      final result = await Navigator.of(context)
                                          .push<CustomSession>(
                                        CupertinoPageRoute(
                                          builder: (context) =>
                                              CourseEditPage(session: session),
                                        ),
                                      );

                                      if (result != null) {
                                        scholar.value
                                            .updateCustomSession(result);
                                        await db.setScholar(scholar.value);
                                        scholar.refresh();
                                        setModalState(() {});
                                      } else {
                                        // 删除
                                        scholar.value
                                            .removeCustomSession(session.id);
                                        await db.setScholar(scholar.value);
                                        scholar.refresh();
                                        setModalState(() {});
                                      }
                                    },
                                  ),
                                  CupertinoButton(
                                    padding: EdgeInsets.zero,
                                    child: const Icon(
                                      CupertinoIcons.delete,
                                      color: CupertinoColors.systemRed,
                                    ),
                                    onPressed: () async {
                                      scholar.value
                                          .removeCustomSession(session.id);
                                      await db.setScholar(scholar.value);
                                      scholar.refresh();
                                      setModalState(() {});
                                    },
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  void _manageHiddenCourses(BuildContext context) {
    final scholar = Get.find<Rx<Scholar>>(tag: 'scholar');
    final db = Get.find<DatabaseHelper>(tag: 'db');

    showCupertinoModalPopup(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) {
          final hiddenIds = scholar.value.hiddenSessionIds.toList();

          // 获取隐藏课程的名称
          List<MapEntry<String, String>> hiddenCourses = [];
          for (var semester in scholar.value.semesters) {
            for (var session in semester.sessions) {
              if (session.id != null && hiddenIds.contains(session.id)) {
                hiddenCourses.add(MapEntry(session.id!, session.name));
              }
            }
          }

          // 获取隐藏的单次课程信息
          List<MapEntry<String, Period>> hiddenPeriods = [];
          if (scholar.value.hiddenPeriodKeys.isNotEmpty) {
            // 获取所有原始 periods（未过滤的）
            var allPeriods = scholar.value.semesters
                .fold(<Period>[], (p, e) => p + e.periods);

            for (var dateKey in scholar.value.hiddenPeriodKeys) {
              // 解析 dateKey: "sessionId_yyyy-MM-dd"
              final parts = dateKey.split('_');
              if (parts.length == 2) {
                final sessionId = parts[0];
                final dateStr = parts[1];

                // 查找匹配的 Period
                final period = allPeriods.firstWhereOrNull((p) {
                  if (p.fromUid != sessionId) return false;
                  final pDateStr =
                      '${p.startTime.year}-${p.startTime.month.toString().padLeft(2, '0')}-${p.startTime.day.toString().padLeft(2, '0')}';
                  return pDateStr == dateStr;
                });

                if (period != null) {
                  hiddenPeriods.add(MapEntry(dateKey, period));
                }
              }
            }
          }

          return Container(
            height: MediaQuery.of(context).size.height * 0.7,
            decoration: BoxDecoration(
              color: CupertinoDynamicColor.resolve(
                  CupertinoColors.systemBackground, context),
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(12)),
            ),
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        '管理隐藏的课程',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      CupertinoButton(
                        padding: EdgeInsets.zero,
                        child: const Text('完成'),
                        onPressed: () => Navigator.of(context).pop(),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: ListView(
                    children: [
                      // 隐藏的整个课程
                      if (hiddenCourses.isNotEmpty) ...[
                        const Padding(
                          padding:
                              EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          child: Text(
                            '隐藏的课程（所有时间）',
                            style: TextStyle(
                              fontSize: 14,
                              color: CupertinoColors.secondaryLabel,
                            ),
                          ),
                        ),
                        ...hiddenCourses.map((course) => CupertinoListTile(
                              title: Text(course.value),
                              trailing: CupertinoButton(
                                padding: EdgeInsets.zero,
                                child: const Text('恢复显示'),
                                onPressed: () async {
                                  scholar.value.unhideSession(course.key);
                                  await db.setScholar(scholar.value);
                                  scholar.refresh();
                                  setModalState(() {});
                                },
                              ),
                            )),
                      ],
                      // 隐藏的单次课程
                      if (hiddenPeriods.isNotEmpty) ...[
                        Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 8),
                          child: Text(
                            '隐藏的单次课程',
                            style: TextStyle(
                              fontSize: 14,
                              color: CupertinoDynamicColor.resolve(
                                  CupertinoColors.secondaryLabel, context),
                            ),
                          ),
                        ),
                        ...hiddenPeriods.map((entry) {
                          final period = entry.value;
                          final weekdays = [
                            '',
                            '周一',
                            '周二',
                            '周三',
                            '周四',
                            '周五',
                            '周六',
                            '周日'
                          ];
                          final weekday = weekdays[period.startTime.weekday];
                          final dateStr =
                              '${period.startTime.month}月${period.startTime.day}日';
                          final timeStr =
                              '${period.startTime.hour.toString().padLeft(2, '0')}:${period.startTime.minute.toString().padLeft(2, '0')}-${period.endTime.hour.toString().padLeft(2, '0')}:${period.endTime.minute.toString().padLeft(2, '0')}';

                          return CupertinoListTile(
                            title: Text(period.summary),
                            subtitle: Text('$dateStr $weekday $timeStr'),
                            trailing: CupertinoButton(
                              padding: EdgeInsets.zero,
                              child: const Text('恢复显示'),
                              onPressed: () async {
                                scholar.value.unhidePeriod(entry.key);
                                await db.setScholar(scholar.value);
                                scholar.refresh();
                                setModalState(() {});
                              },
                            ),
                          );
                        }),
                      ],
                      // 空状态
                      if (hiddenCourses.isEmpty && hiddenPeriods.isEmpty)
                        const Padding(
                          padding: EdgeInsets.all(32),
                          child: Center(
                            child: Text(
                              '暂无隐藏的课程',
                              style: TextStyle(
                                color: CupertinoColors.secondaryLabel,
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
