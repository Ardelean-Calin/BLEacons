import 'package:flutter/material.dart';

class AirQualityIndex extends StatelessWidget {
  AirQualityIndex(this._airQuality);

  final int _airQuality;

  // Return the appropriate color for the current air quality index
  Color _getColor() {
    if (_airQuality > 0 && _airQuality <= 50)
      return Colors.green;
    else if (_airQuality > 50 && _airQuality <= 100)
      return Colors.yellow[600];
    else if (_airQuality > 100 && _airQuality <= 150)
      return Colors.orange[600];
    else if (_airQuality > 150 && _airQuality <= 200)
      return Colors.red;
    else if (_airQuality > 200 && _airQuality <= 300)
      return Colors.purple;
    else if (_airQuality > 300) return Colors.red[900];
    return Colors.black;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
        child: Column(
      children: <Widget>[
        Text(
          _airQuality.toString(),
          style: TextStyle(
              color: _getColor(),
              fontFamily: "IBM Plex Sans",
              fontWeight: FontWeight.bold,
              fontSize: 24.0),
        ),
        Text(
          "Air Quality Index",
          style: TextStyle(
              fontFamily: "IBM Plex Sans Condensed",
              fontSize: 12.0,
              fontStyle: FontStyle.italic),
        )
      ],
    ));
  }
}
