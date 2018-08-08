import 'package:flutter/material.dart';

class LabelText extends StatelessWidget {
  final String label;
  final String text;

  LabelText({this.label, this.text});

  @override
  Widget build(BuildContext context) {
    return RichText(
      text: TextSpan(
          text: label,
          style: TextStyle(
              fontFamily: "IBM Plex Sans",
              fontSize: 12.0,
              fontWeight: FontWeight.w600,
              color: Color.fromARGB(80, 0, 0, 0)),
          children: [
            TextSpan(
                text: text,
                style:
                    TextStyle(color: Colors.black, fontWeight: FontWeight.w600))
          ]),
    );
  }
}
