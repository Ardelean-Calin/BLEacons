/// Example of a simple line chart.
import 'package:charts_flutter/flutter.dart' as charts;
import 'package:flutter/material.dart';

const int CHART_TICK_NO = 3;

class SimpleLineChart extends StatelessWidget {
  final List<charts.Series> seriesList;
  final bool animate;
  final IconData dataIcon;

  SimpleLineChart(this.seriesList, {this.animate, this.dataIcon});

  /// Creates a [TimeSeriesChart] with sample data and no transition.
  // factory SimpleLineChart.withSampleData() {
  //   return new SimpleLineChart(
  //     _createSampleData(),
  //     // Disable animations for image tests.
  //     animate: false,
  //   );
  // }

  /// Creates a [TimeSeriesChart] with given data and label
  factory SimpleLineChart.withData(List<DataPoint> data,
      {animate = false, label = "N/A", dataIcon = Icons.insert_chart}) {
    return SimpleLineChart(seriesFromDataPoints(data, label),
        animate: animate, dataIcon: dataIcon);
  }

  @override
  Widget build(BuildContext context) {
    var staticTicks = <charts.TickSpec<DateTime>>[];
    int dataLength = seriesList[0].data.length;
    // Now, create 5 ticks
    if (dataLength >= 2) {
      DateTime startTime = DateTime.fromMillisecondsSinceEpoch(
          seriesList[0].data[0].time.toInt());
      DateTime lastTime = DateTime.fromMillisecondsSinceEpoch(
          seriesList[0].data[dataLength - 1].time.toInt());
      Duration timeDelta = lastTime.difference(startTime);

      int millisBetweenTicks = timeDelta.inMilliseconds ~/ CHART_TICK_NO;

      staticTicks = List.generate(
          CHART_TICK_NO + 1,
          (index) => charts.TickSpec(startTime
              .add(Duration(milliseconds: index * millisBetweenTicks))));
    }

    return charts.TimeSeriesChart(
      seriesList,
      animate: animate,
      dateTimeFactory: const charts.LocalDateTimeFactory(),
      domainAxis: charts.DateTimeAxisSpec(
        showAxisLine: false,
        tickFormatterSpec: charts.AutoDateTimeTickFormatterSpec(
          hour: charts.TimeFormatterSpec(
              format: "HH:mm", transitionFormat: "HH:mm"),
          day: charts.TimeFormatterSpec(
              format: "d", transitionFormat: "MM-dd-yyyy"),
          minute: charts.TimeFormatterSpec(
              format: "HH:mm", transitionFormat: "HH:mm"),
        ),
        tickProviderSpec: charts.StaticDateTimeTickProviderSpec(staticTicks),
      ),
      behaviors: [
        charts.PanAndZoomBehavior(),
        charts.SeriesLegend(
          position: charts.BehaviorPosition.top,
          outsideJustification: charts.OutsideJustification.start,
        ),
      ],
      defaultRenderer:
          charts.LineRendererConfig(symbolRenderer: IconRenderer(dataIcon)),
    );
  }

  static List<charts.Series<DataPoint, DateTime>> seriesFromDataPoints(
      List<DataPoint> data, String dataLabel) {
    return [
      charts.Series<DataPoint, DateTime>(
        id: dataLabel,
        colorFn: (_, __) => charts.MaterialPalette.blue.shadeDefault,
        domainFn: (DataPoint value, index) =>
            DateTime.fromMillisecondsSinceEpoch(value.time.toInt()),
        measureFn: (DataPoint value, _) => value.value,
        data: data,
      )
    ];
  }
}

class IconRenderer extends charts.CustomSymbolRenderer {
  final IconData iconData;

  IconRenderer(this.iconData);

  @override
  Widget build(BuildContext context, {Color color, Size size, bool enabled}) {
    // TODO: implement build
    return Icon(iconData, color: color, size: 20.0);
  }
}

/// Sample linear data type.
class DataPoint {
  final double time;
  final double value;

  DataPoint({this.time, this.value});

  Map<String, double> toMap() {
    return {
      "time": time,
      "value": value,
    };
  }
}
