/**
 * @created 22/10/2023 - 12:07
 * @project aindia_auto_app
 * @author mamadoudiallo
 */

import 'package:intl/intl.dart';
import 'package:timezone/timezone.dart' as tz;

class DatesUtil {
  String getCurrentTime(String timezone, String format) {
    final timeZone = tz.getLocation(timezone);
    final currentTime = tz.TZDateTime.now(timeZone);
    final DateFormat timeFormat = DateFormat(format);
    return timeFormat.format(currentTime);
  }

  int convertDateTimeToMilliseconds(
      String datetimeString, String timezone, String format) {
    DateTime datetime = DateFormat(format).parse(datetimeString);
    DateTime datetimeWithTimezone = getDatetimeWithTimezone(datetime);
    return datetimeWithTimezone.millisecondsSinceEpoch;
  }

  DateTime getDatetimeWithTimezone(DateTime datetime) {
    Duration offset = DateTime.parse(datetime.toString()).timeZoneOffset;
    int offsetSeconds = offset.inSeconds;
    return datetime.add(Duration(seconds: offsetSeconds));
  }
}
