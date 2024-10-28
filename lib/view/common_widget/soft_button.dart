import 'package:flutter/material.dart';
import '../../res/app_colors.dart';

class CircularSoftButton extends StatelessWidget {
  final double radius; // تعريف الحقل كـ final
  final Widget? icon;
  final Color lightColor;
  final double? padding;
  final double? circularRadius;

  const CircularSoftButton({
    super.key,
    double? radius,
    this.icon,
    this.lightColor = Colors.white,
    this.padding,
    this.circularRadius,
  }) : radius = (radius == null || radius <= 0) ? 32 : radius; // التأكد من ضبط قيمة radius

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(padding ?? radius / 2),
      child: Stack(
        children: <Widget>[
          Container(
            width: radius * 2,
            height: radius * 2,
            decoration: BoxDecoration(
              color: backgroundColor,
              borderRadius: BorderRadius.circular(circularRadius ?? radius),
              boxShadow: [
                BoxShadow(
                    color: shadowColor,
                    offset: const Offset(8, 6),
                    blurRadius: 12),
                BoxShadow(
                    color: lightColor,
                    offset: const Offset(-8, -6),
                    blurRadius: 12),
              ],
            ),
          ),
          Positioned.fill(child: icon ?? Container()),
        ],
      ),
    );
  }
}
