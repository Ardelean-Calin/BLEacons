import 'package:flutter/material.dart';
import 'package:bleacons/classes/beacon.dart';
import 'package:intl/intl.dart';

import 'airquality.dart';
import 'dataTag.dart';
import 'labelText.dart';
import 'package:bleacons/pages/nearby/components/chart.dart';

class BeaconCard extends StatefulWidget {
  Beacon beaconObject;
  Function resetLocationCallback;

  BeaconCard({@required this.beaconObject, this.resetLocationCallback});

  @override
  _BeaconCardState createState() => _BeaconCardState();
}

class _BeaconCardState extends State<BeaconCard> {
  // Index to the _tags list
  int _dataToShow;
  bool _showChart;

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
    _showChart = true;
    // beaconObject = widget.beaconObject;
  }

  @override
  Widget build(BuildContext context) {
    // Depending on _dataToShow, show different data and put different legends
    // var dataToShow =
    List<DataPoint> _data;
    String _yLabel = "Air Quality Index";
    IconData _chartIcon = Icons.child_friendly;

    int _dataLength = widget.beaconObject.aqiValues.length;
    if (_dataLength == 0) {
      _dataLength = 1;
    }

    switch (_dataToShow) {
      case 1:
        _data = widget.beaconObject.temperatureValues;
        _yLabel = "Temperature";
        _chartIcon = Icons.ac_unit;
        break;
      case 2:
        _data = widget.beaconObject.humidityValues;
        _yLabel = "Humidity";
        _chartIcon = Icons.opacity;
        break;
      case 3:
        _data = widget.beaconObject.pressureValues;
        _yLabel = "Pressure";
        _chartIcon = Icons.cloud_queue;
        break;
      case 0:
      default:
        _data = widget.beaconObject.aqiValues;
        _yLabel = "Air Quality Index";
        _chartIcon = Icons.toys;
    }

    DateTime _lastUpload = DateTime
        .fromMillisecondsSinceEpoch(widget.beaconObject.lastUploadTime.toInt());

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
                _showChart = !_showChart;
              });
            },
            onLongPress: widget.resetLocationCallback,
            child: ListTile(
              trailing: AirQualityIndex(
                _dataLength != 0
                    ? widget.beaconObject.aqiValues[_dataLength - 1].value
                        .toInt()
                    : null,
                onTap: () {
                  setState(() {
                    _showChart = true;
                    _dataToShow = _dataToShow == 0 ? null : 0;
                  });
                },
              ),
              // isThreeLine: true,
              title: Container(
                margin: EdgeInsets.only(bottom: 3.0),
                child: Text(
                  widget.beaconObject.id,
                  // overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                      fontSize: 22.0,
                      color: Colors.black,
                      fontFamily: "IBM Plex Sans",
                      fontWeight: FontWeight.w600),
                ),
              ),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Last update: ",
                    style: TextStyle(fontWeight: FontWeight.w400),
                  ),
                  Text(
                    DateFormat("dd-MMM  H:mm:ss a").format(_lastUpload),
                    style: TextStyle(fontWeight: FontWeight.w700),
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
                    "${widget.beaconObject.temperatureValues[_dataLength-1].value.toStringAsFixed(1)}°C",
                    iconColor: Theme.of(context).primaryColor,
                    selected: _dataToShow == 1,
                    onTap: () {
                      setState(() {
                        _showChart = true;
                        _dataToShow = _dataToShow == 1 ? null : 1;
                      });
                    },
                  ),
                  DataTag(
                    Icons.opacity,
                    "${widget.beaconObject.humidityValues[_dataLength-1].value.toStringAsFixed(1)}%",
                    iconColor: Theme.of(context).primaryColor,
                    selected: _dataToShow == 2,
                    onTap: () {
                      setState(() {
                        _showChart = true;
                        _dataToShow = _dataToShow == 2 ? null : 2;
                      });
                    },
                  ),
                  DataTag(
                    Icons.cloud_queue,
                    " ${widget.beaconObject.pressureValues[_dataLength-1].value.toStringAsFixed(1)}kPa",
                    iconColor: Theme.of(context).primaryColor,
                    selected: _dataToShow == 3,
                    onTap: () {
                      setState(() {
                        _showChart = true;
                        _dataToShow = _dataToShow == 3 ? null : 3;
                      });
                    },
                  ),
                  DataTag(
                    Icons.battery_charging_full,
                    "${widget.beaconObject.lastBatteryLevel?.toInt()}%",
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
              child: SimpleLineChart.withData(
                _data,
                animate: false,
                label: _yLabel,
                dataIcon: _chartIcon,
              ),
            ),
            secondChild: Container(),
            crossFadeState: _showChart
                ? CrossFadeState.showFirst
                : CrossFadeState.showSecond,
          ),
          GestureDetector(
              child: Container(
                margin: EdgeInsets.only(bottom: 5.0),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20.0),
                  color: Color.fromARGB(10, 0, 0, 0),
                ),
                child: Icon(
                  _showChart
                      ? Icons.keyboard_arrow_up
                      : Icons.keyboard_arrow_down,
                  color: Theme.of(context).primaryColor,
                ),
              ),
              onTap: () => setState(() {
                    _showChart = !_showChart;
                  }))
        ],
      ),
    );
  }
}
