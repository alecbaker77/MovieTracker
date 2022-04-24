//import 'dart:html';

import 'package:comment_box/comment/comment.dart';
import 'package:flutter/material.dart';
import 'package:movie_tracker_app/database/database_methods.dart';
import 'package:movie_tracker_app/uservariables.dart';

class CommentScreen extends StatefulWidget {
  @override
  String movieId = "";
  CommentScreen({
    required this.movieId,
  });
  _CommentScreenState createState() => _CommentScreenState();
}

class _CommentScreenState extends State<CommentScreen> {



  final formKey = GlobalKey<FormState>();
  final TextEditingController commentController = TextEditingController();
  List filedata = [];

  Future<List> getListData() async{
    print("GETTING LIST DATA -- movieid = " + widget.movieId);
    filedata =  await DatabaseMethods().getMovieComments(widget.movieId);
    return filedata;
  }

 /* @override
  void initState() {
    getListData();
  }*/

  Widget commentChild(data) {
    return ListView(
      children: [
        for (var i = 0; i < data.length; i++)
          Padding(
            padding: const EdgeInsets.fromLTRB(2.0, 8.0, 2.0, 0.0),
            child: ListTile(
              leading: GestureDetector(
                onTap: () async {
                  // Display the image in large form.
                  print("Comment Clicked");
                },
                child: Container(
                  height: 50.0,
                  width: 50.0,
                  decoration: new BoxDecoration(
                      color: Colors.blue,
                      borderRadius: new BorderRadius.all(Radius.circular(50))),
                  child: CircleAvatar(
                      radius: 50,
                      backgroundImage: NetworkImage(data[i]['pic'])),
                ),
              ),
              title: Text(
                data[i]['name'],
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              subtitle: Text(data[i]['message']),
            ),
          )
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        future: getListData(),
        builder: (context, AsyncSnapshot snapshot) {
         if (snapshot.hasData) {
            return  Scaffold(
              appBar: AppBar(
                title: Text("Comment Page"),
                backgroundColor: Colors.pink,
              ),
              body: Container(
                child: CommentBox(
                  userImage:
                  UserVariables.imagePath,
                  child: commentChild(filedata),
                  labelText: 'Write a comment...',
                  withBorder: false,
                  errorText: 'Comment cannot be blank',
                  sendButtonMethod: () async {
                    if (formKey.currentState!.validate()) {
                      print(commentController.text);
                      setState(() {
                        var value = {
                          'name': UserVariables.myName,
                          'pic': UserVariables.imagePath,
                          'message': commentController.text
                        };

                        //add comment to firebase
                        DatabaseMethods().addMovieComment(commentController.text, widget.movieId, UserVariables.userId);
                        filedata.insert(0, value);
                      });
                      commentController.clear();
                      FocusScope.of(context).unfocus();
                    } else {
                      print("Not validated");
                    }
                  },
                  formKey: formKey,
                  commentController: commentController,
                  backgroundColor: Colors.black,
                  textColor: Colors.white,
                  sendWidget: Icon(Icons.send_sharp, size: 30, color: Colors.white),
                ),
              ),
            );
          } else {
            return CircularProgressIndicator();
          }
        }
    );
  }
}