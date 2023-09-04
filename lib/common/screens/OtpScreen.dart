// ignore_for_file: use_build_context_synchronously, prefer_const_constructors, dead_code

import 'dart:convert';

import 'package:appwrite/models.dart';
import 'package:flutter/material.dart';
//import 'package:parse_server_sdk_flutter/parse_server_sdk_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:titantrue/client/screens/ClientMainScreen.dart';
import '../../utils/constants.dart';
import 'package:appwrite/appwrite.dart';
//import 'package:dart_appwrite/dart_appwrite.dart';
import 'package:titantrue/state.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;

class OtpScreen extends StatefulWidget {
  const OtpScreen({super.key});

  @override
  State<OtpScreen> createState() => _OtpScreenState();
}

class _OtpScreenState extends State<OtpScreen> {
  final formKey = GlobalKey<FormState>();
  final firstController = TextEditingController();
  final secondController = TextEditingController();
  final thirdController = TextEditingController();
  final fourthController = TextEditingController();
  String code = '';
  bool isVerifying = false;
  //String userId =

  //final authService = AuthService();

  Future<void> initAuth() async {}

  Future<void> createUser() async {
    try {
      final account = Account(client);
      User user = await account.create(
          userId: ID.unique(),
          email: context.read<AppState>().myUser!.email,
          password: context.read<AppState>().myUser!.password);
      //user.up
      /*User user = await account.createuserId:ID.unique(),email:emailController.text,password:passwordController.text);*/
      /*final session = account.updatePhoneVerification(
    context.read<AppState>().myUser?.userId,

    );*/
      final session = await account.createPhoneSession(
          userId: ID.unique(),
          phone: '${context.read<AppState>().myUser?.telephone}');
      context.read<AppState>().myUser?.userId = session.userId;

      SharedPreferences preferences = await SharedPreferences.getInstance();
      await preferences.setBool('login', true);

      await preferences.setString('nom', context.read<AppState>().myUser!.nom);
      await preferences.setString(
          'prenom', context.read<AppState>().myUser!.prenom);
      await preferences.setString(
          'password', context.read<AppState>().myUser!.password);
      await preferences.setString(
          'email', context.read<AppState>().myUser!.email);
      await preferences.setString(
          'telephone', context.read<AppState>().myUser!.telephone);

      await preferences.setString('userId', user.$id);
      await preferences.setString('accountType', 'Client');

      final clientDoc = await databases.createDocument(
          databaseId: DATABASE_ID,
          collectionId: CLIENT_COLLECTION_ID,
          documentId: ID.unique(),
          data: {
            'nom': context.read<AppState>().myUser?.nom,
            'prenom': context.read<AppState>().myUser?.prenom,
            'numero': context.read<AppState>().myUser?.telephone,
            'email': context.read<AppState>().myUser?.email,
            'user_id': user.$id,
            'verifie': true
          });

      context.read<AppState>().myUser?.id = clientDoc.$id;
      await preferences.setString('clientId', clientDoc.$id);
      await preferences.setBool('login', true);
      Navigator.push(
          context, MaterialPageRoute(builder: (context) => ClientMainScreen()));
    } catch (e) {
      setState(() {
        isVerifying = false;
      });
      showDialog<void>(
        context: context,
        barrierDismissible: false, // user must tap button!
        builder: (BuildContext context) {
          return AlertDialog(
            // <-- SEE HERE
            title: const Text('Avertiseement'),
            content: SingleChildScrollView(
              child: ListBody(
                children: const <Widget>[
                  Text(
                      'Une erreur  est survenue, veuillez ressayer s\'il vous plait'),
                ],
              ),
            ),
            actions: <Widget>[
              TextButton(
                child: const Text('OK'),
                onPressed: () async {
                  Navigator.of(context).pop();
                },
              ),
            ],
          );
        },
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: SafeArea(
            top: false,
            child: Padding(
                padding: const EdgeInsets.all(8),
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      //Image.asset('assets/images/titan.png'),
                      const Text('TITAN',style:TextStyle(fontSize:25,color:Colors.blue,fontWeight:FontWeight.bold)),
                      SizedBox(height:35),
                      Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            Container(
                                decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(5),
                                    border: Border.all()),
                                width: 50,
                                height: 50,
                                child: Center(
                                    child: TextField(
                                    maxLength:1,
                                        controller: firstController,
                                        style: TextStyle(fontSize: 28),
                                        textAlign: TextAlign.center,
                                        keyboardType: TextInputType.number,
                                        decoration: InputDecoration(
                                          border: InputBorder.none,
                                          counter: Offstage(),
                                        )))),
                            Container(
                                decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(5),
                                    border: Border.all()),
                                width: 50,
                                height: 50,
                                child: Center(
                                    child: TextField(
                                    maxLength:1,
                                        controller: secondController,
                                        style: TextStyle(fontSize: 28),
                                        textAlign: TextAlign.center,
                                        keyboardType: TextInputType.number,
                                        decoration: InputDecoration(
                                        counter: Offstage(),
                                            border: InputBorder.none)))),
                            Container(
                                decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(5),
                                    border: Border.all()),
                                width: 50,
                                height: 50,
                                child: Center(
                                    child: TextField(
                                    maxLength:1,
                                        controller: thirdController,
                                        style: TextStyle(fontSize: 28),
                                        textAlign: TextAlign.center,
                                        keyboardType: TextInputType.number,
                                        decoration: InputDecoration(
                                        counter: Offstage(),
                                            border: InputBorder.none)))),
                            Container(
                                decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(5),
                                    border: Border.all()),
                                width: 50,
                                height: 50,
                                child: Center(
                                    child: TextField(
                                    
                                    maxLength:1,
                                        controller: fourthController,
                                        textAlign: TextAlign.center,
                                        style: TextStyle(fontSize: 28),
                                        keyboardType: TextInputType.number,
                                        decoration: InputDecoration(
                                        counter: Offstage(),
                                            border: InputBorder.none)))),
                          ]),
                      const SizedBox(height: 10),
                      Text(
                          "Nous allons vous envoyer un code sur le numero ${context.read<AppState>().myUser?.telephone}",
                          textAlign: TextAlign.center),
                      ElevatedButton(
                          onPressed: isVerifying == true
                              ? null
                              : () async {
                                  try {
                                  if(firstController.text.toString() == "" || secondController.text.toString() == "" || thirdController.text.toString() == "" || fourthController.text.toString() == ""  ){
                                  showDialog<void>(
                                            context: context,
                                            barrierDismissible:
                                                false, // user must tap button!
                                            builder: (BuildContext context) {
                                              return AlertDialog(
                                                // <-- SEE HERE
                                                title:
                                                    const Text('Avertiseement'),
                                                content: SingleChildScrollView(
                                                  child: ListBody(
                                                    children: const <Widget>[
                                                      Text(
                                                          'Veuillez remplire tous les champs!'),
                                                    ],
                                                  ),
                                                ),
                                                actions: <Widget>[
                                                  TextButton(
                                                    child: const Text('OK'),
                                                    onPressed: () async {
                                                      Navigator.of(context)
                                                          .pop();
                                                    },
                                                  ),
                                                ],
                                              );
                                            },
                                          );
                                          return;
                                  }
                                    setState(() {
                                      isVerifying = true;
                                    });
                                    String code =
                                        "${firstController.text.toString()}${secondController.text.toString()}${thirdController.text.toString()}${fourthController.text?.toString()}";
                                    print(code);
                                    final response = await http.get(Uri.parse(
                                        'http://${BASE_URL}:2023/verify-otp?numero=+228${context.read<AppState>().myUser?.telephone}&otpcode=${code}'));

                                    if (response.statusCode == 200) {
                                      var jsonResponse =
                                          jsonDecode(response.body)
                                              as Map<String, dynamic>;
                                      var success = jsonResponse['success'];
                                      print(success);
                                      if (success == 'OK') {
                                        //print('SUCCESSSSSSSSSSS');

                                        if (jsonResponse['status'] ==
                                            'pending') {
                                          showDialog<void>(
                                            context: context,
                                            barrierDismissible:
                                                false, // user must tap button!
                                            builder: (BuildContext context) {
                                              return AlertDialog(
                                                // <-- SEE HERE
                                                title:
                                                    const Text('Avertiseement'),
                                                content: SingleChildScrollView(
                                                  child: ListBody(
                                                    children: const <Widget>[
                                                      Text(
                                                          'Code incorrect veuillez ressayer'),
                                                    ],
                                                  ),
                                                ),
                                                actions: <Widget>[
                                                  TextButton(
                                                    child: const Text('OK'),
                                                    onPressed: () async {
                                                      Navigator.of(context)
                                                          .pop();
                                                    },
                                                  ),
                                                ],
                                              );
                                            },
                                          );

                                          setState(() {
                                            isVerifying = false;
                                          });
                                        }

                                        if (jsonResponse['status'] ==
                                            'approved') {
                                          createUser();
                                        }
                                      }
                                    }
                                    // createUser();
                                  } catch (e) {
                                    print(e);

                                    setState(() {
                                      isVerifying = false;
                                    });
                                    showDialog<void>(
                                      context: context,
                                      barrierDismissible:
                                          false, // user must tap button!
                                      builder: (BuildContext context) {
                                        return AlertDialog(
                                          // <-- SEE HERE
                                          title: const Text('Avertiseement'),
                                          content: SingleChildScrollView(
                                            child: ListBody(
                                              children: const <Widget>[
                                                Text(
                                                    'Une erreur de connexion est survenue, veuillez verifier votre connexion et ressayer'),
                                              ],
                                            ),
                                          ),
                                          actions: <Widget>[
                                            TextButton(
                                              child: const Text('OK'),
                                              onPressed: () async {
                                                Navigator.of(context).pop();
                                              },
                                            ),
                                          ],
                                        );
                                      },
                                    );
                                  }
                                },
                          child: Text("Verifier",style:TextStyle(fontSize:20)))
                    ]))));
  }
}
