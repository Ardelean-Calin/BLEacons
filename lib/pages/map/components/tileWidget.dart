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
      imageUrl: "https://maps.wikimedia.org/osm-intl/$query.png",
      // "https://api.mapbox.com/v4/mapbox.emerald/$query.jpg90?access_token=pk.eyJ1IjoiYWNwY2FsaW4iLCJhIjoiY2prbGg2cXJ4MDNpNDN2cm4ycWVqY25iciJ9.5-sRA3r_dB2Dz8SytBe1GA",
      // placeholder: Image.asset("images/placeholder.png"),
      errorWidget: new Icon(Icons.error_outline),
      width: 256 * scale,
      height: 256 * scale,
      fit: BoxFit.fill,
      key: Key(query),
    );
  }
}
