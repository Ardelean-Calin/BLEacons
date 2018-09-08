import 'dart:async';

import 'package:bleacons/classes/beacon.dart';
import 'package:bleacons/pages/nearby/components/chart.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:location/location.dart';
import 'components/beaconCard.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_blue/flutter_blue.dart';

class NearbyPage extends StatefulWidget {
  @override
  _NearbyPageState createState() => _NearbyPageState();
}

class _NearbyPageState extends State<NearbyPage> {
  Map<String, Beacon> _beacons;
  FlutterBlue _flutterBlue = FlutterBlue.instance;
  StreamSubscription _scanSubscription;
  Timer _cleanupTimer;
  Map<String, double> _currentLocation;

  @override
  void initState() {
    super.initState();
    _beacons = {};
    _scanSubscription?.cancel();
    _getNearbyBeacons();
    // _startCleanupTimer();
  }

  @override
  void dispose() {
    super.dispose();
    _scanSubscription?.cancel();
    _cleanupTimer?.cancel();
  }

  // If a given beacon hasn't been updated in the last 10 seconds it's no longer in range
  // void _startCleanupTimer() {
  //   _cleanupTimer = Timer.periodic(Duration(seconds: 1), (timer) {
  //     List<String> toRemove = [];
  //     _beacons.forEach((String key, Beacon beacon) {
  //       if (DateTime.now().difference(DateTime.fromMillisecondsSinceEpoch(
  //               beacon.lastUploadTime.toInt())) >
  //           Duration(seconds: 10)) {
  //         toRemove.add(key);
  //       }
  //     });
  //     setState(() {
  //       toRemove.forEach((key) => _beacons.remove(key));
  //     });
  //   });
  // }

  _getBeaconFromInternet(String id) async {
    var beacon;

    try {
      var response = await http.get(
          "http://gicamois.pythonanywhere.com/graphql?query={beacon(id:\"$id\"){location{latitude,longitude},aqiValues{value,time},temperatureValues{value,time},humidityValues{value,time},pressureValues{value,time}}}");
      beacon = json.decode(response.body)["data"]["beacon"];
    } catch (e) {
      beacon = null;
    }

    return beacon;
  }

  _getNearbyBeacons() async {
    var location;
    try {
      location = await (new Location()).getLocation();
    } catch (e) {
      // No location, no nothing
      location = null;
    }

    setState(() {
      _currentLocation = location;
    });

    _scanSubscription =
        _flutterBlue.scan(scanMode: ScanMode.lowLatency).listen((result) async {
      String id = result.device.id.id;
      String name = result.advertisementData.localName;
      if (name == "IAQ") {
        _scanSubscription.pause();

        Beacon beacon = _createBeaconFromManufacturer(
            id, result.advertisementData.manufacturerData.values.toList()[0]);

        // Beacon already exists locally => add data and update to cloud
        if (_beacons.containsKey(beacon.id)) {
          _beacons[id].lastUploadTime = beacon.lastUploadTime;
          _beacons[id].aqiValues.addAll(beacon.aqiValues);
          _beacons[id].temperatureValues.addAll(beacon.temperatureValues);
          _beacons[id].humidityValues.addAll(beacon.humidityValues);
          _beacons[id].pressureValues.addAll(beacon.pressureValues);

          // Remote update beacon
          await http.post("http://gicamois.pythonanywhere.com/graphql",
              headers: {
                'Content-Type': 'application/json',
                'Accept': 'application/json',
              },
              body: jsonEncode({
                "query":
                    "mutation UpdateBeacon(\$id: String, \$lastUpdate: Float, \$lastBatteryLevel: Float, \$aqiValue: DataPointInput, \$temperatureValue: DataPointInput, \$humidityValue: DataPointInput, \$pressureValue: DataPointInput ){updateBeacon(aqiValue: \$aqiValue, id: \$id, humidityValue: \$humidityValue, temperatureValue: \$temperatureValue, pressureValue: \$pressureValue, lastUpdate: \$lastUpdate, lastBatteryLevel: \$lastBatteryLevel){ok}}",
                "variables": {
                  "id": _beacons[id].id,
                  "lastUpdate": beacon.lastUploadTime,
                  "lastBatteryLevel": beacon.lastBatteryLevel,
                  "aqiValue": beacon.aqiValues[0].toMap(),
                  "temperatureValue": beacon.temperatureValues[0].toMap(),
                  "pressureValue": beacon.pressureValues[0].toMap(),
                  "humidityValue": beacon.humidityValues[0].toMap(),
                }
              }));
        } else {
          // Try and get a beacon from the internet first. Limited data only
          var existingBeacon = await _getBeaconFromInternet(id);
          // If there is no beacon with this ID, create one
          if (existingBeacon == null) {
            await http.post("http://gicamois.pythonanywhere.com/graphql",
                headers: {
                  'Content-Type': 'application/json',
                  'Accept': 'application/json',
                },
                body: jsonEncode({
                  "query":
                      "mutation CreateBeacon(\$id: String, \$location: LocationInput){createBeacon(id:\$id, location:\$location){ok}}",
                  "variables": {
                    "id": id,
                    "location": {
                      "longitude": location["longitude"],
                      "latitude": location["latitude"]
                    }
                  }
                }));
            // Then add it to the current beacons
            _beacons[id] = beacon;
          } else {
            // If there is a beacon with this ID already, just add it and it's data to our
            // local beacons list
            _beacons[id] = Beacon.fromData(beaconData: existingBeacon);
            _beacons[id].id = id;
          }

          _beacons[id].lastUploadTime = beacon.lastUploadTime;
          _beacons[id].lastBatteryLevel = beacon.lastBatteryLevel;
        }

        // Check if beacon exists

        // http.post("http://gicamois.pythonanywhere.com/graphql", body: JSON.encode(bea))
        if (this.mounted) setState(() {});
        _scanSubscription.resume();
      }
    });
  }

  Beacon _createBeaconFromManufacturer(String id, List<int> manufacturerData) {
    double batteryVoltage =
        0.00186 * ((manufacturerData[8] << 8) + manufacturerData[9]);
    double pressure = manufacturerData[6] + manufacturerData[7] / 100;
    double humidity = manufacturerData[4] + manufacturerData[5] / 100;
    double temperature = manufacturerData[2] + manufacturerData[3] / 100;
    int iaq = ((manufacturerData[0] & 0x01) << 8) + manufacturerData[1];
    // int accuracy = (manufacturerData[0] & 0x02) >> 1;

    DateTime now = DateTime.now();

    Beacon beacon = Beacon();
    beacon.id = id;
    beacon.lastBatteryLevel = (batteryVoltage / 3.7) * 100;
    beacon.lastUploadTime = now.millisecondsSinceEpoch.toDouble();

    beacon.aqiValues.add(DataPoint(
        value: iaq.toDouble(), time: now.millisecondsSinceEpoch.toDouble()));
    beacon.temperatureValues.add(DataPoint(
        value: temperature.toDouble(),
        time: now.millisecondsSinceEpoch.toDouble()));
    beacon.humidityValues.add(DataPoint(
        value: humidity.toDouble(),
        time: now.millisecondsSinceEpoch.toDouble()));
    beacon.pressureValues.add(DataPoint(
        value: pressure.toDouble(),
        time: now.millisecondsSinceEpoch.toDouble()));

    return beacon;
  }

  @override
  Widget build(BuildContext context) {
    return _beacons.length != 0
        ? ListView(
            children: _beacons.values
                .map(
                  (beacon) => BeaconCard(
                        beaconObject: beacon,
                        resetLocationCallback: () => setState(() {
                              Fluttertoast.showToast(
                                msg: "Beacon location set to current location",
                                toastLength: Toast.LENGTH_LONG,
                                gravity: ToastGravity.CENTER,
                                timeInSecForIos: 1,
                              );

                              http.post(
                                  "http://gicamois.pythonanywhere.com/graphql",
                                  headers: {
                                    'Content-Type': 'application/json',
                                    'Accept': 'application/json',
                                  },
                                  body: jsonEncode({
                                    "query":
                                        "mutation UpdateLocation(\$id: String, \$location: LocationInput){updateLocation(id:\$id, location:\$location){ok}}",
                                    "variables": {
                                      "id": beacon.id,
                                      "location": {
                                        "longitude":
                                            _currentLocation["longitude"],
                                        "latitude": _currentLocation["latitude"]
                                      }
                                    }
                                  }));
                            }),
                        // Download remaining data for the beacon but only the last hour
                        downloadDataForBeacon: (id) async {
                          double stopTimestamp =
                              DateTime.now().millisecondsSinceEpoch.toDouble();
                          double startTimestamp = DateTime.now()
                              .subtract(Duration(hours: 3))
                              .millisecondsSinceEpoch
                              .toDouble();

                          String result = (await http.get(
                                  "http://gicamois.pythonanywhere.com/graphql?query={beacon(id:\"$id\",restrictData:false,startTimestamp:$startTimestamp,stopTimestamp:$stopTimestamp){id,lastUpdate,lastBatteryLevel,location{latitude,longitude},aqiValues{value,time},temperatureValues{value,time},humidityValues{value,time},pressureValues{value,time}}}"))
                              .body;
                          var beaconData = jsonDecode(result)["data"]["beacon"];

                          Beacon tempBeacon =
                              Beacon.fromData(beaconData: beaconData);

                          if (this.mounted)
                            setState(() {
                              _beacons[id].aqiValues
                                ..addAll(tempBeacon.aqiValues)
                                ..sort((dp1, dp2) => dp1.time > dp2.time
                                    ? 1
                                    : dp1.time == dp2.time ? 0 : -1);
                              _beacons[id].temperatureValues
                                ..addAll(tempBeacon.temperatureValues)
                                ..sort((dp1, dp2) => dp1.time > dp2.time
                                    ? 1
                                    : dp1.time == dp2.time ? 0 : -1);
                              _beacons[id].humidityValues
                                ..addAll(tempBeacon.humidityValues)
                                ..sort((dp1, dp2) => dp1.time > dp2.time
                                    ? 1
                                    : dp1.time == dp2.time ? 0 : -1);
                              _beacons[id].pressureValues
                                ..addAll(tempBeacon.pressureValues)
                                ..sort((dp1, dp2) => dp1.time > dp2.time
                                    ? 1
                                    : dp1.time == dp2.time ? 0 : -1);
                            });
                        },
                      ),
                )
                .toList(),
          )
        : Container(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Container(
                  height: 48.0,
                  width: 48.0,
                  child: CircularProgressIndicator(),
                ),
                Container(
                  height: 10.0,
                ),
                Text("Searching for beacons..."),
              ],
            ),
          );
  }
}
