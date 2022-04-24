import 'package:flutter/material.dart';
import 'package:movie_tracker_app/database/database_methods.dart';
import 'package:movie_tracker_app/utils/scroll_top_with_controller.dart'
    as scrollTop;
import 'package:movie_tracker_app/widgets/appbar_widget.dart';
import 'package:movie_tracker_app/widgets/profile_widget.dart';
import 'edit_profile_page.dart';
import 'package:movie_tracker_app/widgets/numbers_widget.dart';
import 'package:movie_tracker_app/uservariables.dart';
import 'package:movie_tracker_app/screens/home_screen.dart';
import 'package:movie_tracker_app/utils/transition_variables.dart';

class ProfileScreen extends StatefulWidget {
  final Color themeColor;

  ProfileScreen({required this.themeColor});

  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  String name = "";
  String email = "";
  String imagePath = "";
  String about = "";
  String textFieldValue = "";
  String subscriptionCount = "";

  //for scroll uppingl;
  late ScrollController _scrollController;
  bool showBackToTopButton = false;

  bool showLoadingScreen = false;

  Future<void> loadData(String movieName) async {
    setState(() {
      scrollTop.scrollToTop(_scrollController);
    });
  }

  @override
  void initState() {
    subscriptionCount = UserVariables.subscriptionCount;
    name = UserVariables.myName;
    email = UserVariables.myEmail;
    imagePath = UserVariables.imagePath;
    about = UserVariables.about;
    super.initState();
    _scrollController = ScrollController()
      ..addListener(() {
        setState(() {
          showBackToTopButton = (_scrollController.offset >= 200);
        });
      });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    name = UserVariables.myName;
    email = UserVariables.myEmail;
    imagePath = UserVariables.imagePath;
    about = UserVariables.about;
    if (about == "") {
      about = "Edit your profile to add a Bio";
    }
    subscriptionCount = UserVariables.subscriptionCount;
    return Scaffold(
      appBar: buildAppBar(context),
      body: ListView(
        physics: BouncingScrollPhysics(),
        children: [
          ProfileWidget(
            imagePath: imagePath,
            onClicked: () {
              Navigator.of(context).pop();
              Navigator.of(context).push(
                MaterialPageRoute(builder: (context) => EditProfilePage()),
              );
            },
          ),
          const SizedBox(height: 24),
          buildName(name, email),
          const SizedBox(height: 14),
          MaterialButton(
            padding: EdgeInsets.symmetric(vertical: 4),
            onPressed: () {
              TransitionVariables.index = 2;
              Navigator.of(context).pushReplacement(
                MaterialPageRoute(
                    builder: (context) => HomeScreen())
            );},
            materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.start,
              children: <Widget>[
                Text(
                  UserVariables.subscriptionCount,
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 24),
                ),
                SizedBox(height: 2),
                Text(
                  "Subscriptions",
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          buildAbout(about),
        ],
      ),
    );
  }

  Widget buildName(name, email) => Column(
        children: [
          Text(
            name,
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 24),
          ),
          const SizedBox(height: 4),
          Text(
            email,
            style: TextStyle(color: Colors.grey),
          )
        ],
      );

  Widget buildAbout(about) => Container(
        padding: EdgeInsets.symmetric(horizontal: 48),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'About',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Text(
              about,
              style: TextStyle(fontSize: 16, height: 1.4),
            ),
          ],
        ),
      );
}
