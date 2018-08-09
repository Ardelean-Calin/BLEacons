import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'notification.dart';

import 'pages/nearby/nearbyPage.dart';
import 'pages/map/mapPage.dart';
import 'pages/settings/settingsPage.dart';

void main() {
  SystemChrome
      .setPreferredOrientations([DeviceOrientation.portraitUp]).then((_) {
    runApp(new MyApp());
  });
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Bleacons',
      theme: ThemeData(
        brightness: Brightness.light,
        primaryColor: Colors.blue[700],
        accentColor: Colors.teal,
      ),
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _currentIndex = 0;

  Widget buildFAB(int index) {
    if (index == 0) {
      return FloatingActionButton(
        child: Icon(Icons.cloud_upload),
        onPressed: null,
        tooltip: "Upload All",
        key: Key("upload"), // having a different key forces animations
      );
    } else if (index == 1) {
      return FloatingActionButton(
        child: Icon(Icons.my_location),
        onPressed: null,
        tooltip: "Current location",
        key: Key("location"), // having a different key forces ze animations
      );
    } else {
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Center(
          child: _currentIndex == 0
              ? NearbyPage()
              : _currentIndex == 1 ? MapPage() : SettingsPage(),
        ),
        bottomNavigationBar: BottomNavigationBar(
          currentIndex: _currentIndex,
          items: <BottomNavigationBarItem>[
            BottomNavigationBarItem(
              icon: Stack(
                children: <Widget>[
                  Icon(Icons.pin_drop),
                  NotificationBubble(10)
                ],
              ),
              title: Text("Nearby"),
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.map),
              title: Text("Map"),
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.settings),
              title: Text("Settings"),
            ),
          ],
          onTap: (index) => setState(() => _currentIndex = index),
        ),
        floatingActionButton: buildFAB(_currentIndex));
  }
}
