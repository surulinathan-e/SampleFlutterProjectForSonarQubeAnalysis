import 'package:intl/intl.dart';

// date time format : https://api.flutter.dev/flutter/intl/DateFormat-class.html

class ConvertionUtil {
  static String convertLocalTimeFromString(String? dateTime) {
    if (dateTime == null || dateTime.trim().isEmpty) return '--';
    //5:08 PM
    return DateFormat.jm()
        .format(DateTime.parse(dateTime).toLocal())
        .toString();
  }

  static String convertToUTCWithZ(String? dateTime) {
    if (dateTime == null || dateTime.trim().isEmpty) return '--';
    return '${dateTime}Z';
  }

  static String convertLocalDateTimeFromString(String? dateTime) {
    if (dateTime == null || dateTime.trim().isEmpty) return '--';
    //July 10, 1996 5:08 PM
    return DateFormat.yMMMd()
        .add_jm()
        .format(DateTime.parse(dateTime).toLocal())
        .toString();
  }

  static String convertLocalDateFromString(String? dateTime) {
    if (dateTime == null || dateTime.trim().isEmpty) return '--';
    // Wed, July 10, 1996
    return DateFormat('EEE, MMM d, ' 'y')
        .format(DateTime.parse(dateTime).toLocal())
        .toString();
  }

  static String convertLocalDateMonthYearString(String? dateTime) {
    if (dateTime == null || dateTime.trim().isEmpty) return '--';
    // 2025-01-28
    return DateFormat('dd-MM-yyyy')
        .format(DateTime.parse(dateTime).toLocal())
        .toString();
  }

  static String convertLocalDateMonthFromString(String? dateTime) {
    if (dateTime == null || dateTime.trim().isEmpty) return '--';
    // 10 July, 1996
    return DateFormat('d MMM, y')
        .format(DateTime.parse(dateTime).toLocal())
        .toString();
  }

  static String calculateBetweenDuration(String? from, String? to) {
    if (from == null ||
        from.trim().isEmpty ||
        to == null ||
        to.trim().isEmpty) {
      return '--';
    }
    DateTime fromDateTime = DateTime.parse(from);
    DateTime toDateTime = DateTime.parse(to);
    Duration durationDifference = toDateTime.difference(fromDateTime);

    return '${printDuration(durationDifference)} hrs';
  }

  static String printDuration(Duration duration) {
    String twoDigits(int n) {
      if (n >= 10) return '$n';
      return '0$n';
    }

    String twoDigitMinutes = twoDigits(duration.inMinutes.remainder(60));
    String twoDigitSeconds = twoDigits(duration.inSeconds.remainder(60));
    if (duration.inHours > 0) {
      return '${twoDigits(duration.inHours)}:$twoDigitMinutes:$twoDigitSeconds';
    } else {
      return '00:$twoDigitMinutes:$twoDigitSeconds';
    }
  }

  static int convertPositiveNumber(int number) {
    return number.abs();
  }

  static String convertSingleName(String firstName, String lastName) {
    return (lastName.trim().isEmpty) ? firstName : '$firstName $lastName';
  }

  static String timeAgo(String dateTimeStr) {
    // check zonetime if not we added Z

    DateTime dateTime = dateTimeStr.contains('Z')
        ? DateTime.parse(dateTimeStr)
        : DateTime.parse('${dateTimeStr}Z');

    Duration diff = DateTime.now().difference(dateTime.toLocal());

    if (diff.inDays > 365) {
      return '${(diff.inDays / 365).floor()} ${(diff.inDays / 365).floor() == 1 ? 'year' : 'years'} ago';
    }
    if (diff.inDays > 30) {
      return '${(diff.inDays / 30).floor()} ${(diff.inDays / 30).floor() == 1 ? 'month' : 'months'} ago';
    }
    if (diff.inDays > 7) {
      return '${(diff.inDays / 7).floor()} ${(diff.inDays / 7).floor() == 1 ? 'week' : 'weeks'} ago';
    }
    if (diff.inDays > 0) {
      return '${diff.inDays} ${diff.inDays == 1 ? 'day' : 'days'} ago';
    }
    if (diff.inHours > 0) {
      return '${diff.inHours} ${diff.inHours == 1 ? 'hour' : 'hours'} ago';
    }
    if (diff.inMinutes > 0) {
      return '${diff.inMinutes} ${diff.inMinutes == 1 ? 'minute' : 'minutes'} ago';
    }
    return 'just now';
  }

  static String closeTime(DateTime dateTime) {
    Duration diff = dateTime.toLocal().difference(DateTime.now());
    // if (diff.inDays > 365) {
    //   return '${(diff.inDays / 365).floor()} ${(diff.inDays / 365).floor() == 1 ? 'year' : 'years'}';
    // }
    // if (diff.inDays > 30) {
    //   return '${(diff.inDays / 30).floor()} ${(diff.inDays / 30).floor() == 1 ? 'month' : 'months'}';
    // }
    // if (diff.inDays > 7) {
    //   return '${(diff.inDays / 7).floor()} ${(diff.inDays / 7).floor() == 1 ? 'week' : 'weeks'}';
    // }
    if (diff.inDays > 0) {
      return '${diff.inDays} ${diff.inDays == 1 ? 'day' : 'days'}';
    }
    if (diff.inHours > 0) {
      return '${diff.inHours} ${diff.inHours == 1 ? 'hour' : 'hours'}';
    }
    if (diff.inMinutes > 0) {
      return '${diff.inMinutes} ${diff.inMinutes == 1 ? 'minute' : 'minutes'}';
    }
    return '';
  }
}
