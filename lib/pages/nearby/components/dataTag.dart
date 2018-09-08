import 'package:flutter/material.dart';

class DataTag extends StatelessWidget {
  DataTag(this._icon, this._data,
      {this.iconColor, this.selected: false, this.onTap});

  final IconData _icon;
  final String _data;
  final Color iconColor;
  final bool selected;
  final Function onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      child: Container(
        padding: EdgeInsets.all(1.0),
        decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20.0),
            boxShadow: selected
                ? [
                    BoxShadow(
                      blurRadius: 1.5,
                    ),
                  ]
                : null,
            color: Colors.white),
        child: GestureDetector(
            child: Row(
              children: <Widget>[
                Icon(
                  _icon,
                  color: Theme.of(context).primaryColor,
                ),
                Text(
                  _data,
                  style: TextStyle(
                    fontFamily: "IBM Plex Sans",
                    fontWeight: FontWeight.w700,
                    color: Theme.of(context).hintColor,
                  ),
                ),
              ],
            ),
            onTap: null),
      ),
      onTap: onTap,
    );
  }
}
