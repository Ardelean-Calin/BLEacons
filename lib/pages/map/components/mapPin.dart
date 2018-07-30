import 'package:bleacons/classes/latlng.dart';
import 'package:flutter/material.dart';

class MapPin extends StatelessWidget {
  MapPin(this.coordinates, this.size);

  final double size;
  final LatLng coordinates;

  @override
  Widget build(BuildContext context) {
    return Icon(
      Icons.location_on,
      size: this.size,
      color: Colors.deepPurpleAccent,
    );
  }
}
