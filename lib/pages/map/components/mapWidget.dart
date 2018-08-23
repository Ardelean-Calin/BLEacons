import 'package:bleacons/classes/latlng.dart';

import 'mapPin.dart';
import 'package:flutter/material.dart';
import 'tileWidget.dart';
import 'package:bleacons/classes/tiles.dart';
import 'package:bleacons/classes/camera.dart';
import 'dart:math';

// TODO: Maybe do some smart pre-caching of the images. For example, when getting
// the location, I could start caching all the tiles which contain that location
// for starters, at all zoom levels (I could also cache the whole 3x3 grid but
// that would probably take a lot of data)
class MapWidget extends StatefulWidget {
  MapWidget({this.mapPins, this.currentLocation});

  final List<MapPin> mapPins;
  final Map<String, double> currentLocation;

  @override
  _MapWidgetState createState() => _MapWidgetState();
}

class _MapWidgetState extends State<MapWidget> {
  // The scale of the camera before the zooming operation
  double _initialCameraScale;

  // The camera is always the center of the map
  Camera _camera;
  // Holds the current location of the user
  LatLng _currentLocation;

  // Used by the gesture detector to detect relative movement
  double _prevX;
  double _prevY;
  double _prevScale;

  // The current zoom level due to pinch-to-zoom
  double _cameraScale;

  // The center coordinates
  double _centerX;
  double _centerY;

  @override
  void initState() {
    super.initState();
    _centerX = 0.0;
    _centerY = 0.0;
    _prevX = 0.0;
    _prevY = 0.0;
    _prevScale = 1.0;
    _cameraScale = 1.0;

    _currentLocation = LatLng(widget.currentLocation["latitude"],
        widget.currentLocation["longitude"]);
    _camera = Camera(
        LatLng(_currentLocation.latitude, _currentLocation.longitude), 12);
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
    // TODO: Cache images already downloaded
    int numXNeeded = (constraints.maxWidth / _cameraScale / 256).ceil() + 1;
    numXNeeded = numXNeeded % 2 == 0 ? numXNeeded + 1 : numXNeeded;
    numXNeeded = numXNeeded == 1 ? 3 : numXNeeded;
    int numYNeeded = (constraints.maxHeight / _cameraScale / 256).ceil() + 1;
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

    (this.widget.mapPins ?? []).forEach((pin) {
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
    return LayoutBuilder(
      key: Key(_camera.toString()),
      builder: (BuildContext context, BoxConstraints constraints) {
        // Get the dimensions of the container and it's center
        _centerX = constraints.maxWidth / 2;
        _centerY = constraints.maxHeight / 2;

        // Build the map around the center of the container.
        // Automatically add as many tiles as necessary.
        var tileWidgets = _buildTiles(_centerX, _centerY, constraints);
        List<Widget> mapPins = _buildMapPins(_centerX, _centerY, constraints);

        // Build a list of tiles and map pins
        var tilesAndPins = [tileWidgets, mapPins].expand((x) => x).toList();

        return Scaffold(
          body: GestureDetector(
            child: Container(
              // decoration: BoxDecoration(border: Border.all()),
              child: Stack(children: tilesAndPins),
            ),
            // Called when the user touches the screen.
            onScaleStart: (details) {
              _prevX = details.focalPoint.dx;
              _prevY = details.focalPoint.dy;
              _initialCameraScale = _cameraScale;
            },
            // Called when the user pans around the screen or pinches to zoom
            // This function moves the map around, as well as zooms the map
            onScaleUpdate: (details) {
              double deltaX = 0.0;
              double deltaY = 0.0;

              // details.focalPoint returns absolute offset. We make it relative here
              RenderBox box = context.findRenderObject();
              Offset relativePosition = box.globalToLocal(details.focalPoint);
              double relativedx = relativePosition.dx;
              double relativedy = relativePosition.dy;

              // Calculate camera shift due to movement.
              deltaX = -(details.focalPoint.dx - _prevX) / _cameraScale;
              deltaY = -(details.focalPoint.dy - _prevY) / _cameraScale;

              // Calculate camera shift due to zoom.
              double deltaZoom = details.scale - (_prevScale ?? details.scale);
              deltaX += deltaZoom *
                  (relativedx - _centerX) /
                  (details.scale * _cameraScale);
              deltaY += deltaZoom *
                  (relativedy - _centerY) /
                  (details.scale * _cameraScale);

              // Calculate if the current _cameraScale corresponds to another zoom level
              double ratio = log(_cameraScale) / log(2);
              int newZoomLevel =
                  _camera.zoomLevel + ratio.sign.toInt() * ratio.abs().floor();

              // Limit zoom level
              if (newZoomLevel < 0)
                newZoomLevel = 0;
              else if (newZoomLevel > 19) newZoomLevel = 19;

              // Calculate the new scale the camera should have and the scale to
              // which to relate the details.scale to.
              double _newCameraScale;
              if (newZoomLevel != _camera.zoomLevel) {
                _newCameraScale = 1.0;
                _initialCameraScale = 1 / details.scale;
              } else {
                // At fist, _initialCameraScale is 1. Then it becomes 1/2, then 1/4, etc.
                // so that when zooming in, right after a zoom level change, the product
                // remains 1.0
                _newCameraScale = _initialCameraScale * details.scale;
              }

              _prevX = details.focalPoint.dx;
              _prevY = details.focalPoint.dy;
              _prevScale = details.scale;

              // Move and zoom the camera, as well as change the zoom level if necessary
              setState(() {
                _camera.x += deltaX;
                _camera.y += deltaY;
                _camera.zoomLevel = newZoomLevel;
                _cameraScale = _newCameraScale;
              });
            },
            // Called when the user finishes touching the screen
            // This function resets some variables needed for panning the map
            onScaleEnd: (details) {
              // Reset the last finger coordinate
              _prevX = null;
              _prevY = null;
              _prevScale = null;
              if (_camera.zoomLevel == 19 && _cameraScale > 1.0) {
                setState(() {
                  _cameraScale = 1.0;
                });
              }
            },
            onDoubleTap: () {
              setState(() {
                _camera.zoomLevel < 19 ? _camera.zoomLevel++ : null;
              });
            },
          ),
          floatingActionButton: FloatingActionButton(
            child: Icon(Icons.my_location),
            onPressed: () {
              setState(() {
                _camera.latitude = _currentLocation.latitude;
                _camera.longitude = _currentLocation.longitude;
                _camera.zoomLevel = 12;
                _cameraScale = 1.0;
              });
            },
          ),
        );
      },
    );
  }
}
