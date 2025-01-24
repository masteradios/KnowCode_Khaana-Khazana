import 'package:alz/models/usermodel.dart';
import 'package:alz/providers/UserProvider.dart';
import 'package:alz/screens/PatientProfileScreen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class FirebaseServices {
  final FirebaseAuth firebaseAuth=FirebaseAuth.instance;
  final FirebaseFirestore firestore=FirebaseFirestore.instance;
  Future<void> signUpUser({
    required String email,
    required String password,
    required String name,
    required BuildContext context,
  }) async {
    try {
      // Step 1: Create the user with Firebase Authentication
      print('Creating user...');
      UserCredential userCredential = await firebaseAuth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Step 2: Create the UserModel instance with the newly created user
      UserModel userModel = UserModel(
        id: userCredential.user!.uid,
        email: email,
        name: name, // Set default or empty values for now
        diseaseDiagnosed: '',
        relation: '',
        phoneNumber: '',
        emergencyContacts: [],
        homeLat: 0.0,
        homeLong: 0.0,
        dateOfBirth: DateTime.now()
      );

      // Step 3: Save the UserModel data to Firestore
      await firestore.collection('users').doc(userCredential.user!.uid).set(userModel.toMap());

      // Step 4: Update the UserProvider with the new UserModel
      Provider.of<UserProvider>(context, listen: false).setBasicDetails(
        id: userModel.id,
        email: email,
        name: name,
      );
      Navigator.of(context).push(MaterialPageRoute(builder: (context){
        return PatientProfilePage();
      }));

      print('User signed up and data stored successfully.');
    } on FirebaseAuthException catch (e) {
      print('Error during sign-up: ${e.message}');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.message!)),
      );

    } catch (e) {
      print('Unexpected error: $e');
    }
  }

  Future<void> setPatientProfileDetails({required BuildContext context,required String relationship,required DateTime dateOfBirth,required String diseaseDiagnosed})async{
    UserModel userModel = Provider.of<UserProvider>(context,listen: false).userModel!;
    await firestore.collection('users').doc(userModel.id).update({
      'relation':relationship,
      'dateOfBirth':dateOfBirth,
      'diseaseDiagnosed':diseaseDiagnosed
    });

    Provider.of<UserProvider>(context,listen: false).setAdditionalDetails(diseaseDiagnosed: diseaseDiagnosed, relation: relationship, phoneNumber: '', emergencyContacts: [], homeAddressLat: 0, homeAddressLong: 0, dateOfBirth: dateOfBirth);

  }
  void setUserModel(BuildContext context, String uid) async {
    try {
      DocumentSnapshot userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(uid)
          .get();

      if (userDoc.exists) {
        // Convert the Firestore document into a UserModel
        UserModel userModel = UserModel.fromMap(userDoc.data() as Map<String, dynamic>);
        print("user Doc is");
        print(userDoc.toString());
        // Update the UserProvider with the new userModel
        Provider.of<UserProvider>(context, listen: false).setUserModel(userModel: userModel);
      }
    } catch (e) {
      print('Error fetching user data: $e');
    }
  }




}