import 'dart:math';
import 'dart:ui';

double percentageToRadians(double percentage) => ((2 * pi * percentage) / 100);

double radiansToPercentage(double radians) {
  var normalized = radians < 0 ? -radians : 2 * pi - radians;
  var percentage = ((100 * normalized) / (2 * pi));
  // TODO we have an inconsistency of pi/2 in terms of percentage and radians
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
  ClockTimeFormat? clockTimeFormat,
}) {
  var clockTime = clockTimeFormat ?? ClockTimeFormat.twentyFourHours;

  /// converting pickedTime data with the picker circle division angle
  var hours = ((clockTime.division * pickedTime.h) / clockTime.value).round() %
      clockTime.division;
  var minutes =
      ((clockTime.division * (pickedTime.m / 60)) / clockTime.value).round() %
          clockTime.division;

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
  // distance is root(sqr(x2 - x1) + sqr(y2 - y1))
  // i.e., (7,8) and (3,2) -> 7.21
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
    Offset center, double radius, int sections) {
  var intervalAngle = (pi * 2) / sections;
  return List<int>.generate(sections, (int index) => index).map((i) {
    var radians = (pi / 2) + (intervalAngle * i);
    return radiansToCoordinates(center, radians, radius);
  }).toList();
}

bool isAngleInsideRadiansSelection(double angle, double start, double sweep) {
  var normalized = angle > pi / 2 ? 5 * pi / 2 - angle : pi / 2 - angle;
  var end = (start + sweep) % (2 * pi);
  return end > start
      ? normalized > start && normalized < end
      : normalized > start || normalized < end;
}

// this is not 100% accurate but it works
// we just want to see if a value changed drastically its value
bool radiansWasModuloded(double current, double previous) {
  return (previous - current).abs() > (3 * pi / 2);
}

enum ClockTimeFormat {
  twelveHours,
  twentyFourHours,
}

extension ClockTimeFormatExtension on ClockTimeFormat {
  int get value {
    switch (this) {
      case ClockTimeFormat.twelveHours:
        return 12;
      case ClockTimeFormat.twentyFourHours:
        return 24;
      default:
        return 24;
    }
  }

  int get division {
    switch (this) {
      case ClockTimeFormat.twelveHours:
        return 144;
      case ClockTimeFormat.twentyFourHours:
        return 288;
      default:
        return 288;
    }
  }
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
}) {
  if (time == 0) {
    return PickedTime(h: 0, m: 0);
  }
  var hours = time ~/ 12;
  var minutes = (time % 12) * 5;

  return PickedTime(h: hours, m: minutes);
}

PickedTime formatIntervalTime({
  required PickedTime init,
  required PickedTime end,
  ClockTimeFormat? clockTimeFormat,
}) {
  var clockTime = clockTimeFormat ?? ClockTimeFormat.twentyFourHours;

  var _init =
      pickedTimeToDivision(pickedTime: init, clockTimeFormat: clockTime);
  var _end = pickedTimeToDivision(pickedTime: end, clockTimeFormat: clockTime);

  var sleepTime =
      _end > _init ? _end - _init : clockTime.division - _init + _end;

  var hours = sleepTime ~/ 12;
  var minutes = (sleepTime % 12) * 5;

  return PickedTime(
    h: hours,
    m: minutes,
  );
}

bool validateSleepGoal({
  required PickedTime inTime,
  required PickedTime outTime,
  required double sleepGoal,
  ClockTimeFormat? clockTimeFormat,
}) {
  var clockTime = clockTimeFormat ?? ClockTimeFormat.twentyFourHours;

  var _inTime =
      pickedTimeToDivision(pickedTime: inTime, clockTimeFormat: clockTime);
  var _outTime =
      pickedTimeToDivision(pickedTime: outTime, clockTimeFormat: clockTime);

  var sleepTime = _outTime > _inTime
      ? _outTime - _inTime
      : clockTime.division - _inTime + _outTime;
  var sleepHours = sleepTime ~/ 12;
  return (sleepHours >= sleepGoal) ? true : false;
}
