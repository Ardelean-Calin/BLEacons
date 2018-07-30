import 'package:bleacons/classes/camera.dart';
import 'package:flutter/material.dart';
import 'components/mapWidget.dart';
import 'package:bleacons/classes/latlng.dart';


class MapPage extends StatefulWidget {
  final Camera camera = new Camera(LatLng(46.79383, 23.75047), 7);

  @override
  _MapPageState createState() => _MapPageState(camera);
}

class _MapPageState extends State<MapPage> {
  _MapPageState(this._camera);

  Camera _camera;
  
  @override
  Widget build(BuildContext context) {
    return Container(
      child: MapWidget(_camera, null),
    );
  }
}
