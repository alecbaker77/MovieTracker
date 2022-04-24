import 'package:flutter/material.dart';
import 'package:movie_tracker_app/screens/drawer_screen.dart';
import 'package:movie_tracker_app/screens/finder_screen.dart';
import 'package:movie_tracker_app/utils/constants.dart';
import 'package:movie_tracker_app/utils/file_manager.dart' as file;
import 'package:movie_tracker_app/utils/navi.dart' as navi;
import 'package:movie_tracker_app/utils/scroll_top_with_controller.dart'
    as scrollTop;
import 'package:movie_tracker_app/utils/toast_alert.dart' as alert;
import 'package:movie_tracker_app/widgets/bottom_navigation.dart';
import 'package:movie_tracker_app/widgets/bottom_navigation_item.dart';
import 'package:movie_tracker_app/widgets/custom_loading_spin_kit_ring.dart';
import 'package:movie_tracker_app/widgets/custom_main_appbar_content.dart';
import 'package:movie_tracker_app/widgets/movie_card.dart';
import 'package:movie_tracker_app/widgets/movie_card_container.dart';
import 'package:movie_tracker_app/widgets/shadowless_floating_button.dart';
import 'package:sizer/sizer.dart';
import 'package:movie_tracker_app/services/movie.dart';
import 'package:movie_tracker_app/database/database_methods.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:movie_tracker_app/uservariables.dart';
import "profile_screen.dart";
import 'package:movie_tracker_app/utils/transition_variables.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  HomeScreenState createState() => HomeScreenState();
}

class HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
  //for custom drawer opening
  GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();

  //for scroll upping
  ScrollController? _scrollController;

  bool showBackToTopButton = false;

  Color? themeColor;

  int? activeInnerPageIndex;

  List<MovieCard>? _movieCards;

  bool showSlider = true;
  String title = kHomeScreenTitleText;
  int bottomBarIndex = 1;

  Future<void> loadData() async {
    MovieModel movieModel = MovieModel();
    _movieCards = (bottomBarIndex == 1)
        ? await movieModel.getMovies(
            moviesType: MoviePageType.values[activeInnerPageIndex!],
            themeColor: themeColor!)
        : await movieModel.getFavorites(
            themeColor: themeColor!, bottomBarIndex: bottomBarIndex);
    setState(() {
      scrollTop.scrollToTop(_scrollController!);
      showBackToTopButton = false;
    });
  }

  void pageSwitcher(int index) {
    setState(() {
      bottomBarIndex = (index == 2) ? 2 : 1;
      title = (index == 2) ? kFavoriteScreenTitleText : kHomeScreenTitleText;
      showSlider = !(index == 2);
      _movieCards = null;
      loadData();
    });
  }

  void movieCategorySwitcher(int index) {
    setState(() {
      activeInnerPageIndex = index;
      _movieCards = null;
      loadData();
    });
  }

  getUserInfo() async {
    print("trying");
    DatabaseMethods databaseMethods = new DatabaseMethods();
    final FirebaseAuth auth = FirebaseAuth.instance;
    User? user = auth.currentUser;
    if (user != null) {
      UserVariables.myName = await databaseMethods.getName(user.uid);
      UserVariables.myEmail = await databaseMethods.getEmail(user.uid);
      UserVariables.imagePath = await databaseMethods.getImagePath(user.uid);
      UserVariables.about = await databaseMethods.getAbout(user.uid);
      UserVariables.subscriptionCount = await databaseMethods.getSubscriptionCount(user.uid).toString();
      UserVariables.userId = user.uid;
    }
    print(UserVariables.myName);
  }

  @override
  void initState() {
    getUserInfo();
    super.initState();
    () async {
      themeColor = await file.currentTheme();
      print(themeColor);
      _scrollController = ScrollController()
        ..addListener(() {
          setState(() {
            showBackToTopButton = (_scrollController!.offset >= 200);
          });
        });
      int transitionVar = TransitionVariables.index;
      if (transitionVar != 9){
        pageSwitcher(transitionVar);

      }
      activeInnerPageIndex = 0;
      setState(() {
        loadData();
      });

    }();
  }

  @override
  void dispose() {
    if (_scrollController != null) _scrollController!.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return (themeColor == null)
        ? CustomLoadingSpinKitRing(loadingColor: themeColor)
        : Scaffold(
            key: _scaffoldKey,
            appBar: AppBar(
              automaticallyImplyLeading: false,
              backgroundColor: kAppBarColor,
              shadowColor: Colors.transparent,
              bottom: PreferredSize(
                child: CustomMainAppBarContent(
                  showSlider: showSlider,
                  title: title,
                  activeButtonIndex: activeInnerPageIndex!,
                  activeColor: themeColor!,
                  buttonFistOnPressed: (index) => movieCategorySwitcher(index),
                  buttonSecondOnPressed: (index) =>
                      movieCategorySwitcher(index),
                  buttonThirdOnPressed: (index) => movieCategorySwitcher(index),
                  searchOnPressed: () => navi.newScreen(
                    context: context,
                    newScreen: () => FinderScreen(
                      themeColor: themeColor!,
                    ),
                  ),
                ),
                preferredSize:
                    Size.fromHeight((bottomBarIndex == 1) ? 16.0.h : 7.h),
              ),
            ),
            body: (_movieCards == null)
                ? CustomLoadingSpinKitRing(loadingColor: themeColor)
                : (_movieCards!.length == 0)
                    ? Center(child: Text(k404Text))
                    : MovieCardContainer(
                        scrollController: _scrollController!,
                        themeColor: themeColor!,
                        movieCards: _movieCards!,
                      ),
            bottomNavigationBar: BottomNavigation(
              activeColor: themeColor!,
              index: bottomBarIndex,
              children: [
                BottomNavigationItem(
                  icon: Icon(Icons.more_horiz),
                  iconSize: 35.sp,
                  onPressed: () => _scaffoldKey.currentState!.openDrawer(),
                ),
                BottomNavigationItem(
                  icon: Icon(Icons.videocam),
                  iconSize: 28.sp,
                  onPressed: () {
                    pageSwitcher(1);
                  },
                ),
                BottomNavigationItem(
                    icon: Icon(Icons.bookmark_sharp),
                    iconSize: 23.sp,
                    onPressed: () {
                      pageSwitcher(2);
                    }
                    ),
                BottomNavigationItem(
                  icon: Icon(Icons.person_pin),
                  iconSize: 28.sp,
                  onPressed: () => navi.newScreen(
                    context: context,
                    newScreen: () => ProfileScreen(
                      themeColor: themeColor!,
                    ),
                  ),
                ),
              ],
            ),
            drawerEnableOpenDragGesture: false,
            drawer: DrawerScreen(colorChanged: (color) {
              themeColor = color;
              setState(() {
                alert.toastAlert(
                    message: kAppliedTheme, themeColor: themeColor);
              });
            }),
            floatingActionButton: showBackToTopButton
                ? ShadowlessFloatingButton(
                    iconData: Icons.keyboard_arrow_up_outlined,
                    onPressed: () {
                      setState(() {
                        scrollTop.scrollToTop(_scrollController!);
                      });
                    },
                    backgroundColor: themeColor,
                  )
                : null,
          );
  }
}
