import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:depflow_ai_app/entities/entity_tweet.dart';
import 'package:depflow_ai_app/utilities/depflow_model_manager.dart';
import 'package:depflow_ai_app/utilities/twitter_manager.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher_string.dart';

class TabProfile extends StatefulWidget {

  final TwitterManager twitterManager;

  const TabProfile({super.key, required this.twitterManager});

  @override
  State<TabProfile> createState() => _TabProfileState();
}

class _TabProfileState extends State<TabProfile> {

  FirebaseAuth auth = FirebaseAuth.instance;
  FirebaseFirestore firestore = FirebaseFirestore.instance;

  String _profilePhotoURL = "https://upload.wikimedia.org/wikipedia/commons/7/7c/Profile_avatar_placeholder_large.png";
  String _profileNamme = "No Name Guy";

  String _twitterUsername = "@realRusiru";
  String _twitterDepressiveCount = "0";

  bool _isDepressive = false;

  List<Tweet> feedTweets = [];

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisSize: MainAxisSize.max,
      children: [
        Container(
          width: MediaQuery.of(context).size.width,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisSize: MainAxisSize.max,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(50),
                child: Image.network(
                  _profilePhotoURL,
                  width: 100,
                  height: 100,
                  fit: BoxFit.cover,
                  loadingBuilder: (context, child, loadingProgress) {
                    if (loadingProgress == null) {
                      return child;
                    }
                    return const Center(
                      child: CircularProgressIndicator(),
                    );
                  },
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(12),
                child: Text(
                  _profileNamme,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: ElevatedButton.icon(
                  onPressed: () {
                    auth.signOut();
                  },
                  icon: const Icon(Icons.logout),
                  label: const Text("Sign Out"),
                ),
              ),
              Container(
                decoration: const BoxDecoration(
                  color: Color(0xFFD8E7C5),
                ),
                padding: const EdgeInsets.all(12),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisSize: MainAxisSize.max,
                  children: [
                    Expanded(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisSize: MainAxisSize.max,
                        children: [
                          InkWell(
                            child: Text(
                              _twitterUsername,
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            onTap: () {
                              launchUrlString("https://twitter.com/$_twitterUsername");
                            },
                          ),
                          const Text("Tweeter Username"),
                        ],
                      ),
                    ),
                    Expanded(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisSize: MainAxisSize.max,
                        children: [
                          Text(
                            _twitterDepressiveCount,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const Text("Depressive Tweets\nDetected", textAlign: TextAlign.center,),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12,),
              Row(
                mainAxisSize: MainAxisSize.max,
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    "Your Depressive Tweets",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(left: 12),
                    child: ElevatedButton.icon(
                      onPressed: loadMyField,
                      label: const Text("Refresh"),
                      icon: const Icon(Icons.refresh),
                    ),
                  ),
                ],
              ),
              AnimatedCrossFade(
                duration: const Duration(milliseconds: 500),
                firstChild:  Padding(
                  padding: const EdgeInsets.only(top: 12, left: 12, right: 12),
                  child: Container(
                    decoration: const BoxDecoration(
                      color: Color(0xFFffcccc),
                      borderRadius: BorderRadius.all(Radius.circular(12)),
                    ),
                    padding: const EdgeInsets.all(12),
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisSize: MainAxisSize.max,
                        children: [
                          const Icon(Icons.warning_rounded, color: Colors.black, size: 30,),
                          const SizedBox(height: 4,),
                          Text(
                            "We have detected $_twitterDepressiveCount depressive tweets",
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 2,),
                          const Text(
                            "We want to encourage you to seek help. It's okay to not\n feel okay,"
                                " and you don't have to go through this alone.",
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 14,
                            ),
                          ),
                          const SizedBox(height: 4,),
                          const Text(
                            "We like to suggest you some resources to help you get\n through this tough time.",
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8,),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            mainAxisSize: MainAxisSize.max,
                            children: [
                              TextButton.icon(
                                onPressed: () {
                                  launchUrlString("https://www.mentalhealth.gov/get-help/immediate-help");
                                },
                                icon: const Icon(Icons.phone),
                                label: const Text("Call"),
                                style: TextButton.styleFrom(
                                  primary: Colors.black,
                                )
                              ),
                              TextButton.icon(
                                onPressed: () {
                                  launchUrlString("https://www.mentalhealth.gov/get-help/urgent-care");
                                },
                                icon: const Icon(Icons.chat),
                                label: const Text("Chat"),
                                style: TextButton.styleFrom(
                                  primary: Colors.black,
                                )
                              ),
                              TextButton.icon(
                                onPressed: () {
                                  launchUrlString("https://www.mentalhealth.gov/get-help/helping-someone");
                                },
                                icon: const Icon(Icons.people),
                                label: const Text("Help"),
                                style: TextButton.styleFrom(
                                  primary: Colors.black,
                                )
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                secondChild: const SizedBox(height: 0,),
                crossFadeState: _isDepressive ? CrossFadeState.showFirst : CrossFadeState.showSecond,
              ),
              Padding(
                padding: const EdgeInsets.only(top: 12, left: 12, right: 12),
                child: ListView.separated(
                  itemCount: feedTweets.length,
                  itemBuilder: (context, index) {
                    return ListTile(
                      title: Text(feedTweets[index].text),
                      subtitle: Text(feedTweets[index].author),
                      trailing: Icon(Icons.flag, color: feedTweets[index].isDepressive ? Colors.red : Colors.grey,),
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

  @override
  void initState() {
    super.initState();
    loadProfileDetails();
  }

  void loadProfileDetails() {
    auth.currentUser!.reload();
    setState(() {
      _profilePhotoURL = auth.currentUser!.photoURL!;
      _profileNamme = auth.currentUser!.displayName!;
    });
  }

  void loadMyField() async {
    var latestTweets = await widget.twitterManager.loadMyLatestTweets();

    String usernameResponse = await widget.twitterManager.getTwitterUsername();

    setState(() {
      _twitterUsername = usernameResponse;
    });

    setState(() {
      feedTweets.clear();
      _twitterDepressiveCount = 0.toString();
    });

    if (int.parse(_twitterDepressiveCount) > 0) {
      setState(() {
        _isDepressive = true;
      });
    } else {
      setState(() {
        _isDepressive = false;
      });
    }

    DepFlowModelManager depFlowModelManager = DepFlowModelManager(twitterManager: widget.twitterManager);
    FirebaseAuth auth = FirebaseAuth.instance;

    Map<String, dynamic> jsonPayload = {
      "user": {
        "userid": auth.currentUser!.uid,
      },
    };

    List<dynamic> preparedData = [];

    for (var tweet in latestTweets) {
      preparedData.add(
          {
            "post_id": tweet.id,
            "post_value": widget.twitterManager.getCleanedStrings(tweet.text),
          }
      );
    }

    jsonPayload.addAll({"posts": preparedData});

    var response = await depFlowModelManager.getDepressive(jsonPayload);

    response.forEach((element) async {
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
        feedTweets.add(Tweet(
          id: postid,
          text: text,
          url: "https://twitter.com/@$author/status/$postid",
          author: "@$author",
          isDepressive: element["label"] == "depressive",
        ));
      });
      if (element["label"] == "depressive") {
        setState(() {
          _twitterDepressiveCount = (int.parse(_twitterDepressiveCount) + 1).toString();
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
          if (value.data()!.containsKey("users")) {
            Map<String, dynamic> currentData = value.data()!["users"];

            if (currentData.containsKey(today)) {
              currentData[today] = int.parse(_twitterDepressiveCount);
            } else {
              currentData.addAll({today: int.parse(_twitterDepressiveCount)});
            }

            try {
              _collectionRef.doc(auth.currentUser!.uid).set(
                  {'users': currentData}, SetOptions(merge: true));
              print('Data saved successfully!');
            } catch (e) {
              print('Error saving data: $e');
            }
          } else {
            Map<String, dynamic> user = {
              today: int.parse(_twitterDepressiveCount),
            };
            try {
              _collectionRef.doc(auth.currentUser!.uid).set({'users': user}, SetOptions(merge: true));
              print('Data saved successfully!');
            } catch (e) {
              print('Error saving data: $e');
            }
          }
        } else {
          Map<String, dynamic> user = {
            today: int.parse(_twitterDepressiveCount),
          };
          try {
            _collectionRef.doc(auth.currentUser!.uid).set({'user': user}, SetOptions(merge: true));
            print('Data saved successfully!');
          } catch (e) {
            print('Error saving data: $e');
          }
        }
      });

      if (int.parse(_twitterDepressiveCount) > 0) {
        setState(() {
          _isDepressive = true;
        });
      } else {
        setState(() {
          _isDepressive = false;
        });
      }
    });
  }
}