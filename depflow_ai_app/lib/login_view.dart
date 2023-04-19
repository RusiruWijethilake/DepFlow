import 'dart:ui';

import 'package:depflow_ai_app/theme/app_colors.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:icons_plus/icons_plus.dart';
import 'package:url_launcher/url_launcher_string.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {

  FirebaseAuth auth = FirebaseAuth.instance;

  Future<UserCredential> signInWithGoogle() async {
    final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();

    final GoogleSignInAuthentication? googleAuth = await googleUser?.authentication;

    final credential = GoogleAuthProvider.credential(
      accessToken: googleAuth?.accessToken,
      idToken: googleAuth?.idToken,
    );

    return await auth.signInWithCredential(credential);
  }

  @override
  void initState() {
    super.initState();
    handleSignIn();
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      body: SingleChildScrollView(
        child: Center(
          child: Stack(
            fit: StackFit.passthrough,
            children: [
              Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(42, 64, 42, 12),
                    child: Image.asset("assets/images/app_logo.png", width: 200, height: 200),
                  ),
                  Text(
                    "DepFlow",
                    style: GoogleFonts.poppins(
                      fontSize: 32,
                    ),
                  ),
                  const Padding(
                    padding: EdgeInsets.fromLTRB(64, 4, 64, 12),
                    child: Text(
                      "Mental Health Support",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.black,
                      ),
                    ),
                  ),
                  const Padding(
                    padding: EdgeInsets.fromLTRB(24, 0, 24, 0),
                    child: Text(
                      "An AI powered app that helps you track your and loved ones' mental health "
                          "and provides you or them with personalized support.",
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 16),
                    ),
                  ),
                  Padding(
                      padding: const EdgeInsets.fromLTRB(32, 64, 32, 12),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisSize: MainAxisSize.max,
                        children: [
                          const Padding(
                              padding: EdgeInsets.only(bottom: 12),
                              child: Text("Continue with", style: TextStyle(fontSize: 16))
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            mainAxisSize: MainAxisSize.max,
                            children: [
                              FilledButton.icon(
                                onPressed: signInWithGoogle,
                                icon: const Icon(FontAwesome.google_plus_g),
                                label: const Text("   Google"),
                                style: FilledButton.styleFrom(
                                  backgroundColor: googleRedColor,
                                  foregroundColor: Colors.white,
                                  splashFactory: InkRipple.splashFactory,
                                  fixedSize: const Size(130, 30),
                                  alignment: Alignment.center,
                                ),
                              ),
                              const SizedBox(width: 12),
                              FilledButton.icon(
                                onPressed: () {
                                  showDialog(
                                    context: context,
                                    builder: (BuildContext context) {
                                      return AlertDialog(
                                        title: const Text("Coming Soon!"),
                                        content: const Text("Apple sign in is coming soon!"),
                                        actions: [
                                          TextButton(
                                            onPressed: () => Navigator.pop(context),
                                            child: const Text("OK"),
                                          ),
                                        ],
                                      );
                                    },
                                  );
                                },
                                icon: const Icon(FontAwesome.apple),
                                label: const Text("   Apple"),
                                style: FilledButton.styleFrom(
                                  backgroundColor: appleRedColor,
                                  foregroundColor: Colors.white,
                                  splashFactory: InkRipple.splashFactory,
                                  fixedSize: const Size(130, 30),
                                ),
                              ),
                            ],
                          ),
                          Padding(
                              padding: const EdgeInsets.only(top: 12),
                              child: Center(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: <Widget>[
                                    const Text(
                                      'By signing in with either your Google or Apple account, you agree to our app\'s',
                                      textAlign: TextAlign.center,
                                    ),
                                    const SizedBox(height: 8),
                                    InkWell(
                                      child: const Text(
                                        'Privacy Policy',
                                        style: TextStyle(
                                          color: Colors.blue,
                                          decoration: TextDecoration.underline,
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
                                    const SizedBox(height: 4),
                                    InkWell(
                                      child: const Text(
                                        'Terms of Service',
                                        style: TextStyle(
                                          color: Colors.blue,
                                          decoration: TextDecoration.underline,
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
                                ),
                              ),
                          ),
                        ],
                      )
                  ),
                ],
              )
            ],
          ),
        ),
      )
    );
  }

  void handleSignIn() {
    auth.authStateChanges().listen((User? user) {
      if (user == null) {
        FlutterNativeSplash.remove();
      } else {
        Navigator.popAndPushNamed(context, '/home');
      }
    });
  }
}