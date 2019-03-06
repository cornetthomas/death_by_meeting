import 'dart:async';
import 'package:flutter/material.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: MyHomePage(),
      theme: ThemeData(
        fontFamily: 'Abel',
        primaryColor: Colors.white,
        primaryColorDark: Colors.white,
        accentColor: Colors.black87,
        textTheme: Theme.of(context).textTheme.copyWith(
            title: new TextStyle(
              fontSize: 28.0,
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

class MyHomePage extends StatefulWidget {
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> with TickerProviderStateMixin {
  double _height = 0.0;
  AnimationController _controller;
  Animation<double> _animation;
  int _availableSeconds = 10; //8 * 60 * 60;
  int _elapsedSeconds = 0;
  int _elapsedMinutes = 0;
  double _treshold = 0.6;
  double _opacity = 0.0;
  double _tickOpacity = 1.0;
  CrossFadeState _fadeState = CrossFadeState.showFirst;
  Stopwatch _timer;
  Color _color = Colors.black87;

  void initState() {
    super.initState();
    _controller =
        AnimationController(vsync: this, duration: Duration(milliseconds: 300));

    _timer = Stopwatch();
  }

  void updateAnimation() {
    double _newHeight = (_elapsedSeconds / _availableSeconds) *
        MediaQuery.of(context).size.height;

    print(" ${_height} +  ${_newHeight}");

    _animation = Tween(begin: 0, end: _newHeight)
        .animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));

    _animation.addListener(() {
      print(_animation.value);
    });

    _animation.addStatusListener((status) {
      print(status);
    });

    _controller.reset();

    _height = _newHeight;
  }

  void updateTime(Timer timer) {
    if (_timer.isRunning) {
      _elapsedSeconds = _timer.elapsed.inSeconds;
      _elapsedMinutes = _timer.elapsed.inMinutes;

      _tickOpacity =
          _tickOpacity == 0.0 ? _tickOpacity = 1.0 : _tickOpacity = 0.0;

      _fadeState = _fadeState == CrossFadeState.showFirst
          ? CrossFadeState.showSecond
          : CrossFadeState.showFirst;

      //_controller.forward();
      print("play");

      updateAnimation();

      double _currentPerc = (_elapsedSeconds / _availableSeconds);

      if (_currentPerc >= _treshold) {
        timer.cancel();
        _opacity = 1.0;
        _color = Colors.redAccent;
      }
    } else {
      timer.cancel();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          AnimatedBuilder(
              animation: _controller,
              builder: (BuildContext context, Widget child) {
                print('Buikd');
                return Align(
                  alignment: Alignment.bottomCenter,
                  child: Container(
                    color: _color,
                    height: _animation == null ? 0.0 : _animation.value,
                  ),
                );
              }),
          Align(
            alignment: Alignment.center,
            child: Padding(
              padding: const EdgeInsets.all(60.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  AnimatedOpacity(
                    child: Text(
                      "Death by meeting",
                      style: Theme.of(context).textTheme.title,
                    ),
                    opacity: _opacity,
                    duration: Duration(milliseconds: 500),
                    curve: Curves.elasticInOut,
                  ),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      AnimatedOpacity(
                        child: Text(
                          "TICK",
                          style: Theme.of(context).textTheme.title,
                        ),
                        opacity: _tickOpacity,
                        duration: Duration(milliseconds: 500),
                        curve: Curves.easeInOut,
                      ),
                      AnimatedOpacity(
                        child: Text(
                          "TOCK",
                          style: Theme.of(context).textTheme.title,
                        ),
                        opacity: 1.0 - _tickOpacity,
                        duration: Duration(milliseconds: 500),
                        curve: Curves.easeInOut,
                      ),
                    ],
                  ),
                  Text(
                    "${_elapsedMinutes.toString().padLeft(2, "0")} minutes ${(_elapsedSeconds - (_elapsedMinutes * 60)).toString().padLeft(2, "0")} seconds",
                    style: Theme.of(context).textTheme.caption,
                  ),
                ],
              ),
            ),
          ),
          Positioned(
            top: MediaQuery.of(context).size.height * (1 - _treshold),
            height: 2.0,
            width: MediaQuery.of(context).size.width,
            child: Divider(
              height: 2.0,
              color: Colors.black45,
            ),
          )
        ],
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: FloatingActionButton(
        foregroundColor: Colors.black87,
        backgroundColor: Colors.white70,
        child: _timer.isRunning ? Icon(Icons.stop) : Icon(Icons.play_arrow),
        onPressed: () {
          setState(() {
            if (_timer.isRunning) {
              _timer.stop();
              _controller.stop();
            } else {
              _timer.start();

              Timer.periodic(Duration(seconds: 1), updateTime);
            }
          });
        },
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}
