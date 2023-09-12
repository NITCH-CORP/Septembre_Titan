import 'package:flutter/material.dart';
import 'package:titantrue/common/screens/LoginScreen.dart';
import 'package:titantrue/common/screens/RegisterScreen.dart';

class ConRegScreen extends StatelessWidget {
  const ConRegScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView(
      children: [
        Container(
            decoration: const BoxDecoration(color: Colors.blue),
            child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Image.asset('assets/images/titan.png'),
                  ElevatedButton(
                      style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white),
                      onPressed: () {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => const RegisterScreen()));
                      },
                      child: const Text("S'inscrire",
                          style: TextStyle(color: Colors.blue))),
                  ElevatedButton(
                      onPressed: () {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => const LoginScreen()));
                      },
                      child: const Text("Se connecter")),
                ]))
      ],
    );
  }
}
