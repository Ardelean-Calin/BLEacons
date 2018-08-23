import 'package:flutter/material.dart';

class AirQualityIndex extends StatelessWidget {
  AirQualityIndex(this._airQuality, {this.selected: false, this.onTap});

  final int _airQuality;
  final bool selected;
  final Function onTap;

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
    return InkWell(
      child: Container(
        padding: EdgeInsets.only(top: 20.0),
        child: Column(
          children: <Widget>[
            Text(
              "Air Quality Index",
              style: TextStyle(
                  fontFamily: "IBM Plex Sans Condensed",
                  fontSize: 12.0,
                  fontWeight: FontWeight.bold,
                  color: Color.fromARGB(80, 0, 0, 0)),
            ),
            Text(
              _airQuality.toString(),
              style: TextStyle(
                  color: _getColor(),
                  fontFamily: "IBM Plex Sans",
                  fontWeight: FontWeight.w800,
                  fontSize: 36.0),
            ),
          ],
        ),
        decoration: selected
            ? BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    blurRadius: 1.5,
                  ),
                ],
                borderRadius: BorderRadius.circular(10.0),
              )
            : null,
      ),
      onTap: onTap,
    );
  }
}
