import 'package:flutter/material.dart';
import 'components/beacon.dart';

class NearbyPage extends StatefulWidget {
  @override
  _NearbyPageState createState() => _NearbyPageState();
}

class _NearbyPageState extends State<NearbyPage> {
  @override
  Widget build(BuildContext context) {
    return ListView(
      children: <Widget>[
        BeaconCard(),
        BeaconCard(),
        BeaconCard(),
        // BeaconCard(),
        // BeaconCard(),
        // BeaconCard(),
        // BeaconCard(),
        // BeaconCard(),
        // BeaconCard(),
      ],
    );
  }
}
