import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:newone/firebase_options.dart';
import 'package:newone/login.dart';
import 'package:newone/onboardingscreen.dart';
import 'package:shared_preferences/shared_preferences.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  print('✅ Firebase connected!');
  // final prefs = await SharedPreferences.getInstance();
  // await prefs.remove('seenOnboarding');

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  Future<bool> checkOnboardingSeen() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool('seenOnboarding') ?? false;
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'English Planner',
      debugShowCheckedModeBanner: false,
      home: FutureBuilder<bool>(
        future: checkOnboardingSeen(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const SizedBox(); // or splash
          }
          return snapshot.data! ? LoginScreen() : OnboardingScreen();
        },
      ),
    );
  }
}
