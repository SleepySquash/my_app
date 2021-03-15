import 'package:flutter/material.dart';

class Temperature extends StatelessWidget {
  final double temperature;
  final double high;
  final double low;

  Temperature({
    Key? key,
    required this.temperature,
    required this.high,
    required this.low,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Padding(
          padding: EdgeInsets.only(right: 20),
          child: Text(
            '${temperature.round()}°',
            style: TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
        ),
        Column(
          children: [
            Text(
              '${high.round()}°',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w100,
                color: Colors.white,
              ),
            ),
            Text(
              '${low.round()}°',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w100,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ],
    );
  }
}
