import 'components/mapPin.dart';
import 'package:flutter/material.dart';
import 'components/mapWidget.dart';
import 'package:bleacons/classes/latlng.dart';

class MapPage extends StatefulWidget {
  @override
  _MapPageState createState() => _MapPageState();
}

class _MapPageState extends State<MapPage> {
  @override
  Widget build(BuildContext context) {
    return Container(
      child: MapWidget([
        MapPin(
          LatLng(46.784057, 23.585648),
          icon: Icons.bluetooth_searching,
          color: Colors.blue,
        ),
        MapPin(
          LatLng(46.7699829, 23.5894832),
          icon: Icons.bluetooth_searching,
          color: Colors.blue,
        )
      ]),
    );
  }
}
