class LatLng{
  double latitude;
  double longitude;

  LatLng(this.latitude, this.longitude);

  @override
  String toString() {
      return "Lat: ${this.latitude}; Lng: ${this.longitude}";
    }
}
