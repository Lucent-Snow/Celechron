import 'package:get/get.dart';

import 'package:celechron/page/option/option_controller.dart';

import 'period.dart';
import 'grade.dart';
import 'semester.dart';
import 'todo.dart';
import 'custom_session.dart';
import 'package:celechron/utils/gpa_helper.dart';
import 'package:celechron/http/spider.dart';
import 'package:celechron/http/ugrs_spider.dart';
import 'package:celechron/http/grs_spider.dart';
import 'package:celechron/database/database_helper.dart';

class Scholar {
  Scholar();

  // 构造用户对象
  DatabaseHelper? _db;

  set db(DatabaseHelper? db) {
    _db = db;
  }

  // 登录状态
  bool isLogan = false;
  DateTime lastUpdateTime = DateTime.parse("20010101");

  // 爬虫区
  String? username;
  String? password;
  Spider? _spider;

  bool get isGrs => !username!.startsWith('3');

  // 按学期整理好的学业信息，包括该学期的所有科目、考试、课表、均绩等
  List<Semester> semesters = <Semester>[];

  // 按课程号整理好的成绩单（方便算重修成绩）
  Map<String, List<Grade>> grades = {};

  // 保研 GPA, 四个数据依次为五分制、四分制（4.3 分制）、原始的四分制、百分制
  List<double> gpa = [0.0, 0.0, 0.0, 0.0];

  // 出国 GPA, 四个数据依次为五分制、四分制（4.3 分制）、原始的四分制、百分制
  List<double> aboardGpa = [0.0, 0.0, 0.0, 0.0];

  // 所获学分
  double credit = 0.0;

  // 主修成绩，两个数据依次为主修GPA，主修学分
  List<double> majorGpaAndCredit = [0.0, 0.0];

  // 特殊日期
  Map<DateTime, String> specialDates = {};

  // 作业（学在浙大）
  List<Todo> todos = [];

  // 用户自定义课程列表
  List<CustomSession> customSessions = [];

  // 被隐藏的教务系统课程ID集合
  Set<String> hiddenSessionIds = {};

  // 被隐藏的特定课程实例（Session ID + 日期）集合
  // 格式: "sessionId_yyyy-MM-dd"
  Set<String> hiddenPeriodKeys = {};

  int get gradedCourseCount {
    return grades.values.fold(0, (p, e) => p + e.length);
  }

  List<Period> get periods {
    // 获取所有学期的 periods
    var allPeriods = semesters.fold(<Period>[], (p, e) => p + e.periods);

    // 过滤掉被隐藏的课程（基于 fromUid 和日期）
    allPeriods = allPeriods.where((period) {
      if (period.type == PeriodType.classes) {
        // 检查整个课程是否被隐藏
        if (period.fromUid != null &&
            hiddenSessionIds.contains(period.fromUid)) {
          return false;
        }
        // 检查特定日期的实例是否被隐藏
        if (period.fromUid != null) {
          final dateKey = _getPeriodDateKey(period.fromUid!, period.startTime);
          if (hiddenPeriodKeys.contains(dateKey)) {
            return false;
          }
        }
      }
      return true;
    }).toList();

    // 添加自定义课程生成的 periods
    allPeriods.addAll(_generateCustomSessionPeriods());

    return allPeriods;
  }

  /// 从自定义课程生成 Period 列表
  List<Period> _generateCustomSessionPeriods() {
    List<Period> periods = [];

    for (var customSession in customSessions) {
      // 找到对应的学期
      final semester = semesters.firstWhereOrNull(
        (s) => s.name == customSession.semesterName,
      );
      if (semester == null) continue;

      // 使用学期的时间配置生成 periods
      periods.addAll(
        _generatePeriodsFromCustomSession(customSession, semester),
      );
    }

    return periods;
  }

  /// 从单个自定义课程生成 Period 列表
  List<Period> _generatePeriodsFromCustomSession(
    CustomSession session,
    Semester semester,
  ) {
    List<Period> periods = [];

    // 获取学期的日期配置
    final dayOfWeekToDays = semester.dayOfWeekToDays;
    final sessionToTime = semester.sessionToTime;

    if (dayOfWeekToDays.isEmpty || sessionToTime.isEmpty) {
      return periods;
    }

    // 处理自定义重复周次的课程
    if (session.customRepeat && session.customRepeatWeeks.isNotEmpty) {
      for (var week in session.customRepeatWeeks) {
        DateTime day;
        if (week > 16) {
          day = dayOfWeekToDays.last.last.last.last
              .add(Duration(days: (week - 17) * 7 + session.dayOfWeek));
        } else {
          final halfIndex = (week - 1) ~/ 8;
          final oddEvenIndex = 1 - week % 2;
          final dayIndex = (week - 1) % 8 ~/ 2;
          if (halfIndex < dayOfWeekToDays.length &&
              oddEvenIndex < dayOfWeekToDays[halfIndex].length &&
              session.dayOfWeek <
                  dayOfWeekToDays[halfIndex][oddEvenIndex].length &&
              dayIndex <
                  dayOfWeekToDays[halfIndex][oddEvenIndex][session.dayOfWeek]
                      .length) {
            day = dayOfWeekToDays[halfIndex][oddEvenIndex][session.dayOfWeek]
                [dayIndex];
          } else {
            continue;
          }
        }
        periods.add(
            _createPeriodFromCustomSession(session, day, sessionToTime, week));
      }
      return periods;
    }

    // 处理常规单双周课程
    // 上半学期
    if (session.firstHalf) {
      if (session.oddWeek && dayOfWeekToDays[0][0].length > session.dayOfWeek) {
        for (var day in dayOfWeekToDays[0][0][session.dayOfWeek]) {
          periods.add(_createPeriodFromCustomSession(
              session, day, sessionToTime, null));
        }
      }
      if (session.evenWeek &&
          dayOfWeekToDays[0][1].length > session.dayOfWeek) {
        for (var day in dayOfWeekToDays[0][1][session.dayOfWeek]) {
          periods.add(_createPeriodFromCustomSession(
              session, day, sessionToTime, null));
        }
      }
    }

    // 下半学期
    if (session.secondHalf) {
      if (session.oddWeek && dayOfWeekToDays[1][0].length > session.dayOfWeek) {
        for (var day in dayOfWeekToDays[1][0][session.dayOfWeek]) {
          periods.add(_createPeriodFromCustomSession(
              session, day, sessionToTime, null));
        }
      }
      if (session.evenWeek &&
          dayOfWeekToDays[1][1].length > session.dayOfWeek) {
        for (var day in dayOfWeekToDays[1][1][session.dayOfWeek]) {
          periods.add(_createPeriodFromCustomSession(
              session, day, sessionToTime, null));
        }
      }
    }

    return periods;
  }

  /// 创建单个 Period
  Period _createPeriodFromCustomSession(
    CustomSession session,
    DateTime day,
    List<List<Duration>> sessionToTime,
    int? week,
  ) {
    final startDuration =
        session.time.isNotEmpty && session.time.first < sessionToTime.length
            ? sessionToTime[session.time.first].firstOrNull ?? Duration.zero
            : Duration.zero;
    final endDuration =
        session.time.isNotEmpty && session.time.last < sessionToTime.length
            ? sessionToTime[session.time.last].lastOrNull ?? Duration.zero
            : Duration.zero;

    return Period(
      uid:
          '${session.id}${session.dayOfWeek}${session.time.firstOrNull ?? 0}${week ?? ''}',
      fromUid: session.id,
      type: PeriodType.classes,
      description:
          "教师: ${session.teacher}${session.isUserCreated ? '\n(自定义课程)' : '\n(已修改)'}",
      location: session.location ?? "未知",
      summary: session.name,
      startTime: day.add(startDuration),
      endTime: day.add(endDuration),
    );
  }

  Semester get thisSemester {
    if (semesters.length > 1) {
      if (semesters[1]
          .periods
          .last
          .endTime
          .isAfter(DateTime.now().subtract(const Duration(days: 14)))) {
        return semesters[1];
      } else {
        return semesters[0];
      }
    } else {
      return semesters.isEmpty ? Semester('未刷新') : semesters.first;
    }
  }

  // 初始化以获取Cookies，并刷新数据
  Future<List<String?>> login() async {
    if (username == null || password == null) {
      return ["未登录"];
    }
    if (username == '3200000000') {
      _spider = MockSpider();
    } else if (!isGrs) {
      _spider = UgrsSpider(username!, password!);
    } else {
      _spider = GrsSpider(username!, password!);
    }
    var loginErrorMessage = await _spider!.login();
    if (loginErrorMessage.every((e) => e == null)) {
      isLogan = true;
      _db?.setScholar(this);
    }
    return loginErrorMessage;
  }

  Future<bool> logout() async {
    username = "";
    password = "";
    semesters = [];
    grades = {};
    gpa = [0.0, 0.0, 0.0, 0.0];
    aboardGpa = [0.0, 0.0, 0.0, 0.0];
    credit = 0.0;
    majorGpaAndCredit = [0.0, 0.0];
    customSessions = [];
    hiddenSessionIds = {};
    hiddenPeriodKeys = {};
    isLogan = false;
    lastUpdateTime = DateTime.parse("20010101");
    _spider?.logout();
    await _db?.removeScholar();
    await _db?.removeAllCachedWebPage();
    return true;
  }

  // 刷新数据
  var _mutex = 0;

  Future<List<String?>> refresh() async {
    if (!isLogan) {
      return ["未登录"];
    }
    if (_mutex > 0) {
      // Wait until the mutex is released.
      while (_mutex > 0) {
        await Future.delayed(const Duration(milliseconds: 100));
      }
      return [];
    }
    _mutex++;
    return await _spider?.getEverything().then((value) async {
          for (var e in value.item1) {
            // ignore: avoid_print
            if (e != null) print(e);
          }
          for (var e in value.item2) {
            // ignore: avoid_print
            if (e != null) print(e);
          }
          if (value.item1.every((e) => e == null) &&
              value.item2.every((e) => e == null)) {
            lastUpdateTime = DateTime.now();
          }

          // Fix: Do not overwrite local data if fetch failed and returned empty data
          if (value.item2.every((e) => e == null) || value.item3.isNotEmpty) {
            semesters = value.item3;
          }

          if (value.item2.every((e) => e == null) || value.item4.isNotEmpty) {
            grades = value.item4.fold(<String, List<Grade>>{}, (p, e) {
              // 体育课
              var matchClass = RegExp(r'(\(.*\)-(.*?))-.*').firstMatch(e.id);
              var key = matchClass?.group(2) ?? e.id.substring(14, 22);
              if (key.startsWith('PPAE') || key.startsWith('401')) {
                key = matchClass?.group(1) ?? e.id.substring(0, 22);
              }
              var courseIdMappingList =
                  Get.find<OptionController>(tag: 'optionController')
                      .courseIdMappingList;
              var courseIdMappingMap = {
                for (var e in courseIdMappingList) e.id1: e.id2
              };
              if (courseIdMappingMap.containsKey(key)) {
                key = courseIdMappingMap[key]!;
              }
              p.putIfAbsent(key, () => <Grade>[]).add(e);
              return p;
            });
          }

          if (value.item2.every((e) => e == null) || value.item5.isNotEmpty) {
            majorGpaAndCredit = value.item5;
          }

          if (value.item2.every((e) => e == null) || value.item6.isNotEmpty) {
            specialDates = value.item6;
          }

          if (value.item2.every((e) => e == null) || value.item7.isNotEmpty) {
            todos = value.item7;
          }

          // 保研成绩，只取第一次
          var netGrades = grades.values.map((e) => e.first);
          if (netGrades.isNotEmpty) {
            gpa = GpaHelper.calculateGpa(netGrades).item1;
          }
          // 出国成绩，取最高的一次
          var aboardNetGrades = grades.values.map((e) {
            e.sort((a, b) => a.hundredPoint.compareTo(b.hundredPoint));
            return e.last;
          });
          if (aboardNetGrades.isNotEmpty) {
            var result = GpaHelper.calculateGpa(aboardNetGrades);
            aboardGpa = result.item1;
            // 所获学分，不包括挂科的。
            credit = result.item2;
          } else {
            credit = 0.0;
          }

          await _db?.setScholar(this);
          return value.item1.every((e) => e == null)
              ? value.item2
              : value.item1;
        }).whenComplete(() => _mutex--) ??
        ['未登录'];
  }

  Map<String, dynamic> toJson() {
    return {
      'semesters': semesters,
      'grades': grades,
      'gpa': gpa,
      'aboardGpa': aboardGpa,
      'credit': credit,
      'majorGpaAndCredit': majorGpaAndCredit,
      'specialDates':
          specialDates.map((k, v) => MapEntry(k.toIso8601String(), v)),
      'lastUpdateTime': lastUpdateTime.toIso8601String(),
      'todos': todos,
      'customSessions': customSessions.map((e) => e.toJson()).toList(),
      'hiddenSessionIds': hiddenSessionIds.toList(),
      'hiddenPeriodKeys': hiddenPeriodKeys.toList(),
    };
  }

  Future<void> recalculateGpa() async {
    grades =
        grades.values.expand((e) => e).fold(<String, List<Grade>>{}, (p, e) {
      // 体育课
      var matchClass = RegExp(r'(\(.*\)-(.*?))-.*').firstMatch(e.id);
      var key = matchClass?.group(2) ?? e.id.substring(14, 22);
      if (key.startsWith('PPAE') || key.startsWith('401')) {
        key = matchClass?.group(1) ?? e.id.substring(0, 22);
      }
      var courseIdMappingList =
          Get.find<OptionController>(tag: 'optionController')
              .courseIdMappingList;
      var courseIdMappingMap = {
        for (var e in courseIdMappingList) e.id1: e.id2
      };
      if (courseIdMappingMap.containsKey(key)) {
        key = courseIdMappingMap[key]!;
      }
      p.putIfAbsent(key, () => <Grade>[]).add(e);
      return p;
    });

    // 保研成绩，只取第一次
    var netGrades = grades.values.map((e) => e.first);
    if (netGrades.isNotEmpty) {
      gpa = GpaHelper.calculateGpa(netGrades).item1;
    }
    // 出国成绩，取最高的一次
    var aboardNetGrades = grades.values.map((e) {
      e.sort((a, b) => a.hundredPoint.compareTo(b.hundredPoint));
      return e.last;
    });
    if (aboardNetGrades.isNotEmpty) {
      var result = GpaHelper.calculateGpa(aboardNetGrades);
      aboardGpa = result.item1;
      // 所获学分，不包括挂科的。
      credit = result.item2;
    } else {
      credit = 0.0;
    }

    await _db?.setScholar(this);
  }

  Scholar.fromJson(Map<String, dynamic> json) {
    username = json.containsKey('username')
        ? json['username']
        : null; // <=0.2.6 Compatibility
    password = json.containsKey('password')
        ? json['password']
        : null; // <=0.2.6 Compatibility
    semesters =
        (json['semesters'] as List).map((e) => Semester.fromJson(e)).toList();
    grades = (json['grades'] as Map<String, dynamic>).map((key, value) {
      return MapEntry(
          key, (value as List).map((e) => Grade.fromJson(e)).toList());
    });
    gpa = List<double>.from(json['gpa']);
    aboardGpa = List<double>.from(json['aboardGpa']);
    credit = json['credit'];
    majorGpaAndCredit = List<double>.from(json['majorGpaAndCredit']);
    specialDates = ((json['specialDates'] ?? {}) as Map)
        .map((k, v) => MapEntry(DateTime.parse(k as String), v as String));
    lastUpdateTime = DateTime.parse(json['lastUpdateTime']);
    todos = json.containsKey('todos') // back compatibility
        ? (json['todos'] as List).map((e) => Todo.fromJson(e)).toList()
        : [];
    // 自定义课程和隐藏课程（向后兼容）
    customSessions = json.containsKey('customSessions')
        ? (json['customSessions'] as List)
            .map((e) => CustomSession.fromJson(e as Map<String, dynamic>))
            .toList()
        : [];
    hiddenSessionIds = json.containsKey('hiddenSessionIds')
        ? Set<String>.from(json['hiddenSessionIds'] as List)
        : {};
    hiddenPeriodKeys = json.containsKey('hiddenPeriodKeys')
        ? Set<String>.from(json['hiddenPeriodKeys'] as List)
        : {};
    isLogan = true;
    if (gpa.length == 3) {
      gpa.insert(2, 0);
    }
    if (aboardGpa.length == 3) {
      aboardGpa.insert(2, 0);
    }
  }

  // 添加自定义课程
  void addCustomSession(CustomSession session) {
    customSessions.add(session);
  }

  // 更新自定义课程
  void updateCustomSession(CustomSession session) {
    final index = customSessions.indexWhere((e) => e.id == session.id);
    if (index != -1) {
      customSessions[index] = session;
    }
  }

  // 删除自定义课程
  void removeCustomSession(String sessionId) {
    customSessions.removeWhere((e) => e.id == sessionId);
  }

  // 隐藏教务系统课程
  void hideSession(String sessionId) {
    hiddenSessionIds.add(sessionId);
  }

  // 恢复显示教务系统课程
  void unhideSession(String sessionId) {
    hiddenSessionIds.remove(sessionId);
  }

  // 检查课程是否被隐藏
  bool isSessionHidden(String sessionId) {
    return hiddenSessionIds.contains(sessionId);
  }

  // 生成 Period 日期键（Session ID + 日期）
  String _getPeriodDateKey(String sessionId, DateTime date) {
    return '${sessionId}_${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }

  // 隐藏特定课程实例（某一天的课程）
  void hidePeriod(Period period) {
    if (period.fromUid != null) {
      final dateKey = _getPeriodDateKey(period.fromUid!, period.startTime);
      hiddenPeriodKeys.add(dateKey);
    }
  }

  // 恢复显示特定课程实例
  void unhidePeriod(String dateKey) {
    hiddenPeriodKeys.remove(dateKey);
  }

  // 检查特定课程实例是否被隐藏
  bool isPeriodHidden(Period period) {
    if (period.fromUid != null) {
      final dateKey = _getPeriodDateKey(period.fromUid!, period.startTime);
      return hiddenPeriodKeys.contains(dateKey);
    }
    return false;
  }
}
