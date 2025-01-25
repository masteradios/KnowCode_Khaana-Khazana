import 'dart:convert';

import 'package:alz/AddLocation.dart';
import 'package:alz/AddReminder.dart';
import 'package:alz/ShakeDetector.dart';
import 'package:http/http.dart' as http;
import 'package:alz/helper/services/auth.dart';
import 'package:alz/models/imageModel.dart';
import 'package:alz/screens/AddRelative.dart';
import 'package:alz/screens/PatientProfileScreen.dart';
import 'package:alz/screens/signUpScreen.dart';
import 'package:android_alarm_manager_plus/android_alarm_manager_plus.dart';
import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:just_audio/just_audio.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sms_advanced/sms_advanced.dart';
import 'package:workmanager/workmanager.dart';
import 'games/fourthGame.dart';
import 'games/secondGame.dart';
import 'games/thirdGame.dart';
import 'helper/diseases.dart';
import 'helper/helperFunctions.dart';
import 'providers/UserProvider.dart';
import 'screens/AlarmScreen.dart';
import 'screens/DeepFace.dart';
import 'screens/DoctorVisit.dart';
import 'screens/HomeScreen.dart';
void playAudioAlarm() async {
  final dir = await getApplicationDocumentsDirectory();
  final customAudioPath = "${dir.path}/custom_audiololo.mp3";

  final player = AudioPlayer();
  await player.setFilePath(customAudioPath);
  player.play();
}
@pragma('vm:entry-point')
void callbackDispatcher() {
  Workmanager().executeTask((task, inputData) async {
    switch (task) {
      case 'checkUserLocation':
        double houseLat = inputData?['houseLat'] ?? 0.0;
        double houseLng = inputData?['houseLng'] ?? 0.0;
        bool isWithin100m = await checkProximity(houseLat, houseLng);
        if (isWithin100m) {
          showNotification("You're near your house!", "Welcome home!");
        }
        break;

      case 'showAppReminder':
        showNotification(
            "Reminder", "You have this app if you need help!");
        break;

      case 'alarmClock':
        print("lolo");
        showAlarmNotification("alarm", 'this is good');

        playAudioAlarm();
        break;

    }
    return Future.value(true);
  });
}




void main() async{

    WidgetsFlutterBinding.ensureInitialized();
    await AndroidAlarmManager.initialize();
    // Initialize Workmanager
    Workmanager().initialize(callbackDispatcher, isInDebugMode: true);

      AwesomeNotifications().initialize(
        null, // Use the default icon
        [NotificationChannel(
          channelKey: 'reminder_channel',
          channelName: 'SOS Reminders',
          channelDescription: 'Notifications with custom sounds',
          playSound: true,
          // Custom sound will be defined per notification
          importance: NotificationImportance.High,
        ),
          NotificationChannel(
            channelKey: 'custom_sound_channel',
            channelName: 'Custom Sound Notifications',
            channelDescription: 'Notifications with custom sounds',
            playSound: true,
         // Custom sound will be defined per notification
            importance: NotificationImportance.High,
          ),
  NotificationChannel(
    channelKey: 'scheduled_channel',
  channelName: 'Doctor Visit Notif',
  channelDescription: 'Notifications with custom sounds',
  playSound: true,
  // Custom sound will be defined per notification
  importance: NotificationImportance.High,
  ),
          NotificationChannel(
            channelKey: 'high_frequency',
            channelName: 'high_frequency',
            channelDescription: 'Notifications with custom sounds',
            playSound: true,
            // Custom sound will be defined per notification
            importance: NotificationImportance.High,
          ),
          NotificationChannel(
            channelKey: 'low_frequency',
            channelName: 'Doctor Visit Notif',
            channelDescription: 'Notifications with custom sounds',
            playSound: true,
            // Custom sound will be defined per notification
            importance: NotificationImportance.High,
          )
        ],
      );
    AwesomeNotifications().isNotificationAllowed().then((isAllowed) {
      if (!isAllowed) {
        AwesomeNotifications().requestPermissionToSendNotifications();
      }
    });
    FirebaseApp app = await Firebase.initializeApp();
    print('Initialized default app $app');

    runApp(const MyApp() );
  }




class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  bool _loading=false;
  bool isFirst=false;
  void setFirstTimeUserFlag() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isFirstTimeUser', false);
    print('setFirstTimeUserFlag: isFirstTimeUser set to false');
    setState(() {
      isFirst = false;
    });
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    isFirstTimeUser();
  }
  Future<void> isFirstTimeUser() async {
    setState(() {
      _loading = true;
    });
    final prefs = await SharedPreferences.getInstance();
    final isFirstTime = prefs.getBool('isFirstTimeUser') ?? false;

    setState(() {
      _loading = false;
      isFirst = isFirstTime;
    });

    print('isFirstTimeUser: isFirst = $isFirst');
  }

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {

    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => UserProvider()),
        ChangeNotifierProvider(create: (_) => ImagesProvider()  ),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Flutter Demo',
        theme: ThemeData(
          fontFamily: 'Montserrat',
          textSelectionTheme:
          const TextSelectionThemeData(cursorColor: Colors.black),
          elevatedButtonTheme: ElevatedButtonThemeData(
              style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 5),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15)),
                  foregroundColor: Colors.white,
                  backgroundColor:  Colors.deepPurpleAccent,)),
          inputDecorationTheme: InputDecorationTheme(
            outlineBorder: BorderSide(color: Colors.black),
            labelStyle: const TextStyle(color: Colors.black54),
            hintStyle: const TextStyle(color: Colors.black54),
            contentPadding:
            const EdgeInsets.symmetric(vertical: 10, horizontal: 15),
            focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(15),
                borderSide: BorderSide(color: Colors.black26)),
            enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(15),
                borderSide: BorderSide(color: Colors.black26)),
            border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(15),
                borderSide: BorderSide(color: Colors.black26)),
          ),
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
          useMaterial3: true,
        ),

        home: (_loading)?Scaffold(body: Center(child: CircularProgressIndicator(color: Colors.white,))):
           StreamBuilder(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        print('StreamBuilder: ConnectionState: ${snapshot.connectionState}');
        print('StreamBuilder: isFirst = $isFirst');

        if (snapshot.connectionState == ConnectionState.active) {
          if (snapshot.hasData) {
            final User? firebaseUser = snapshot.data as User?;
            if (firebaseUser != null) {
              if (isFirst) {
                setFirstTimeUserFlag();
                return PatientProfilePage();
              } else {
                FirebaseServices().setUserModel(context, firebaseUser.uid);
                return HomeScreen();
              }
            }
          } else if (snapshot.hasError) {
            return Scaffold(
              body: Center(
                child: Text('${snapshot.error}'),
              ),
            );
          }
        }

        if (snapshot.connectionState == ConnectionState.waiting) {
          return Scaffold(
            body: Center(
              child: CircularProgressIndicator(),
            ),
          );
        }

        return SignUpScreen();
      },
    )



    ),
    );
  }
}



