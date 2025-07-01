// 文件: utils/date_time_helper.dart
// 日期和时间辅助工具类

import 'package:intl/intl.dart';
import 'package:jiffy/jiffy.dart';

class DateTimeHelper {
  // 日期格式
  static final DateFormat _dateFormat = DateFormat('yyyy-MM-dd');
  static final DateFormat _timeFormat = DateFormat('HH:mm');
  static final DateFormat _dateTimeFormat = DateFormat('yyyy-MM-dd HH:mm');
  static final DateFormat _fullDateTimeFormat = DateFormat('yyyy-MM-dd HH:mm:ss');
  static final DateFormat _dayMonthFormat = DateFormat('dd MMM');
  static final DateFormat _monthYearFormat = DateFormat('MMM yyyy');
  static final DateFormat _shortDateFormat = DateFormat('dd/MM/yyyy');
  static final DateFormat _shortTimeFormat = DateFormat('HH:mm');
  static final DateFormat _weekdayFormat = DateFormat('EEEE');
  static final DateFormat _chineseDateFormat = DateFormat('yyyy年MM月dd日');

  // 格式化为日期字符串 (2023-09-15)
  static String formatDate(DateTime date) {
    return _dateFormat.format(date);
  }

  // 格式化为时间字符串 (14:30)
  static String formatTime(DateTime time) {
    return _timeFormat.format(time);
  }

  // 格式化为日期时间字符串 (2023-09-15 14:30)
  static String formatDateTime(DateTime dateTime) {
    return _dateTimeFormat.format(dateTime);
  }

  // 格式化为完整日期时间字符串 (2023-09-15 14:30:25)
  static String formatFullDateTime(DateTime dateTime) {
    return _fullDateTimeFormat.format(dateTime);
  }

  // 格式化为月日格式 (15 Sep)
  static String formatDayMonth(DateTime date) {
    return _dayMonthFormat.format(date);
  }

  // 格式化为年月格式 (Sep 2023)
  static String formatMonthYear(DateTime date) {
    return _monthYearFormat.format(date);
  }

  // 格式化为短日期格式 (15/09/2023)
  static String formatShortDate(DateTime date) {
    return _shortDateFormat.format(date);
  }

  // 格式化为短时间格式 (14:30)
  static String formatShortTime(DateTime time) {
    return _shortTimeFormat.format(time);
  }

  // 获取星期几 (Monday, Tuesday, etc.)
  static String getWeekday(DateTime date) {
    return _weekdayFormat.format(date);
  }

  // 格式化为中文日期格式 (2023年09月15日)
  static String formatChineseDate(DateTime date) {
    return _chineseDateFormat.format(date);
  }

  // 从字符串解析日期 (2023-09-15)
  static DateTime? parseDate(String dateStr) {
    try {
      return _dateFormat.parse(dateStr);
    } catch (e) {
      return null;
    }
  }

  // 从字符串解析时间 (14:30)
  static DateTime? parseTime(String timeStr) {
    try {
      return _timeFormat.parse(timeStr);
    } catch (e) {
      return null;
    }
  }

  // 从字符串解析日期时间 (2023-09-15 14:30)
  static DateTime? parseDateTime(String dateTimeStr) {
    try {
      return _dateTimeFormat.parse(dateTimeStr);
    } catch (e) {
      return null;
    }
  }

  // 获取当前日期（不含时间）
  static DateTime getCurrentDate() {
    final now = DateTime.now();
    return DateTime(now.year, now.month, now.day);
  }

  // 获取当前时间（不含日期）
  static DateTime getCurrentTime() {
    final now = DateTime.now();
    return DateTime(1970, 1, 1, now.hour, now.minute, now.second);
  }

  // 比较两个日期是否为同一天
  static bool isSameDay(DateTime date1, DateTime date2) {
    return date1.year == date2.year && 
           date1.month == date2.month && 
           date1.day == date2.day;
  }

  // 比较两个日期是否为同一周
  static bool isSameWeek(DateTime date1, DateTime date2) {
    // 使用jiffy库简化周计算
    return Jiffy.parseFromDateTime(date1).weekOfYear == 
           Jiffy.parseFromDateTime(date2).weekOfYear &&
           date1.year == date2.year;
  }

  // 比较两个日期是否为同一月
  static bool isSameMonth(DateTime date1, DateTime date2) {
    return date1.year == date2.year && date1.month == date2.month;
  }

  // 检查日期是否在过去
  static bool isPast(DateTime date) {
    final now = DateTime.now();
    return date.isBefore(now);
  }

  // 检查日期是否在未来
  static bool isFuture(DateTime date) {
    final now = DateTime.now();
    return date.isAfter(now);
  }

  // 检查日期是否是今天
  static bool isToday(DateTime date) {
    final now = DateTime.now();
    return isSameDay(date, now);
  }

  // 检查日期是否是明天
  static bool isTomorrow(DateTime date) {
    final tomorrow = DateTime.now().add(const Duration(days: 1));
    return isSameDay(date, tomorrow);
  }

  // 检查日期是否是昨天
  static bool isYesterday(DateTime date) {
    final yesterday = DateTime.now().subtract(const Duration(days: 1));
    return isSameDay(date, yesterday);
  }

  // 获取两个日期之间的差异（天数）
  static int daysBetween(DateTime from, DateTime to) {
    from = DateTime(from.year, from.month, from.day);
    to = DateTime(to.year, to.month, to.day);
    return (to.difference(from).inHours / 24).round();
  }

  // 获取两个日期时间之间的差异（小时数）
  static int hoursBetween(DateTime from, DateTime to) {
    return to.difference(from).inHours;
  }

  // 获取两个日期时间之间的差异（分钟数）
  static int minutesBetween(DateTime from, DateTime to) {
    return to.difference(from).inMinutes;
  }

  // 增加天数
  static DateTime addDays(DateTime date, int days) {
    return date.add(Duration(days: days));
  }

  // 减少天数
  static DateTime subtractDays(DateTime date, int days) {
    return date.subtract(Duration(days: days));
  }

  // 增加月数
  static DateTime addMonths(DateTime date, int months) {
    return Jiffy.parseFromDateTime(date).add(months: months).dateTime;
  }

  // 减少月数
  static DateTime subtractMonths(DateTime date, int months) {
    return Jiffy.parseFromDateTime(date).subtract(months: months).dateTime;
  }

  // 获取指定月份的天数
  static int getDaysInMonth(int year, int month) {
    return DateTime(year, month + 1, 0).day;
  }

  // 获取指定日期是当月的第几天
  static int getDayOfMonth(DateTime date) {
    return date.day;
  }

  // 获取指定日期是当年的第几天
  static int getDayOfYear(DateTime date) {
    return Jiffy.parseFromDateTime(date).dayOfYear;
  }

  // 获取当前星期的星期一
  static DateTime getFirstDayOfWeek(DateTime date) {
    int weekday = date.weekday;
    return date.subtract(Duration(days: weekday - 1));
  }

  // 获取当月的第一天
  static DateTime getFirstDayOfMonth(DateTime date) {
    return DateTime(date.year, date.month, 1);
  }

  // 获取当月的最后一天
  static DateTime getLastDayOfMonth(DateTime date) {
    return DateTime(date.year, date.month + 1, 0);
  }

  // 获取当前学年开始日期（假设学年从9月开始）
  static DateTime getAcademicYearStart(DateTime date) {
    if (date.month >= 9) {
      return DateTime(date.year, 9, 1);
    } else {
      return DateTime(date.year - 1, 9, 1);
    }
  }

  // 获取当前学年结束日期（假设学年到次年6月底）
  static DateTime getAcademicYearEnd(DateTime date) {
    if (date.month >= 9) {
      return DateTime(date.year + 1, 6, 30);
    } else {
      return DateTime(date.year, 6, 30);
    }
  }

  // 获取当前学期（根据月份判断：9-1月为第一学期，2-6月为第二学期，7-8月为假期）
  static String getCurrentSemester(DateTime date) {
    int month = date.month;

    if (month >= 9 || month <= 1) {
      return '第一学期';
    } else if (month >= 2 && month <= 6) {
      return '第二学期';
    } else {
      return '暑假';
    }
  }

  // 获取相对时间描述（例如：刚刚、5分钟前、1小时前等）
  static String getRelativeTimeDescription(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inSeconds < 60) {
      return '刚刚';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes}分钟前';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}小时前';
    } else if (difference.inDays < 7) {
      return '${difference.inDays}天前';
    } else if (difference.inDays < 30) {
      return '${(difference.inDays / 7).floor()}周前';
    } else if (difference.inDays < 365) {
      return '${(difference.inDays / 30).floor()}月前';
    } else {
      return '${(difference.inDays / 365).floor()}年前';
    }
  }

  // 获取考试或作业的截止状态描述
  static String getDeadlineStatus(DateTime deadline) {
    final now = DateTime.now();
    final difference = deadline.difference(now);

    if (difference.isNegative) {
      // 已过期
      if (difference.inDays > -1) {
        return '今天已过期';
      } else if (difference.inDays > -2) {
        return '昨天过期';
      } else {
        return '已过期${-difference.inDays}天';
      }
    } else {
      // 未过期
      if (difference.inDays == 0) {
        if (difference.inHours == 0) {
          return '还剩${difference.inMinutes}分钟';
        } else {
          return '今天还剩${difference.inHours}小时';
        }
      } else if (difference.inDays == 1) {
        return '明天截止';
      } else if (difference.inDays < 7) {
        return '还剩${difference.inDays}天';
      } else if (difference.inDays < 30) {
        return '还剩${(difference.inDays / 7).floor()}周';
      } else {
        return '还剩${(difference.inDays / 30).floor()}个月';
      }
    }
  }

  // 生成日期范围
  static List<DateTime> generateDateRange(DateTime start, DateTime end) {
    List<DateTime> dates = [];
    DateTime currentDate = start;

    while (!currentDate.isAfter(end)) {
      dates.add(currentDate);
      currentDate = currentDate.add(const Duration(days: 1));
    }

    return dates;
  }
}
