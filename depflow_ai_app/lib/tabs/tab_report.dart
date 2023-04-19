import 'package:depflow_ai_app/entities/entity_follower.dart';
import 'package:depflow_ai_app/entities/entity_tweet.dart';
import 'package:depflow_ai_app/theme/app_colors.dart';
import 'package:depflow_ai_app/utilities/depflow_model_manager.dart';
import 'package:depflow_ai_app/utilities/twitter_manager.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:icons_plus/icons_plus.dart';
import 'package:url_launcher/url_launcher_string.dart';

class TabFind extends StatefulWidget {

  final TwitterManager twitterManager;

  TabFind({super.key, required this.twitterManager});

  @override
  State<TabFind> createState() => _TabFindState();
}

class _TabFindState extends State<TabFind> {

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
              const Padding(
                padding: EdgeInsets.only(top: 12),
                child: Text(
                  "Feed",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                )
              ),
              Padding(
                padding: EdgeInsets.only(top: 8, bottom: 12),
                child: ElevatedButton(
                  onPressed: loadFriends,
                  child: const Text("Refresh"),
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
                          launchUrlString(feedTweets[index].url);
                        },
                        icon: const Icon(FontAwesome.hand_holding_medical, color: Colors.lightGreen),
                        color: twitterBlueColor,
                      ),
                      visualDensity: VisualDensity.compact,
                    );
                  },
                  shrinkWrap: true,
                  separatorBuilder: (BuildContext context, int index) {
                    return const Padding(
                      padding: EdgeInsets.only(top: 4, bottom: 4),
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
      preparedData.add(
        {
          "post_id": tweet.id,
          "post_value": tweet.text,
        }
      );
    }

    jsonPayload.addAll({"posts": preparedData});

    var response = await depFlowModelManager.getDepressive(jsonPayload);

    List<Tweet> filteredTweets = [];

    response.forEach((element) async {
      if (element["post_label"] == "depressive") {
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
          ));
        });
      }
    });
  }

  @override
  void initState() {
    super.initState();
    loadFriends();
  }
}