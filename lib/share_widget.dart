import 'package:flutter/material.dart';
import 'package:share/share.dart';

class ShareWidget extends StatelessWidget {
  int _time = 0;

  ShareWidget(this._time);

  @override
  Widget build(BuildContext context) {
    int _hours = (_time / 3600).floor();
    int _minutes = ((_time % 3600) / 60).floor();

    String _hourString =
        _hours == 0 ? "" : _hours == 1 ? " $_hours hour" : " $_hours hours";
    String _minutesString = _minutes == 0
        ? ""
        : _minutes == 1 ? " $_minutes minute" : " $_minutes minutes";

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Text(
              "Help others escape the toxic culture and share your defeat."),
        ),
        RaisedButton.icon(
          label: Text("Share"),
          icon: Icon(Icons.share),
          color: Colors.white,
          onPressed: () {
            Share.share(
                "WASTED... I died from too many meetings today after$_hourString$_minutesString. What about you? Check it out on https://thismightwork.co");
          },
        )
      ],
    );
  }
}
