// ignore_for_file: prefer_const_literals_to_create_immutables, prefer_const_constructors, use_build_context_synchronously, curly_braces_in_flow_control_structures

import 'package:flutter/material.dart';
import 'package:titantrue/client/screens/ClientMainScreen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:titantrue/pilote/PiloteMainScreen.dart';

import 'ConRegScreen.dart';

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  void initState() {}

  @override
  Widget build(BuildContext context) {
    Future.delayed(const Duration(seconds: 5)).then((value) {
      SharedPreferences.getInstance().then((prefernces) async {
        //await prefernces.remove('login');
        final l = prefernces.getBool('login');
        print(l);
        if (l == null) {
          Navigator.push(
              context, MaterialPageRoute(builder: (context) => ConRegScreen()));
          print(l == null);
          print(57198456524);
        }

        final t = prefernces.getString('accountType');
        print(t);
        if (t == null) {
          Navigator.push(
              context, MaterialPageRoute(builder: (context) => ConRegScreen()));
          return;
        }
        //print(t);
        if (t == 'Client') {
          Navigator.push(context,
              MaterialPageRoute(builder: (context) => ClientMainScreen()));
          return;
        }

        if (t == 'Pilote') {
          Navigator.push(context,
              MaterialPageRoute(builder: (context) => PiloteMainScreen()));
        }
      });
    });
    return Scaffold(
        body: SafeArea(
      child: Container(
        child: Column(children: [
          Expanded(
              child: Image.asset('assets/images/titan.png')),
          //const Spacer(),

          const Text('By Nitch Corp',
              style:
                  TextStyle(fontWeight: FontWeight.bold, color: Colors.blue)),
          const SizedBox(height: 20)
        ]),
      ),
    ));
  }
}
