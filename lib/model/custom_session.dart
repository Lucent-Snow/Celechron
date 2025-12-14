import 'package:uuid/uuid.dart';

/// 用户自定义课程/修改后的课程
/// 用于存储用户手动创建或修改的课程信息
class CustomSession {
  /// 唯一标识符
  String id;

  /// 课程名称
  String name;

  /// 教师
  String teacher;

  /// 上课地点
  String? location;

  /// 星期几上课 (1-7)
  int dayOfWeek;

  /// 第几节课开始和结束 (例如 [1, 2] 表示第1-2节)
  List<int> time;

  /// 是否单周上课
  bool oddWeek;

  /// 是否双周上课
  bool evenWeek;

  /// 是否上半学期（秋/春）
  bool firstHalf;

  /// 是否下半学期（冬/夏）
  bool secondHalf;

  /// 是否用户创建（true）还是从教务系统修改（false）
  bool isUserCreated;

  /// 关联的原始课程ID（用于成绩关联，可为空）
  String? originalSessionId;

  /// 所属学期名称
  String semesterName;

  /// 最后修改时间
  DateTime lastModifiedTime;

  /// 自定义重复周次（研究生课程使用）
  bool customRepeat;
  List<int> customRepeatWeeks;

  CustomSession({
    String? id,
    required this.name,
    this.teacher = '',
    this.location,
    required this.dayOfWeek,
    required this.time,
    this.oddWeek = true,
    this.evenWeek = true,
    this.firstHalf = true,
    this.secondHalf = false,
    this.isUserCreated = true,
    this.originalSessionId,
    required this.semesterName,
    DateTime? lastModifiedTime,
    this.customRepeat = false,
    this.customRepeatWeeks = const [],
  })  : id = id ?? const Uuid().v4(),
        lastModifiedTime = lastModifiedTime ?? DateTime.now();

  /// 从 JSON 反序列化
  factory CustomSession.fromJson(Map<String, dynamic> json) {
    return CustomSession(
      id: json['id'] as String,
      name: json['name'] as String,
      teacher: json['teacher'] as String? ?? '',
      location: json['location'] as String?,
      dayOfWeek: json['dayOfWeek'] as int,
      time: List<int>.from(json['time'] as List),
      oddWeek: json['oddWeek'] as bool? ?? true,
      evenWeek: json['evenWeek'] as bool? ?? true,
      firstHalf: json['firstHalf'] as bool? ?? true,
      secondHalf: json['secondHalf'] as bool? ?? false,
      isUserCreated: json['isUserCreated'] as bool? ?? true,
      originalSessionId: json['originalSessionId'] as String?,
      semesterName: json['semesterName'] as String,
      lastModifiedTime: json['lastModifiedTime'] != null
          ? DateTime.parse(json['lastModifiedTime'] as String)
          : DateTime.now(),
      customRepeat: json['customRepeat'] as bool? ?? false,
      customRepeatWeeks: json['customRepeatWeeks'] != null
          ? List<int>.from(json['customRepeatWeeks'] as List)
          : [],
    );
  }

  /// 序列化为 JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'teacher': teacher,
      'location': location,
      'dayOfWeek': dayOfWeek,
      'time': time,
      'oddWeek': oddWeek,
      'evenWeek': evenWeek,
      'firstHalf': firstHalf,
      'secondHalf': secondHalf,
      'isUserCreated': isUserCreated,
      'originalSessionId': originalSessionId,
      'semesterName': semesterName,
      'lastModifiedTime': lastModifiedTime.toIso8601String(),
      'customRepeat': customRepeat,
      'customRepeatWeeks': customRepeatWeeks,
    };
  }

  /// 复制并修改
  CustomSession copyWith({
    String? id,
    String? name,
    String? teacher,
    String? location,
    int? dayOfWeek,
    List<int>? time,
    bool? oddWeek,
    bool? evenWeek,
    bool? firstHalf,
    bool? secondHalf,
    bool? isUserCreated,
    String? originalSessionId,
    String? semesterName,
    DateTime? lastModifiedTime,
    bool? customRepeat,
    List<int>? customRepeatWeeks,
  }) {
    return CustomSession(
      id: id ?? this.id,
      name: name ?? this.name,
      teacher: teacher ?? this.teacher,
      location: location ?? this.location,
      dayOfWeek: dayOfWeek ?? this.dayOfWeek,
      time: time ?? List.from(this.time),
      oddWeek: oddWeek ?? this.oddWeek,
      evenWeek: evenWeek ?? this.evenWeek,
      firstHalf: firstHalf ?? this.firstHalf,
      secondHalf: secondHalf ?? this.secondHalf,
      isUserCreated: isUserCreated ?? this.isUserCreated,
      originalSessionId: originalSessionId ?? this.originalSessionId,
      semesterName: semesterName ?? this.semesterName,
      lastModifiedTime: lastModifiedTime ?? this.lastModifiedTime,
      customRepeat: customRepeat ?? this.customRepeat,
      customRepeatWeeks: customRepeatWeeks ?? List.from(this.customRepeatWeeks),
    );
  }

  /// 获取友好的时间描述
  String get friendlyTimeDescription {
    final weekDays = ['', '周一', '周二', '周三', '周四', '周五', '周六', '周日'];
    final weekDay = weekDays[dayOfWeek];
    final timeRange = time.length == 1
        ? '第${time.first}节'
        : '第${time.first}-${time.last}节';

    final weekType = <String>[];
    if (oddWeek && evenWeek) {
      // 每周
    } else if (oddWeek) {
      weekType.add('单周');
    } else if (evenWeek) {
      weekType.add('双周');
    }

    final halfType = <String>[];
    if (firstHalf) halfType.add('上半学期');
    if (secondHalf) halfType.add('下半学期');

    var result = '$weekDay $timeRange';
    if (weekType.isNotEmpty) {
      result += ' (${weekType.join('/')})';
    }
    if (halfType.isNotEmpty) {
      result += ' ${halfType.join('/')}';
    }
    return result;
  }
}
