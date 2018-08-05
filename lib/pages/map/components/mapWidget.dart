import 'package:bleacons/classes/latlng.dart';

import 'mapPin.dart';
import 'package:flutter/material.dart';
import 'tileWidget.dart';
import 'package:bleacons/classes/tiles.dart';
import 'package:bleacons/classes/camera.dart';
import 'dart:math';
import 'package:location/location.dart';

// TODO: Maybe do some smart pre-caching of the images. For example, when getting
// the location, I could start caching all the tiles which contain that location
// for starters, at all zoom levels (I could also cache the whole 3x3 grid but
// that would probably take a lot of data)
class MapWidget extends StatefulWidget {
  MapWidget([this._mapPins]);

  List<MapPin> _mapPins;

  @override
  _MapWidgetState createState() => _MapWidgetState(_mapPins);
}

class _MapWidgetState extends State<MapWidget> {
  _MapWidgetState(this._mapPins);

  // The camera is always the center of the map
  Camera _camera;
  // A list of mapPin widgets, each with it's own coordinates
  List<MapPin> _mapPins;

  Location _locationObject;

  // Used by the gesture detector to detect relative movement
  double _prevX;
  double _prevY;

  // The current zoom level due to pinch-to-zoom
  double _cameraScale;

  // The center coordinates
  double _centerX;
  double _centerY;

  // Coordinates topLeft corner of the Viewport. Format is the Map coordinates
  double _topLeftX;
  double _topLeftY;

  @override
  void initState() {
    super.initState();
    _centerX = 0.0;
    _centerY = 0.0;
    _topLeftX = 0.0;
    _topLeftY = 0.0;
    _prevX = 0.0;
    _prevY = 0.0;
    _cameraScale = 1.0;
    _camera = null;
    _mapPins = [];
    _locationObject = Location();
    initLocation();
  }

  initLocation() async {
    var currentLocation = await _locationObject.getLocation;
    setState(() {
      _camera = Camera(
          LatLng(currentLocation["latitude"], currentLocation["longitude"]),
          12);
      _mapPins.add(MapPin(
        LatLng(currentLocation["latitude"], currentLocation["longitude"]),
        color: Colors.red,
      ));
    });
  }

  // Build the map tiles. For now, build a NxM square of tiles.
  // Where N and M are determined from the container size (using the constraints variable)
  List<Widget> _buildTiles(
      double centerX, double centerY, BoxConstraints constraints) {
    int upperTileLimit = pow(2, _camera.zoomLevel);

    int tileX = tileXfromLatLng(_camera.coordinates, _camera.zoomLevel);
    int tileY = tileYfromLatLng(_camera.coordinates, _camera.zoomLevel);

    // Calculate internal tile coordinates. Also include the current zoom level in calculation
    double cameraX = coordsXinsideTile(_camera.coordinates, _camera.zoomLevel) *
        _cameraScale;
    double cameraY = coordsYinsideTile(_camera.coordinates, _camera.zoomLevel) *
        _cameraScale;

    // Coordinates of the center tile so that the camera coordinates are exactly
    // in the center of the viewport.
    double centerTileX = centerX - cameraX;
    double centerTileY = centerY - cameraY;

    List<Widget> tiles = [];

    // Round to nearest upper odd number. So we only have, for example
    // 3x3 grids or 3x5 grids or 1x3...
    // TODO: Having the gestureZoom there kinda slows-down zooming out. Maybe caching will fix this?
    // TODO: Cache images already downloaded
    int numXNeeded = (constraints.maxWidth / _cameraScale / 256).ceil();
    numXNeeded = numXNeeded % 2 == 0 ? numXNeeded + 1 : numXNeeded;
    numXNeeded = numXNeeded == 1 ? 3 : numXNeeded;
    int numYNeeded = (constraints.maxHeight / _cameraScale / 256).ceil();
    numYNeeded = numYNeeded % 2 == 0 ? numYNeeded + 1 : numYNeeded;
    numYNeeded = numYNeeded == 1 ? 3 : numYNeeded;

    // Generate relative indexes of the form [-2, -1, 0, 1, 2]
    List possibleX =
        List.generate(numXNeeded, (index) => index - (numXNeeded / 2).floor());
    List possibleY =
        List.generate(numYNeeded, (index) => index - (numYNeeded / 2).floor());

    // Relative to the center tile, which is 0, 0
    List possibleCoordinates = [];
    for (var yRel in possibleY) {
      for (var xRel in possibleX) {
        possibleCoordinates.add([xRel, yRel]);
      }
    }

    for (var coords in possibleCoordinates) {
      int x = coords[0];
      int y = coords[1];

      int curTileX = tileX + x;
      int curTileY = tileY + y;

      Widget tileWidget;

      if (curTileX < 0 ||
          curTileY < 0 ||
          curTileX >= upperTileLimit ||
          curTileY >= upperTileLimit) {
        tileWidget = Image.asset("images/placeholder.png");
      } else {
        // Hmm... need to zoom around a focal point
        tileWidget = Tile(curTileX, curTileY, _camera.zoomLevel, _cameraScale);
      }

      tiles.add(Positioned(
        // Problem. I seem to zoom a bit to the left and top. Why?
        top: centerTileY + (y * _cameraScale * 256),
        left: centerTileX + (x * _cameraScale * 256),
        child: tileWidget,
      ));
    }

    return tiles;
  }

  List<Widget> _buildMapPins(
      double centerX, double centerY, BoxConstraints constraints) {
    List<Widget> pins = [];

    (_mapPins ?? []).forEach((pin) {
      double x = pin.getX(_camera.zoomLevel);
      double y = pin.getY(_camera.zoomLevel);

      // TODO: Do not render the pins that are not on the screen
      // This code is buggy, makes pins dissapear on the right.
      // if (x < 0 || x > (_topLeftX + constraints.maxWidth)) return;
      // if (y < 0 || y > (_topLeftY + constraints.maxHeight)) return;

      pins.add((Positioned(
        child: pin,
        top: centerY + (y - _camera.y) * _cameraScale - 48.0,
        left: centerX + (x - _camera.x) * _cameraScale - 24.0,
      )));
    });

    return pins;
  }

  @override
  Widget build(BuildContext context) {
    if (_camera == null) {
      return Container();
    }
    return GestureDetector(
      child: LayoutBuilder(
        key: Key(_camera.toString()),
        builder: (BuildContext context, BoxConstraints constraints) {
          // Get the dimensions of the container and it's center
          _centerX = constraints.maxWidth / 2;
          _centerY = constraints.maxHeight / 2;

          // Update topLeft coordinates
          _topLeftX = _camera.x - _centerX;
          _topLeftY = _camera.y - _centerY;

          // Build the map around the center of the container.
          // Automatically add as many tiles as necessary.
          var tileWidgets = _buildTiles(_centerX, _centerY, constraints);
          List<Widget> mapPins = _buildMapPins(_centerX, _centerY, constraints);

          // Build a list of tiles and map pins
          var tilesAndPins = [tileWidgets, mapPins].expand((x) => x).toList();

          return Container(
            // decoration: BoxDecoration(border: Border.all()),
            child: Stack(children: tilesAndPins),
          );
        },
      ),
      // Called when the user touches the screen.
      onScaleStart: (details) {
        _prevX = details.focalPoint.dx;
        _prevY = details.focalPoint.dy;
      },
      // Called when the user pans around the screen or pinches to zoom
      // This function moves the map around, as well as zooms the map
      onScaleUpdate: (details) {
        double deltaX = 0.0;
        double deltaY = 0.0;

        // Calculate camera shift due to movement.
        deltaX = -(details.focalPoint.dx - _prevX ?? details.focalPoint.dx) /
            details.scale;
        deltaY = -(details.focalPoint.dy - _prevY ?? details.focalPoint.dy) /
            details.scale;

        // Calculate camera shift due to zoom.
        double deltaZoom = details.scale - _cameraScale;
        deltaX += deltaZoom *
            (details.focalPoint.dx - _centerX) /
            pow(details.scale, 2);
        deltaY += deltaZoom *
            (details.focalPoint.dy - _centerY) /
            pow(details.scale, 2);

        setState(() {
          _camera.x += deltaX;
          _camera.y += deltaY;
          _cameraScale = details.scale;
        });

        _prevX = details.focalPoint.dx;
        _prevY = details.focalPoint.dy;
      },
      // Called when the user finishes touching the screen
      // This function resets some variables needed for panning the map, as well as
      // sets the map to the closest zoom level.
      onScaleEnd: (details) {
        // Reset the last finger coordinate
        _prevX = null;
        _prevY = null;

        double ratio = log(_cameraScale ?? 1.0.round()) / log(2);
        int newZoomLevel = _camera.zoomLevel + ratio.round();

        // Limit zoom level
        if (newZoomLevel < 0)
          newZoomLevel = 0;
        else if (newZoomLevel > 19) newZoomLevel = 19;

        // Do not do this while panning.
        if (newZoomLevel != _camera.zoomLevel) {
          setState(() {
            _camera.zoomLevel = newZoomLevel;
          });
        }

        // Reset the gesture zoom
        setState(() {
          _cameraScale = 1.0;
        });
      },
      onDoubleTap: () {
        setState(() {
          _camera.zoomLevel < 19 ? _camera.zoomLevel++ : null;
        });
      },
    );
  }
}
