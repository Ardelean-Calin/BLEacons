import 'package:bleacons/classes/latlng.dart';
import 'package:bleacons/classes/tiles.dart';
import 'package:flutter/material.dart';

class MapPin extends StatelessWidget {
  MapPin(
    this.coordinates, {
    this.size: 48.0,
    this.icon: Icons.location_on,
    this.color: Colors.deepPurple,
    this.onTap,
  });

  final double size;
  final LatLng coordinates;
  final IconData icon;
  final Color color;
  Function onTap;

  double getX(int zoomLevel) {
    return fromLatLngX(coordinates, zoomLevel);
  }

  double getY(int zoomLevel) {
    return fromLatLngY(coordinates, zoomLevel);
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      child: Icon(
        icon,
        size: size,
        color: color,
      ),
      onTap: onTap,
    );
  }
}
