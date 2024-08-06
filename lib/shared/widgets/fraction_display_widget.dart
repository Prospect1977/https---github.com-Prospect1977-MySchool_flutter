import 'package:flutter/material.dart';

class FractionDisplay extends StatelessWidget {
  final String numerator;
  final String denominator;
  final Color color;
  final double fontSize;
  final FontWeight fontWeight;
  final double dividerWidth;
  FractionDisplay(
      {@required this.numerator,
      @required this.denominator,
      @required this.color,
      @required this.fontSize,
      @required this.fontWeight,
      this.dividerWidth});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        Text(
          numerator,
          style: TextStyle(
              fontSize: fontSize, fontWeight: fontWeight, color: color),
        ),
        Container(
          height: 2,
          width: dividerWidth == null ? 40 : dividerWidth,
          color: color,
        ),
        Text(
          denominator,
          style: TextStyle(
              fontSize: fontSize, fontWeight: fontWeight, color: color),
        ),
      ],
    );
  }
}
