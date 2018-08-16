import 'dart:async';

import 'package:bleacons/classes/beacon.dart';
import 'package:bleacons/classes/latlng.dart';
import 'package:flutter/material.dart';
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

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _beacons = {};
    _scanSubscription?.cancel();
    _getNearbyBeacons();
  }

  @override
  void dispose() {
    super.dispose();
    _scanSubscription?.cancel();
  }

  _getBeaconFromInternet(String id) async {
    var beacon;

    try {
      var response = await http.get(
          "<YOUR_URL_HERE>?query={beacon(id:\"$id\"){location{latitude,longitude,address},aqiValues{value,time},temperatureValues{value,time},humidityValues{value,time},pressureValues{value,time}}}");
      beacon = json.decode(response.body)["data"]["beacon"];
    } catch (e) {
      beacon = null;
    }

    return beacon;
  }

  _getNearbyBeacons() async {
    var location;
    try {
      location = await (new Location()).getLocation;
    } catch (e) {
      // No location, no nothing
      return;
    }
    _scanSubscription =
        _flutterBlue.scan(scanMode: ScanMode.lowLatency).listen((result) async {
      String id = result.device.id.id;
      String name = result.advertisementData.localName;
      if (name == "IAQ") {
        Beacon beacon = _createBeaconFromManufacturer(
            id, result.advertisementData.manufacturerData.values.toList()[0]);

        var beaconJSON = await _getBeaconFromInternet(id);
        // Daca exista acest beacon pe net
        if (beaconJSON != null) {
          beacon.aqiValues =
              beaconJSON["aqiValues"].expand(beacon.aqiValues[0]);
          beacon.temperatureValues = beaconJSON["temperatureValues"]
              .expand(beacon.temperatureValues[0]);
          beacon.humidityValues =
              beaconJSON["humidityValues"].expand(beacon.humidityValues[0]);
          beacon.pressureValues =
              beaconJSON["pressureValues"].expand(beacon.pressureValues[0]);
          beacon.address = beaconJSON["location"]["address"];
          beacon.coordinates = LatLng(beaconJSON["location"]["latitude"],
              beaconJSON["location"]["longitude"]);
        } else {
          beacon.address = "Str. Somesului Nr. 14";
          beacon.coordinates =
              LatLng(location["latitude"], location["longitude"]);
          // TODO: Upload beacon

        }

        // http.post("<YOUR_URL_HERE>", body: JSON.encode(bea))

        setState(() {
          _beacons[id] = beacon;
        });
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
    int accuracy = (manufacturerData[0] & 0x02) >> 1;

    DateTime now = DateTime.now();

    Beacon beacon = Beacon();
    beacon.id = id;
    beacon.lastBatteryLevel = (batteryVoltage / 3.7) * 100;
    beacon.lastUploadTime = now.millisecondsSinceEpoch.toString();

    beacon.aqiValues.add({
      "value": iaq.toDouble(),
      "time": now.millisecondsSinceEpoch.toString()
    });

    beacon.temperatureValues.add(
        {"value": temperature, "time": now.millisecondsSinceEpoch.toString()});

    beacon.humidityValues.add(
        {"value": humidity, "time": now.millisecondsSinceEpoch.toString()});

    beacon.pressureValues.add(
        {"value": pressure, "time": now.millisecondsSinceEpoch.toString()});

    return beacon;
  }

  @override
  Widget build(BuildContext context) {
    return _beacons.length != 0
        ? ListView(
            children: _beacons.values
                .map((beacon) => BeaconCard(
                      beaconObject: beacon,
                    ))
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
