import 'package:bleacons/pages/nearby/components/chart.dart';

import 'latlng.dart';

class Beacon {
  String id;
  LatLng coordinates;
  double lastUploadTime;
  double lastBatteryLevel;
  List<DataPoint> aqiValues;
  List<DataPoint> temperatureValues;
  List<DataPoint> humidityValues;
  List<DataPoint> pressureValues;

  Beacon.fromData({beaconData}) {
    var location = beaconData["location"];

    id = beaconData["id"];
    coordinates = LatLng(location["latitude"], location["longitude"]);
    lastUploadTime = beaconData["lastUpdate"];
    lastBatteryLevel = beaconData["lastBatteryLevel"];
    aqiValues = (beaconData["aqiValues"] ?? [])
        .map<DataPoint>(
            (dict) => DataPoint(time: dict["time"], value: dict["value"]))
        .toList();
    temperatureValues = (beaconData["temperatureValues"] ?? [])
        .map<DataPoint>(
            (dict) => DataPoint(time: dict["time"], value: dict["value"]))
        .toList();
    humidityValues = (beaconData["humidityValues"] ?? [])
        .map<DataPoint>(
            (dict) => DataPoint(time: dict["time"], value: dict["value"]))
        .toList();
    pressureValues = (beaconData["pressureValues"] ?? [])
        .map<DataPoint>(
            (dict) => DataPoint(time: dict["time"], value: dict["value"]))
        .toList();
  }

  Beacon() {
    id = "";
    aqiValues = [];
    temperatureValues = [];
    humidityValues = [];
    pressureValues = [];
  }
}
