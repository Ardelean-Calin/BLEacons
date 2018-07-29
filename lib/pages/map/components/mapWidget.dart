import 'mapPin.dart';
import 'package:flutter/material.dart';
import 'tileWidget.dart';
import 'package:bleacons/classes/tiles.dart';
import 'package:trotter/trotter.dart';
import 'dart:math';

// TODO: Maybe do some smart pre-caching of the images. For example, when getting
// the location, I could start caching all the tiles which contain that location
// for starters, at all zoom levels (I could also cache the whole 3x3 grid but
// that would probably take a lot of data)
class MapWidget extends StatefulWidget {
  MapWidget(this.camera);

  // The camera will always remain in the center of the map.
  // Moving needs to update the cameraLocation.
  // TODO: These should be pixel coordinates. Should they?
  final Camera camera;

  @override
  _MapWidgetState createState() => _MapWidgetState(camera);
}

class _MapWidgetState extends State<MapWidget> {
  _MapWidgetState(this.camera);

  Camera camera;

  // Used by the gesture detector to detect relative movement
  double _prevX;
  double _prevY;

  // The current zoom level due to pinch-to-zoom
  double _gestureZoom = 1.0;

  // Build the map tiles. For now, build a 3x3 square of tiles.
  // In the future, maybe calculate how many tiles are needed
  // by taking into account the container size.
  List<Widget> _buildTiles(double centerX, double centerY) {
    int tileX = tileXfromLatLng(this.camera.coordinates, this.camera.zoomLevel);
    int tileY = tileYfromLatLng(this.camera.coordinates, this.camera.zoomLevel);

    // Calculate internal tile coordinates. Also include the current zoom level in calculation
    double cameraX =
        coordsXinsideTile(this.camera.coordinates, this.camera.zoomLevel) *
            _gestureZoom;
    double cameraY =
        coordsYinsideTile(this.camera.coordinates, this.camera.zoomLevel) *
            _gestureZoom;

    double centerTileX = centerX - cameraX;
    double centerTileY = centerY - cameraY;

    List<Widget> tiles = [];

    // Create 9 combinations of relative tile coordinates.
    // Relative to the center tile, which is 0, 0
    List possibleRelations = [-1, 0, 1];
    var amalgams = Amalgams(2, possibleRelations);

    for (var coords in amalgams()) {
      int x = coords[0];
      int y = coords[1];
      tiles.add(Positioned(
        // Problem. I seem to zoom a bit to the left and top. Why?
        top: centerTileY + y * _gestureZoom * 256,
        left: centerTileX + x * _gestureZoom * 256,
        child: Tile(tileX + x, tileY + y, this.camera.zoomLevel, _gestureZoom),
      ));
    }

    return tiles;
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      child: LayoutBuilder(
        builder: (BuildContext context, BoxConstraints constraints) {
          // Get the dimensions of the container and it's center
          double height = constraints.maxHeight;
          double width = constraints.maxWidth;
          double centerX = width / 2;
          double centerY = height / 2;

          // Build the map around the center of the container.
          // TODO: Remove the pin widget
          var tileWidgets = _buildTiles(centerX, centerY);
          var pinWidget = Positioned(
            top: centerY - 48,
            left: centerX - 24,
            child: MapPin(48.0),
          );

          var mapWidget = tileWidgets..add(pinWidget);

          return Container(
            // decoration: BoxDecoration(border: Border.all()),
            child: Stack(children: mapWidget),
          );
        },
      ),
      // Called when the user touches the screen.
      onScaleStart: (details) {
        this._prevX = details.focalPoint.dx;
        this._prevY = details.focalPoint.dy;
      },
      // Called when the user pans around the screen or pinches to zoom
      // This function moves the map around, as well as zooms the map
      onScaleUpdate: (details) {
        // Calculate how much the pointer moved between last updates.
        double deltaX =
            details.focalPoint.dx - this._prevX ?? details.focalPoint.dx;
        double deltaY =
            details.focalPoint.dy - this._prevY ?? details.focalPoint.dy;

        this._prevX = details.focalPoint.dx;
        this._prevY = details.focalPoint.dy;

        setState(() {
          this.camera.x -= deltaX;
          this.camera.y -= deltaY;
          this._gestureZoom = details.scale;
        });
      },
      // Called when the user finishes touching the screen
      // This function resets some variables needed for panning the map, as well as
      // sets the map to the closest zoom level.
      onScaleEnd: (details) {
        // TODO: Sometimes when lifting both fingers at the same time, the screen doesn't update.
        this._prevX = null;
        this._prevY = null;

        double ratio = log(this._gestureZoom ?? 1.0.round()) / log(2);
        int newZoomLevel = this.camera.zoomLevel + ratio.round();
        // Do not do this while panning.
        if (newZoomLevel != this.camera.zoomLevel) {
          setState(() {
            this._gestureZoom = 1.0;
            this.camera.zoomLevel += ratio.round();
          });
        }
      },
    );
  }
}
