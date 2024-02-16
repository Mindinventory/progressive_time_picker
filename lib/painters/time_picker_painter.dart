import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

import 'base_time_painter.dart';
import '../decoration/time_picker_decoration.dart';
import '../painters/picker_painter.dart';
import '../src/utils.dart';

typedef SelectionChanged<T> = void Function(T a, T b, bool? valid);

class TimePickerPainter extends StatefulWidget {
  final int init;
  final int end;
  final int? disableTimeStart;
  final int? disableTimeEnd;
  final Color? disabledRangeColor;
  final Color? errorColor;
  final int primarySectors;
  final int secondarySectors;
  final SelectionChanged<int> onSelectionChange;
  final SelectionChanged<int> onSelectionEnd;
  final Widget child;
  final TimePickerDecoration pickerDecoration;
  final bool isInitHandlerSelectable;
  final bool isEndHandlerSelectable;
  final bool isSelectableHandlerMoveAble;
  final bool drawInitHandlerOnTop;

  TimePickerPainter({
    required this.init,
    required this.end,
    this.disableTimeStart,
    this.disableTimeEnd,
    this.disabledRangeColor,
    this.errorColor,
    required this.child,
    required this.primarySectors,
    required this.secondarySectors,
    required this.onSelectionChange,
    required this.onSelectionEnd,
    required this.pickerDecoration,
    required this.isInitHandlerSelectable,
    required this.isEndHandlerSelectable,
    required this.isSelectableHandlerMoveAble,
    this.drawInitHandlerOnTop = false,
  });

  @override
  _TimePickerPainterState createState() => _TimePickerPainterState();
}

class _TimePickerPainterState extends State<TimePickerPainter> {
  bool _isInitHandlerSelected = false;
  bool _isEndHandlerSelected = false;

  late PickerPainter _painter;

  /// this field will allow us to keep track of the last known good location for
  /// endHandler it helps to fix issue when using MIN/MAX values and the picker
  /// is sweep across the total clock division
  int lastValidEndHandlerLocation = 0;

  /// this field will allow us to keep track of the last known good location for
  /// initHandler it helps to fix issue when using MIN/MAX values and the picker
  /// is sweep across the total clock division
  int lastValidInitHandlerLocation = 0;

  /// start angle in radians where we need to locate the init handler
  double _startAngle = 0.0;

  /// end angle in radians where we need to locate the end handler
  double _endAngle = 0.0;

  /// the absolute angle in radians representing the selection
  late double _sweepAngle;

  double? _disableTimeStartAngle;
  double? _disableTimeEndAngle;
  double? _disableSweepAngle;

  /// in case we have a double picker and we want to move the whole selection by
  /// clicking in the picker this will capture the position in the selection
  /// relative to the initial handler that way we will be able to keep the
  /// selection constant when moving
  late int _differenceFromInitPoint;

  bool get isBothHandlersSelected =>
      _isEndHandlerSelected && _isInitHandlerSelected;

  bool get isNoHandlersSelected =>
      !_isEndHandlerSelected && !_isInitHandlerSelected;

  @override
  void initState() {
    super.initState();

    _calculatePaintData();
  }

  /// we need to update this widget both with gesture detector but
  /// also when the parent widget rebuilds itself
  @override
  void didUpdateWidget(TimePickerPainter oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.init != widget.init || oldWidget.end != widget.end) {
      _calculatePaintData();
    }
  }

  @override
  Widget build(BuildContext context) {
    return RawGestureDetector(
      gestures: <Type, GestureRecognizerFactory>{
        CustomPanGestureRecognizer:
            GestureRecognizerFactoryWithHandlers<CustomPanGestureRecognizer>(
          () => CustomPanGestureRecognizer(
            onPanDown: _onPanDown,
            onPanUpdate: _onPanUpdate,
            onPanEnd: _onPanEnd,
          ),
          (CustomPanGestureRecognizer instance) {},
        ),
      },
      child: MouseRegion(
        cursor: kIsWeb
            ? widget.pickerDecoration.mouseCursorForWeb
            : SystemMouseCursors.none,
        child: CustomPaint(
          painter: BaseTimePainter(
            decoration: widget.pickerDecoration,
            primarySectors: widget.primarySectors,
            secondarySectors: widget.secondarySectors,
            pickerStrokeWidth:
                widget.pickerDecoration.sweepDecoration.pickerStrokeWidth,
          ),
          foregroundPainter: _painter,
          child: Padding(
            padding: const EdgeInsets.all(12.0),
            child: widget.child,
          ),
        ),
      ),
    );
  }

  void _calculatePaintData() {
    var clockTimeDivision = getClockTimeFormatDivision(
      widget.pickerDecoration.clockNumberDecoration?.clockTimeFormat ??
          ClockTimeFormat.twentyFourHours,
      widget.pickerDecoration.clockNumberDecoration?.clockIncrementTimeFormat ??
          ClockIncrementTimeFormat.fiveMin,
    );
    var initPercent = valueToPercentage(widget.init, clockTimeDivision);
    var endPercent = valueToPercentage(widget.end, clockTimeDivision);
    var sweep = getSweepAngle(initPercent, endPercent);

    _startAngle = percentageToRadians(initPercent);
    _endAngle = percentageToRadians(endPercent);
    _sweepAngle = percentageToRadians(sweep.abs());

    if (widget.disableTimeStart != null && widget.disableTimeEnd != null) {
      var disableTimeInitPercentage =
          valueToPercentage(widget.disableTimeStart!, clockTimeDivision);
      var disableTimeEndPercentage =
          valueToPercentage(widget.disableTimeEnd!, clockTimeDivision);
      var disabledSweep =
          getSweepAngle(disableTimeInitPercentage, disableTimeEndPercentage);

      _disableTimeStartAngle = percentageToRadians(disableTimeInitPercentage);
      _disableTimeEndAngle = percentageToRadians(disableTimeEndPercentage);
      _disableSweepAngle = percentageToRadians(disabledSweep.abs());
    }

    _painter = PickerPainter(
      startAngle: _startAngle,
      endAngle: _endAngle,
      sweepAngle: _sweepAngle,
      pickerDecorator: widget.pickerDecoration,
      disableTimeStartAngle: _disableTimeStartAngle,
      disableTimeEndAngle: _disableTimeEndAngle,
      disabledSweepAngle: _disableSweepAngle,
      disabledRangeColor: widget.disabledRangeColor,
      errorColor: widget.errorColor,
      drawInitHandlerOnTop: widget.drawInitHandlerOnTop,
    );
  }

  void _onPanUpdate(Offset details) {
    if (!_isInitHandlerSelected && !_isEndHandlerSelected) {
      return;
    }
    _handlePan(details, false);
  }

  void _onPanEnd(Offset details) {
    _handlePan(details, true);

    _isInitHandlerSelected = false;
    _isEndHandlerSelected = false;
  }

  void _handlePan(Offset details, bool isPanEnd) {
    RenderBox renderBox = context.findRenderObject() as RenderBox;
    var position = renderBox.globalToLocal(details);

    var angle = coordinatesToRadians(_painter.center, position);
    var percentage = radiansToPercentage(angle);
    var clockTimeDivision = getClockTimeFormatDivision(
      widget.pickerDecoration.clockNumberDecoration?.clockTimeFormat ??
          ClockTimeFormat.twentyFourHours,
      widget.pickerDecoration.clockNumberDecoration?.clockIncrementTimeFormat ??
          ClockIncrementTimeFormat.fiveMin,
    );

    var newValue = percentageToValue(percentage, clockTimeDivision);

    if (isBothHandlersSelected) {
      var newValueInit =
          (newValue - _differenceFromInitPoint) % clockTimeDivision;
      var newValueEnd =
          (widget.end + (newValueInit - widget.init)) % clockTimeDivision;

      widget.onSelectionChange(newValueInit, newValueEnd, null);
      if (isPanEnd) {
        widget.onSelectionEnd(newValueInit, newValueEnd, null);
      }
      return;
    }

    /// isDoubleHandler but one handler was selected
    if (_isInitHandlerSelected) {
      widget.onSelectionChange(newValue, widget.end, null);
      if (isPanEnd) {
        widget.onSelectionEnd(newValue, widget.end, null);
      }
    } else {
      widget.onSelectionChange(widget.init, newValue, null);
      if (isPanEnd) {
        widget.onSelectionEnd(widget.init, newValue, null);
      }
    }
  }

  bool _onPanDown(Offset details) {
    RenderBox renderBox = context.findRenderObject() as RenderBox;
    var position = renderBox.globalToLocal(details);

    _isInitHandlerSelected = widget.isInitHandlerSelectable
        ? isPointInsideCircle(position, _painter.initHandlerCenterLocation,
            widget.pickerDecoration.initHandlerDecoration.handlerOutterRadius)
        : false;

    if (!_isInitHandlerSelected) {
      _isEndHandlerSelected = widget.isEndHandlerSelectable
          ? isPointInsideCircle(position, _painter.endHandlerCenterLocation,
              widget.pickerDecoration.endHandlerDecoration.handlerOutterRadius)
          : false;

      if (isNoHandlersSelected && widget.isSelectableHandlerMoveAble) {
        /// we check if the user pressed in the selection in a double handler
        /// picker that means the user wants to move the selection as a whole
        if (isPointAlongCircle(position, _painter.center, _painter.radius)) {
          var angle = coordinatesToRadians(_painter.center, position);
          if (isAngleInsideRadiansSelection(
            angle,
            _startAngle,
            _sweepAngle,
            widget.pickerDecoration.clockNumberDecoration
                    ?.clockIncrementTimeFormat ??
                ClockIncrementTimeFormat.fiveMin,
          )) {
            _isEndHandlerSelected = true;
            _isInitHandlerSelected = true;
            var positionPercentage = radiansToPercentage(angle);
            var clockTimeDivision = getClockTimeFormatDivision(
              widget.pickerDecoration.clockNumberDecoration?.clockTimeFormat ??
                  ClockTimeFormat.twentyFourHours,
              widget.pickerDecoration.clockNumberDecoration
                      ?.clockIncrementTimeFormat ??
                  ClockIncrementTimeFormat.fiveMin,
            );

            /// no need to account for negative values, that will be sorted out
            /// in the onPanUpdate
            _differenceFromInitPoint =
                percentageToValue(positionPercentage, clockTimeDivision) -
                    widget.init;
          }
        }
      }
    }
    return _isInitHandlerSelected || _isEndHandlerSelected;
  }
}

class CustomPanGestureRecognizer extends OneSequenceGestureRecognizer {
  final Function onPanDown;
  final Function onPanUpdate;
  final Function onPanEnd;

  CustomPanGestureRecognizer({
    required this.onPanDown,
    required this.onPanUpdate,
    required this.onPanEnd,
  });

  @override
  void addPointer(PointerEvent event) {
    if (onPanDown(event.position)) {
      startTrackingPointer(event.pointer);
      resolve(GestureDisposition.accepted);
    } else {
      stopTrackingPointer(event.pointer);
    }
  }

  @override
  void handleEvent(PointerEvent event) {
    if (event is PointerMoveEvent) {
      onPanUpdate(event.position);
    }
    if (event is PointerUpEvent) {
      onPanEnd(event.position);
      stopTrackingPointer(event.pointer);
    }
  }

  @override
  String get debugDescription => 'customPan';

  @override
  void didStopTrackingLastPointer(int pointer) {}
}
