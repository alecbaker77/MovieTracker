import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:movie_tracker_app/services/auth.dart';
import 'package:movie_tracker_app/screens/loginScreen.dart';
import 'package:restart_app/restart_app.dart';

AppBar buildAppBar(BuildContext context) {

  return AppBar(
    leading: BackButton(),
    backgroundColor: Colors.transparent,
    elevation: 0,
    actions: [
      GestureDetector(
        onTap: ()  async {
          await AuthService().signOut();
          Restart.restartApp();
        },
        child: Container(
            padding: EdgeInsets.symmetric(horizontal: 16),
            child: Icon(Icons.exit_to_app)),
      )
    ],
  );
}