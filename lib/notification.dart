import 'package:flutter/material.dart';

class NotificationBubble extends StatelessWidget {
  final int notificationNo;

  NotificationBubble(this.notificationNo);

  @override
  Widget build(BuildContext context) {
    return this.notificationNo > 0
        ? Positioned(
            top: 0.0,
            right: 0.0,
            child: Stack(
              children: <Widget>[
                Icon(
                  Icons.brightness_1,
                  size: 12.0,
                  color: Colors.red,
                ),
                Positioned(
                  top: 0.4,
                  left: 3.3,
                  child: Text(
                    this.notificationNo <= 9 ? this.notificationNo.toString() : "+",
                    style: TextStyle(
                        fontSize: 10.0,
                        color: Colors.white,
                        fontWeight: FontWeight.bold),
                  ),
                )
              ],
            ))
        : Container(
            width: 0.0,
            height: 0.0,
          );
  }
}
