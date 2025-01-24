import 'package:alz/screens/DoctorVisit.dart';
import 'package:flutter/material.dart';

import 'AllNotesScreen.dart';
import 'screens/AllDoctorAppointments.dart';
import 'screens/EssentialScreens.dart';
import 'screens/ShowContacts.dart';
final String baseUrl = "https://f317-2409-40c0-7e-776f-1d7f-27a6-1588-4236.ngrok-free.app"; // Replace with your server URL

List<Widget> pages = [
  EssentialScreen(),
  NotesScreen(),
  DoctorVisitDetailsPage(),
  Scaffold(),

];