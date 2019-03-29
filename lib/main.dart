import 'dart:async';
import 'package:death_by_meeting/share_widget.dart';
import 'package:flutter/material.dart';
import 'package:auto_size_text/auto_size_text.dart';

enum TimerState { init, play, pause, reset, end }

void main() => runApp(App());

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

class _PageState extends State<Page> {
  TimerState _state = TimerState.init;

  double _height = 0;
  int _limit = 1200;
  int _elapsedSec = 0;
  double _opacity = 0;
  double _tickOpacity = 1;
  Duration _duration = Duration(milliseconds: 350);
  Stopwatch _watch = Stopwatch();
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

  bool hasStarted = false;

  String _actionLabel = "Go";

  void update(Timer t) {
    if (_state == TimerState.play) {
      setState(() {
        _elapsedSec = _watch.elapsed.inSeconds;
        _tickOpacity = 1 - _tickOpacity;

        Curve curve = Curves.easeOutQuart;

        _height = curve.transform(_elapsedSec / _limit) *
            MediaQuery.of(context).size.height *
            0.6;

        _height = _height < 0 ? 0 : _height;

        if (_elapsedSec == _limit) {
          _watch.stop();
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

  void start() {
    setState(() {
      _watch.start();
      Timer.periodic(Duration(milliseconds: 950), update);
      hasStarted = true;
      _state = TimerState.play;
      _actionLabel = "Pause";
    });
  }

  void pause() {
    setState(() {
      _watch.stop();
      _actionLabel = "Go";
      _state = TimerState.pause;
    });
  }

  void resume() {
    setState(() {
      _watch.start();
      _actionLabel = "Pause";
      _state = TimerState.play;
      Timer.periodic(Duration(milliseconds: 950), update);
    });
  }

  void end() {
    setState(() {
      _watch.stop();
      _actionLabel = "Reset";
      _state = TimerState.reset;
      hasStarted = false;
    });
  }

  void reset() {
    setState(() {
      _elapsedSec = 0;
      _height = _opacity = 0;
      _color = black;
      _watch.reset();
      hasStarted = false;
      _state = TimerState.init;
      _actionLabel = "Go";
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
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Column(
                                children: [
                                  Text("Limit", textAlign: TextAlign.center),
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
                  Text("Time left:"),
                  Text(
                    "${((_limit - _elapsedSec) / 60).floor().toString().padLeft(2, "0")} min. ${((_limit - _elapsedSec) % 60).toString().padLeft(2, "0")} sec.",
                    style: _captionStyle,
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
                                break;
                              case TimerState.play:
                                pause();
                                break;
                              case TimerState.pause:
                                resume();
                                break;
                              case TimerState.end:
                                end();
                                break;
                              case TimerState.reset:
                                reset();
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
}
