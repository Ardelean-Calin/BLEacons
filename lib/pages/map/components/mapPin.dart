import 'package:flutter/material.dart';

class MapPin extends StatelessWidget {
  MapPin(this.size);

  final double size;

  @override
  Widget build(BuildContext context) {
    return Icon(
      Icons.location_on,
      size: this.size,
      color: Colors.deepPurpleAccent,
    );
  }
}
