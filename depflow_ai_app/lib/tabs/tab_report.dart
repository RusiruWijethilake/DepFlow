import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:depflow_ai_app/entities/entity_follower.dart';
import 'package:depflow_ai_app/entities/entity_tweet.dart';
import 'package:depflow_ai_app/theme/app_colors.dart';
import 'package:depflow_ai_app/utilities/depflow_model_manager.dart';
import 'package:depflow_ai_app/utilities/twitter_manager.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:icons_plus/icons_plus.dart';
import 'package:intl/intl.dart';
import 'package:twitter_api_v2/twitter_api_v2.dart';
import 'package:url_launcher/url_launcher_string.dart';

class TabFind extends StatefulWidget {

  final TwitterManager twitterManager;

  TabFind({super.key, required this.twitterManager});

  @override
  State<TabFind> createState() => _TabFindState();
}

class _TabFindState extends State<TabFind> {

  FirebaseAuth auth = FirebaseAuth.instance;
  FirebaseFirestore firestore = FirebaseFirestore.instance;

  List<Tweet> feedTweets = [];

  String helpMessage = "Hey, I saw that you are feeling depressed."
      " I am here to for you. Please let me know if you need help."
      " If you are looking for help, checkout this website: https://www.mentalhealth.gov/get-help/immediate-help";

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisSize: MainAxisSize.max,
      children: [
        SizedBox(
          width: MediaQuery.of(context).size.width,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisSize: MainAxisSize.max,
            children: [
              const Padding(
                padding: EdgeInsets.only(top: 8),
                child: Text(
                  "Friends Depressive Tweets",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                )
              ),
              Padding(
                padding: const EdgeInsets.only(top: 8, bottom: 12),
                child: ElevatedButton.icon(
                  onPressed: loadFriends,
                  label: const Text("Refresh"),
                  icon: const Icon(Icons.refresh),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(top: 12, left: 12, right: 12),
                child: ListView.separated(
                  itemCount: feedTweets.length,
                  itemBuilder: (context, index) {
                    return ListTile(
                      title: Text(feedTweets[index].text),
                      subtitle: Text(feedTweets[index].author),
                      trailing: IconButton(
                        onPressed: () {
                          showModalBottomSheet(
                            context: context,
                            builder: (context) {
                              return Container(
                                padding: const EdgeInsets.all(24),
                                child: Column(
                                  mainAxisSize: MainAxisSize.max,
                                  children: [
                                    const Text("Help your friend!", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                                    const SizedBox(height: 12),
                                    Text(
                                      "We have detected that your friend ${feedTweets[index].author} is feeling depressed."
                                          " Would you like to send them a message?",
                                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w300),
                                      textAlign: TextAlign.center,
                                    ),
                                    const SizedBox(height: 12),
                                    Container(
                                      padding: const EdgeInsets.all(12),
                                      margin: const EdgeInsets.only(left: 12, right: 12),
                                      decoration: BoxDecoration(
                                        color: Colors.lightGreen,
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: Column(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        crossAxisAlignment: CrossAxisAlignment.center,
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          const Text(
                                            "Personalized Message For Your Friend",
                                            style: TextStyle(color: Colors.black, fontSize: 16, fontWeight: FontWeight.bold),
                                          ),
                                          const Padding(
                                            padding: EdgeInsets.only(top: 4),
                                            child: Divider(color: Colors.black),
                                          ),
                                          Text(
                                            helpMessage,
                                            style: const TextStyle(color: Colors.black, fontSize: 16, fontWeight: FontWeight.w300),
                                            textAlign: TextAlign.center,
                                          ),
                                        ],
                                      ),
                                    ),
                                    const SizedBox(height: 12),
                                    ElevatedButton.icon(
                                      onPressed: () async {
                                        launchUrlString("https://twitter.com/messages/compose?recipient_id=${feedTweets[index].authorid}&text=${helpMessage.replaceAll(" ", "%20")}");
                                        Navigator.pop(context);
                                      },
                                      icon: const Icon(FontAwesome.twitter),
                                      label: const Text("Send a message"),
                                    ),
                                  ],
                                )
                              );
                            },
                            enableDrag: false,
                          );
                        },
                        icon: const Icon(FontAwesome.hand_holding_medical, color: Colors.lightGreen),
                      ),
                      visualDensity: VisualDensity.compact,
                    );
                  },
                  shrinkWrap: true,
                  separatorBuilder: (BuildContext context, int index) {
                    return const Padding(
                      padding: EdgeInsets.only(top: 8, bottom: 8),
                      child: Divider(
                        color: Colors.grey,
                        height: 1,
                      ),
                    );
                  },
                  physics: const NeverScrollableScrollPhysics(),
                ),
              )
            ],
          ),
        ),
      ],
    );
  }

  void loadFriends() async {
    var latestTweets = await widget.twitterManager.loadLatestTweets();

    setState(() {
      feedTweets.clear();
    });

    DepFlowModelManager depFlowModelManager = DepFlowModelManager(twitterManager: widget.twitterManager);
    FirebaseAuth auth = FirebaseAuth.instance;

    Map<String, dynamic> jsonPayload = {
      "user": {
        "userid": auth.currentUser!.uid,
      },
    };

    List<dynamic> preparedData = [];

    for (var tweet in latestTweets) {
      print(widget.twitterManager.getCleanedStrings(tweet.text));
      preparedData.add(
        {
          "post_id": tweet.id,
          "post_value": widget.twitterManager.getCleanedStrings(tweet.text),
        }
      );
    }

    jsonPayload.addAll({"posts": preparedData});

    var response = await depFlowModelManager.getDepressive(jsonPayload);

    List<Tweet> filteredTweets = [];

    final me = await widget.twitterManager.twitter!.users.lookupMe();

    response.forEach((element) async {
      if (element["label"] == "depressive") {
        String postid = element["post_id"];

        String? text = latestTweets.firstWhere((element) => element.id == postid).text;
        String? authorid = latestTweets.firstWhere((element) => element.id == postid).authorId;
        String author = "";

        if (authorid == null) {
          author = "Unknown";
        } else {
          var response = await widget.twitterManager.twitter!.users.lookupById(userId: authorid);
          author = response.data.username;
        }

        setState(() {
          if (authorid != me.data.id) {
            feedTweets.add(Tweet(
              id: postid,
              text: text,
              url: "https://twitter.com/@$author/status/$postid",
              author: "@$author",
              authorid: authorid ?? "",
            ));
          }
        });

      }

      String today = DateFormat('yyyy-MM-dd').format(DateTime.now());

      firestore.collection("reports").doc(auth.currentUser!.uid).get().then((value) {
        // Define the collection reference
        final CollectionReference<Map<String, dynamic>> _collectionRef =
        firestore.collection('reports').withConverter<Map<String, dynamic>>(
            fromFirestore: (snapshot, _) => snapshot.data()!,
            toFirestore: (value, _) => value);

        if (value.exists) {
          if (value.data()!.containsKey("friends")) {
            Map<String, dynamic> currentData = value.data()!["friends"];

            if (currentData.containsKey(today)) {
              currentData[today] = feedTweets.length;
            } else {
              currentData.addAll({today: feedTweets.length});
            }

            try {
              _collectionRef.doc(auth.currentUser!.uid).set(
                  {'friends': currentData}, SetOptions(merge: true));
              print('Data saved successfully!');
            } catch (e) {
              print('Error saving data: $e');
            }
          } else {
            Map<String, dynamic> user = {
              today: feedTweets.length,
            };
            try {
              _collectionRef.doc(auth.currentUser!.uid).set({'friends': user}, SetOptions(merge: true));
              print('Data saved successfully!');
            } catch (e) {
              print('Error saving data: $e');
            }
          }
        } else {
          Map<String, dynamic> user = {
            today: feedTweets.length,
          };
          try {
            _collectionRef.doc(auth.currentUser!.uid).set({'friends': user}, SetOptions(merge: true));
            print('Data saved successfully!');
          } catch (e) {
            print('Error saving data: $e');
          }
        }
      });

      var tweetLists = feedTweets.map((e) => e.text).toList();

      firestore.collection("reports").doc(auth.currentUser!.uid).set({
        'friendsTweets': tweetLists,
      }, SetOptions(merge: true));
    });
  }

  @override
  void initState() {
    super.initState();
    loadFriends();
  }
}