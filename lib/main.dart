import 'package:alz/AddLocation.dart';
import 'package:alz/AddReminder.dart';
import 'package:alz/ShakeDetector.dart';
import 'package:alz/helper/services/auth.dart';
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
        [
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




class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => UserProvider()),
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
        home:  StreamBuilder(
          stream: FirebaseAuth.instance.authStateChanges(),
          builder: (context, snapshot) {
            print('Connection State: ${snapshot.connectionState}');
            print('Snapshot Data: ${snapshot.data}');
            print('Snapshot Error: ${snapshot.error}');

            if (snapshot.connectionState == ConnectionState.active) {
              if (snapshot.hasData) {
                final User? firebaseUser = snapshot.data;
                print('User Logged In: ${firebaseUser?.uid}');
                if (firebaseUser != null) {
                  FirebaseServices().setUserModel(context, firebaseUser.uid);
                }
                return HomeScreen();
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
            print('Showing SignUpScreen');
            return SignUpScreen();
          },

        ),

      ),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}



class _MyHomePageState extends State<MyHomePage> {

  void sendMessage()async{
    //String message = "This is a test message!";
    List<String> recipents = ["9326699667", "5556787676"];
    SmsSender sender=SmsSender();
    SmsMessage message = new SmsMessage(recipents[0], 'Hello flutter world!');
    message.onStateChanged.listen((state) {
      if (state == SmsMessageState.Sent) {
        print("SMS is sent!");
      } else if (state == SmsMessageState.Delivered) {
        print("SMS is delivered!");
      }
    });
    sender.sendSms(message);
  }


  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    scheduleNotifications();
    Workmanager().registerPeriodicTask('appReminder', 'showAppReminder',frequency: Duration(minutes: 30));
    ShakeDetector shakeDetector=ShakeDetector.autoStart(onPhoneShake: (){
      showNotification("SOS Sent !!", "Your contacts have been informed!");

    });
  }



  void scheduleNotifications() {
    int? severity = dementiaConditions['sda'];
    dementiaConditions.forEach((condition, severity) {
      String channelKey =
      severity >= 8 ? 'high_frequency' : 'low_frequency'; // Frequency logic

      // Notification Content
      String message = severity >= 8
          ? "Reminder: Use SOS and Face Recognition for emergencies."
          : "Stay safe! Use SOS and YOLO when needed.";

      int frequencyMinutes = severity >= 8 ? 10 : 30;

      AwesomeNotifications().createNotification(
        content: NotificationContent(
          id: severity,
          channelKey: channelKey,
          title: "Stay Prepared: Important Features for $condition",
          body: message,
          notificationLayout: NotificationLayout.Default,
        ),
        schedule: NotificationInterval(
          interval: Duration(minutes: frequencyMinutes),// Convert minutes to seconds
          timeZone: DateTime.now().timeZoneName,
          preciseAlarm: true,
        ),
      );
    });
  }




  @override
  Widget build(BuildContext context) {
    return  Scaffold(
      body: Column(
        children: [
          LocationCheckPage(),
          ElevatedButton(onPressed: (){
            Navigator.push(context, MaterialPageRoute(builder: (context){
              return AddReminderPage();
            }));
          }, child: Text("Add a reminder")),
          ElevatedButton(onPressed: (){
            Navigator.push(context, MaterialPageRoute(builder: (context){
              return AlarmHomePage();
            }));
          }, child: Text("Add a Custom Reminder"))
        ],
      ),
    );
  }
}


