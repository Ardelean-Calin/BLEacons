import 'package:bleacons/classes/latlng.dart';
import 'package:bleacons/classes/tiles.dart';
import 'package:flutter/material.dart';

class MapPin extends StatelessWidget {
  MapPin(this.coordinates, this.size);

  final double size;
  final LatLng coordinates;

  double getX(int zoomLevel){
    return fromLatLngX(this.coordinates, zoomLevel);
  }

  double getY(int zoomLevel){
    return fromLatLngY(this.coordinates, zoomLevel);
  }

  @override
  Widget build(BuildContext context) {
    return Icon(
      Icons.location_on,
      size: this.size,
      color: Colors.deepPurpleAccent,
    );
    // return Container(
    //     color: Colors.red,
    //     width: 3.0,
    //     height: 3.0,
      
    // );
  }
}
