/// Example of a simple line chart.
import 'package:charts_flutter/flutter.dart' as charts;
import 'package:flutter/material.dart';

const int CHART_TICK_NO = 3;
const int CHART_TICK_NO_Y = 3;

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
    var staticPrimaryTicks = <charts.TickSpec<num>>[];
    int dataLength = seriesList[0].data.length;
    String id = seriesList[0].id;
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

      num minValue = seriesList[0].data.fold(seriesList[0].data[0].value,
          (prev, point) => point.value < prev ? point.value : prev);
      num maxValue = seriesList[0].data.fold(seriesList[0].data[0].value,
          (prev, point) => point.value > prev ? point.value : prev);

      num delta = (maxValue - minValue) / CHART_TICK_NO_Y;
      staticPrimaryTicks = List.generate(CHART_TICK_NO_Y + 1,
          (index) => charts.TickSpec((minValue + delta * index)));
    }

    return charts.TimeSeriesChart(
      seriesList,
      animate: animate,
      dateTimeFactory: const charts.LocalDateTimeFactory(),
      domainAxis: charts.DateTimeAxisSpec(
        showAxisLine: false,
        renderSpec: charts.SmallTickRendererSpec(labelOffsetFromAxisPx: 12),
        tickFormatterSpec: charts.AutoDateTimeTickFormatterSpec(
          minute: charts.TimeFormatterSpec(
              format: "HH:mm", transitionFormat: "dd-MMM\n HH:mm"),
        ),
        tickProviderSpec: charts.StaticDateTimeTickProviderSpec(staticTicks),
      ),
      primaryMeasureAxis: charts.NumericAxisSpec(
        tickFormatterSpec: charts.BasicNumericTickFormatterSpec(
          (num value) => id.contains("Quality")
              ? value.toStringAsFixed(0)
              : value == value.toInt()
                  ? value.toStringAsFixed(0)
                  : value.toStringAsFixed(1),
        ),
        tickProviderSpec:
            charts.StaticNumericTickProviderSpec(staticPrimaryTicks),
      ),
      behaviors: [
        charts.PanAndZoomBehavior(),
        charts.SeriesLegend(
          position: charts.BehaviorPosition.top,
          outsideJustification: charts.OutsideJustification.start,
        ),
      ],
      defaultRenderer: charts.LineRendererConfig(
        symbolRenderer: IconRenderer(dataIcon),
        includeLine: true,
        includePoints: false,
        includeArea: true,
        stacked: true,
      ),
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
