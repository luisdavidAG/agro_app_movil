import 'package:flutter/material.dart';

class FancyDivider extends StatelessWidget {
  final double thickness;
  final double radius;
  final List<Color> gradientColors;
  final double opacity;

  const FancyDivider({
    Key? key,
    this.thickness = 5.0,
    this.radius = 10.0,
    this.gradientColors = const [Color(0xFF8A6DE9), Color(0xFF5C5DE9)],
    this.opacity = 0.8, // Nivel de opacidad (0.0 a 1.0)
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: thickness,
      margin: const EdgeInsets.symmetric(vertical: 10.0),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(radius),
        gradient: LinearGradient(
          colors: gradientColors
              .map((color) => color.withOpacity(opacity)) // Aplicar opacidad
              .toList(),
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        ),
        boxShadow: [
          BoxShadow(
            color:
                Colors.black.withOpacity(opacity * 0.5), // Sombra con opacidad
            blurRadius: 10.0,
            offset: const Offset(0, 4),
          ),
        ],
      ),
    );
  }
}
