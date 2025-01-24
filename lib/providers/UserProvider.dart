import 'package:flutter/material.dart';

import '../models/usermodel.dart';

class UserProvider extends ChangeNotifier {
  UserModel? _userModel;

  // Getter for user model
  UserModel? get userModel => _userModel;

  // Method to set basic user details (email, password, name)
  void setBasicDetails({
    required String email,
    required String name,
    required String id
  }) {
    _userModel = UserModel(
      id: id,
      dateOfBirth: DateTime.now(),
      email: email,
      name: name,
      diseaseDiagnosed: '',
      relation: '',
      phoneNumber: '',
      emergencyContacts: [],
      homeLong: 0.0,
      homeLat: 0.0,
    );
    notifyListeners(); // Notify listeners about the change
  }

  // Method to set remaining details
  void setAdditionalDetails({
    required String diseaseDiagnosed,
    required String relation,
    required String phoneNumber,
    required List<String> emergencyContacts,
    required double homeAddressLat,
    required double homeAddressLong,
    required DateTime dateOfBirth
  }) {
    if (_userModel != null) {
      _userModel = UserModel(
        id: '',
        dateOfBirth: dateOfBirth,
        email: _userModel!.email,
        name: _userModel!.name,
        diseaseDiagnosed: diseaseDiagnosed,
        relation: relation,
        phoneNumber: phoneNumber,
        emergencyContacts: emergencyContacts,
        homeLong: homeAddressLong,
        homeLat: homeAddressLat
      );
      notifyListeners(); // Notify listeners about the change
    }
  }

  void setUserModel({required UserModel userModel}){

    _userModel=userModel;
    notifyListeners();
  }

}
