import 'package:flutter/material.dart';

class DataTag extends StatelessWidget {
  DataTag(this._icon, this._data, {this.iconColor});

  final IconData _icon;
  final String _data;
  final Color iconColor;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: <Widget>[
        Icon(
          _icon,
          color: iconColor ?? Theme.of(context).hintColor,
        ),
        Text(_data,
            style: TextStyle(
                fontFamily: "IBM Plex Sans",
                fontWeight: FontWeight.w700,
                color: Color.fromARGB(60, 0, 0, 0))),
      ],
    );
  }
}
