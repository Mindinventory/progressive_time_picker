import 'dart:math';
import 'dart:ui';

double percentageToRadians(double percentage) => ((2 * pi * percentage) / 100);

double radiansToPercentage(double radians) {
  /// we have an inconsistency of pi/2 in terms of percentage and radians
  var normalized = radians < 0 ? -radians : 2 * pi - radians;
  var percentage = ((100 * normalized) / (2 * pi));
  return (percentage + 25) % 100;
}

double coordinatesToRadians(Offset center, Offset coords) {
  var a = coords.dx - center.dx;
  var b = center.dy - coords.dy;
  return atan2(b, a);
}

Offset radiansToCoordinates(Offset center, double radians, double radius) {
  var dx = center.dx + radius * cos(radians);
  var dy = center.dy + radius * sin(radians);
  return Offset(dx, dy);
}

double valueToPercentage(int time, int intervals) => (time / intervals) * 100;

int percentageToValue(double percentage, int intervals) =>
    ((percentage * intervals) / 100).round();

int pickedTimeToDivision({
  required PickedTime pickedTime,
  required ClockTimeFormat clockTimeFormat,
  required ClockIncrementTimeFormat clockIncrementTimeFormat,
}) {
  var clockTimeDivision = getClockTimeFormatDivision(
    clockTimeFormat,
    clockIncrementTimeFormat,
  );

  /// converting pickedTime data with the picker circle division angle
  var hours =
      ((clockTimeDivision * pickedTime.h) / clockTimeFormat.value).round() %
          clockTimeDivision;
  var minutes =
      ((clockTimeDivision * (pickedTime.m / 60)) / clockTimeFormat.value)
              .round() %
          clockTimeDivision;

  return (hours + minutes);
}

bool isPointInsideCircle(Offset point, Offset center, double rradius) {
  var radius = rradius * 1.2;
  return point.dx < (center.dx + radius) &&
      point.dx > (center.dx - radius) &&
      point.dy < (center.dy + radius) &&
      point.dy > (center.dy - radius);
}

bool isPointAlongCircle(Offset point, Offset center, double radius) {
  /// distance is root(sqr(x2 - x1) + sqr(y2 - y1))
  /// i.e., (7,8) and (3,2) -> 7.21
  var d1 = pow(point.dx - center.dx, 2);
  var d2 = pow(point.dy - center.dy, 2);
  var distance = sqrt(d1 + d2);
  return (distance - radius).abs() < 10;
}

double getSweepAngle(double init, double end) {
  if (end > init) {
    return end - init;
  }
  return (100 - init + end).abs();
}

List<Offset> getSectionsCoordinatesInCircle(
  Offset center,
  double radius,
  int sections,
) {
  var intervalAngle = (pi * 2) / sections;
  return List<int>.generate(sections, (int index) => index).map((i) {
    var radians = (pi / 2) + (intervalAngle * i);
    return radiansToCoordinates(center, radians, radius);
  }).toList();
}

bool isAngleInsideRadiansSelection(
  double angle,
  double start,
  double sweep,
  ClockIncrementTimeFormat clockIncrementTimeFormat,
) {
  var normalized = angle > pi / 2
      ? clockIncrementTimeFormat.value * pi / 2 - angle
      : pi / 2 - angle;
  var end = (start + sweep) % (2 * pi);
  return end > start
      ? normalized > start && normalized < end
      : normalized > start || normalized < end;
}

enum ClockTimeFormat {
  TWELVEHOURS,
  TWENTYFOURHOURS,
}

extension ClockTimeFormatExtension on ClockTimeFormat {
  int get value {
    switch (this) {
      case ClockTimeFormat.TWELVEHOURS:
        return 12;
      case ClockTimeFormat.TWENTYFOURHOURS:
        return 24;
    }
  }
}

enum ClockIncrementTimeFormat {
  ONEMIN,
  TWOMIN,
  THREEMIN,
  FOURMIN,
  FIVEMIN,
  SIXMIN,
  TENMIN,
  TWELVEMIN,
  FIFTEENMIN,
  TWENTYMIN,
  THIRTYMIN,
  SIXTYMIN,
}

extension ClockIncrementTimeFormatExtension on ClockIncrementTimeFormat {
  int get value {
    switch (this) {
      case ClockIncrementTimeFormat.ONEMIN:
        return 1;
      case ClockIncrementTimeFormat.TWOMIN:
        return 2;
      case ClockIncrementTimeFormat.THREEMIN:
        return 3;
      case ClockIncrementTimeFormat.FOURMIN:
        return 4;
      case ClockIncrementTimeFormat.FIVEMIN:
        return 5;
      case ClockIncrementTimeFormat.SIXMIN:
        return 6;
      case ClockIncrementTimeFormat.TENMIN:
        return 10;
      case ClockIncrementTimeFormat.TWELVEMIN:
        return 12;
      case ClockIncrementTimeFormat.FIFTEENMIN:
        return 15;
      case ClockIncrementTimeFormat.TWENTYMIN:
        return 20;
      case ClockIncrementTimeFormat.THIRTYMIN:
        return 30;
      case ClockIncrementTimeFormat.SIXTYMIN:
        return 60;
    }
  }
}

int getClockTimeFormatDivision(
  ClockTimeFormat clockTimeFormat,
  ClockIncrementTimeFormat incrementTimeFormat,
) {
  /// The 60 minute is divisible by
  /// 1, 2, 3, 4, 5, 6, 10, 12, 15, 20, 30, and 60.
  var timeDivisor = 60 ~/ incrementTimeFormat.value;
  return (timeDivisor * clockTimeFormat.value);
}

class PickedTime {
  final int h;
  final int m;

  PickedTime({
    required this.h,
    required this.m,
  });
}

PickedTime formatTime({
  required int time,
  required ClockIncrementTimeFormat incrementTimeFormat,
}) {
  if (time == 0) {
    return PickedTime(h: 0, m: 0);
  }
  var timeDivisor = 60 ~/ incrementTimeFormat.value;
  var hours = time ~/ timeDivisor;
  var minutes = (time % timeDivisor) * incrementTimeFormat.value;
  return PickedTime(h: hours, m: minutes);
}

PickedTime formatIntervalTime({
  required PickedTime init,
  required PickedTime end,
  ClockTimeFormat clockTimeFormat = ClockTimeFormat.TWENTYFOURHOURS,
  ClockIncrementTimeFormat clockIncrementTimeFormat =
      ClockIncrementTimeFormat.FIVEMIN,
}) {
  var clockTimeDivision = getClockTimeFormatDivision(
    clockTimeFormat,
    clockIncrementTimeFormat,
  );

  var _init = pickedTimeToDivision(
    pickedTime: init,
    clockTimeFormat: clockTimeFormat,
    clockIncrementTimeFormat: clockIncrementTimeFormat,
  );
  var _end = pickedTimeToDivision(
    pickedTime: end,
    clockTimeFormat: clockTimeFormat,
    clockIncrementTimeFormat: clockIncrementTimeFormat,
  );

  var sleepTime =
      _end > _init ? _end - _init : clockTimeDivision - _init + _end;

  var timeDivisor = 60 ~/ clockIncrementTimeFormat.value;
  var hours = sleepTime ~/ timeDivisor;
  var minutes = (sleepTime % timeDivisor) * clockIncrementTimeFormat.value;

  return PickedTime(
    h: hours,
    m: minutes,
  );
}

bool validateSleepGoal({
  required PickedTime inTime,
  required PickedTime outTime,
  required double sleepGoal,
  ClockTimeFormat clockTimeFormat = ClockTimeFormat.TWENTYFOURHOURS,
  ClockIncrementTimeFormat clockIncrementTimeFormat =
      ClockIncrementTimeFormat.FIVEMIN,
}) {
  var clockTimeDivision = getClockTimeFormatDivision(
    clockTimeFormat,
    clockIncrementTimeFormat,
  );

  var _inTime = pickedTimeToDivision(
    pickedTime: inTime,
    clockTimeFormat: clockTimeFormat,
    clockIncrementTimeFormat: clockIncrementTimeFormat,
  );
  var _outTime = pickedTimeToDivision(
    pickedTime: outTime,
    clockTimeFormat: clockTimeFormat,
    clockIncrementTimeFormat: clockIncrementTimeFormat,
  );

  var sleepTime = _outTime > _inTime
      ? _outTime - _inTime
      : clockTimeDivision - _inTime + _outTime;

  var timeDivisor = 60 ~/ clockIncrementTimeFormat.value;
  var sleepHours = sleepTime ~/ timeDivisor;
  return (sleepHours >= sleepGoal) ? true : false;
}
