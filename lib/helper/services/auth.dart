import 'package:firebase_auth/firebase_auth.dart';

class FirebaseServices {
  final FirebaseAuth firebaseAuth=FirebaseAuth.instance;
  Future<void> signUpUser({required String email,required String password})async{
    try{
      print('creating user');
      UserCredential user = await firebaseAuth.createUserWithEmailAndPassword(
          email: email, password: password);
    }
    on FirebaseAuthException catch (message){
      print(message);

    }
  }


}