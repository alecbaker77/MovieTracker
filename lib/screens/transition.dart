import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';
import 'package:movie_tracker_app/utils/constants.dart';
import 'home_screen.dart';


class TransitionPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Sizer(
      builder: (context, orientation, deviceType) {
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'Sizer',
          theme: ThemeData.dark().copyWith(
            platform: TargetPlatform.iOS,
            primaryColor: kPrimaryColor,
            scaffoldBackgroundColor: kPrimaryColor,
          ),
          home: HomeScreen(
            key: kHomeScreenKey,
          ),
        );
      },
    );

  }
}