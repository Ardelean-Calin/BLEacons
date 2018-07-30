import 'dart:math';
import 'package:bleacons/classes/latlng.dart';

// TODO: Document functions
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