import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import '../painters/picker_painter.dart';
import '../decoration/time_picker_decoration.dart';
import 'base_time_painter.dart';
import '../src/utils.dart';

typedef SelectionChanged<T> = void Function(T a, T b);

class TimePickerPainter extends StatefulWidget {
  final int init;
  final int end;
  final int primarySectors;
  final int secondarySectors;
  final SelectionChanged<int> onSelectionChange;
  final SelectionChanged<int> onSelectionEnd;
  final Widget child;
  final TimePickerDecoration pickerDecoration;
  final bool isInitHandlerSelectable;
  final bool isEndHandlerSelectable;

  TimePickerPainter({
    required this.init,
    required this.end,
    required this.child,
    required this.primarySectors,
    required this.secondarySectors,
    required this.onSelectionChange,
    required this.onSelectionEnd,
    required this.pickerDecoration,
    required this.isInitHandlerSelectable,
    required this.isEndHandlerSelectable,
  });

  @override
  _TimePickerPainterState createState() => _TimePickerPainterState();
}

class _TimePickerPainterState extends State<TimePickerPainter> {
  bool _isInitHandlerSelected = false;
  bool _isEndHandlerSelected = false;

  late PickerPainter _painter;

  /// this field will allow us to keep track of the last known good location for endHandler
  /// it helps to fix issue when using MIN/MAX values and the picker is sweep across the total clock division
  int lastValidEndHandlerLocation = 0;

  /// this field will allow us to keep track of the last known good location for initHandler
  /// it helps to fix issue when using MIN/MAX values and the picker is sweep across the total clock division
  int lastValidInitHandlerLocation = 0;

  /// start angle in radians where we need to locate the init handler
  double _startAngle = 0.0;

  /// end angle in radians where we need to locate the end handler
  double _endAngle = 0.0;

  /// the absolute angle in radians representing the selection
  late double _sweepAngle;

  /// in case we have a double picker and we want to move the whole selection by clicking in the picker
  /// this will capture the position in the selection relative to the initial handler
  /// that way we will be able to keep the selection constant when moving
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
    );
  }

  void _calculatePaintData() {
    var initPercent = valueToPercentage(
        widget.init,
        widget.pickerDecoration.clockNumberDecoration?.clockTimeFormat
                .division ??
            ClockTimeFormat.twentyFourHours.division);
    var endPercent = valueToPercentage(
        widget.end,
        widget.pickerDecoration.clockNumberDecoration?.clockTimeFormat
                .division ??
            ClockTimeFormat.twentyFourHours.division);
    var sweep = getSweepAngle(initPercent, endPercent);

    _startAngle = percentageToRadians(initPercent);
    _endAngle = percentageToRadians(endPercent);
    _sweepAngle = percentageToRadians(sweep.abs());

    _painter = PickerPainter(
        startAngle: _startAngle,
        endAngle: _endAngle,
        sweepAngle: _sweepAngle,
        pickerDecorator: widget.pickerDecoration);
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
    var newValue = percentageToValue(
        percentage,
        widget.pickerDecoration.clockNumberDecoration?.clockTimeFormat
                .division ??
            ClockTimeFormat.twentyFourHours.division);

    if (isBothHandlersSelected) {
      var newValueInit = (newValue - _differenceFromInitPoint) %
          (widget.pickerDecoration.clockNumberDecoration?.clockTimeFormat
                  .division ??
              ClockTimeFormat.twentyFourHours.division);
      if (newValueInit != widget.init) {
        var newValueEnd = (widget.end + (newValueInit - widget.init)) %
            (widget.pickerDecoration.clockNumberDecoration?.clockTimeFormat
                    .division ??
                ClockTimeFormat.twentyFourHours.division);

        widget.onSelectionChange(newValueInit, newValueEnd);
        if (isPanEnd) {
          widget.onSelectionEnd(newValueInit, newValueEnd);
        }
      }
      return;
    }

    /// isDoubleHandler but one handler was selected
    if (_isInitHandlerSelected) {
      widget.onSelectionChange(newValue, widget.end);
      if (isPanEnd) {
        widget.onSelectionEnd(newValue, widget.end);
      }
    } else {
      widget.onSelectionChange(widget.init, newValue);
      if (isPanEnd) {
        widget.onSelectionEnd(widget.init, newValue);
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

      if (isNoHandlersSelected) {
        /// we check if the user pressed in the selection in a double handler picker
        /// that means the user wants to move the selection as a whole
        if (isPointAlongCircle(position, _painter.center, _painter.radius)) {
          var angle = coordinatesToRadians(_painter.center, position);
          if (isAngleInsideRadiansSelection(angle, _startAngle, _sweepAngle)) {
            _isEndHandlerSelected = true;
            _isInitHandlerSelected = true;
            var positionPercentage = radiansToPercentage(angle);

            /// no need to account for negative values, that will be sorted out in the onPanUpdate
            _differenceFromInitPoint = percentageToValue(
                    positionPercentage,
                    (widget.pickerDecoration.clockNumberDecoration
                            ?.clockTimeFormat.division ??
                        ClockTimeFormat.twentyFourHours.division)) -
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
