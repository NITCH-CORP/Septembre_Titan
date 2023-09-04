// ignore_for_file: prefer_const_constructors, use_build_context_synchronously, avoid_print

//import 'dart:js_interop';

//import 'dart:js_interop';

import 'dart:convert';

import 'package:appwrite/appwrite.dart';
import 'package:appwrite/models.dart';
import 'package:flutter/material.dart';
//import 'package:parse_server_sdk_flutter/parse_server_sdk_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:titantrue/state.dart';
import 'package:provider/provider.dart';
import '../../client/screens/ClientMainScreen.dart';
import '../../pilote/PiloteMainScreen.dart';
import '../../utils/constants.dart';
import 'OtpScreen.dart';
import 'package:http/http.dart' as http;

class RegisterScreen2 extends StatefulWidget {
  const RegisterScreen2({super.key});

  @override
  State<RegisterScreen2> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen2> {
  final formKey = GlobalKey<FormState>();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final password2Controller = TextEditingController();
  final usernameController = TextEditingController();
  String accountType = 'Client';
  late SharedPreferences preferences;
  bool isWorking = false;

  void initBackground() async {
    preferences = await SharedPreferences.getInstance();
  }

  Future<void> registernWithEmailAndPassword() async {
    try {
      Databases databases = Databases(client);
      final account = Account(client);
      User user = await account.create(
          userId: ID.unique(),
          name: usernameController.text,
          email: emailController.text,
          password: passwordController.text);

      switch (accountType) {
        case 'Client':
          //user.prefs.data.addAll({'accountType': 'Client'});
          account.updatePrefs(prefs: {'accountType': 'Client'});
          final prefs = await account.getPrefs();
          print(prefs.data);

          //print(prefs.data['accountType']);
          SharedPreferences preferences = await SharedPreferences.getInstance();
          //await preferences.setBool('login', true);
          await preferences.setString('username', user.name);
          await preferences.setString('password', passwordController.text);
          await preferences.setString('email', emailController.text);
          await preferences.setString('accountType', 'Client');

          final client = await databases.createDocument(
            databaseId: DATABASE_ID,
            collectionId: CLIENT_COLLECTION_ID,
            documentId: ID.unique(),
            data: {
              'nom_utilisateur': user.name,
              'nom': 'Ababa',
              'prenom': 'Kolomouani',
              'email': user.email,
              'user_id': user.$id.toString()
            },
          );
          //print('XXXXXXXXXXXXXXXXXXXX');

          final result = await databases.createDocument(
            databaseId: DATABASE_ID,
            collectionId: ACTIVITE_COLLECTION_ID,
            documentId: ID.unique(),
            data: {
              'description': 'Un client vient de se s\'inscrire ',
              'categorie': 'INSCRIPTIONCLIENT',
              'client': client.$id
            },
          );

          //print('NNNNNNNNNNNNNNNNNNNNNNN');

          Session session = await account.createEmailSession(
              email: emailController.text, password: passwordController.text);

          /*if (session.isNull) {
            print('OOOPS');
          }*/

          //print(result.data);
          Navigator.push(context,
              MaterialPageRoute(builder: (context) => ClientMainScreen()));
          break;

        case 'Pilote':
          account.updatePrefs(prefs: {'accountType': 'Pilote'});
          final prefs = await account.getPrefs();

          print(prefs.data);
          print('ddddddddddddddddd');

          SharedPreferences preferences = await SharedPreferences.getInstance();
          await preferences.setBool('login', true);
          await preferences.setString('username', user.name);
          await preferences.setString('password', passwordController.text);
          await preferences.setString('email', emailController.text);
          await preferences.setString('accountType', prefs.data['accountType']);

          final pilote = await databases.createDocument(
            databaseId: DATABASE_ID,
            collectionId: PILOTE_COLLECTION_ID,
            documentId: ID.unique(),
            data: {
              'nom_utilisateur': user.name,
              'nom': 'Adankpo',
              'prenom': 'Junior',
              'email': user.email,
              'user_id': user.$id.toString()
            },
          );
          final result = await databases.createDocument(
            databaseId: DATABASE_ID,
            collectionId: NOTIFICATION_COLLECTION_ID,
            documentId: ID.unique(),
            data: {'type': 'INSCRIPTIONPILOTE', 'id': pilote.$id},
          );

          Session session = await account.createEmailSession(
              email: emailController.text, password: passwordController.text);

          print(result.data);
          Navigator.push(context,
              MaterialPageRoute(builder: (context) => PiloteMainScreen()));
          break;
      }
    } catch (e) {
      print(e);
    }

    /*Navigator.push(
        context, MaterialPageRoute(builder: (context) => ClientMainScreen()));*/
  }

  @override
  void initState() {
    super.initState();
    initBackground();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
          child: SafeArea(
              top: false,
              child: Container(
                padding: const EdgeInsets.only(left: 20, right: 20),
                decoration: BoxDecoration(color: Colors.blue),
                width: MediaQuery.of(context).size.width,
                height: MediaQuery.of(context).size.height,
                child: ListView(
                  children: [
                    //const SizedBox(height: 10),
                    Image.asset('assets/images/titan.png'),

                    //Text('Titan', style: TextStyle(fontSize: 20, color: Colors.white)),
                    Form(
                        key: formKey,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            SizedBox(
                              width: MediaQuery.of(context).size.width,
                              child: TextFormField(
                                controller: emailController,
                                validator: (value) {
                                  final bool emailValid = RegExp(r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+").hasMatch(value!);
                                  if (!emailValid) {

                                    return 'Veuillez entrer un email valide';
                                  }
                                  return null;
                                },
                                onChanged: (value) {},
                                style: const TextStyle(
                                  color: Colors.white,
                                ),
                                decoration: InputDecoration(
                                    suffixIcon: IconButton(
                                      onPressed: () {},
                                      icon: Icon(Icons.clear,
                                          color: Colors.white),
                                    ),
                                    labelStyle: TextStyle(color: Colors.white),
                                    hintText: 'Adress email',
                                    errorStyle:
                                        const TextStyle(color: Colors.white),
                                    hintStyle:
                                        const TextStyle(color: Colors.white)),
                              ),
                            ),
                            const SizedBox(height: 20),
                            SizedBox(
                              width: MediaQuery.of(context).size.width,
                              child: TextFormField(
                              obscureText: true,
                                controller: passwordController,
                                validator: (value) {
                                  if (value!.length < 8) {
                                    return 'Veuillez choisir un mot de pass de plus de 8 carateres';
                                  }
                                  return null;
                                },
                                onChanged: (value) {},
                                style: const TextStyle(
                                  color: Colors.white,
                                ),
                                decoration: InputDecoration(
                                    suffixIcon: IconButton(
                                      onPressed: () {},
                                      icon: Icon(Icons.clear,
                                          color: Colors.white),
                                    ),
                                    labelStyle: TextStyle(color: Colors.white),
                                    hintText: 'Mot de pass',
                                    errorStyle:
                                        const TextStyle(color: Colors.white),
                                    hintStyle:
                                        const TextStyle(color: Colors.white)),
                              ),
                            ),
                            const SizedBox(height: 20),
                            SizedBox(
                              width: MediaQuery.of(context).size.width,
                              child: TextFormField(
                              obscureText: true,
                                controller: password2Controller,
                                validator: (value) {
                                  if (passwordController.text !=
                                      password2Controller.text) {
                                    return 'Le mot de pass ne correspond pas au premier';
                                    //return null;
                                  }
                                  return null;
                                },
                                style: TextStyle(
                                  color: Colors.white,
                                ),
                                decoration: InputDecoration(
                                    suffixIcon: IconButton(
                                      onPressed: () {},
                                      icon: Icon(Icons.clear,
                                          color: Colors.white),
                                    ),
                                    labelStyle: TextStyle(color: Colors.white),
                                    hintText: 'Confirmer le Mot de Pass',
                                    errorStyle: TextStyle(color: Colors.white),
                                    hintStyle: TextStyle(color: Colors.white)),
                              ),
                            ),
                            /*const SizedBox(height: 20),
                            SizedBox(
                              width: MediaQuery.of(context).size.width,
                              child: DropdownButton<String>(
                                  dropdownColor: Colors.blue,
                                  style: TextStyle(
                                      color: Color.fromARGB(255, 255, 255, 255),
                                      fontSize: 18,
                                      fontWeight: FontWeight.w500),
                                  value: accountType,
                                  onChanged: (value) {
                                    print(value);
                                    setState(() {
                                      accountType = value!;
                                    });
                                  },
                                  items: const [
                                    DropdownMenuItem(
                                        value: 'Client',
                                        child: Text(
                                          'Client',
                                          style: TextStyle(color: Colors.white),
                                        )),
                                    DropdownMenuItem(
                                        value: 'Pilote',
                                        child: Text('Pilote',
                                            style: TextStyle(
                                                color: Colors.white))),
                                  ]),
                            ),
                            const SizedBox(height: 20),*/
                            SizedBox(
                                width: MediaQuery.of(context).size.width,
                                child: ElevatedButton(
                                    style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors.white,
                                        shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(18.0),
                                            side: BorderSide(
                                                color: Colors.white))),
                                    onPressed: isWorking == true
                                        ? null
                                        : () async {
                                            /*if (formKey.currentState!
                                                .validate()) {
                                              //registernWithEmailAndPassword();
                                              setState(() {
                                                isWorking = true;
                                              });
                                              try {
                                                /*final session = await account.createPhoneSession(
                                         userId:ID.unique(),
                                         phone:'+228${context.read<AppState>().myUser?.telephone}'
                                         );*/
                                                //print('HHHHHHHHHHHHHHHHHHHHHHHHH');

                                                final response = await http.get(
                                                    Uri.parse(
                                                        'http://${BASE_URL}:2023/verify-number?numero=${context.read<AppState>().myUser?.telephone}'));
                                                if (response.statusCode ==
                                                    200) {
                                                  var jsonResponse = jsonDecode(
                                                          response.body)
                                                      as Map<String, dynamic>;
                                                  var success =
                                                      jsonResponse['success'];
                                                  if (success == 'OK') {
                                                    context
                                                            .read<AppState>()
                                                            .myUser
                                                            ?.email =
                                                        emailController.text;
                                                    context
                                                            .read<AppState>()
                                                            .myUser
                                                            ?.password =
                                                        passwordController.text;
                                                    Navigator.push(
                                                        context,
                                                        MaterialPageRoute(
                                                            builder: (context) =>
                                                                OtpScreen()));
                                                  }
                                                }

                                                //print('${context.read<AppState>().myUser?.telephone}');

                                                /*final session = await account.createEmailSession(
                                              email: emailController.text,
                                              password:
                                                  passwordController.text);
                                          //print(session.)
                                          account.createVerification(
                                              url:
                                                  'http://${EMAIL_URL}:2023/verify-email');*/

                                                //account.ver
                                                /*context
                                                        .read<AppState>()
                                                        .myUser
                                                        ?.email =
                                                    emailController.text;
                                                context
                                                        .read<AppState>()
                                                        .myUser
                                                        ?.password =
                                                    passwordController.text;
                                                setState(() {
                                                  isWorking = false;
                                                });

                                                Navigator.push(
                                                    context,
                                                    MaterialPageRoute(
                                                        builder: (context) =>
                                                            OtpScreen()));*/
                                              } catch (e) {
                                                print(e.toString());
                                                String msg = '';
                                                setState(() {
                                                  isWorking = false;
                                                });

                                                return showDialog<void>(
                                                  context: context,
                                                  barrierDismissible:
                                                      false, // user must tap button!
                                                  builder:
                                                      (BuildContext context) {
                                                    return AlertDialog(
                                                      // <-- SEE HERE
                                                      title: const Text(
                                                          'Avertisement'),
                                                      content:
                                                          SingleChildScrollView(
                                                        child: ListBody(
                                                          children: const <Widget>[
                                                            Text(
                                                                'Une erreur de connexion est survenue, veuillez verifier votre connexion et ressayer'),
                                                          ],
                                                        ),
                                                      ),
                                                      actions: <Widget>[
                                                        TextButton(
                                                          child:
                                                              const Text('OK'),
                                                          onPressed: () async {
                                                            Navigator.of(
                                                                    context)
                                                                .pop();
                                                          },
                                                        ),
                                                      ],
                                                    );
                                                  },
                                                );
                                              }
                                            }*/
                                            //if(user)
                                            Navigator.push(
                                                        context,
                                                        MaterialPageRoute(
                                                            builder: (context) =>
                                                                OtpScreen()));
                                          },
                                    child: Center(
                                        child: Text('Suivant',
                                            style: TextStyle(
                                                color: Theme.of(context)
                                                    .primaryColor))))),
                            const SizedBox(height: 20),
                            /*Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  MyDivider(
                                      width: MediaQuery.of(context).size.width *
                                          0.35,
                                      height: 2,
                                      color:
                                          Color.fromARGB(255, 255, 255, 255)),
                                  const Text(
                                    'ou',
                                    style: TextStyle(
                                        color: Colors.white, fontSize: 20),
                                  ),
                                  MyDivider(
                                      width: MediaQuery.of(context).size.width *
                                          0.35,
                                      height: 2,
                                      color:
                                          Color.fromARGB(255, 255, 255, 255)),
                                ])*/
                            const SizedBox(height: 10),
                            /*Wrap(
                              spacing: 20,
                              children: [
                                IconButton(
                                    onPressed: () {},
                                    icon: Icon(Icons.apple,
                                        color: Colors.black, size: 40)),
                                IconButton(
                                    onPressed: () {},
                                    icon: const Icon(Icons.facebook,
                                        color: Colors.white, size: 40)),
                                IconButton(
                                    onPressed: () {},
                                    icon: const Icon(IonIcons.logo_google,
                                        color: Colors.yellow, size: 40)),
                                IconButton(
                                    onPressed: () {},
                                    icon: Icon(IonIcons.logo_instagram,
                                        color: Colors.purple, size: 42)),
                              ],
                            ),*/
                            const SizedBox(height: 30)
                          ],
                        ))
                  ],
                ),
              ))),
    );
  }
}
