import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';

class Tile extends StatelessWidget {
  // Constructor
  Tile(this.x, this.y, this.zoomLevel, [this.scale]);

  final int zoomLevel;
  final int x;
  final int y;
  final double scale;

  @override
  Widget build(BuildContext context) {
    String query = "$zoomLevel/$x/$y";

    // Returns an image with a placeholder until the network image is
    // loaded.
    // Algorithm is good. Problem however: We do requests each time I move on screen...
    // I need to monitor this to see if it's fine.
    return CachedNetworkImage(
      imageUrl:
          "https://cartodb-basemaps-b.global.ssl.fastly.net/light_all/$query.png",
      // placeholder: Image.asset("images/placeholder.png"),
      errorWidget: new Icon(Icons.error_outline),
      width: 256 * scale,
      height: 256 * scale,
      fit: BoxFit.fill,
      key: Key(query),
    );
  }
}
