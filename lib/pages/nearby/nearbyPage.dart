import 'package:bleacons/classes/beacon.dart';
import 'package:flutter/material.dart';
import 'components/beaconCard.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class NearbyPage extends StatefulWidget {
  @override
  _NearbyPageState createState() => _NearbyPageState();
}

class _NearbyPageState extends State<NearbyPage> {
  List<Beacon> _beacons;

  _getNearbyBeacons() async {
    // TODO: Implement
    String result = (await http.get(
            "<YOUR_URL_HERE>?query={beacons{id,location{latitude,longitude,address},lastUpdate,lastBatteryLevel,aqiValues{value,time},temperatureValues{value,time},humidityValues{value,time},pressureValues{value,time}}}"))
        .body;

    List<Beacon> beacons = jsonDecode(result)["data"]["beacons"]
        .map<Beacon>((beacon) => Beacon(beaconData: beacon))
        .toList();

    setState(() {
      _beacons = beacons.sublist(0, 2);
    });
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _beacons = [];
    _getNearbyBeacons();
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      children: (_beacons ?? [])
          .map((beacon) => BeaconCard(
                beaconObject: beacon,
              ))
          .toList(),
      // BeaconCard(),
      // BeaconCard(),
      // BeaconCard(),
      // BeaconCard(),
      // BeaconCard(),
      // BeaconCard(),
      // BeaconCard(),
      // BeaconCard(),
      // BeaconCard(),
    );
  }
}
