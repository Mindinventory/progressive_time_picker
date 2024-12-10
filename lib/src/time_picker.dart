import 'dart:math';

import 'package:flutter/material.dart';

import '../decoration/time_picker_decoration.dart';
import '../decoration/time_picker_handler_decoration.dart';
import '../decoration/time_picker_sector_decoration.dart';
import '../decoration/time_picker_sweep_decoration.dart';
import '../painters/time_picker_painter.dart';
import '../src/utils.dart';

/// Returns a widget which displays a circle to be used as a picker.
///
/// Required arguments are init and end to set the initial selection.
/// onSelectionChange is a callback function which returns new values as the
/// user changes the interval.
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

  /// used to enabled or disabled the Movement of Init and End Handler when its
  /// not Selectable
  /// disable the dragging of both handlers
  final bool isSelectableHandlerMoveAble;

  /// used to disable Selection ranges, If null so there is no disable time ranges
  final List<DisabledRange>? disabledRanges;

  /// defines the color for the disabled range
  /// Default Value: [Colors.grey]
  final Color? disabledRangesColor;

  /// defines the color for the error in disabled range
  /// Default Value: [Colors.red]
  final Color? disabledRangesErrorColor;

  /// used to set priority to draw init or end handler on the top
  /// default value: false
  final bool drawInitHandlerOnTop;

  @override
  _TimePickerState createState() => _TimePickerState();

  /// Creates a TimePicker.
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
    this.isSelectableHandlerMoveAble = true,
    this.disabledRanges,
    this.disabledRangesColor = Colors.grey,
    this.disabledRangesErrorColor = Colors.red,
    this.drawInitHandlerOnTop = false,
  });
}

class _TimePickerState extends State<TimePicker> {
  int _init = 0;
  int _end = 0;

  List<int>? _disabledInit;
  List<int>? _disabledEnd;

  List<DateTime>? disabledStartTime;
  List<DateTime>? disabledEndTime;

  bool? error;

  @override
  void initState() {
    super.initState();
    _calculatePickerData();
  }

  /// we need to update this widget when the parent widget changes
  @override
  void didUpdateWidget(TimePicker oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.initTime != widget.initTime ||
        oldWidget.endTime != widget.endTime ||
        oldWidget.disabledRanges != widget.disabledRanges) {
      _calculatePickerData();
    }
  }

  void _calculatePickerData() {
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

    _disabledInit = [];
    _disabledEnd = [];

    if (widget.disabledRanges?.isNotEmpty ?? false) {
      for (DisabledRange disabledRange in widget.disabledRanges!) {
        _disabledInit?.add(
          pickedTimeToDivision(
            pickedTime: disabledRange.initTime,
            clockTimeFormat:
                widget.decoration?.clockNumberDecoration?.clockTimeFormat ??
                    ClockTimeFormat.twentyFourHours,
            clockIncrementTimeFormat: widget.decoration?.clockNumberDecoration
                    ?.clockIncrementTimeFormat ??
                ClockIncrementTimeFormat.fiveMin,
          ),
        );
        _disabledEnd?.add(
          pickedTimeToDivision(
            pickedTime: disabledRange.endTime,
            clockTimeFormat:
                widget.decoration?.clockNumberDecoration?.clockTimeFormat ??
                    ClockTimeFormat.twentyFourHours,
            clockIncrementTimeFormat: widget.decoration?.clockNumberDecoration
                    ?.clockIncrementTimeFormat ??
                ClockIncrementTimeFormat.fiveMin,
          ),
        );
      }

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
        disabledRangeColor: widget.disabledRangesColor,
        errorColor: widget.disabledRangesErrorColor,
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

          if (widget.disabledRanges?.isNotEmpty ?? false) {
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

          if (widget.disabledRanges?.isNotEmpty ?? false) {
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
        isSelectableHandlerMoveAble: widget.isSelectableHandlerMoveAble,
        drawInitHandlerOnTop: widget.drawInitHandlerOnTop,
      ),
    );
  }

  TimePickerDecoration? getDecoration() {
    if (error == false) {
      return widget.decoration?.copyWith(
        sweepDecoration: widget.decoration?.sweepDecoration.copyWith(
          pickerColor: widget.disabledRangesErrorColor,
        ),
      );
    }
    return widget.decoration;
  }

  bool validateRange(PickedTime newStart, PickedTime newEnd) {
    int startInMinutes = _convertToMinutes(newStart);
    int endInMinutes = _convertToMinutes(newEnd);
    int totalMinutesInDay =
        (widget.primarySectors ?? 0) * 60; // Total minutes in a full circle

    // If the selected start and end times are the same, treat it as spanning the full circle
    if (startInMinutes == endInMinutes) {
      for (var disabledRange in widget.disabledRanges!) {
        int disabledStart = _convertToMinutes(disabledRange.initTime);
        int disabledEnd = _convertToMinutes(disabledRange.endTime);

        // Disabled range spans midnight
        if (disabledStart > disabledEnd) {
          // Overlaps with any part of the circular disabled range
          if (_rangesOverlap(0, disabledEnd, 0, totalMinutesInDay - 1) ||
              _rangesOverlap(disabledStart, totalMinutesInDay - 1, 0,
                  totalMinutesInDay - 1)) {
            return false;
          }
        } else {
          // Normal disabled range
          if (_rangesOverlap(
              0, totalMinutesInDay - 1, disabledStart, disabledEnd)) {
            return false;
          }
        }
      }
      return false; // Entire range selected overlaps all disabled ranges
    }

    // Normal range validation
    for (var disabledRange in widget.disabledRanges!) {
      int disabledStart = _convertToMinutes(disabledRange.initTime);
      int disabledEnd = _convertToMinutes(disabledRange.endTime);

      // Handle circular (midnight-spanning) disabled range
      if (disabledStart > disabledEnd) {
        // Part 1: From disabled start to midnight or 23:59
        if (_rangesOverlap(startInMinutes, endInMinutes, disabledStart,
            totalMinutesInDay - 1)) {
          return false;
        }

        // Part 2: From 00:00 to disabled end
        if (_rangesOverlap(startInMinutes, endInMinutes, 0, disabledEnd)) {
          return false;
        }

        // Special Case: If the selected range itself is circular
        if (startInMinutes > endInMinutes) {
          if (_rangesOverlap(disabledStart, totalMinutesInDay - 1,
                  startInMinutes, totalMinutesInDay - 1) ||
              _rangesOverlap(0, disabledEnd, 0, endInMinutes)) {
            return false;
          }
        }
      } else {
        // Normal disabled range
        if (_rangesOverlap(
            startInMinutes, endInMinutes, disabledStart, disabledEnd)) {
          return false;
        }

        // Special Case: If the selected range itself is circular
        if (startInMinutes > endInMinutes) {
          if (_rangesOverlap(disabledStart, disabledEnd, startInMinutes,
                  totalMinutesInDay - 1) ||
              _rangesOverlap(disabledStart, disabledEnd, 0, endInMinutes)) {
            return false;
          }
        }
      }
    }

    return true;
  }

  // Helper function to check overlap between two ranges
  bool _rangesOverlap(int start1, int end1, int start2, int end2) {
    return !(end1 <= start2 || start1 >= end2);
  }

  // Convert PickedTime to minutes for easier comparison
  int _convertToMinutes(PickedTime time) {
    return time.h * 60 + time.m;
  }
}

class DisabledRange {
  const DisabledRange({
    required this.initTime,
    required this.endTime,
  });

  final PickedTime initTime;
  final PickedTime endTime;
}
