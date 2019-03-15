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
  double _h = 0;
  int _limit = 120;
  int _sec = 0;
  double _op = 0;
  double _tick = 1;
  var _dur = Duration(milliseconds: 350);
  Stopwatch _watch = Stopwatch();
  Color _c = black;
  TextStyle _tts = TextStyle(
    fontSize: 38,
    color: black,
  );
  TextStyle _cts = TextStyle(
    fontSize: 16,
    color: black,
  );

  void update(Timer t) {
    if (_watch.isRunning) {
      setState(() {
        _sec = _watch.elapsed.inSeconds;
        _tick = 1 - _tick;
        _h = (_sec / _limit) * MediaQuery.of(context).size.height * 0.6;
        if (_sec == _limit) {
          _watch.stop();
          _h = MediaQuery.of(context).size.height;
          _op = _tick = 1;
          _c = Colors.redAccent;
          t.cancel();
        }
      });
    } else {
      _tick = 1 - _tick;
      t.cancel();
    }
  }

  void reset() {
    setState(() {
      _sec = 0;
      _h = _op = 0;
      _c = black;
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
              color: _c,
              height: _h,
            ),
          ),
          Padding(
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
                          style: _tts,
                        ),
                        opacity: _tick - _op,
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
                  "${(_sec / 60).floor().toString().padLeft(2, "0")} min. ${(_sec % 60).toString().padLeft(2, "0")} sec.",
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
                    "Try again!",
                    style: _cts,
                  ),
                ],
              ),
              opacity: _op,
              duration: _dur,
              curve: curve,
            ),
          ),
          Positioned(
            top: MediaQuery.of(context).size.height * (1 - 0.6),
            height: 60 * (1 - _op),
            width: MediaQuery.of(context).size.width,
            child: Column(
              children: [
                Divider(
                  height: 2,
                  color: black,
                ),
                Padding(
                  padding: EdgeInsets.all(8),
                  child: Text(
                      "Reclaim your workday! ${(_limit / 60).floor().toString()} min. limit"),
                ),
              ],
            ),
          )
        ],
      ),
      floatingActionButton: Padding(
        padding: EdgeInsets.all(8),
        child: FloatingActionButton(
          foregroundColor: black,
          backgroundColor: Colors.white,
          child: _watch.isRunning
              ? Text("Pause")
              : _op == 1 ? Text("Reset") : Text("Go"),
          onPressed: () {
            setState(() {
              if (_watch.isRunning) {
                _watch.stop();
              } else {
                if (_op == 1) {
                  reset();
                } else {
                  _watch.start();
                  Timer.periodic(Duration(milliseconds: 950), update);
                }
              }
            });
          },
        ),
      ),
    );
  }
}
