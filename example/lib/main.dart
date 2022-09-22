import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:progressive_time_picker/progressive_time_picker.dart';
import 'package:intl/intl.dart' as intl;

void main() {
  /// To set fixed device orientation
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]).then(
    (value) => runApp(MyApp()),
  );
  SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.light);
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: MyHomePage(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key? key}) : super(key: key);

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  ClockTimeFormat _clockTimeFormat = ClockTimeFormat.TWENTYFOURHOURS;
  ClockIncrementTimeFormat _clockIncrementTimeFormat =
      ClockIncrementTimeFormat.FIVEMIN;

  PickedTime _inBedTime = PickedTime(h: 0, m: 0);
  PickedTime _outBedTime = PickedTime(h: 8, m: 0);
  PickedTime _intervalBedTime = PickedTime(h: 0, m: 0);

  PickedTime _disabledInitTime = PickedTime(h: 12, m: 0);
  PickedTime _disabledEndTime = PickedTime(h: 20, m: 0);

  double _sleepGoal = 8.0;
  bool _isSleepGoal = false;

  bool? validRange = true;

  @override
  void initState() {
    super.initState();
    _isSleepGoal = (_sleepGoal >= 8.0) ? true : false;
    _intervalBedTime = formatIntervalTime(
      init: _inBedTime,
      end: _outBedTime,
      clockTimeFormat: _clockTimeFormat,
      clockIncrementTimeFormat: _clockIncrementTimeFormat,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFF141925),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          Text(
            'Sleep Time',
            style: TextStyle(
              color: Color(0xFF3CDAF7),
              fontSize: 30,
              fontWeight: FontWeight.bold,
            ),
          ),
          TimePicker(
            initTime: _inBedTime,
            endTime: _outBedTime,
            disabledRange: DisabledRange(
              initTime: _disabledInitTime,
              endTime: _disabledEndTime,
              disabledRangeColor: Colors.grey,
              errorColor: Colors.red,
            ),
            height: 260.0,
            width: 260.0,
            onSelectionChange: _updateLabels,
            onSelectionEnd: (start, end, valid) => print(
                'onSelectionEnd => init : ${start.h}:${start.m}, end : ${end.h}:${end.m}, valid: $valid'),
            primarySectors: _clockTimeFormat.value,
            secondarySectors: _clockTimeFormat.value * 2,
            decoration: TimePickerDecoration(
              baseColor: Color(0xFF1F2633),
              pickerBaseCirclePadding: 15.0,
              sweepDecoration: TimePickerSweepDecoration(
                pickerStrokeWidth: 30.0,
                pickerColor: _isSleepGoal ? Color(0xFF3CDAF7) : Colors.white,
                showConnector: true,
              ),
              initHandlerDecoration: TimePickerHandlerDecoration(
                color: Color(0xFF141925),
                shape: BoxShape.circle,
                radius: 12.0,
                icon: Icon(
                  Icons.power_settings_new_outlined,
                  size: 20.0,
                  color: Color(0xFF3CDAF7),
                ),
              ),
              endHandlerDecoration: TimePickerHandlerDecoration(
                color: Color(0xFF141925),
                shape: BoxShape.circle,
                radius: 12.0,
                icon: Icon(
                  Icons.notifications_active_outlined,
                  size: 20.0,
                  color: Color(0xFF3CDAF7),
                ),
              ),
              primarySectorsDecoration: TimePickerSectorDecoration(
                color: Colors.white,
                width: 1.0,
                size: 4.0,
                radiusPadding: 25.0,
              ),
              secondarySectorsDecoration: TimePickerSectorDecoration(
                color: Color(0xFF3CDAF7),
                width: 1.0,
                size: 2.0,
                radiusPadding: 25.0,
              ),
              clockNumberDecoration: TimePickerClockNumberDecoration(
                defaultTextColor: Colors.white,
                defaultFontSize: 12.0,
                scaleFactor: 2.0,
                showNumberIndicators: true,
                clockTimeFormat: _clockTimeFormat,
                clockIncrementTimeFormat: _clockIncrementTimeFormat,
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.all(62.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    '${intl.NumberFormat('00').format(_intervalBedTime.h)}Hr ${intl.NumberFormat('00').format(_intervalBedTime.m)}Min',
                    style: TextStyle(
                      fontSize: 14.0,
                      color: _isSleepGoal ? Color(0xFF3CDAF7) : Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ),
          Container(
            width: 300.0,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: Color(0xFF1F2633),
              borderRadius: BorderRadius.circular(25.0),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                _isSleepGoal
                    ? "Above Sleep Goal (>=8) 😇"
                    : 'below Sleep Goal (<=8) 😴',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _timeWidget(
                'BedTime',
                _inBedTime,
                Icon(
                  Icons.power_settings_new_outlined,
                  size: 25.0,
                  color: Color(0xFF3CDAF7),
                ),
              ),
              _timeWidget(
                'WakeUp',
                _outBedTime,
                Icon(
                  Icons.notifications_active_outlined,
                  size: 25.0,
                  color: Color(0xFF3CDAF7),
                ),
              ),
            ],
          ),
          SizedBox(
            height: 18,
            child: Text(
              validRange == true
                  ? "Working hours ${intl.NumberFormat('00').format(_disabledInitTime.h)}:${intl.NumberFormat('00').format(_disabledInitTime.m)} to ${intl.NumberFormat('00').format(_disabledEndTime.h)}:${intl.NumberFormat('00').format(_disabledEndTime.m)}"
                  : "Please schedule according time working time!",
              style: TextStyle(
                fontSize: 16.0,
                color: validRange == true ? Colors.white : Colors.red,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _timeWidget(String title, PickedTime time, Icon icon) {
    return Container(
      width: 150.0,
      decoration: BoxDecoration(
        color: Color(0xFF1F2633),
        borderRadius: BorderRadius.circular(25.0),
      ),
      child: Padding(
        padding: const EdgeInsets.all(25.0),
        child: Column(
          children: [
            Text(
              '${intl.NumberFormat('00').format(time.h)}:${intl.NumberFormat('00').format(time.m)}',
              style: TextStyle(
                color: Color(0xFF3CDAF7),
                fontSize: 25,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 15),
            Text(
              '$title',
              style: TextStyle(
                color: Color(0xFF3CDAF7),
                fontSize: 16,
              ),
            ),
            SizedBox(height: 10),
            icon,
          ],
        ),
      ),
    );
  }

  void _updateLabels(PickedTime init, PickedTime end, bool? valid) {
    _inBedTime = init;
    _outBedTime = end;
    _intervalBedTime = formatIntervalTime(
      init: _inBedTime,
      end: _outBedTime,
      clockTimeFormat: _clockTimeFormat,
      clockIncrementTimeFormat: _clockIncrementTimeFormat,
    );
    _isSleepGoal = validateSleepGoal(
      inTime: init,
      outTime: end,
      sleepGoal: _sleepGoal,
      clockTimeFormat: _clockTimeFormat,
      clockIncrementTimeFormat: _clockIncrementTimeFormat,
    );
    setState(() {
      validRange = valid;
    });
  }
}
