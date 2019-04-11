import 'dart:async';
import 'package:death_by_meeting/share_widget.dart';
import 'package:flutter/material.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';
import 'package:flutter/services.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:url_launcher/url_launcher.dart';

enum TimerState { init, play, pause, reset, end }

void main() {
  SystemChrome.setPreferredOrientations(
      [DeviceOrientation.portraitUp, DeviceOrientation.portraitDown]).then((_) {
    runApp(App());
  });
}

const black = Colors.black87;
const curve = Curves.easeInOut;

const kTimerMaxSeconds = 60 * 60 * 8;
const kTimerMinSeconds = 60 * 30;
const kTimerIncrement = 60 * 15;

class App extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Page(),
      theme: ThemeData(
        fontFamily: 'Abel',
      ),
    );
  }
}

class Page extends StatefulWidget {
  @override
  _PageState createState() => _PageState();
}

class _PageState extends State<Page> with WidgetsBindingObserver {
  TimerState _state = TimerState.init;

  FirebaseAnalytics _firebaseAnalytics;

  double _height = 0;
  int _limit = 7200;
  int _elapsedSec = 0;
  int _sessionOffsetSeconds = 0;
  double _opacity = 0;
  double _tickOpacity = 1;
  Duration _duration = Duration(milliseconds: 350);

  Color _color = black;
  TextStyle _titleStyle = TextStyle(
    fontSize: 38,
    color: black,
  );
  TextStyle _tickerStyle = TextStyle(
    fontSize: 45,
    color: black,
  );
  TextStyle _subtitleStyle = TextStyle(
    fontSize: 20,
    color: black,
  );
  TextStyle _captionStyle = TextStyle(
    fontSize: 16,
    color: black,
  );

  TextStyle _smallStyle = TextStyle(
    fontSize: 12,
    color: black,
  );

  bool hasStarted = false;

  String _actionLabel = "Go";

  DateTime _startTime;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);

    _firebaseAnalytics = FirebaseAnalytics();

    _firebaseAnalytics.setCurrentScreen(screenName: "main");

    _restoreState();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);

    if (state == AppLifecycleState.inactive) {
      _saveElapsedSeconds(_elapsedSec);
      _saveLimit(_limit);
      _saveTimerState(_state);
    }
  }

  void _restoreState() async {
    _loadElapsedSeconds().then((elapsedSeconds) {
      _elapsedSec = elapsedSeconds == null ? 0 : elapsedSeconds;
    });

    _loadLimit().then((limit) {
      _limit = limit == null ? _limit : limit;
    });

    _loadTimerStartState().then((startEpoch) {
      _startTime =
          startEpoch == null ? DateTime.now() : epochToDate(startEpoch);

      _loadTimerState().then((state) {
        setState(() {
          switch (state) {
            case "TimerState.init":
              _state = TimerState.init;
              break;
            case "TimerState.play":
              _state = TimerState.play;
              startWith(_startTime);
              break;
            case "TimerState.pause":
              _state = TimerState.pause;
              startWith(_startTime);
              pause();
              break;
            case "TimerState.reset":
              _state = TimerState.reset;
              reset();
              break;
            case "TimerState.end":
              _state = TimerState.end;
              end();
              break;
            default:
              _state = TimerState.init;
              break;
          }
        });
      });
    });
  }

  void _saveTimerStartState(int start) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    await prefs.setInt('start', start);
  }

  void _saveElapsedSeconds(int elapsedSeconds) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    await prefs.setInt('elapsedSeconds', elapsedSeconds);
  }

  void _saveLimit(int limit) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    await prefs.setInt('limit', limit);
  }

  void _saveTimerState(TimerState state) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    await prefs.setString('timerState', state.toString());
  }

  Future<int> _loadElapsedSeconds() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    int elapsedSeconds = prefs.getInt("elapsedSeconds");

    return elapsedSeconds;
  }

  Future<int> _loadLimit() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    int limit = prefs.getInt("limit");

    return limit;
  }

  Future<String> _loadTimerState() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String state = prefs.getString("timerState");

    return state;
  }

  Future<int> _loadTimerStartState() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    int start = prefs.getInt("start");

    return start;
  }

  String epochToFormat(int epoch) {
    DateTime _datetime =
        DateTime.fromMillisecondsSinceEpoch(epoch, isUtc: true);
    var formatter = DateFormat('dd-MM-yyyy HH:mm:ss');
    return formatter.format(_datetime);
  }

  DateTime epochToDate(int epoch) {
    return DateTime.fromMillisecondsSinceEpoch(epoch, isUtc: true);
  }

  void update(Timer t) {
    if (_state == TimerState.play) {
      setState(() {
        _elapsedSec = DateTime.now().difference(_startTime).inSeconds +
            _sessionOffsetSeconds;

        _tickOpacity = 1 - _tickOpacity;

        Curve curve = Curves.easeOutQuart;

        double _heightRate = _elapsedSec / _limit;

        _height = curve.transform(
                _heightRate < 0 ? 0 : _heightRate > 1 ? 1 : _heightRate) *
            MediaQuery.of(context).size.height *
            0.6;

        _height = _height < 0 ? 0 : _height;

        if (_elapsedSec >= _limit) {
          _height = MediaQuery.of(context).size.height;
          _opacity = _tickOpacity = 1;
          _color = Colors.redAccent;
          end();
          t.cancel();
        }
      });
    } else {
      t.cancel();
    }
  }

  void startWith(DateTime startTime) {
    setState(() {
      _startTime = startTime;

      _saveLimit(_limit);
      _saveTimerState(_state);
      _saveTimerStartState(_startTime.millisecondsSinceEpoch);

      Timer.periodic(Duration(milliseconds: 1000), update);
      hasStarted = true;
      _state = TimerState.play;
      _actionLabel = "Pause";
    });
  }

  void start() {
    startWith(DateTime.now());
  }

  void pause() {
    setState(() {
      _actionLabel = "Go";
      _state = TimerState.pause;
      _saveElapsedSeconds(_elapsedSec);
    });
  }

  void resume() {
    setState(() {
      _startTime = DateTime.now();
      _actionLabel = "Pause";
      _state = TimerState.play;
      Timer.periodic(Duration(milliseconds: 1000), update);
      _sessionOffsetSeconds = _elapsedSec;
    });
  }

  void end() {
    setState(() {
      _actionLabel = "Reset";
      _state = TimerState.reset;
      hasStarted = false;
    });
    _firebaseAnalytics.logEvent(name: "end");
  }

  void reset() {
    setState(() {
      _elapsedSec = 0;
      _height = _opacity = 0;
      _color = black;
      hasStarted = false;
      _state = TimerState.init;
      _actionLabel = "Go";
      _saveTimerStartState(0);
      _saveElapsedSeconds(0);
      _saveTimerState(TimerState.init);
      _saveLimit(7200);
    });
  }

  @override
  Widget build(BuildContext context) {
    int _hours = (_limit / 3600).floor();
    int _minutes = ((_limit % 3600) / 60).floor();

    String _hourString =
        _hours == 0 ? "" : _hours == 1 ? " $_hours hour" : " $_hours hours";
    String _minutesString = _minutes == 0
        ? ""
        : _minutes == 1 ? " $_minutes minute" : " $_minutes minutes";

    return Scaffold(
      body: Stack(
        children: [
          Positioned(
            child: FlatButton(
              child: Text(
                "Privacy Policy",
                style: _smallStyle,
              ),
              onPressed: _launchURL,
            ),
            bottom: 40.0,
            left: MediaQuery.of(context).size.width / 2 - 100,
            height: 20.0,
            width: 200.0,
          ),
          AnimatedPositioned(
            duration: _duration,
            curve: curve,
            bottom: !hasStarted ? 100 : -100,
            left: 5,
            right: 5,
            child: AnimatedOpacity(
              duration: Duration(milliseconds: 500),
              curve: curve,
              opacity: hasStarted ? 0 : 1,
              child: Center(
                child: Padding(
                  padding: EdgeInsets.all(8),
                  child: Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text(
                          "Reclaim your workday!",
                          style: _titleStyle,
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text(
                          "Meetings are toxic. Don't spend too much time in meetings. It kills your productivity and creativity. Set your limit but don't overdo it or you will perish.",
                          textAlign: TextAlign.center,
                          style: _subtitleStyle,
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              height: 45,
                              child: FloatingActionButton(
                                foregroundColor: Colors.white,
                                backgroundColor: black,
                                child: Text("Less"),
                                onPressed: () {
                                  setState(() {
                                    _limit = _limit - kTimerIncrement <
                                            kTimerMinSeconds
                                        ? kTimerMinSeconds
                                        : _limit - kTimerIncrement;
                                  });
                                },
                              ),
                            ),
                            Container(
                              width: 150.0,
                              padding: const EdgeInsets.all(8.0),
                              child: Column(
                                children: [
                                  Text(
                                    "Limit",
                                    textAlign: TextAlign.center,
                                    style: _subtitleStyle,
                                  ),
                                  Text(
                                    "$_hourString$_minutesString",
                                  ),
                                ],
                              ),
                            ),
                            Container(
                              height: 45,
                              child: FloatingActionButton(
                                foregroundColor: Colors.white,
                                backgroundColor: black,
                                child: Text("More"),
                                onPressed: () {
                                  setState(() {
                                    _limit = _limit + kTimerIncrement >
                                            kTimerMaxSeconds
                                        ? kTimerMaxSeconds
                                        : _limit + kTimerIncrement;
                                  });
                                },
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          hasStarted
              ? Positioned(
                  top: MediaQuery.of(context).size.height * (1 - 0.6),
                  height: 2 * (1 - _opacity),
                  width: MediaQuery.of(context).size.width,
                  child: Divider(
                    height: 2,
                    color: black,
                  ),
                )
              : Container(),
          Align(
            alignment: Alignment.bottomCenter,
            child: AnimatedContainer(
              duration: Duration(milliseconds: 500),
              curve: Curves.easeOut,
              color: _color,
              height: _height,
            ),
          ),
          AnimatedOpacity(
            duration: Duration(milliseconds: 500),
            curve: curve,
            opacity: hasStarted ? 1.0 : 0.0,
            child: Padding(
              padding: EdgeInsets.all(60),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 0, vertical: 24),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        AnimatedOpacity(
                          child: AutoSizeText(
                            "TICK",
                            style: _tickerStyle,
                          ),
                          opacity: _tickOpacity - _opacity,
                          duration: _duration,
                          curve: curve,
                        ),
                        AnimatedOpacity(
                          child: AutoSizeText(
                            "TOCK",
                            style: _tickerStyle,
                          ),
                          opacity: 1.0 - _tickOpacity,
                          duration: _duration,
                          curve: curve,
                        ),
                      ],
                    ),
                  ),
                  Text(
                    "Time left:",
                    style: _subtitleStyle,
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(
                      "${((_limit - _elapsedSec) / 3600).floor().toString()} hours.  ${(((_limit - _elapsedSec) % 3600) / 60).floor().toString().padLeft(2, "0")} min. ${((_limit - _elapsedSec) % 60).toString().padLeft(2, "0")} sec.",
                      style: _captionStyle,
                    ),
                  ),
                ],
              ),
            ),
          ),
          Align(
            alignment: Alignment.center,
            child: AnimatedOpacity(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text("WASTED", style: _titleStyle),
                  ShareWidget(_elapsedSec),
                ],
              ),
              opacity: _opacity,
              duration: _duration,
              curve: curve,
            ),
          ),
        ],
      ),
      floatingActionButton: Padding(
        padding: EdgeInsets.all(8),
        child: Column(
            mainAxisAlignment: MainAxisAlignment.end,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: <Widget>[
              hasStarted
                  ? Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: FloatingActionButton(
                        foregroundColor: black,
                        backgroundColor: Colors.white,
                        child: Text("Reset"),
                        onPressed: () {
                          reset();
                        },
                      ),
                    )
                  : Container(),
              _state == TimerState.end
                  ? Container()
                  : Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: FloatingActionButton(
                        foregroundColor: black,
                        backgroundColor: Colors.white,
                        child: Text(_actionLabel),
                        onPressed: () {
                          setState(() {
                            switch (_state) {
                              case TimerState.init:
                                start();
                                _firebaseAnalytics.logEvent(
                                    name: "start",
                                    parameters: {"limit": _limit});
                                break;
                              case TimerState.play:
                                pause();
                                _firebaseAnalytics.logEvent(
                                    name: "pause",
                                    parameters: {"limit": _limit});
                                break;
                              case TimerState.pause:
                                resume();
                                _firebaseAnalytics.logEvent(
                                    name: "resume",
                                    parameters: {"limit": _limit});
                                break;
                              case TimerState.end:
                                _firebaseAnalytics.logEvent(
                                    name: "end", parameters: {"limit": _limit});
                                end();
                                break;
                              case TimerState.reset:
                                reset();
                                _firebaseAnalytics.logEvent(
                                    name: "reset",
                                    parameters: {"limit": _limit});
                                break;
                            }
                          });
                        },
                      ),
                    ),
            ]),
      ),
    );
  }

  _launchURL() async {
    const url = 'https://deathbymeeting.thismightwork.co/#privacy';
    print(url);
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not launch $url';
    }
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();

    _saveElapsedSeconds(_elapsedSec);
    _saveLimit(_limit);
    _saveTimerState(_state);
  }
}
