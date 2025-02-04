import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:music/utils/utils.dart';

import '../../res/app_svg.dart';

class CustomAppBar extends StatelessWidget {
  const CustomAppBar({super.key, this.title, this.preIcon, this.postIcon});
  final String? title;
  final Widget? preIcon;
  final Widget? postIcon;
  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Positioned(
          left: 1,
          child: preIcon ?? SvgPicture.asset(AppSvg.drawer, height: 20),
        ),
        Center(
          child: Text(
            title ?? Utils.getGreetingMessage(),
            style: const TextStyle(
                fontWeight: FontWeight.bold, color: Colors.black87),
          ),
        ),
        Positioned(
          right: 1,
          child: postIcon ??
              Row(
                children: [
                  SvgPicture.asset(
                    AppSvg.search,
                    colorFilter: const ColorFilter.mode(
                      Colors.black87,
                      BlendMode.srcIn,
                    ),
                    width: 20,
                  ),
                  const SizedBox(
                    width: 10,
                  ),
                  SvgPicture.asset(
                    AppSvg.notification,
                    colorFilter: const ColorFilter.mode(
                      Colors.black87,
                      BlendMode.srcIn,
                    ),
                    width: 20,
                  ),
                ],
              ),
        )
      ],
    );
  }
}
