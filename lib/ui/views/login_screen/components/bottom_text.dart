import 'package:flutter/material.dart';
import 'package:team_tracking/ui/views/login_screen/animations/change_screen_animation.dart';
import 'package:team_tracking/data/repo/helper_functions.dart';
import 'login_content.dart';

class BottomText extends StatefulWidget {
  const BottomText({super.key});

  @override
  State<BottomText> createState() => _BottomTextState();
}

class _BottomTextState extends State<BottomText> {
  @override
  void initState() {
    ChangeScreenAnimation.bottomTextAnimation.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        setState(() {});
      }
    });

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return HelperFunctions.wrapWithAnimatedBuilder(
      animation: ChangeScreenAnimation.bottomTextAnimation,
      child: GestureDetector(
        onTap: () {
          ChangeScreenAnimation.currentScreen == Screens.signUp
              ? ChangeScreenAnimation.forward()
              : ChangeScreenAnimation.reverse();

          ChangeScreenAnimation.currentScreen =
              Screens.values[1 - ChangeScreenAnimation.currentScreen.index];
        },
        behavior: HitTestBehavior.opaque,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: RichText(
            text: TextSpan(
              style: const TextStyle(
                fontSize: 16,
                fontFamily: 'Montserrat',
              ),
              children: [
                TextSpan(
                  text: ChangeScreenAnimation.currentScreen ==
                          Screens.signUp
                      ? 'Do you have an account? '
                      : "Don't you have an account? ",
                  style: const TextStyle(
                    color: Colors.black87,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                TextSpan(
                  text: ChangeScreenAnimation.currentScreen ==
                          Screens.signUp
                      ? 'Log In'
                      : 'Sign Up',
                  style: TextStyle(
                    fontSize: 20,
                    color: Colors.blue.shade800,
                    fontWeight: FontWeight.bold,
                    decoration: TextDecoration.underline
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
