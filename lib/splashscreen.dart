import 'package:animated_splash_screen/animated_splash_screen.dart';
import 'package:flutter/material.dart';
import 'package:ph_currency_f_v1/capture.dart';
import 'package:page_transition/page_transition.dart';

class SplashScreen extends StatelessWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AnimatedSplashScreen(
      backgroundColor: Colors.grey.shade200,
      splash: Image.asset('assets/icon_ph.png'),
      splashIconSize: 200.0,
      splashTransition: SplashTransition.slideTransition,
      pageTransitionType: PageTransitionType.fade,
      nextScreen: const CamClassify(),
    );
  }
}
