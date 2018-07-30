import 'latlng.dart';
import 'tiles.dart';

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
