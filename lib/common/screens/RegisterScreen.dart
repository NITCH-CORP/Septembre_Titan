// ignore_for_file: prefer_const_constructors, use_build_context_synchronously, avoid_print

//import 'dart:js_interop';

//import 'dart:js_interop';
import 'package:intl_phone_number_input/intl_phone_number_input.dart';

import 'package:appwrite/appwrite.dart';
import 'package:flutter/material.dart';
import 'package:titantrue/common/screens/RegisterScreen2.dart';
//import 'package:parse_server_sdk_flutter/parse_server_sdk_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:titantrue/state.dart';
import 'package:provider/provider.dart';

import '../../utils/constants.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final formKey = GlobalKey<FormState>();
  final nomController = TextEditingController();
  final prenomController = TextEditingController();
  bool isWorking = false;
  String accountType = 'Client';
  late SharedPreferences preferences;

  //final GlobalKey<FormState> formKey = GlobalKey<FormState>();

  //final TextEditingController controller = TextEditingController();
  String initialCountry = 'TG';
  PhoneNumber number = PhoneNumber(isoCode: 'TG');
  final phoneController = TextEditingController();

  void initBackground() async {
    print('ssssssssss');

    preferences = await SharedPreferences.getInstance();
  }

  Future<bool> checkNumber() async {
    final clients = await databases.listDocuments(
        databaseId: DATABASE_ID,
        collectionId: CLIENT_COLLECTION_ID,
        queries: [Query.equal('numero', number.phoneNumber)]);
    if (clients.total != 0) {
      showDialog<void>(
        context: context,
        barrierDismissible: false, // user must tap button!
        builder: (BuildContext context) {
          return AlertDialog(
            // <-- SEE HERE
            title: const Text('Avertisement'),
            content: SingleChildScrollView(
              child: ListBody(
                children: const <Widget>[
                  Text('Cet numero est deja uilise par un autre client'),
                ],
              ),
            ),
            actions: <Widget>[
              TextButton(
                child: const Text('OK'),
                onPressed: () async {
                  phoneController.clear();
                  Navigator.of(context).pop();
                },
              ),
            ],
          );
        },
      );
      setState(() {
        isWorking = false;
      });
      phoneController.clear();
      return true;
    }
    setState(() {
      isWorking = false;
    });
    return false;
  }

  /*Future<void> registernWithEmailAndPassword() async {
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
          //await preferences.setBool('login', true);
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
*/
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
                                controller: nomController,
                                validator: (value) {
                                  if (value!.length < 2) {
                                    return 'Veuillez entre un nom de plus de 2 caracteres';
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
                                    hintText: 'Nom',
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
                                controller: prenomController,
                                validator: (value) {
                                  if (value!.length < 2) {
                                    return 'Veuillez entrer un prenom de plus de 2 caracteres';
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
                                    hintText: 'Prenom',
                                    errorStyle:
                                        const TextStyle(color: Colors.white),
                                    hintStyle:
                                        const TextStyle(color: Colors.white)),
                              ),
                            ),
                            const SizedBox(height: 20),
                            SizedBox(
                              width: MediaQuery.of(context).size.width,
                              child: InternationalPhoneNumberInput(
                                // value:'df',
                                hintText: 'Numero de telephone',
                                textStyle: TextStyle(color: Colors.white),
                                errorMessage: 'Numero de telephone incorrect',
                                validator: (value) {
                                  if (value!.length < 8) {
                                    return 'Veuillez entrer un numero valide';
                                  }
                                  return null;
                                },
                                onInputChanged: (PhoneNumber numbert) {
                                  //print(number.phoneNumber);
                                  setState(() {
                                    number = numbert;
                                  });
                                },
                                onInputValidated: (bool value) {},
                                selectorConfig: SelectorConfig(
                                  selectorType:
                                      PhoneInputSelectorType.BOTTOM_SHEET,
                                ),
                                ignoreBlank: false,
                                autoValidateMode: AutovalidateMode.disabled,
                                selectorTextStyle:
                                    TextStyle(color: Colors.white),
                                initialValue: number,
                                textFieldController: phoneController,
                                formatInput: false,
                                keyboardType: TextInputType.numberWithOptions(
                                    signed: true, decimal: true),
                                onSaved: (PhoneNumber numbert) {
                                  //print('On Saved: $number');
                                  setState(() {
                                    number = numbert;
                                  });
                                },
                              ),
                              /*TextFormField(
                                keyboardType: TextInputType.number,
                                controller: phoneController,
                                validator: (value) {
                                  if (value!.length != 8) {
                                    return 'Veuillez entrer un numero valide';
                                    //return null;
                                  }
                                  return null;
                                },
                                style: TextStyle(
                                  color: Colors.white,
                                ),
                                decoration: InputDecoration(
                                    /*border:OutlineInputBorder(
                            borderSide: BorderSide(
                              color:Color.fromARGB(255, 0, 0, 0),
                              width: 10,
                            )
                          ),*/
                                    suffixIcon: IconButton(
                                      onPressed: () {},
                                      icon: Icon(Icons.clear,
                                          color: Colors.white),
                                    ),
                                    labelStyle: TextStyle(color: Colors.white),
                                    hintText: 'Telephone',
                                    errorStyle: TextStyle(color: Colors.white),
                                    hintStyle: TextStyle(color: Colors.white)),
                              ),*/
                            ),
                            const SizedBox(height: 20),
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
                                              bool l = await checkNumber();
                                              if (l == false) {
                                                context
                                                        .read<AppState>()
                                                        .myUser =
                                                    MyUser(
                                                        nom: nomController.text,
                                                        prenom: prenomController
                                                            .text,
                                                        telephone: number
                                                            .phoneNumber!);
                                                print(context
                                                    .read<AppState>()
                                                    .myUser
                                                    ?.telephone);
                                                Navigator.push(
                                                    context,
                                                    MaterialPageRoute(
                                                        builder: (context) =>
                                                            RegisterScreen2()));

                                                setState(() {
                                                  isWorking = false;
                                                });
                                              }
                                              phoneController.clear();
                                              phoneController.text = '';
                                              //phoneController.value = '';
                                              //phoneController.
                                              setState(() {
                                                number = PhoneNumber(
                                                    isoCode: 'TG',
                                                    phoneNumber: '');
                                                phoneController.text = '';
                                              });
                                            }*/
                                            Navigator.push(
                                                    context,
                                                    MaterialPageRoute(
                                                        builder: (context) =>
                                                            RegisterScreen2()));
                                            //print(phoneController.text);
                                            //print(number);
                                          },
                                    child: Center(
                                        child: Text('Suivant',
                                            style: TextStyle(
                                                color: Theme.of(context)
                                                    .primaryColor))))),
                            const SizedBox(height: 10),
                            /*SizedBox(
                                width: MediaQuery.of(context).size.width,
                                child: ElevatedButton(
                                    style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors.blue,
                                        shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(18.0),
                                            side: BorderSide(
                                                color: Colors.white))),
                                    onPressed: () {
                                      /*Navigator.push(
                               context,
                               MaterialPageRoute(
                                   builder: (context) => RegisterScreen()))*/
                                      Navigator.pop(context);
                                    },
                                    child: const Center(
                                        child: Text('Se connecter',
                                            style: TextStyle(
                                                color: Colors.white))))),*/
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
                            const Text('By NITCH CORP',
                                style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold)),
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
