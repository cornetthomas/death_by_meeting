import 'dart:async';
import 'package:flutter/material.dart';

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
  double _height = 0.0;
  int _limit = 5;
  int _sec = 0;
  double _opa = 0.0;
  double _tick = 1.0;
  var _dur = Duration(milliseconds: 400);
  Stopwatch _watch = Stopwatch();
  Color _color = black;
  TextStyle _tts = TextStyle(
    fontSize: 48.0,
    color: black,
  );
  TextStyle _cts = TextStyle(
    fontSize: 16.0,
    color: black,
  );

  void updateTime(Timer timer) {
    setState(() {
      if (_watch.isRunning) {
        _sec = _watch.elapsed.inSeconds;
        _tick = 1.0 - _tick;
        _height = (_sec / _limit) * MediaQuery.of(context).size.height * 0.7;
        if (_sec == _limit) {
          _watch.stop();
          _height = MediaQuery.of(context).size.height;
          _opa = _tick = 1.0;
          _color = Colors.redAccent;
          timer.cancel();
        }
      }
    });
  }

  void resetTimer() {
    setState(() {
      _sec = 0;
      _height = _opa = 0.0;
      _color = black;
      _watch.reset();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Align(
            alignment: Alignment.bottomCenter,
            child: AnimatedContainer(
              duration: _dur,
              curve: curve,
              color: _color,
              height: _height,
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(60.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      AnimatedOpacity(
                        child: Text(
                          "TICK",
                          style: _tts,
                        ),
                        opacity: _tick - _opa,
                        duration: _dur,
                        curve: curve,
                      ),
                      AnimatedOpacity(
                        child: Text(
                          "TOCK",
                          style: _tts,
                        ),
                        opacity: 1.0 - _tick,
                        duration: _dur,
                        curve: curve,
                      ),
                    ],
                  ),
                ),
                Text(
                  "${(_sec / 60).floor().toString().padLeft(2, "0")} minutes ${(_sec % 60).toString().padLeft(2, "0")} seconds",
                  style: _cts,
                ),
              ],
            ),
          ),
          Align(
            alignment: Alignment.center,
            child: AnimatedOpacity(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text("WASTED", style: _tts),
                  Text(
                    "Try again tomorrow!",
                    style: _cts,
                  ),
                ],
              ),
              opacity: _opa,
              duration: _dur,
              curve: curve,
            ),
          ),
          Positioned(
            top: MediaQuery.of(context).size.height * (1 - 0.7),
            height: 30.0 * (1 - _opa),
            width: MediaQuery.of(context).size.width,
            child: Column(
              children: [
                Divider(
                  height: 2.0,
                  color: black,
                ),
                Text("Get your workday back! Limit: 2 hours."),
              ],
            ),
          )
        ],
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: Padding(
        padding: const EdgeInsets.all(8.0),
        child: FloatingActionButton(
          foregroundColor: black,
          backgroundColor: Colors.white,
          child: _watch.isRunning
              ? Icon(Icons.pause)
              : _opa == 1.0 ? Text("Reset") : Icon(Icons.play_arrow),
          onPressed: () {
            setState(() {
              if (_watch.isRunning) {
                _watch.stop();
              } else {
                if (_opa == 1.0) {
                  resetTimer();
                } else {
                  _watch.start();
                  Timer.periodic(Duration(seconds: 1), updateTime);
                }
              }
            });
          },
        ),
      ),
    );
  }
}
