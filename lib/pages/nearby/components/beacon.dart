import 'dart:math';

import 'package:flutter/material.dart';

import 'airquality.dart';
import 'dataTag.dart';
import 'labelText.dart';
import 'test.dart';

var beacons = {
  "1211AB": {
    "aqi": Random().nextInt(500),
    "temp": Random().nextInt(35),
    "hum": Random().nextInt(101),
    "pres": Random().nextInt(20) + 100
  }
};

class BeaconCard extends StatefulWidget {
  @override
  _BeaconCardState createState() => _BeaconCardState();
}

class _BeaconCardState extends State<BeaconCard> {
  bool showChart;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    showChart = false;
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2.0,
      margin: EdgeInsets.all(10.0),
      child: InkWell(
        onTap: () {
          setState(() {
            showChart = !showChart;
          });
        },
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            ListTile(
              trailing: AirQualityIndex(Random().nextInt(500)),
              // isThreeLine: true,
              title: Container(
                  margin: EdgeInsets.only(bottom: 3.0),
                  child: RichText(
                      text: TextSpan(
                          text: '0x',
                          style: TextStyle(
                              fontFamily: "IBM Plex Sans",
                              fontSize: 28.0,
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
                              fontSize: 24.0,
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
                ],
              ),
            ),
            Divider(
              color: Color.fromARGB(0, 0, 0, 0),
            ),
            Container(
                margin: EdgeInsets.only(left: 10.0, right: 10.0, bottom: 10.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: <Widget>[
                    DataTag(
                      Icons.ac_unit,
                      "25 °C",
                      iconColor: Theme.of(context).primaryColor,
                    ),
                    DataTag(
                      Icons.opacity,
                      "78%",
                      iconColor: Theme.of(context).primaryColor,
                    ),
                    DataTag(
                      Icons.cloud,
                      " 101 kPa",
                      iconColor: Theme.of(context).primaryColor,
                    ),
                    DataTag(
                      Icons.battery_charging_full,
                      "53%",
                      iconColor: Theme.of(context).primaryColor,
                    ),
                  ],
                )),
            // Chart here
            showChart
                ? Container(
                    height: 200.0,
                    margin: EdgeInsets.all(10.0),
                    child: SimpleLineChart.withSampleData(),
                  )
                : Container()
          ],
        ),
      ),
    );
  }
}
