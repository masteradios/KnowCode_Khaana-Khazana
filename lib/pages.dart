import 'package:alz/screens/DoctorVisit.dart';
import 'package:alz/screens/ForgotPage.dart';
import 'package:flutter/material.dart';

import 'AllNotesScreen.dart';
import 'screens/AllDoctorAppointments.dart';
import 'screens/EssentialScreens.dart';
import 'screens/ShowContacts.dart';
final String baseUrl = "https://dec1-128-185-183-42.ngrok-free.app"; // Replace with your server URL
final String linto=baseUrl;
List<Widget> pages = [
  EssentialScreen(),
  NotesScreen(),
  DoctorVisitDetailsPage(),
  ForgotPage(),

];


class PageProvider extends ChangeNotifier{

  int _index=0;
  int get index=>_index;

  void setIndex(int newIndex){

    print("Index updated: $newIndex");
    _index=newIndex;
    notifyListeners();
  }

}