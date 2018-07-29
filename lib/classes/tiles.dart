import 'dart:math';
import 'package:bleacons/classes/latlng.dart';

double sinh(double x) {
  return (exp(x) - exp(-x)) / 2;
}

double fromLatLngX(LatLng coordinates, int zoomLevel) {
  double lng = coordinates.longitude;

  double lonRad = lng * pi / 180.0;
  int n = pow(2, zoomLevel);
  double factor = 256 * n / (2 * pi);

  double xPixel = factor * (lonRad + pi);

  return xPixel;
}

double fromLatLngY(LatLng coordinates, int zoomLevel) {
  double lat = coordinates.latitude;

  double latRad = lat * pi / 180.0;
  int n = pow(2, zoomLevel);
  double factor = 256 * n / (2 * pi);

  double yPixel = factor * (pi - log(tan(pi / 4 + latRad / 2)));

  return yPixel;
}

// Return the longitude in degrees
double fromPixelX(double x, int zoomLevel) {
  // See https://en.wikipedia.org/wiki/Web_Mercator and
  // https://en.wikipedia.org/wiki/Mercator_projection#Derivation_of_the_Mercator_projection
  // Note: I added pi to the original Mercator X so now I need to subtract it.
  int n = pow(2, zoomLevel);
  double factor = 256 * n / (2 * pi);
  double lonRad = (x / factor - pi);
  // Convert to degrees
  return lonRad * 180 / pi;
}

// Return the latitude in degrees
double fromPixelY(double y, int zoomLevel) {
  // See https://en.wikipedia.org/wiki/Web_Mercator and
  // https://en.wikipedia.org/wiki/Mercator_projection#Derivation_of_the_Mercator_projection
  // NOTE: With the Web Mercator, my y coordinate is actually factor * pi - mercator_Y
  int n = pow(2, zoomLevel);
  double factor = 256 * n / (2 * pi);
  double latRad = 2 * atan(exp((factor * pi - y) / factor)) - pi / 2;
  // Convert to degrees
  return latRad * 180 / pi;
}

int tileXfromLatLng(LatLng coordinates, int zoomLevel) {
  double xPixel = fromLatLngX(coordinates, zoomLevel);
  // Tile number, rounded
  return (xPixel / 256).floor();
}

int tileYfromLatLng(LatLng coordinates, int zoomLevel) {
  double yPixel = fromLatLngY(coordinates, zoomLevel);
  // Tile number, rounded
  return (yPixel / 256).floor();
}

double coordsXinsideTile(LatLng coordinates, int zoomLevel) {
  return fromLatLngX(coordinates, zoomLevel) % 256;
}

double coordsYinsideTile(LatLng coordinates, int zoomLevel) {
  return fromLatLngY(coordinates, zoomLevel) % 256;
}

class PixelCoordinates {
  double x;
  double y;
}

class Camera {
  Camera(this.coordinates, this._zoomLevel) {
    this.pixelCoords = PixelCoordinates();

    _updatePixelCoords();
    _updateTileIndexes();
  }

  LatLng coordinates;
  PixelCoordinates pixelCoords;
  int _zoomLevel;
  int tileX;
  int tileY;

  int get zoomLevel => this._zoomLevel;
  set zoomLevel(int level){
    this._zoomLevel = level;
    
    _updatePixelCoords();
    _updateLatLng();
  }

  double get x => this.pixelCoords.x;
  set x(double x) {
    this.pixelCoords.x = x;
    _updateLatLng();
  }

  double get y => this.pixelCoords.y;
  set y(double y) {
    this.pixelCoords.y = y;
    _updateLatLng();
  }

  double get longitude => this.coordinates.longitude;
  set longitude(double longitude) {
    this.coordinates.longitude = longitude;
    _updatePixelCoords();
  }

  double get latitude => this.coordinates.latitude;
  set latitude(double latitude) {
    this.coordinates.latitude = latitude;
    _updatePixelCoords();
  }

  void _updatePixelCoords() {
    this.pixelCoords.x = fromLatLngX(this.coordinates, this._zoomLevel);
    this.pixelCoords.y = fromLatLngY(this.coordinates, this._zoomLevel);

    _updateTileIndexes();
  }

  void _updateLatLng() {
    this.coordinates.latitude = fromPixelY(this.pixelCoords.y, this._zoomLevel);
    this.coordinates.longitude = fromPixelX(this.pixelCoords.x, this._zoomLevel);

    _updateTileIndexes();
  }

  void _updateTileIndexes(){
    this.tileX = (pixelCoords.x / 256).floor();
    this.tileY = (pixelCoords.y / 256).floor();
  }
}
