class LatLng{
  double _latitude;
  double get latitude => _latitude;
  set latitude(double lat) => _latitude = lat;

  double _longitude;
  double get longitude => _longitude;
  set longitude(double lon) => _longitude = lon;

  LatLng(this._latitude, this._longitude);

  @override
  String toString() {
      return "Lat: ${this._latitude}; Lng: ${this._longitude}";
    }
}
