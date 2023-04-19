import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:depflow_ai_app/tabs/tab_account.dart';
import 'package:depflow_ai_app/tabs/tab_home.dart';
import 'package:depflow_ai_app/tabs/tab_report.dart';
import 'package:depflow_ai_app/utilities/twitter_manager.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:icons_plus/icons_plus.dart';
import 'package:url_launcher/url_launcher_string.dart';

class HomePage extends StatefulWidget {

  final TwitterManager twitterManager = TwitterManager();

  HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {

  int currentPageIndex = 0;

  FirebaseAuth auth = FirebaseAuth.instance;
  FirebaseFirestore firestore = FirebaseFirestore.instance;

  @override
  void initState() {
    handleSignIn();
    handleNewUsers();
    super.initState();
    FlutterNativeSplash.remove();
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(
        title: const Text("DepFlow"),
        centerTitle: true,
        actions: [
          PopupMenuButton(
            itemBuilder: (context) {
              return [
                PopupMenuItem(
                  child: ListTile(
                    leading: const Icon(Icons.info),
                    title: const Text("About App"),
                    onTap: () {
                      showAboutDialog(
                        context: context,
                        applicationName: "DepFlow",
                        applicationVersion: "1.0.0",
                        applicationIcon: Image.asset("assets/images/app_logo.png", width: 100, height: 100),
                        applicationLegalese: "© 2021 DepFlow",
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(top: 24),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.start,
                              mainAxisSize: MainAxisSize.min,
                              children: const [
                                Text("An AI powered app that helps you track your and loved ones' mental health "
                                    "and provides you or them with personalized support."),
                                SizedBox(height: 12),
                                Text("Made with ❤️ by DepFlow Team"),
                              ],
                            ),
                          ),
                          ElevatedButton(onPressed: handleNewUsers, child: const Text("New User")),
                        ],
                      );
                    },
                  )
                ),
              ];
            },
          )
        ],
        backgroundColor: Colors.white,
        systemOverlayStyle: const SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
          statusBarIconBrightness: Brightness.dark,
        ),
        elevation: 0,
        surfaceTintColor: Colors.transparent,
      ),
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: IndexedStack(
          index: currentPageIndex,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 8, 12, 8),
              child: TabHome(twitterManager: widget.twitterManager),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 8, 12, 8),
              child: TabFind(twitterManager: widget.twitterManager),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(0, 8, 0, 8),
              child: TabProfile(twitterManager: widget.twitterManager),
            ),
          ],
        ),
      ),
      bottomNavigationBar: NavigationBar(
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          NavigationDestination(
            icon: Icon(Icons.search),
            label: 'Find',
          ),
          NavigationDestination(
            icon: Icon(Icons.person),
            label: 'Account',
          ),
        ],
        selectedIndex: currentPageIndex,
        onDestinationSelected: (int index) {
          setState(() {
            currentPageIndex = index;
          });
        },
        labelBehavior: NavigationDestinationLabelBehavior.onlyShowSelected,
        backgroundColor: Colors.white,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
      ),
    );
  }

  void handleSignIn() {
    auth.authStateChanges().listen((User? user) {
      if (user == null) {
        Navigator.pushReplacementNamed(context, '/login');
      }
    });
  }

  void handleNewUsers() {
    final docRef = firestore.collection("users").doc(auth.currentUser!.uid);

    docRef.get().then((DocumentSnapshot<Map<String, dynamic>> document) async {
      if (document.exists) {
        await widget.twitterManager.initTwitter();
      } else {
        initiateNewUser(docRef);
      }
    });
  }

  void initiateNewUser(DocumentReference<Map<String, dynamic>> docRef) async {
    showModalBottomSheet(
      context: context,
      enableDrag: false,
      isDismissible: false,
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset("assets/images/app_logo.png", width: 100, height: 100),
              const Text(
                "Welcome to DepFlow!",
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Text(
                "Seems like you are a new user.",
                style: TextStyle(
                  fontSize: 18,
                ),
              ),
              const SizedBox(height: 24),
              const Text(
                "To continue we need you to connect your Twitter account.",
                style: TextStyle(
                  fontSize: 14,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              const Text(
                "We will use this to fetch your tweets and analyze them.",
                style: TextStyle(
                  fontSize: 14,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              FilledButton.icon(
                onPressed: () async {
                  await widget.twitterManager.initNewTwitter();

                  var twitterUsername = await widget.twitterManager.getTwitterUsername();

                  firestore.collection("users").doc(auth.currentUser!.uid).set({
                    "twitter": {
                      "authenticated": true,
                      "username": twitterUsername,
                    }
                  });

                  Navigator.pop(context);
                },
                icon: const Icon(FontAwesome.twitter),
                label: const Text("Connect Twitter"),
              ),
              const SizedBox(height: 8),
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  const Text(
                    'By connecting your Twitter account, you agree to our app\'s',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 10,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      InkWell(
                        child: const Text(
                          'Privacy Policy',
                          style: TextStyle(
                            color: Colors.green,
                            decoration: TextDecoration.underline,
                            fontSize: 10,
                          ),
                        ),
                        onTap: () => launchUrlString(
                          'https://depflow-ai.web.app/privacy-policy.html',
                          mode: LaunchMode.externalApplication,
                          webOnlyWindowName: 'Terms of Service',
                          webViewConfiguration: const WebViewConfiguration(
                            enableJavaScript: true,
                          ),
                        ),
                      ),
                      const Padding(
                        padding: EdgeInsets.only(left: 8, right: 8),
                        child: Text(
                          'and',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 10,
                          ),
                        ),
                      ),
                      InkWell(
                        child: const Text(
                          'Terms of Service',
                          style: TextStyle(
                            color: Colors.green,
                            decoration: TextDecoration.underline,
                            fontSize: 10,
                          ),
                        ),
                        onTap: () => launchUrlString(
                          'https://depflow-ai.web.app/terms-of-service.html',
                          mode: LaunchMode.externalApplication,
                          webOnlyWindowName: 'Terms of Service',
                          webViewConfiguration: const WebViewConfiguration(
                            enableJavaScript: true,
                          ),
                        ),
                      ),
                    ],
                  )
                ],
              )
            ],
          ),
        );
      },
    );
  }
}