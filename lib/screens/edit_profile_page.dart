import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:movie_tracker_app/model/user.dart';
import 'package:movie_tracker_app/widgets/appbar_widget.dart';
import 'package:movie_tracker_app/widgets/button_widget.dart';
import 'package:movie_tracker_app/widgets/profile_widget.dart';
import 'package:movie_tracker_app/widgets/textfield_widget.dart';
import 'package:path/path.dart';
import 'package:movie_tracker_app/database/database_methods.dart';
import 'package:movie_tracker_app/uservariables.dart';
import "profile_screen.dart";
import 'package:firebase_storage/firebase_storage.dart';

class EditProfilePage extends StatefulWidget {
  @override

  _EditProfilePageState createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  String name = "";
  String email = "";
  String imagePath = "";
  String about = "";
  String newAbout = "";
  File? _photo;
  FirebaseStorage storage = FirebaseStorage.instance;

  TextEditingController _emailController = TextEditingController();
  TextEditingController _nameController = TextEditingController();
  TextEditingController _aboutController = TextEditingController();
  @override
  void initState() {
    name =  UserVariables.myName;
    email = UserVariables.myEmail;
    imagePath = UserVariables.imagePath;
    about = UserVariables.about;
    super.initState();
  }

  Future uploadFile() async {
    if (_photo == null) return;
    final fileName = basename(_photo!.path);
    final destination = 'files/$fileName';
    print("fileName = " + fileName);
    print("destination = " + destination);

    try {
      final ref = storage
          .ref(destination)
          .child('file/');
      await ref.putFile(_photo!);
      final url = "https://firebasestorage.googleapis.com/v0/b/movietracker-59b7e.appspot.com/o/files%2F"+fileName+"%2Ffile?alt=media&token=20211ab3-d0d7-4609-bc27-a12313103c24";
      await DatabaseMethods().setImagePath(UserVariables.userId, url);
    } catch (e) {
      print('error occured');
    }
  }

  @override
  Widget build(BuildContext context) {
    about = UserVariables.about;
    return Scaffold(
      appBar: buildAppBar(context),
      body: ListView(
        padding: EdgeInsets.symmetric(horizontal: 32),
        physics: BouncingScrollPhysics(),
        children: <Widget>[
          ProfileWidget(
            imagePath: imagePath,
            isEdit: true,
            onClicked: () async {
              final pickedFile = await ImagePicker().pickImage(source: ImageSource.gallery);
              setState(() {
                if (pickedFile != null) {
                  _photo = File(pickedFile.path);
                  uploadFile();
                } else {
                  print('No image selected.');
                }
              });


              setState(() {

              });
             /* setState(()  =>
                  DatabaseMethods().setImagePath(
                      UserVariables.userId, newImage.path));*/
            },
          ),
          const SizedBox(height: 24),
          TextField(
            controller: _nameController,
            keyboardType: TextInputType.name,
            decoration:  InputDecoration(
              hintText: "Name: " + name,
            ),
          ),
          const SizedBox(height: 24),
          TextField(
            controller: _emailController,
            keyboardType: TextInputType.emailAddress,
            decoration: InputDecoration(
              hintText: "Email: " + email,
            ),
          ),
          const SizedBox(height: 24),
          TextField(
            controller: _aboutController,
            decoration: InputDecoration(
              hintText: "About: " + about,
            ),
          ),
          const SizedBox(height: 24),
          ButtonWidget(
            text: 'Save',
            onClicked: () async {
              //UserPreferences.setUser(user);
              print("SAVINGGGG ----"+ _aboutController.text);
              if (_nameController.text != ""){
                await DatabaseMethods().setName(UserVariables.userId, _nameController.text);
              }
              if (_emailController.text != ""){
                await DatabaseMethods().setEmail(UserVariables.userId, _emailController.text);
              }
              if (_aboutController.text != ""){
                await DatabaseMethods().setAbout(UserVariables.userId, _aboutController.text);
              }
              Navigator.of(context).pop();
              Navigator.of(context).push(
                MaterialPageRoute(builder: (context) => ProfileScreen(themeColor: Theme.of(context).colorScheme.primary)),
              );
            },
          ),
        ],
      ),
    );
  }
}