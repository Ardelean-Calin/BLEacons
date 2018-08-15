import 'dart:convert';

import 'components/mapPin.dart';
import 'package:flutter/material.dart';
import 'components/mapWidget.dart';
import 'package:bleacons/classes/latlng.dart';
import 'package:location/location.dart';
import 'package:http/http.dart' as http;

const databaseURL = "http://192.168.0.101:4000/graphql/";

class MapPage extends StatefulWidget {
  @override
  _MapPageState createState() => _MapPageState();
}

class _MapPageState extends State<MapPage> {
  var beacons;
  var _currentLocation;

  _getBeacons() async {
    String result = (await http.get(
            databaseURL + "?query={beacons{location{latitude,longitude}}}"))
        .body;

    var beacons = jsonDecode(result)["data"]["beacons"];

    // Update the beacons
    setState(() {
      this.beacons = beacons;
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
    final List<MapPin> beaconsPins = beacons.map<MapPin>((beacon) {
      return MapPin(
        LatLng(beacon["location"]["latitude"], beacon["location"]["longitude"]),
        icon: Icons.place,
        color: Colors.blue,
      );
    }).toList();

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
    return Container(
      child: _buildMapWidget(),
    );
  }
}
