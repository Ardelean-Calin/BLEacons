import 'dart:convert';

import 'package:bleacons/pages/nearby/components/beaconCard.dart';

import 'components/mapPin.dart';
import 'package:flutter/material.dart';
import 'package:bleacons/classes/beacon.dart';
import 'components/mapWidget.dart';
import 'package:bleacons/classes/latlng.dart';
import 'package:location/location.dart';
import 'package:http/http.dart' as http;

const databaseURL = "<YOUR_URL_HERE>";

class MapPage extends StatefulWidget {
  @override
  _MapPageState createState() => _MapPageState();
}

class _MapPageState extends State<MapPage> {
  List<Beacon> beacons;
  var _currentLocation;
  int _selectedBeacon;

  _getBeacons() async {
    String result = (await http.get(databaseURL +
            "?query={beacons{id,location{latitude,longitude,address},lastUpdate,lastBatteryLevel,aqiValues{value,time},temperatureValues{value,time},humidityValues{value,time},pressureValues{value,time}}}"))
        .body;

    List<Beacon> _beacons = jsonDecode(result)["data"]["beacons"]
        .map<Beacon>((beacon) => Beacon(beaconData: beacon))
        .toList();

    // Update the beacons
    setState(() {
      this.beacons = _beacons;
    });
  }

  _getCurrentLocation() async {
    var location;
    try {
      location = await (new Location()).getLocation;
    } catch (e) {
      location = null;
    }

    setState(() {
      _currentLocation = location;
    });
  }

  _buildMarkers() {
    final List<MapPin> beaconsPins = beacons
        .map<MapPin>((Beacon beacon) => MapPin(
              LatLng(beacon.coordinates.latitude, beacon.coordinates.longitude),
              icon: Icons.place,
              // Show which beacon is selected
              color: beacon.id == _selectedBeacon
                  ? Colors.deepPurple
                  : Colors.blue,
              onTap: () {
                if (_selectedBeacon != beacon.id)
                  setState(() {
                    _selectedBeacon = beacon.id;
                  });
                else
                  setState(() {
                    // Null means hide the beacon widget
                    _selectedBeacon = null;
                  });
              },
            ))
        .toList();

    if (_currentLocation != null)
      beaconsPins.add(MapPin(
        LatLng(_currentLocation["latitude"], _currentLocation["longitude"]),
        icon: Icons.person_pin_circle,
        color: Colors.red,
      ));

    return beaconsPins;
  }

  // Builds the map widget as soon as we have location enabled
  _buildMapWidget() {
    if (_currentLocation == null) {
      return Container();
    } else {
      return MapWidget(
        currentLocation: _currentLocation,
        mapPins: _buildMarkers(),
      );
    }
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    beacons = [];
    // Start a beacon fetch
    _getBeacons();
    _getCurrentLocation();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        Expanded(
          child: Container(
            child: _buildMapWidget(),
            height: 400.0,
          ),
        ),
        AnimatedCrossFade(
          firstChild: Container(),
          secondChild: _selectedBeacon == null
              ? Container()
              : BeaconCard(
                  beaconObject: beacons
                      .singleWhere((beacon) => beacon.id == _selectedBeacon),
                ),
          crossFadeState: _selectedBeacon == null
              ? CrossFadeState.showFirst
              : CrossFadeState.showSecond,
          duration: Duration(milliseconds: 200),
        )
      ],
    );
  }
}
