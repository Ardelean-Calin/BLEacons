import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'pages/nearby/nearbyPage.dart';
import 'pages/map/mapPage.dart';
import 'pages/favorites/favoritesPage.dart';

void main() {
  SystemChrome.setEnabledSystemUIOverlays([]);
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
          primaryColor: Colors.blue[700],
          accentColor: Colors.blue[700],
          fontFamily: "IBM Plex Sans"),
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Center(
          child: _currentIndex == 0
              ? NearbyPage()
              : _currentIndex == 1 ? MapPage() : FavoritesPage(),
        ),
        bottomNavigationBar: BottomNavigationBar(
          currentIndex: _currentIndex,
          items: <BottomNavigationBarItem>[
            BottomNavigationBarItem(
              icon: Stack(
                children: <Widget>[
                  Icon(Icons.pin_drop),
                ],
              ),
              title: Text(
                "Nearby",
                style: _currentIndex == 0
                    ? TextStyle(fontWeight: FontWeight.w600)
                    : TextStyle(fontWeight: FontWeight.w500),
              ),
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.map),
              title: Text(
                "Map",
                style: _currentIndex == 1
                    ? TextStyle(fontWeight: FontWeight.w600)
                    : TextStyle(fontWeight: FontWeight.w500),
              ),
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.favorite_border),
              title: Text(
                "Favorites",
                style: _currentIndex == 2
                    ? TextStyle(fontWeight: FontWeight.w600)
                    : TextStyle(fontWeight: FontWeight.w500),
              ),
            ),
          ],
          onTap: (index) => setState(() => _currentIndex = index),
        ));
  }
}
