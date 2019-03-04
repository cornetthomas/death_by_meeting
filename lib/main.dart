import 'dart:async';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  bool hasSeenIntro = false;

  @override
  Widget build(BuildContext context) {
    // getIntroState();

    return MaterialApp(
      home: hasSeenIntro ? MyHomePage() : IntroPage(),
    );
  }

  void getIntroState() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    if (prefs.getBool("HAS_SEEN_INTRO")) {
      prefs.setBool("HAS_SEEN_INTRO", true);
    }
  }
}

class IntroPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return PageView(
      children: <Widget>[
        Center(child: Text("Page1")),
        Center(child: Text("Page2")),
        Center(
          child: RaisedButton(
              onPressed: () async {
                SharedPreferences prefs = await SharedPreferences.getInstance();
                prefs.setBool("HAS_SEEN_INTRO", true);
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => MyHomePage()),
                );
              },
              child: Text("Ok")),
        ),
      ],
    );
  }
}

class MyHomePage extends StatefulWidget {
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage>
    with SingleTickerProviderStateMixin {
  double _height = 0.0;
  AnimationController _controller;
  Animation<double> _animation;
  int _availableSeconds = 8 * 60 * 60;
  int _elapsedSeconds = 0;
  int _elapsedMinutes = 0;
  double _treshold = 0.6;
  double _opacity = 0.0;
  CrossFadeState _fadeState = CrossFadeState.showFirst;
  Stopwatch _timer;

  void initState() {
    super.initState();
    _controller =
        AnimationController(vsync: this, duration: Duration(milliseconds: 500));

    _timer = Stopwatch();
  }

  void updateAnimation() {
    double _newHeight = (_elapsedSeconds / _availableSeconds) *
        MediaQuery.of(context).size.height;

    _animation = Tween(begin: _height, end: _newHeight)
        .animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
    _height = _newHeight;
  }

  void updateTime(Timer timer) {
    if (_timer.isRunning) {
      setState(() {
        _elapsedSeconds = _timer.elapsed.inSeconds;
        _elapsedMinutes = _timer.elapsed.inMinutes;

        _fadeState = _fadeState == CrossFadeState.showFirst
            ? CrossFadeState.showSecond
            : CrossFadeState.showFirst;

        updateAnimation();

        double _currentPerc = (_elapsedSeconds / _availableSeconds);

        print(_currentPerc);

        if (_currentPerc >= _treshold) {
          timer.cancel();
          _opacity = 1.0;
          print("Death by Meeting");
        }
      });
    } else {
      timer.cancel();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Align(
            alignment: Alignment.bottomCenter,
            child: ClipPath(
              clipper: BottomWaveClipper(animation: _animation),
              child: Container(
                color: Colors.black87,
                height: _animation == null ? 0.0 : _animation.value,
              ),
            ),
          ),
          Align(
            alignment: Alignment.center,
            child: Padding(
              padding: const EdgeInsets.all(60.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  AnimatedOpacity(
                    child: Text("Death by meeting"),
                    opacity: _opacity,
                    duration: Duration(milliseconds: 500),
                    curve: Curves.bounceIn,
                  ),
                  AnimatedCrossFade(
                    firstChild: Text("Tick"),
                    secondChild: Text('Tock'),
                    crossFadeState: _fadeState,
                    duration: Duration(milliseconds: 200),
                    firstCurve: Curves.easeInOut,
                    secondCurve: Curves.easeInOut,
                  ),
                  Text(
                    "${_elapsedMinutes.toString().padLeft(2, "0")}:${(_elapsedSeconds - (_elapsedMinutes * 60)).toString().padLeft(2, "0")}",
                  ),
                ],
              ),
            ),
          ),
          Positioned(
            top: MediaQuery.of(context).size.height * (1 - _treshold),
            height: 30.0,
            left: 5.0,
            width: 100.0,
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
              _controller.forward();
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

class BottomWaveClipper extends CustomClipper<Path> {
  const BottomWaveClipper({
    @required this.animation,
  }) : super(reclip: animation);

  final Listenable animation;

  @override
  Path getClip(Size size) {
    var path = new Path();
    path.moveTo(0.0, size.height);
    path.lineTo(0.0, size.height - (size.height - 20));
    path.lineTo(size.width / 2, size.height - (size.height - 20));

    path.lineTo(size.width, size.height - (size.height - 30));

    path.lineTo(size.width, size.height);

    path.close();

    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => true;
}
