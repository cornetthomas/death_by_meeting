import 'dart:async';
import 'package:flutter/material.dart';

enum TimerState { init, play, pause, reset, end }

void main() => runApp(App());

const black = Colors.black87;
const curve = Curves.easeInOut;

class App extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
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

  double _h = 0;
  int _limit = 120;
  int _sec = 0;
  double _op = 0;
  double _tick = 1;
  var _d = Duration(milliseconds: 350);
  Stopwatch _watch = Stopwatch();
  Color _c = black;
  TextStyle _ts = TextStyle(
    fontSize: 38,
    color: black,
  );
  TextStyle _cs = TextStyle(
    fontSize: 16,
    color: black,
  );

  bool hasStarted = false;

  String _actionLabel = "Go";

  void update(Timer t) {
    print("update");
    if (_state == TimerState.play) {
      setState(() {
        _sec = _watch.elapsed.inSeconds;
        _tick = 1 - _tick;

        Curve curve = Curves.easeOutQuart;

        _h = curve.transform(_sec / _limit) *
            MediaQuery.of(context).size.height *
            0.6;

        if (_sec == _limit) {
          _watch.stop();
          _h = MediaQuery.of(context).size.height;
          _op = _tick = 1;
          _c = Colors.redAccent;
          t.cancel();
        }
      });
    }

    if (_state == TimerState.reset) {
      t.cancel();
    }
  }

  void start() {
    print("Start");
    setState(() {
      _watch.start();
      Timer.periodic(Duration(milliseconds: 950), update);
      hasStarted = true;
      _state = TimerState.play;
      _actionLabel = "Pause";
    });
  }

  void pause() {
    print("Pause");
    setState(() {
      _watch.stop();
      _actionLabel = "Go";
      _state = TimerState.pause;
    });
  }

  void resume() {
    print("Resume");
    setState(() {
      _watch.start();
      _actionLabel = "Pause";
      _state = TimerState.play;
    });
  }

  void end() {
    print("End");
    setState(() {
      _watch.stop();
      _actionLabel = "Reset";
      _state = TimerState.reset;
    });
  }

  void reset() {
    print("Reset");
    setState(() {
      _sec = 0;
      _h = _op = 0;
      _c = black;
      _watch.reset();
      hasStarted = false;
      _state = TimerState.reset;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          !hasStarted
              ? Positioned(
                  top: MediaQuery.of(context).size.height * 0.7,
                  height: 250 * (1 - _op),
                  width: MediaQuery.of(context).size.width,
                  child: Center(
                    child: Padding(
                      padding: EdgeInsets.all(8),
                      child: Column(
                        children: [
                          Text(
                            "Reclaim your workday!",
                            style: _ts,
                          ),
                          Row(
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
                                      _limit =
                                          _limit - 30 < 0 ? 0 : _limit - 30;
                                    });
                                  },
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Text(
                                  "${(_limit / 60).floor().toString()} min. limit",
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
                                      _limit =
                                          _limit + 30 > 300 ? 300 : _limit + 30;
                                    });
                                  },
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                )
              : Container(),
          Positioned(
            top: MediaQuery.of(context).size.height * (1 - 0.6),
            height: 2 * (1 - _op),
            width: MediaQuery.of(context).size.width,
            child: Divider(
              height: 2,
              color: black,
            ),
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: AnimatedContainer(
              duration: Duration(milliseconds: 700),
              curve: Curves.easeOutBack,
              color: _c,
              height: _h,
            ),
          ),
          hasStarted
              ? Padding(
                  padding: EdgeInsets.all(60),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Padding(
                        padding: EdgeInsets.all(24),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
                            AnimatedOpacity(
                              child: Text(
                                "TICK",
                                style: _ts,
                              ),
                              opacity: _tick - _op,
                              duration: _d,
                              curve: curve,
                            ),
                            AnimatedOpacity(
                              child: Text(
                                "TOCK",
                                style: _ts,
                              ),
                              opacity: 1.0 - _tick,
                              duration: _d,
                              curve: curve,
                            ),
                          ],
                        ),
                      ),
                      Text("Time left:"),
                      Text(
                        "${((_limit - _sec) / 60).floor().toString().padLeft(2, "0")} min. ${((_limit - _sec) % 60).toString().padLeft(2, "0")} sec.",
                        style: _cs,
                      ),
                    ],
                  ),
                )
              : Container(),
          Align(
            alignment: Alignment.center,
            child: AnimatedOpacity(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text("WASTED", style: _ts),
                  Text(
                    "Try again!",
                    style: _cs,
                  ),
                ],
              ),
              opacity: _op,
              duration: _d,
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
              Padding(
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
