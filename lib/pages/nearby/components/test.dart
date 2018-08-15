import 'dart:math';

/// Example of a simple line chart.
import 'package:charts_flutter/flutter.dart' as charts;
import 'package:flutter/material.dart';

class SimpleLineChart extends StatelessWidget {
  final List<charts.Series> seriesList;
  final bool animate;

  SimpleLineChart(this.seriesList, {this.animate});

  /// Creates a [LineChart] with sample data and no transition.
  factory SimpleLineChart.withSampleData() {
    return new SimpleLineChart(
      _createSampleData(),
      // Disable animations for image tests.
      animate: false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return new charts.LineChart(
      seriesList,
      animate: animate,
      defaultRenderer: charts.LineRendererConfig(includePoints: true),
    );
  }

  /// Create one series with sample hard coded data.
  static List<charts.Series<DataPoint, double>> _createSampleData() {
    final data = List.generate(
        10, (i) => DataPoint(i.toDouble(), Random().nextDouble() * 50));

    return [
      new charts.Series<DataPoint, double>(
        id: 'value',
        colorFn: (_, __) => charts.MaterialPalette.blue.shadeDefault,
        domainFn: (DataPoint value, _) => value.time,
        measureFn: (DataPoint value, _) => value.value,
        data: data,
      )
    ];
  }
}

/// Sample linear data type.
class DataPoint {
  final double time;
  final double value;

  DataPoint(this.time, this.value);
}
