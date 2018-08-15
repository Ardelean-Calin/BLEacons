import 'latlng.dart';

class Beacon {
  int id;
  LatLng coordinates;
  String address;
  int lastUploadTime;
  double lastBatteryLevel;
  List<dynamic> aqiValues;
  List<dynamic> temperatureValues;
  List<dynamic> humidityValues;
  List<dynamic> pressureValues;

  Beacon({beaconData}) {
    var location = beaconData["location"];

    id = beaconData["id"];
    coordinates = LatLng(location["latitude"], location["longitude"]);
    address = location["address"];
    lastUploadTime = beaconData["lastUpdate"];
    lastBatteryLevel = beaconData["lastBatteryLevel"];
    aqiValues = beaconData["aqiValues"];
    temperatureValues = beaconData["temperatureValues"];
    humidityValues = beaconData["humidityValues"];
    pressureValues = beaconData["pressureValues"];
  }
}
