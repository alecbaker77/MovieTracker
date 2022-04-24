import 'package:cloud_firestore/cloud_firestore.dart';
import "package:movie_tracker_app/uservariables.dart";

class DatabaseMethods {

  getName(String? uid) async {
    var name = "";
    var data;
    await FirebaseFirestore.instance.collection("users").doc(uid).get().then ((DocumentSnapshot ds){
      data = ds.data();
    });
    if(data != null){
      name = data["userName"];
    }
    return name;
  }

  setName(String? uid, name) async {
    UserVariables.myName = name;
    await FirebaseFirestore.instance.collection("users").doc(uid).update({
      "userName": name
    });
  }

  getEmail(String? uid) async {
    var email = "";
    var data;
    await FirebaseFirestore.instance.collection("users").doc(uid).get().then ((DocumentSnapshot ds){
      data = ds.data();
    });
    if(data != null){
      email = data["userEmail"];
    }
    return email;
  }

  setEmail(String? uid, email) async {
    UserVariables.myEmail = email;
    await FirebaseFirestore.instance.collection("users").doc(uid).update({
      "email": email
    });
  }

  updateSubscriptionCount(String? uid, int change) async {
    var currCount = await getSubscriptionCount(uid);
    print("CURRENT SUB COUNT = "+currCount.toString());
    var newCount = currCount + change;
    await FirebaseFirestore.instance.collection("users").doc(uid).update({
      "subscriptionCount": newCount
    });
    UserVariables.subscriptionCount = newCount.toString();
  }

  getSubscriptionCount(String? uid) async {
    var count;
    var data;
    await FirebaseFirestore.instance.collection("users").doc(uid).get().then ((DocumentSnapshot ds){
      data = ds.data();
    });
    if(data != null){
      count = data["subscriptionCount"];
    }
    UserVariables.subscriptionCount = count.toString();
    return count;
  }

  getAbout(String? uid) async {
    var about = "";
    var data;
    await FirebaseFirestore.instance.collection("users").doc(uid).get().then ((DocumentSnapshot ds){
      data = ds.data();
    });
    if(data != null){
      about = data["about"];
    }
    print("GOT ABOUT -- " + about);
    return about;
  }

  setAbout(String? uid, aboutText) async {
    UserVariables.about = aboutText;
    print("SET ABOUT -----" + aboutText);

    await FirebaseFirestore.instance.collection("users").doc(uid).update({
      "about": aboutText
    });
  }

  getImagePath(String? uid) async {
    var email = "";
    var data;
    await FirebaseFirestore.instance.collection("users").doc(uid).get().then ((DocumentSnapshot ds){
      data = ds.data();
    });
    if(data != null){
      email = data["imagePath"];
    }
    return email;
  }

  setImagePath(String? uid, imagePath)  {
    UserVariables.imagePath = imagePath;
     FirebaseFirestore.instance.collection("users").doc(uid).update({
      "imagePath": imagePath
    });
  }


  searchByName(String? searchField) {
    return FirebaseFirestore.instance
        .collection("chatappusers")
        .where('userName', isEqualTo: searchField)
        .get();
  }



  addMovieComment(comment, movieId, userId) async{
    await FirebaseFirestore.instance
        .collection("movieComments")
        .doc(movieId)
        .set({"movieId":movieId});
    await FirebaseFirestore.instance
        .collection("movieComments")
        .doc(movieId)
        .collection("comments")
        .doc(userId.toString())
        .set({"userId": userId.toString()});
    await FirebaseFirestore.instance
        .collection("movieComments")
        .doc(movieId)
        .collection("comments")
        .doc(userId.toString())
        .collection("userComments")
        .doc()
        .set({
          "comment": comment
        }
        )
        .catchError((e) {
      print(e.toString());
    });

  }

  getMovieComments(id) async {
    String movieId = id;
    if(movieId == null || movieId == ""){
      return;
    }
    var collection =  FirebaseFirestore.instance
        .collection("movieComments")
        .doc(movieId)
        .collection("comments");
    QuerySnapshot snapshot = await collection.get();
    var userId = "";
    var name = "";
    var pic = "";
    var message = "";
    var data;
    List comments = [];
    for(int i = 0; i < snapshot.docs.length; i++){
      userId = snapshot.docs[i].id;
      name = await getName(userId);
      pic = await getImagePath(userId);
      var userComments = FirebaseFirestore.instance
          .collection("movieComments")
          .doc(movieId)
          .collection("comments")
          .doc(userId)
          .collection("userComments");
      QuerySnapshot userSnapshot = await userComments.get();
      for(int j = 0; j < userSnapshot.docs.length; j++){
        data = userSnapshot.docs[j].data();
        if(data != null){
          message = data["comment"];
          comments.add(
              {
                'name': name,
                'pic': pic,
                'message': message
              }
          );
        }
      }

    }
    return comments;
  }


  //add movie to users favorites
  addFavorite(userId, movieId) async{
    Map<String, dynamic> favoritesMessageMap = {
      "movieId": movieId
    };
    FirebaseFirestore.instance
        .collection("users")
        .doc(userId)
        .collection("favorites")
        .doc(movieId).set({"movieId": movieId})
        .catchError((e) {
          print(e.toString());
        });
    await updateSubscriptionCount(userId, 1);
  }

  removeFavorite(userId, movieId) async {
    FirebaseFirestore.instance
        .collection("users")
        .doc(userId)
        .collection("favorites")
        .doc(movieId).delete();
    await updateSubscriptionCount(userId, -1);
  }

  getFavorites(userId) async{
      if(userId == null || userId == ""){
        return;
      }
      var collection =  FirebaseFirestore.instance
          .collection("users")
          .doc(userId)
          .collection("favorites");
      QuerySnapshot snapshot = await collection.get();
      List<String> movieIds = [];
      for(int i = 0; i < snapshot.docs.length; i++){
        movieIds.add(snapshot.docs[i].id.toString());
      }
      if(movieIds == null){
        return [" "];
      }
      return movieIds;
  }


}