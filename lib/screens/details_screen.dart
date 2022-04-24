import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:movie_tracker_app/model/movie_details.dart';
import 'package:movie_tracker_app/services/movie.dart';
import 'package:movie_tracker_app/utils/constants.dart';
import 'package:movie_tracker_app/widgets/custom_loading_spin_kit_ring.dart';
import 'package:share/share.dart';
import 'package:sizer/sizer.dart';
import 'package:movie_tracker_app/utils/star_calculator.dart'
as starCalculator;
import 'package:movie_tracker_app/utils/file_manager.dart' as file;
import 'package:movie_tracker_app/utils/toast_alert.dart' as alert;
import 'package:cloud_firestore/cloud_firestore.dart';
import "package:movie_tracker_app/uservariables.dart";
import "package:movie_tracker_app/database/database_methods.dart";
import 'comment_screen.dart';


class DetailsScreen extends StatefulWidget {
  final String id;
  final Color themeColor;
  DetailsScreen({required this.id, required this.themeColor});
  @override
  _DetailsScreenState createState() => _DetailsScreenState();

  Future<MovieDetails> getMovieDetails() async {
    MovieModel movieModel = MovieModel();
    MovieDetails temp = await movieModel.getMovieDetails(movieID: id);
    return temp;
  }
}

class _DetailsScreenState extends State<DetailsScreen> {
  MovieDetails? movieDetails;
  List<Widget>? stars;
  bool isFavorite = false;

  @override
  void initState() {
    super.initState();
        () async {
      MovieDetails temp = await widget.getMovieDetails();
      List<Widget> temp2 =
      starCalculator.getStars(rating: temp.rating, starSize: 15.sp);

      setState(() {
        isFavorite = temp.isFavorite;
        movieDetails = temp;
        stars = temp2;
      });
    }();
  }

  saveFavorite() async {
    await DatabaseMethods().addFavorite(UserVariables.userId, widget.id);
      alert.toastAlert(
        message: kFavoriteAddedText,
        themeColor: widget.themeColor,
      );

    setState(() {
      isFavorite = true;
    });
  }

  removeFavorite() async {
    if (await file.removeFavorite(movieID: widget.id)) {
      alert.toastAlert(
        message: kFavoriteRemovedText,
        themeColor: widget.themeColor,
      );
    }
    setState(() {
      isFavorite = false;
    });
  }

  TextEditingController commentController = new TextEditingController();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: (stars == null)
            ? CustomLoadingSpinKitRing(loadingColor: widget.themeColor)
            : CustomScrollView(
          slivers: [
            SliverAppBar(
              shadowColor: Colors.transparent,
              leading: Padding(
                padding: EdgeInsets.only(left: 3.w),
                child: IconButton(
                  icon: Icon(Icons.arrow_back_ios),
                  onPressed: () {
                    Navigator.pop(context);
                  },
                ),
              ),
              automaticallyImplyLeading: false,
              pinned: true,
              snap: false,
              floating: false,
              expandedHeight: 22.0.h,
              actions: [
                Padding(
                  padding: EdgeInsets.only(right: 3.w),
                  child: IconButton(
                    onPressed: () {
                      setState(() {
                        (!isFavorite) ? saveFavorite() : removeFavorite();
                      });
                    },
                    icon: Icon((isFavorite)
                        ? Icons.bookmark_sharp
                        : Icons.bookmark_border_sharp),
                  ),
                ),
              ],
              flexibleSpace: FlexibleSpaceBar(
                centerTitle: true,
                title: Text(kDetailsScreenTitleText),
                background: SafeArea(
                  child: CachedNetworkImage(
                    fit: BoxFit.cover,
                    placeholder: (context, url) => SafeArea(
                      child: Container(
                        height: 22.h,
                        child: CustomLoadingSpinKitRing(
                            loadingColor: widget.themeColor),
                      ),
                    ),
                    imageUrl: movieDetails!.backgroundURL,
                    errorWidget: (context, url, error) => SafeArea(
                      child: Container(
                        height: 22.h,
                        child: CustomLoadingSpinKitRing(
                            loadingColor: widget.themeColor),
                      ),
                    ),
                  ),
                ),
              ),
            ),
            SliverFillRemaining(
              child: Column(
                children: [
                Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                SizedBox(
                height: 4.h,
              ),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 4.h),
                child: Wrap(
                  children: [
                    Text(
                      "${movieDetails!.title} ",
                      style: kDetailScreenBoldTitle,
                    ),
                    Text(
                      (movieDetails!.year == "")
                          ? ""
                          : "(${movieDetails!.year})",
                      style: kDetailScreenRegularTitle,
                    )
                  ],
                ),
              ),
              SizedBox(height: 1.h),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 4.h),
                child: Row(children: stars!),
              ),
              SizedBox(height: 3.h),
              SingleChildScrollView(
                physics: BouncingScrollPhysics(),
                scrollDirection: Axis.horizontal,
                child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 3.h),
                    child:
                    Row(children: movieDetails!.getGenresList()),
              ),
            ),
            SizedBox(height: 1.h),
          ],
        ),
        if (movieDetails!.overview != "")
    Expanded(
      child: Padding(
        padding: EdgeInsets.symmetric(
            horizontal: 3.h, vertical: 3.h),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: EdgeInsets.only(
                right: 1.h,
                left: 1.h,
                bottom: 1.h,
              ),
              child: Container(
                child: Text(kStoryLineTitleText,
                    style: kSmallTitleTextStyle),
              ),
            ),

            Expanded(
              child: Padding(
                padding: EdgeInsets.only(
                    right: 1.h,
                    left: 1.h,
                    top: 1.h,
                    bottom: 4.h),
                child: Text(
                  movieDetails!.overview,
                  style: TextStyle(
                      fontSize: 16.sp,
                      color: Color(0xFFC9C9C9)),
                ),
              ),
            ),
            /*CommentBox(
              userImage: UserVariables.imagePath,
              labelText: 'Write a comment...',
              withBorder: false,
              errorText: 'Comment cannot be blank',
              sendButtonMethod: () {

              },
              commentController: commentController,
              backgroundColor: Colors.black,
              textColor: Colors.white,
              sendWidget: Icon(Icons.send_sharp, size: 30, color: Colors.white),

            ),*/
          ],
        ),
      ),
    ),
    ],
    ),
    )
    ],
    ),
        floatingActionButton: Column(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              FloatingActionButton(
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(builder: (context) => CommentScreen(movieId: widget.id)),
                  );

                },
                child: const Icon(Icons.comment),
                backgroundColor: Colors.white,
              ),
              SizedBox(
                height: 10,
              ),
              FloatingActionButton(
                onPressed: () {
                  Share.share(
                      '${movieDetails!.title}, Follow the link https://www.themoviedb.org/movie/' +
                          movieDetails!.id.toString());
                },
                child: const Icon(Icons.share),
                backgroundColor: Colors.white,
              )
            ]
        )
    );
  }
}