import 'latlng.dart';

class Beacon {
  String id;
  LatLng coordinates;
  String address;
  String lastUploadTime;
  double lastBatteryLevel;
  List<dynamic> aqiValues;
  List<dynamic> temperatureValues;
  List<dynamic> humidityValues;
  List<dynamic> pressureValues;

  factory Beacon.fromData({beaconData}) {
    Beacon beacon = Beacon();

    var location = beaconData["location"];

    beacon.id = beaconData["id"];
    beacon.coordinates = LatLng(location["latitude"], location["longitude"]);
    beacon.address = location["address"];
    beacon.lastUploadTime = beaconData["lastUpdate"];
    beacon.lastBatteryLevel = beaconData["lastBatteryLevel"];
    beacon.aqiValues = beaconData["aqiValues"];
    beacon.temperatureValues = beaconData["temperatureValues"];
    beacon.humidityValues = beaconData["humidityValues"];
    beacon.pressureValues = beaconData["pressureValues"];

    return beacon;
  }

  Beacon() {
    id = "";
    address = "";
    aqiValues = [];
    temperatureValues = [];
    humidityValues = [];
    pressureValues = [];
  }
}
