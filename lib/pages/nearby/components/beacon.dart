import 'dart:math';
import 'package:flutter/material.dart';
import 'airquality.dart';

class BeaconCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.all(10.0),
      child: new Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          ListTile(
              trailing: AirQualityIndex(Random().nextInt(500)),
              isThreeLine: true,
              title: Text(
                'DEADBEEF',
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                    fontSize: 20.0,
                    fontFamily: "IBM Plex Sans",
                    fontWeight: FontWeight.w600),
              ),
              subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    RichText(
                      text: TextSpan(
                          text: "Last Upload: ",
                          style: TextStyle(
                              fontFamily: "IBM Plex Sans",
                              fontSize: 12.0,
                              fontWeight: FontWeight.w600,
                              color: Color.fromARGB(60, 0, 0, 0)),
                          children: [
                            TextSpan(
                                text: "~2d ago",
                                style: TextStyle(
                                    color: Colors.black,
                                    fontWeight: FontWeight.w600))
                          ]),
                    ),
                  ])),
          // ButtonTheme.bar(
          //   height: 10.0,
          //   child: ButtonBar(
          //     // mainAxisSize: MainAxisSize.max,
          //     children: <Widget>[
          //       IconButton(
          //         icon: Icon(Icons.cloud_upload),
          //         onPressed: null,
          //       )
          //     ],
          //   ),
          // )
        ],
      ),
    );
  }
}
