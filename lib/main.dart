import 'dart:async';
import 'package:flutter/material.dart';
import 'package:share/share.dart';

void main() => runApp(App());

const black = Colors.black87;

class App extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Page(),
      theme: ThemeData(
        fontFamily: 'Abel',
        primaryColor: Colors.white,
        primaryColorDark: Colors.white,
        accentColor: black,
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
  int _availSec = 10; //8 * 60 * 60;
  int _sec = 0;
  int _min = 0;
  double _limit = 0.6;
  double _opa = 0.0;
  double _tickOpa = 1.0;
  var _dur = Duration(milliseconds: 500);
  Stopwatch _timer = Stopwatch();
  Color _color = black;
  TextStyle _tts = TextStyle(
    fontSize: 38.0,
    color: black,
  );
  TextStyle _cts = TextStyle(
    fontSize: 16.0,
    color: black,
  );

  void updateTime(Timer timer) {
    setState(() {
      if (_timer.isRunning) {
        _sec = _timer.elapsed.inSeconds;
        _min = _timer.elapsed.inMinutes;
        _tickOpa = 1.0 - _tickOpa;
        _height = (_sec / _availSec) * MediaQuery.of(context).size.height;

        if ((_sec / _availSec) >= _limit) {
          _timer.stop();
        }
      } else {
        _height = MediaQuery.of(context).size.height;
        _opa = 1.0;
        _color = Colors.redAccent;
        timer.cancel();
      }
    });
  }

  void resetTimer() {
    setState(() {
      _sec = 0;
      _min = 0;
      _height = 0.0;
      _opa = 0.0;
      _color = black;
      _timer.reset();
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
              curve: Curves.easeIn,
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
                        opacity: _tickOpa,
                        duration: _dur,
                        curve: Curves.easeInOut,
                      ),
                      AnimatedOpacity(
                        child: Text(
                          "TOCK",
                          style: _tts,
                        ),
                        opacity: 1.0 - _tickOpa,
                        duration: _dur,
                        curve: Curves.easeInOut,
                      ),
                    ],
                  ),
                ),
                Text(
                  "${_min.toString().padLeft(2, "0")} minutes ${(_sec - (_min * 60)).toString().padLeft(2, "0")} seconds",
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
                  Text("Death by meeting", style: _tts),
                  Text(
                    "Try again tomorrow, good luck!",
                    style: _cts,
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: RaisedButton(
                      child: Text("Share"),
                      onPressed: () {
                        Share.share(
                            "I wasted my time in meetings again today.");
                      },
                    ),
                  )
                ],
              ),
              opacity: _opa,
              duration: _dur,
              curve: Curves.elasticInOut,
            ),
          ),
          Positioned(
            top: MediaQuery.of(context).size.height * (1 - _limit),
            height: 30.0 * (1 - _opa),
            width: MediaQuery.of(context).size.width,
            child: Column(
              children: [
                Divider(
                  height: 2.0,
                  color: black,
                ),
                Text(
                    "Don't spend more than 6 out of 8 hours a day in meetings."),
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
          child: _timer.isRunning
              ? Icon(Icons.stop)
              : _opa == 1.0 ? Text("Reset") : Icon(Icons.play_arrow),
          onPressed: () {
            setState(() {
              if (_timer.isRunning) {
                _timer.stop();
              } else {
                if (_opa == 1.0) {
                  resetTimer();
                } else {
                  _timer.start();
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
