import 'dart:math';

import 'package:flutter/material.dart';

import 'airquality.dart';
import 'dataTag.dart';
import 'labelText.dart';

var beacons = {
  "1211AB": {
    "aqi": Random().nextInt(500),
    "temp": Random().nextInt(35),
    "hum": Random().nextInt(101),
    "pres": Random().nextInt(20) + 100
  }
};

class BeaconCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.all(10.0),
      child: new Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          ListTile(
              trailing: AirQualityIndex(Random().nextInt(500)),
              isThreeLine: true,
              title: Container(
                  margin: EdgeInsets.only(bottom: 3.0),
                  child: RichText(
                      text: TextSpan(
                          text: '0x',
                          style: TextStyle(
                              fontFamily: "IBM Plex Sans",
                              fontSize: 22.0,
                              fontWeight: FontWeight.w600,
                              color: Color.fromARGB(50, 0, 0, 0)),
                          children: [
                        TextSpan(
                          text: Random()
                              .nextInt(pow(2, 16).toInt())
                              .toRadixString(16)
                              .toUpperCase()
                              .padLeft(6, '0'),
                          // overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                              fontSize: 22.0,
                              color: Colors.black,
                              fontFamily: "IBM Plex Sans",
                              fontWeight: FontWeight.w600),
                        ),
                      ]))),
              subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    LabelText(
                      label: "Last upload: ",
                      text: "~ 1d ago",
                    ),
                    LabelText(
                      label: "Refresh rate: ",
                      text: "1 Hz",
                    ),
                    Container(
                      height: 1.0,
                    ),
                    Text(
                      "Someșului Nr. 14, Cluj-Napoca, RO",
                      style: TextStyle(
                          fontFamily: "IBM Plex Sans",
                          fontSize: 12.0,
                          fontStyle: FontStyle.italic,
                          fontWeight: FontWeight.w600,
                          color: Color.fromARGB(80, 0, 0, 0)),
                    )
                  ])),
          Divider(),
          Container(
              margin: EdgeInsets.only(left: 10.0, right: 10.0, bottom: 10.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: <Widget>[
                  DataTag(Icons.ac_unit, "25 °C"),
                  DataTag(Icons.opacity, "78%"),
                  DataTag(Icons.cloud, " 101 kPa"),
                  DataTag(
                    Icons.battery_charging_full,
                    "53%",
                    iconColor: Theme.of(context).primaryColor,
                  ),
                ],
              ))
        ],
      ),
    );
  }
}
