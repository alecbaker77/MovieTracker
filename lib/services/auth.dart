import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:restart_app/restart_app.dart';


class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  /*User? _userFromFirebaseUser(User user) {
    return user != null ? User(uid: user.uid) : null;
  }*/

  static Future<User?> loginUsingEmailPassword({required String email, required String password, required BuildContext context}) async{
    FirebaseAuth auth = FirebaseAuth.instance;
    User? user;
    try {
      UserCredential userCredential = await auth.signInWithEmailAndPassword(email: email, password: password);
      user = userCredential.user;
    } on FirebaseAuthException catch (e){
      if (e.code == "user-not-found"){
        print("No User Found for that email");
      }
    }

    return user;
  }

  static Future<User?> createUserWithEmailAndPassword({required String firstName, required String lastName, required String role, required String email, required String password, required BuildContext context}) async{
    FirebaseAuth auth = FirebaseAuth.instance;
    User? user;
    try {
      UserCredential userCredential = await auth.createUserWithEmailAndPassword(email: email, password: password);
      user = userCredential.user;

      User? firestoreUser = FirebaseAuth.instance.currentUser;

      if (firestoreUser != null){
        DateTime myDateTime = DateTime.now(); //DateTime
        await FirebaseFirestore.instance.collection("users").doc(firestoreUser.uid).set({
          'uid': firestoreUser.uid,
          'firstName': firstName,
          'lastName': lastName,
          'role': role,
          'registrationDatetime':  myDateTime,
        });
      }
    } on FirebaseAuthException catch (e){
      print (e) ;
    }

    return user;
  }

  Future resetPass(String email) async {
    try {
      return await _auth.sendPasswordResetEmail(email: email);
    } catch (e) {
      print(e.toString());
      return null;
    }
  }



  Future signOut() async {
    try {
      return await _auth.signOut();
    } catch (e) {
      print(e.toString());
      return null;
    }
  }
}