import 'package:flutter/material.dart';
import 'package:introduction_screen/introduction_screen.dart';
import 'package:newone/login.dart';
import 'package:shared_preferences/shared_preferences.dart';

class OnboardingScreen extends StatelessWidget {
  const OnboardingScreen({super.key});

  void goToLogin(BuildContext context) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('seenOnboarding', true);
    Navigator.of(context).pushReplacement( MaterialPageRoute(
      builder: (context) => LoginScreen(),
    ));
  }

  @override
  Widget build(BuildContext context) {
    return IntroductionScreen(
      pages: [
        PageViewModel(
          title: "Rishaf's English Learning App",
          body: "Practice real-life English—speaking, listening, reading, and writing—all in one place.",
          image: Center(child: Image.asset("assets/OIP.jpg", height: 250)),
        ),
        PageViewModel(
          title: "Learn Together, Grow Faster",
          body: "Join live discussions, explore music and stories, and connect with a global community.",
          image: Center(child: Image.asset("assets/OIP.jpg", height: 250)),
        ),
        PageViewModel(
          title: "Are you ready to embark on a transformative journey?",
          body: "Sign up and join a global community of learners.",
          image: Center(child: Image.asset("assets/OIP.jpg", height: 250)),
        ),
      ],
      onDone: () => goToLogin(context),
      onSkip: () => goToLogin(context),
      showSkipButton: true,
      skip: const Text("Skip"),
      next: const Text("Next"),
      done: const Text("Get Started"),
      dotsDecorator: DotsDecorator(
        size: const Size(8, 8),
        activeSize: const Size(16, 8),
        activeColor: Colors.teal,
        color: Colors.grey,
        spacing: const EdgeInsets.symmetric(horizontal: 4),
        activeShape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
        ),
      ),
    );
  }
}
