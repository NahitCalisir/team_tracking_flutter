import 'package:flutter/material.dart';
import 'package:team_tracking/ui/views/login_screen/animations/change_screen_animation.dart';
import 'package:team_tracking/utils/helper_functions.dart';
import 'login_content.dart';

class TopText extends StatefulWidget {
  const TopText({super.key});

  @override
  State<TopText> createState() => _TopTextState();
}

class _TopTextState extends State<TopText> {
  @override
  void initState() {
    ChangeScreenAnimation.topTextAnimation.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        setState(() {});
      }
    });

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return HelperFunctions.wrapWithAnimatedBuilder(
      animation: ChangeScreenAnimation.topTextAnimation,
      child: Text(
        ChangeScreenAnimation.currentScreen == Screens.signUp
            ? 'Hesap\nOluştur'
            : 'Tekrar\nHoşgeldin',
        style: const TextStyle(
          fontSize: 40,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
