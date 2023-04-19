import 'package:flutter/material.dart';

class NewUserPage extends StatefulWidget {
  const NewUserPage({super.key});

  @override
  State<NewUserPage> createState() => _NewUserPageState();
}

class _NewUserPageState extends State<NewUserPage> {

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Welcome to DepFlow"),
        centerTitle: true,
      ),
      body: Center(
        child: Text("New User View"),
      ),
    );
  }

}