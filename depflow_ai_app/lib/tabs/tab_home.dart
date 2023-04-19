import 'package:depflow_ai_app/utilities/twitter_manager.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class TabHome extends StatefulWidget {

  final TwitterManager twitterManager;

  const TabHome({super.key, required this.twitterManager});

  @override
  State<TabHome> createState() => _TabHomeState();
}

class _TabHomeState extends State<TabHome> {

  FirebaseAuth auth = FirebaseAuth.instance;

  List<dynamic> latestTweets = [];
  
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: MediaQuery.of(context).size.width,
      height: MediaQuery.of(context).size.height,
      child: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(height: 24),
            const Text("Home"),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () {
                auth.signOut();
              },
              child: const Text("Sign Out"),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void initState() {
    super.initState();
  }
}