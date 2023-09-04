// ignore_for_file: avoid_unnecessary_containers

import 'package:appwrite/appwrite.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:titantrue/client/screens/ClientMainScreen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../state.dart';
import '../../utils/constants.dart';

class ValideEmailScreen extends StatefulWidget {
  const ValideEmailScreen({super.key});

  @override
  State<ValideEmailScreen> createState() => _ValideEmailScreenState();
}

class _ValideEmailScreenState extends State<ValideEmailScreen> {
  bool isVeriying = true;
  late SharedPreferences preferences;

  void _initWork() async {
    final realtime = Realtime(client);
    preferences = await SharedPreferences.getInstance();
    final subscription = realtime.subscribe([
      'databases.$DATABASE_ID.collections.$CLIENT_COLLECTION_ID.documents.${context.read<AppState>().myUser?.id}'
    ]);
    subscription.stream.listen((response) async {
      // Callback will be executed on changes for documents A and all files.
      print(response.payload['\$id']);
      print(response.payload);

      if (response.payload['\$id'] == context.read<AppState>().myUser?.id &&
          response.payload['verifie'] == true) {
        await preferences.setBool('login', true);
        await preferences.setString('username', '');
        await preferences.setString(
            'nom', context.read<AppState>().myUser!.nom);
        await preferences.setString(
            'prenom', context.read<AppState>().myUser!.prenom);
        await preferences.setString(
            // ignore: use_build_context_synchronously
            'password',
            context.read<AppState>().myUser!.password);
        await preferences.setString(
            // ignore: use_build_context_synchronously
            'telephone',
            context.read<AppState>().myUser!.telephone);
        await preferences.setString(
            // ignore: use_build_context_synchronously
            'clientId',
            context.read<AppState>().myUser!.id);
        await preferences.setString(
            // ignore: use_build_context_synchronously
            'userId',
            context.read<AppState>().myUser!.userId);
        await preferences.setString(
            'email', context.read<AppState>().myUser!.email);
        await preferences.setString('id', context.read<AppState>().myUser!.id);
        await preferences.setString('accountType', 'Client');
        // ignore: use_build_context_synchronously
        Navigator.push(context,
            MaterialPageRoute(builder: (context) => const ClientMainScreen()));
      }
    });
  }

  @override
  void initState() {
    super.initState();
    //print(context.read<AppState>().myUser?.email);
    _initWork();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(10.0),
        child: Container(
            // ignore: prefer_const_constructors
            child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
              Image.asset('assets/images/titan.png'),
              const SizedBox(height: 20),
              const Text(
                  textAlign: TextAlign.center,
                  'Nous vous avons envoyer un mail pour activier votre compte veuillez consulter votre messagerie,Une fois votre compte verifier vous serez automatiquement diriger vers la page principale de l\'application ',
                  style: TextStyle(
                    fontSize: 17,
                  )),
              const SizedBox(height: 10),
              isVeriying == true
                  ? const CircularProgressIndicator()
                  : const Text('')
            ])),
      ),
    ));
  }
}
