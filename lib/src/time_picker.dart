import 'dart:math';
import 'package:flutter/material.dart';
import '../src/utils.dart';
import '../decoration/time_picker_sector_decoration.dart';
import '../decoration/time_picker_sweep_decoration.dart';
import '../decoration/time_picker_handler_decoration.dart';
import '../decoration/time_picker_decoration.dart';
import '../painters/time_picker_painter.dart';

/// Returns a widget which displays a circle to be used as a picker.
///
/// Required arguments are init and end to set the initial selection.
/// onSelectionChange is a callback function which returns new values as the user
/// changes the interval.
/// The rest of the params are used to change the look and feel.
///
class TimePicker extends StatefulWidget {
  /// the initial time
  final PickedTime initTime;

  /// the end time
  final PickedTime endTime;

  /// the number of primary sectors to be painted
  /// will be painted using selectionColor
  final int? primarySectors;

  /// the number of secondary sectors to be painted
  /// will be painted using baseColor
  final int? secondarySectors;

  /// an optional widget that would be mounted inside the circle
  final Widget? child;

  /// height of the canvas, default at 220
  final double? height;

  /// width of the canvas, default at 220
  final double? width;

  /// callback function when init and end change
  final SelectionChanged<PickedTime> onSelectionChange;

  /// callback function when init and end finish
  final SelectionChanged<PickedTime> onSelectionEnd;

  /// used to decorate the our widget
  final TimePickerDecoration? decoration;

  /// used to enabled or disabled Selection of Init Handler
  final bool isInitHandlerSelectable;

  /// used to enabled or disabled Selection of End Handler
  final bool isEndHandlerSelectable;

  /// used to disable Selection range, If null so there is no time range
  final DisabledRange? disabledRange;

  @override
  _TimePickerState createState() => _TimePickerState();

  TimePicker({
    required this.initTime,
    required this.endTime,
    required this.onSelectionChange,
    required this.onSelectionEnd,
    this.child,
    this.decoration,
    this.height,
    this.width,
    this.primarySectors,
    this.secondarySectors,
    this.isInitHandlerSelectable = true,
    this.isEndHandlerSelectable = true,
    this.disabledRange,
  });
}

class _TimePickerState extends State<TimePicker> {
  int _init = 0;
  int _end = 0;

  int? _disabledInit;
  int? _disabledEnd;

  DateTime? disabledStartTime;
  DateTime? disabledEndTime;

  bool? error;

  @override
  void initState() {
    super.initState();
    _init = pickedTimeToDivision(
      pickedTime: widget.initTime,
      clockTimeFormat:
          widget.decoration?.clockNumberDecoration?.clockTimeFormat ??
              ClockTimeFormat.twentyFourHours,
      clockIncrementTimeFormat:
          widget.decoration?.clockNumberDecoration?.clockIncrementTimeFormat ??
              ClockIncrementTimeFormat.fiveMin,
    );
    _end = pickedTimeToDivision(
      pickedTime: widget.endTime,
      clockTimeFormat:
          widget.decoration?.clockNumberDecoration?.clockTimeFormat ??
              ClockTimeFormat.twentyFourHours,
      clockIncrementTimeFormat:
          widget.decoration?.clockNumberDecoration?.clockIncrementTimeFormat ??
              ClockIncrementTimeFormat.fiveMin,
    );

    if (widget.disabledRange != null) {
      disabledStartTime = getTime(widget.disabledRange!.initTime);
      disabledEndTime = getTime(widget.disabledRange!.endTime);

      _disabledInit = pickedTimeToDivision(
        pickedTime: widget.disabledRange!.initTime,
        clockTimeFormat:
            widget.decoration?.clockNumberDecoration?.clockTimeFormat ??
                ClockTimeFormat.twentyFourHours,
        clockIncrementTimeFormat: widget
                .decoration?.clockNumberDecoration?.clockIncrementTimeFormat ??
            ClockIncrementTimeFormat.fiveMin,
      );
      _disabledEnd = pickedTimeToDivision(
        pickedTime: widget.disabledRange!.endTime,
        clockTimeFormat:
            widget.decoration?.clockNumberDecoration?.clockTimeFormat ??
                ClockTimeFormat.twentyFourHours,
        clockIncrementTimeFormat: widget
                .decoration?.clockNumberDecoration?.clockIncrementTimeFormat ??
            ClockIncrementTimeFormat.fiveMin,
      );

      error = validateRange(widget.initTime, widget.endTime);
    }
  }

  TimePickerDecoration getDefaultPickerDecorator() {
    var startBox = TimePickerHandlerDecoration(
      color: Colors.lightBlue[900]!.withOpacity(0.6),
      shape: BoxShape.circle,
      icon: Icon(
        Icons.filter_tilt_shift,
        size: 30,
        color: Colors.lightBlue[700],
      ),
      useRoundedPickerCap: true,
    );

    var endBox = TimePickerHandlerDecoration(
      color: Colors.lightBlue[900]!.withOpacity(0.8),
      shape: BoxShape.circle,
      icon: Icon(
        Icons.filter_tilt_shift,
        size: 40,
        color: Colors.lightBlue[700],
      ),
      useRoundedPickerCap: true,
    );

    var sweepDecoration = TimePickerSweepDecoration(
      pickerStrokeWidth: 12,
      pickerGradient: SweepGradient(
        startAngle: 3 * pi / 2,
        endAngle: 7 * pi / 2,
        tileMode: TileMode.repeated,
        colors: [Colors.red.withOpacity(0.8), Colors.blue.withOpacity(0.8)],
      ),
    );

    var primarySectorDecoration = TimePickerSectorDecoration(
      color: Colors.blue,
      width: 2,
      size: 8,
      useRoundedCap: false,
    );

    var secondarySectorDecoration = primarySectorDecoration.copyWith(
      color: Colors.lightBlue.withOpacity(0.5),
      width: 1,
      size: 6,
    );

    return TimePickerDecoration(
      sweepDecoration: sweepDecoration,
      baseColor: Colors.lightBlue[200]!.withOpacity(0.2),
      primarySectorsDecoration: primarySectorDecoration,
      secondarySectorsDecoration: secondarySectorDecoration,
      initHandlerDecoration: startBox,
      endHandlerDecoration: endBox,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: widget.height ?? 220,
      width: widget.width ?? 220,
      child: TimePickerPainter(
        init: _init,
        end: _end,
        disableTimeStart: _disabledInit,
        disableTimeEnd: _disabledEnd,
        disabledRangeColor: widget.disabledRange?.disabledRangeColor,
        errorColor: widget.disabledRange?.errorColor,
        primarySectors: widget.primarySectors ?? 0,
        secondarySectors: widget.secondarySectors ?? 0,
        child: widget.child ?? Container(),
        onSelectionChange: (newInit, newEnd, isDisableRange) {
          PickedTime inTime = formatTime(
            time: newInit,
            incrementTimeFormat: widget.decoration?.clockNumberDecoration
                    ?.clockIncrementTimeFormat ??
                ClockIncrementTimeFormat.fiveMin,
          );
          PickedTime outTime = formatTime(
            time: newEnd,
            incrementTimeFormat: widget.decoration?.clockNumberDecoration
                    ?.clockIncrementTimeFormat ??
                ClockIncrementTimeFormat.fiveMin,
          );

          bool? _valid;

          if (widget.disabledRange != null) {
            _valid = validateRange(inTime, outTime);
            widget.onSelectionChange(inTime, outTime, _valid);
          } else {
            widget.onSelectionChange(inTime, outTime, true);
          }

          setState(() {
            error = _valid;
            _init = newInit;
            _end = newEnd;
          });
        },
        onSelectionEnd: (newInit, newEnd, isDisableRange) {
          var inTime = formatTime(
            time: newInit,
            incrementTimeFormat: widget.decoration?.clockNumberDecoration
                    ?.clockIncrementTimeFormat ??
                ClockIncrementTimeFormat.fiveMin,
          );
          var outTime = formatTime(
            time: newEnd,
            incrementTimeFormat: widget.decoration?.clockNumberDecoration
                    ?.clockIncrementTimeFormat ??
                ClockIncrementTimeFormat.fiveMin,
          );

          if (widget.disabledRange != null) {
            bool _valid = validateRange(inTime, outTime);
            widget.onSelectionEnd(inTime, outTime, _valid);
            if (_valid != error) {
              setState(() {
                error = _valid;
              });
            }
          } else {
            widget.onSelectionEnd(inTime, outTime, true);
          }
        },
        pickerDecoration: getDecoration() ?? getDefaultPickerDecorator(),
        isInitHandlerSelectable: widget.isInitHandlerSelectable,
        isEndHandlerSelectable: widget.isEndHandlerSelectable,
      ),
    );
  }

  TimePickerDecoration? getDecoration() {
    if (error == false) {
      return widget.decoration?.copyWith(
        sweepDecoration: widget.decoration?.sweepDecoration.copyWith(
          pickerColor: widget.disabledRange?.errorColor ?? Colors.red,
        ),
      );
    }
    return widget.decoration;
  }

  bool validateRange(PickedTime newStart, PickedTime newEnd) {
    DateTime _newStart = getTime(newStart);
    DateTime _newEnd = getTime(newEnd);

    if (_newStart.isAfter(_newEnd) || _newStart.isAtSameMomentAs(_newEnd)) {
      if (disabledStartTime!.isAfter(_newStart) &&
          disabledStartTime!
              .isBefore(_newEnd.add(Duration(hours: widget.primarySectors!)))) {
        return false;
      }
      if (disabledEndTime!.isAfter(_newStart) &&
          disabledEndTime!
              .isBefore(_newEnd.add(Duration(hours: widget.primarySectors!)))) {
        return false;
      }
      _newStart = _newStart.add(Duration(hours: -widget.primarySectors!));
    }
    if (disabledStartTime!.isAfter(disabledEndTime!) ||
        disabledStartTime!.isAtSameMomentAs(disabledEndTime!)) {
      disabledStartTime =
          disabledStartTime!.add(Duration(hours: -widget.primarySectors!));
    }
    if (_newStart.isAfter(disabledStartTime!) &&
        _newStart.isBefore(disabledEndTime!)) {
      return false;
    }
    if (_newEnd.isAfter(disabledStartTime!) &&
        _newEnd.isBefore(disabledEndTime!)) {
      return false;
    }

    if (disabledStartTime!.isAfter(_newStart) &&
        disabledStartTime!.isBefore(_newEnd)) {
      return false;
    }
    if (disabledEndTime!.isAfter(_newStart) &&
        disabledEndTime!.isBefore(_newEnd)) {
      return false;
    }
    return true;
  }

  DateTime getTime(PickedTime time) {
    DateTime now = DateTime.now();
    return DateTime(now.year, now.month, now.day,
        time.h == 0 ? (widget.primarySectors!) : time.h, time.m);
  }
}

class DisabledRange {
  const DisabledRange({
    required this.initTime,
    required this.endTime,
    this.disabledRangeColor,
    this.errorColor,
  });

  final PickedTime initTime;
  final PickedTime endTime;
  final Color? disabledRangeColor;
  final Color? errorColor;
}
