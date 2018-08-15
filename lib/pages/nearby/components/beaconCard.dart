import 'dart:math';

import 'package:flutter/material.dart';
import 'package:bleacons/classes/beacon.dart';

import 'airquality.dart';
import 'dataTag.dart';
import 'labelText.dart';
import 'test.dart';

class BeaconCard extends StatefulWidget {
  Beacon beaconObject;

  BeaconCard({@required this.beaconObject});

  @override
  _BeaconCardState createState() => _BeaconCardState();
}

class _BeaconCardState extends State<BeaconCard> {
  Beacon beaconObject;

  // Index to the _tags list
  int _dataToShow;

  static const List<String> _tags = [
    "aqi",
    "temperature",
    "humidity",
    "pressure"
  ];

  @override
  void initState() {
    super.initState();
    _dataToShow = null;
    // beaconObject = widget.beaconObject;
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      key: Key(widget.beaconObject.id.toString()),
      elevation: 2.0,
      margin: EdgeInsets.all(10.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          InkWell(
            onTap: () {
              setState(() {
                _dataToShow = _dataToShow == null ? 0 : null;
              });
            },
            child: ListTile(
              trailing: AirQualityIndex(
                widget.beaconObject.aqiValues[0]["value"].toInt(),
                selected: _dataToShow == 0,
                onTap: () {
                  setState(() {
                    _dataToShow = _dataToShow == 0 ? null : 0;
                  });
                },
              ),
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
                          text: widget.beaconObject.id
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
                    text: "~ 1d ago (TODO)",
                  ),
                  Container(
                    height: 1.0,
                  ),
                  Text(
                    widget.beaconObject.address,
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
                    "${widget.beaconObject.temperatureValues[0]["value"].toStringAsFixed(1)}°C",
                    iconColor: Theme.of(context).primaryColor,
                    selected: _dataToShow == 1,
                    onTap: () {
                      setState(() {
                        _dataToShow = _dataToShow == 1 ? null : 1;
                      });
                    },
                  ),
                  DataTag(
                    Icons.opacity,
                    "${widget.beaconObject.humidityValues[0]["value"].toStringAsFixed(1)}%",
                    iconColor: Theme.of(context).primaryColor,
                    selected: _dataToShow == 2,
                    onTap: () {
                      setState(() {
                        _dataToShow = _dataToShow == 2 ? null : 2;
                      });
                    },
                  ),
                  DataTag(
                    Icons.cloud,
                    " ${widget.beaconObject.pressureValues[0]["value"].toStringAsFixed(1)}kPa",
                    iconColor: Theme.of(context).primaryColor,
                    selected: _dataToShow == 3,
                    onTap: () {
                      setState(() {
                        _dataToShow = _dataToShow == 3 ? null : 3;
                      });
                    },
                  ),
                  DataTag(
                    Icons.battery_charging_full,
                    "${widget.beaconObject.lastBatteryLevel.toInt()}%",
                    iconColor: Theme.of(context).primaryColor,
                  ),
                ],
              )),
          // Chart here
          AnimatedCrossFade(
            duration: Duration(milliseconds: 200),
            firstChild: Container(
              height: 200.0,
              margin: EdgeInsets.all(10.0),
              child: SimpleLineChart.withSampleData(),
            ),
            secondChild: Container(),
            crossFadeState: _dataToShow != null
                ? CrossFadeState.showFirst
                : CrossFadeState.showSecond,
          )
        ],
      ),
    );
  }
}
