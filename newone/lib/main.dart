import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:newone/firebase_options.dart';
import 'package:newone/login.dart';
import 'package:newone/notification_service.dart';
import 'package:newone/onboardingscreen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import 'package:firebase_messaging/firebase_messaging.dart';

final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

  print('✅ Firebase connected!');
  tz.initializeTimeZones();
  await NotificationService.initialize();
  print('✅ Local notifications initialized!');
  runApp(MyApp());
}

Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  print('Handling a background message: ${message.messageId}');
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  void initState() {
    super.initState();
    requestPermission();
    setupInteractedMessage();
    listenForegroundMessages();
    FirebaseMessaging.instance.getToken().then((token) {
      print('📱 Your FCM Token: $token');
    });
  }

  void requestPermission() async {
    FirebaseMessaging messaging = FirebaseMessaging.instance;

    NotificationSettings settings = await messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      print('User granted permission');
    } else {
      print('User declined or has not accepted permission');
    }
  }

  void listenForegroundMessages() {
  FirebaseMessaging.onMessage.listen((RemoteMessage message) {
    print('📥 Received message in foreground: ${message.messageId}');
    
    final notification = message.notification;
    final android = message.notification?.android;

    if (notification != null && android != null) {
      NotificationService.showNotification(
        id: message.hashCode,
        title: notification.title ?? 'Notification',
        body: notification.body ?? '',
      );
    }
  });
}


  void setupInteractedMessage() async {
    // Handle when app is opened from terminated state via a notification
    RemoteMessage? initialMessage =
        await FirebaseMessaging.instance.getInitialMessage();
    if (initialMessage != null) {
      handleMessage(initialMessage);
    }

    // Handle when app is opened from background via a notification
    FirebaseMessaging.onMessageOpenedApp.listen(handleMessage);
  }

  void handleMessage(RemoteMessage message) {
    // Navigate to specific screen or handle notification tap
    print('User tapped notification: ${message.messageId}');
  }

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
            return const SizedBox();
          }
          return snapshot.data! ? LoginScreen() : OnboardingScreen();
        },
      ),
    );
  }
}
