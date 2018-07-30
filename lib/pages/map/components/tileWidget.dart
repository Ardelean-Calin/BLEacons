import 'package:flutter/material.dart';


class Tile extends StatelessWidget {
  // Constructor
  Tile(this.x, this.y, this.zoomLevel, [this.scale]);

  final int zoomLevel;
  final int x;
  final int y;
  final double scale;

  @override
  Widget build(BuildContext context) {
    // Returns an image with a placeholder until the network image is
    // loaded.
    String key = "$zoomLevel/$x/$y";

    // Algorithm is good. Problem however: We do requests each time I move on screen...
    // I need to monitor this to see if it's fine.
    return FadeInImage.assetNetwork(
      // image: "https://c.tile.openstreetmap.org/$zoomLevel/$x/$y.png",
      image: "https://maps.wikimedia.org/osm-intl/${zoomLevel}/${x}/${y}.png",
      placeholder: "images/placeholder.png",
      width: 256 * scale,
      height: 256 * scale,
      fit: BoxFit.fill,
      key: Key(key),
    );
  }
}