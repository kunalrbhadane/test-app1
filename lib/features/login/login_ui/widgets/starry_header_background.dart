
import 'package:flutter/material.dart';

class StarryHeaderBackground extends StatelessWidget {
  final double height;

  const StarryHeaderBackground({
    super.key,
    this.height = 160,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: height,
      width: double.infinity,
      child: Image.asset(
        'assets/images/global_header.png',
        fit: BoxFit.cover,
        
      ),
    );
  }
}

