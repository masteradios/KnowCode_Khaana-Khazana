import 'dart:async';

import 'package:alz/screens/signUpScreen.dart';
import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:iconsax/iconsax.dart';
import 'package:workmanager/workmanager.dart';

import '../ShakeDetector.dart';
import '../helper/diseases.dart';
import '../helper/helperFunctions.dart';
import '../pages.dart';


class HomeScreen extends StatefulWidget {
  static const routeName = '/home';
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  //final ReminderService _reminderService = ReminderService();
  bool isLoading = false;
  double homeLat = 0;
  double homeLong = 0;
  bool _isNotificationSent = false;
  bool _isMounted = false;


  @override
  void initState() {
    super.initState();
    _isMounted = true;
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
  void dispose() {
    _isMounted = false;
    super.dispose();
  }

  void signOut() async {
    await FirebaseAuth.instance.signOut();

    // Navigate to the login page after signing out
    Navigator.of(context).pushAndRemoveUntil(MaterialPageRoute(builder: (context){
      return SignUpScreen();
    }), (route) => false);
  }


  int selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
              onPressed: () {
                signOut();
              },
              icon: Icon(
                Iconsax.logout,
                color: Colors.white,
              ))
        ],
        title: Text(
          'YaadonKiBaarat',
          style: TextStyle(color: Colors.white,
              fontWeight: FontWeight.w900)
        ),
        centerTitle: true,
        backgroundColor: Colors.deepPurple,
      ),
      bottomNavigationBar: NavigationBarTheme(
        data: NavigationBarThemeData(
          elevation: 5,
          labelTextStyle: MaterialStateProperty.resolveWith<TextStyle>(
                (Set<MaterialState> states) =>
            states.contains(MaterialState.selected)
                ? TextStyle(color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.bold)
                : TextStyle(color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.bold),
          ),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.only(
            topRight: Radius.circular(30),
            topLeft: Radius.circular(30),
          ),
          child: NavigationBar(
            animationDuration: Duration(milliseconds: 50),
            selectedIndex: selectedIndex,
            indicatorColor: Colors.white60,
            backgroundColor: Colors.deepPurple,
            onDestinationSelected: (newIndex) {
              setState(() {
                selectedIndex = newIndex;
              });
            },
            destinations: [
              NavigationItem(text: 'Home', icon: (Iconsax.home)),
              NavigationItem(text: 'To-do', icon: (Iconsax.note)),
              NavigationItem(text: 'My Doctor', icon: (Iconsax.health)),
              NavigationItem(text: 'Community', icon: (Iconsax.people)),
            ],
          ),
        ),
      ),
      body: pages[selectedIndex],
      extendBody: (selectedIndex == 3 || selectedIndex == 1) ? false : true,
    );
  }
}

class NavigationItem extends StatelessWidget {
  final IconData icon;
  final String text;
  const NavigationItem({super.key, required this.text, required this.icon});

  @override
  Widget build(BuildContext context) {
    return NavigationDestination(
      icon: Icon(
        icon,
        color: Colors.white,
        size: 25,
      ),
      label: text,
    );
  }
}
