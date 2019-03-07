import 'dart:async';
import 'package:flutter/material.dart';
import 'package:share/share.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Page(),
      theme: ThemeData(
        fontFamily: 'Abel',
        primaryColor: Colors.white,
        primaryColorDark: Colors.white,
        accentColor: Colors.black87,
        textTheme: Theme.of(context).textTheme.copyWith(
            title: new TextStyle(
              fontSize: 38.0,
              color: Colors.black87,
            ),
            caption: new TextStyle(
              fontSize: 16.0,
              color: Colors.black87,
            )),
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

  Stopwatch _timer;
  Color _color = Colors.black87;

  void initState() {
    super.initState();

    _timer = Stopwatch();
  }

  void updateTime(Timer timer) {
    if (_timer.isRunning) {
      setState(() {
        _sec = _timer.elapsed.inSeconds;
        _min = _timer.elapsed.inMinutes;

        _tickOpa = _tickOpa == 0.0 ? _tickOpa = 1.0 : _tickOpa = 0.0;

        double _newHeight =
            (_sec / _availSec) * MediaQuery.of(context).size.height;

        _height = _newHeight;

        double _currentPerc = (_sec / _availSec);

        if (_currentPerc >= _limit) {
          _timer.stop();
        }
      });
    } else {
      setState(() {
        _height = MediaQuery.of(context).size.height;
        _opa = 1.0;
        _color = Colors.redAccent;
      });
      timer.cancel();
    }
  }

  void resetTimer() {
    setState(() {
      _sec = 0;
      _min = 0;
      _height = 0.0;
      _opa = 0.0;
      _color = Colors.black87;
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
              duration: Duration(milliseconds: 300),
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
                          style: Theme.of(context).textTheme.title,
                        ),
                        opacity: _tickOpa,
                        duration: Duration(milliseconds: 500),
                        curve: Curves.easeInOut,
                      ),
                      AnimatedOpacity(
                        child: Text(
                          "TOCK",
                          style: Theme.of(context).textTheme.title,
                        ),
                        opacity: 1.0 - _tickOpa,
                        duration: Duration(milliseconds: 500),
                        curve: Curves.easeInOut,
                      ),
                    ],
                  ),
                ),
                Text(
                  "${_min.toString().padLeft(2, "0")} minutes ${(_sec - (_min * 60)).toString().padLeft(2, "0")} seconds",
                  style: Theme.of(context).textTheme.caption,
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
                  Text(
                    "Death by meeting",
                    style: Theme.of(context).textTheme.title,
                  ),
                  Text(
                    "Try again tomorrow, good luck!",
                    style: Theme.of(context).textTheme.caption,
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
              duration: Duration(milliseconds: 500),
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
                  color: Colors.black87,
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
          foregroundColor: Colors.black87,
          backgroundColor: Colors.white70,
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
