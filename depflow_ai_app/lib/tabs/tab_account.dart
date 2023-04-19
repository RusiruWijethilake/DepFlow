import 'package:depflow_ai_app/components/tweet_item_view.dart';
import 'package:depflow_ai_app/utilities/twitter_manager.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher_string.dart';

class TabProfile extends StatefulWidget {

  final TwitterManager twitterManager;

  const TabProfile({super.key, required this.twitterManager});

  @override
  State<TabProfile> createState() => _TabProfileState();
}

class _TabProfileState extends State<TabProfile> {

  FirebaseAuth auth = FirebaseAuth.instance;

  String _profilePhotoURL = "https://upload.wikimedia.org/wikipedia/commons/7/7c/Profile_avatar_placeholder_large.png";
  String _profileNamme = "No Name Guy";

  String _twitterUsername = "@realRusiru";
  String _twitterDepressiveCount = "0";
  
  dynamic _userDepressiveTweets = [];

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
                          const Text("Depressive Tweets"),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const Padding(
                padding: EdgeInsets.only(top: 12),
                child: Text(
                  "Your Depressive Tweets",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                )
              ),
              Padding(
                padding: const EdgeInsets.only(top: 12, left: 12, right: 12),
                child: ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: _userDepressiveTweets.length,
                  itemBuilder: (context, index) {
                    return TwitterItemView(
                      _userDepressiveTweets[index]["post_url"],
                      _userDepressiveTweets[index]["post_value"],
                      _userDepressiveTweets[index]["post_author"],
                      _userDepressiveTweets[index]["post_label"] == "depressive" ? true : false,
                    );
                  },
                  separatorBuilder: (BuildContext context, int index) {
                    return const SizedBox(height: 12);
                  },
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
    kDebugMode ? loadSampleData() : null;
  }

  void loadProfileDetails() {
    auth.currentUser!.reload();
    setState(() {
      _profilePhotoURL = auth.currentUser!.photoURL!;
      _profileNamme = auth.currentUser!.displayName!;
    });
  }

  void loadSampleData() {
    for (int i = 0; i < 10; i++) {
      _userDepressiveTweets.add(
        {
          "post_url": "https://twitter.com/$_twitterUsername",
          "post_value": "Lorem ipsum dolor sit amet, consectetur adipiscing elit. Sed sit amet odio iaculis, consectetur neque eget, imperdiet diam.",
          "post_author": "@realRusiru",
          "post_label": "depressive",
        }
      );
    }
  }
}