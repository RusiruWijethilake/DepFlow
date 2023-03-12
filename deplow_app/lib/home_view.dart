import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:icons_plus/icons_plus.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {

  Future<UserCredential> signInWithGoogle() async {
    final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();

    final GoogleSignInAuthentication? googleAuth = await googleUser?.authentication;

    final credential = GoogleAuthProvider.credential(
      accessToken: googleAuth?.accessToken,
      idToken: googleAuth?.idToken,
    );

    return await FirebaseAuth.instance.signInWithCredential(credential);
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      body: SingleChildScrollView(
        child: Center(
          child: Column(
            children: [
              Padding(
                padding: EdgeInsets.fromLTRB(42, 64, 42, 12),
                child: Image.asset("assets/images/app_logo.png", width: 200, height: 200),
              ),
              Text(
                "DepFlow",
                style: GoogleFonts.poppins(
                  fontSize: 32,
                ),
              ),
              Padding(
                padding: EdgeInsets.fromLTRB(64, 4, 64, 12),
                child: Text(
                  "Mental Health Support",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey,
                  ),
                ),
              ),
              Padding(
                padding: EdgeInsets.fromLTRB(24, 0, 24, 0),
                child: Text(
                  "An AI powered app that helps you track your and loved ones' mental health "
                      "and provides you or them with personalized support.",
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 16),
                ),
              ),
              Padding(
                padding: EdgeInsets.fromLTRB(32, 64, 32, 12),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisSize: MainAxisSize.max,
                  children: [
                    Padding(
                      padding: EdgeInsets.only(bottom: 12),
                      child: Text("Sign in or sign up with", style: TextStyle(fontSize: 16))),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisSize: MainAxisSize.max,
                      children: [
                        IconButton(
                          onPressed: () {
                            signInWithGoogle().then((value) {
                              print(value);
                            });
                          },
                          icon: Icon(FontAwesome.google),
                          style: ButtonStyle(
                            padding: MaterialStateProperty.all(EdgeInsets.all(12)),
                            backgroundColor: MaterialStateProperty.all(Colors.green),
                            foregroundColor: MaterialStateProperty.all(Colors.black),
                          ),
                        ),
                        SizedBox(width: 12),
                        IconButton(
                          onPressed: () {},
                          icon: Icon(FontAwesome.apple),
                          style: ButtonStyle(
                            padding: MaterialStateProperty.all(EdgeInsets.all(12)),
                            backgroundColor: MaterialStateProperty.all(Colors.green),
                            foregroundColor: MaterialStateProperty.all(Colors.black),
                          ),
                        ),
                      ],
                    )
                  ],
                )
              ),
            ],
          )
        ),
      )
    );
  }
}