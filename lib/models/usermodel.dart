import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class UserModel {
  String id;
  String email;
  String name;
  String diseaseDiagnosed;
  String relation;
  String phoneNumber;
  List<String> emergencyContacts;
  double homeLat;
  double homeLong;
  DateTime dateOfBirth;

  UserModel({
    required this.id,
    required this.email,
    required this.name,
    required this.diseaseDiagnosed,
    required this.relation,
    required this.phoneNumber,
    required this.emergencyContacts,
    required this.homeLat,
    required this.homeLong,
    required this.dateOfBirth
  });


  // Convert UserModel to a Map (useful for Firebase Firestore)
  Map<String, dynamic> toMap() {
    return {
      'email': email,
      'id':id,
      'name': name,
      'diseaseDiagnosed': diseaseDiagnosed,
      'relation': relation,
      'phoneNumber': phoneNumber,
      'emergencyContacts': emergencyContacts,
      'homeLong': homeLong,
      'homeLat': homeLat,
      'dateOfBirth':Timestamp.fromDate(dateOfBirth) ,
    };
  }

  // Create UserModel from a Map (useful for Firebase Firestore)
  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(

      email: map['email'] ?? '',
      id: map['id'] ?? '',
      dateOfBirth: map['dateOfBirth'] != null
          ? (map['dateOfBirth'] as Timestamp).toDate() // Convert Timestamp to DateTime
          : DateTime.now(),
      name: map['name'] ?? '',
      diseaseDiagnosed: map['diseaseDiagnosed'] ?? '',
      relation: map['relation'] ?? '',
      phoneNumber: map['phoneNumber'] ?? '',
      emergencyContacts: List<String>.from(map['emergencyContacts'] ?? []),
      homeLat: map['homeLat'] ?? 0,
      homeLong: map['homeLong'] ?? 0,

    );
  }
}
