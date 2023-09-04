// ignore_for_file: use_build_context_synchronously, prefer_const_constructors, dead_code

import 'package:appwrite/models.dart';
import 'package:flutter/material.dart';
import 'package:intl_phone_number_input/intl_phone_number_input.dart';
//import 'package:parse_server_sdk_flutter/parse_server_sdk_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:titantrue/client/screens/ClientMainScreen.dart';

import '../../pilote/PiloteMainScreen.dart';
import '../../utils/constants.dart';
import 'RegisterScreen.dart';
import 'package:appwrite/appwrite.dart';
import './ChangePasswordScreen.dart';
//import 'package:dart_appwrite/dart_appwrite.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final formKey = GlobalKey<FormState>();
  final numeroController = TextEditingController();
  final passwordController = TextEditingController();
  String initialCountry = 'TG';
  PhoneNumber number = PhoneNumber(isoCode: 'TG');
  final phoneController = TextEditingController();
  bool isWorking = false;

  //final authService = AuthService();

  Future<void> _login() async {
    try {
      setState(() {
        isWorking = true;
      });
      print(number.phoneNumber);
      SharedPreferences preferences = await SharedPreferences.getInstance();
      final clients = await databases.listDocuments(
          databaseId: DATABASE_ID,
          collectionId: CLIENT_COLLECTION_ID,
          queries: [Query.equal('numero', number.phoneNumber)]);
      if (clients.total != 0) {
        print('Client');
        final client = clients.documents[0];
        print(client.data);
        if (client.data['actif'] == false) {
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
                      Text(
                          'Votre compte a ete desactivie,veuillez contacter l\'equipe Titan'),
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
          setState(() {
            isWorking = false;
          });
          return;
        }

        print(client.data['supprime']);
        if (client.data['supprime'] == true) {
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
                      Text('Votre compte a ete supprimer !'),
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
          setState(() {
            isWorking = false;
          });
          return;
        }

        Session session = await account.createEmailSession(
            email: client.data['email'], password: passwordController.text);
        final result = await databases.createDocument(
          databaseId: DATABASE_ID,
          collectionId: ACTIVITE_COLLECTION_ID,
          documentId: ID.unique(),
          data: {
            'categorie': 'CONNECTIONCLIENT',
            'client': client.$id,
            'description':
                "Le client ${client.data['nom']} ${client.data['prenom']} s'est connecte"
          },
        );

        //await preferences.setString('username', user.name);
        await preferences.setString('nom', client.data['nom']);
        await preferences.setString('prenom', client.data['prenom']);
        await preferences.setString('telephone', client.data['numero']);
        await preferences.setString('password', passwordController.text);
        await preferences.setString('email', client.data['email']);
        await preferences.setString('accountType', 'Client');
        await preferences.setString('clientId', client.$id);
        await preferences.setString('userId', session.userId);
        await preferences.setBool('login', true);
        Navigator.push(context,
            MaterialPageRoute(builder: (context) => ClientMainScreen()));
        return;
      }

      print(number.phoneNumber);
      final pilotes = await databases.listDocuments(
          databaseId: DATABASE_ID,
          collectionId: PILOTE_COLLECTION_ID,
          queries: [Query.equal('numero', number.phoneNumber)]);
      if (pilotes.total != 0) {
        final pilote = pilotes.documents[0];

        if (pilote.data['actif'] == false) {
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
                      Text(
                          'Votre compte a ete desactivie,veuillez contacter l\'equipe Titan'),
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
          setState(() {
            isWorking = false;
          });
          return;
        }

        //print(client.data['supprime']);
        if (pilote.data['supprime'] == true) {
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
                      Text('Votre compte a ete supprimer !'),
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
          setState(() {
            isWorking = false;
          });
          return;
        }

        Session session = await account.createEmailSession(
            email: pilote.data['email'], password: passwordController.text);
        final result = await databases.createDocument(
          databaseId: DATABASE_ID,
          collectionId: ACTIVITE_COLLECTION_ID,
          documentId: ID.unique(),
          data: {
            'categorie': 'CONNECTIONPILOTE',
            'pilote': pilote.$id,
            'description':
                "Le pilote ${pilote.data['nom']} ${pilote.data['prenom']} s'est connecter"
          },
        );

        await preferences.setString('nom', pilote.data['nom']);
        await preferences.setString('prenom', pilote.data['prenom']);
        await preferences.setString('telephone', pilote.data['numero']);
        await preferences.setString('password', passwordController.text);
        await preferences.setString('email', pilote.data['email']);
        await preferences.setString('accountType', 'Pilote');
        await preferences.setString('piloteId', pilote.data['\$id']);
        await preferences.setString(
            'entrepriseId', pilote.data['entreprises']['\$id']);

        if (pilote.data['premiere_fois'] == true) {
          Navigator.push(context,
              MaterialPageRoute(builder: (context) => CgangePasswordScreen(passwordController.text.toString())));
          return;
        }

        //await preferences.setString('username', user.name);

        await preferences.setString('userId', session.userId);
        //await preferences.setBool('login', true);
        Navigator.push(context,
            MaterialPageRoute(builder: (context) => PiloteMainScreen()));
        return;
      }
      setState(() {
        isWorking = false;
      });
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
                  Text('Aucun compte ne correspond a ce numero'),
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
    } catch (e) {
      print(e);
      setState(() {
        isWorking = false;
      });
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
                  Text(
                      'Impossible de se connecter au serveur,veuillez verifier votre connexion internet'),
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
      body: SingleChildScrollView(
          child: SingleChildScrollView(
        child: SafeArea(
            top: false,
            child: Container(
              padding: const EdgeInsets.only(left: 20, right: 20),
              decoration: BoxDecoration(color: Colors.blue),
              width: MediaQuery.of(context).size.width,
              height: MediaQuery.of(context).size.height,
              child: ListView(
                /*mainAxisAlignment: MainAxisAlignment.center,
                 crossAxisAlignment: CrossAxisAlignment.center,*/
                children: [
                  /*Row(
             mainAxisAlignment: MainAxisAlignment.end,
             children: [
               
               TextButton(onPressed: (){}, child: Text("S'inscrire",style:TextStyle(color:Colors.white,fontSize: 20)))
             ],
                   ),*/
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
                            child: InternationalPhoneNumberInput(
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
                              selectorTextStyle: TextStyle(color: Colors.white),
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
                          ),
                          const SizedBox(height: 20),
                          SizedBox(
                            width: MediaQuery.of(context).size.width,
                            child: TextFormField(
                            obscureText: true,
                              controller: passwordController,
                              validator: (value) {
                                if (value!.length < 10) {
                                  return 'Veuillez entrer un mot de pass de plus de 10 caracterers';
                                  return null;
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
                                    icon:
                                        Icon(Icons.clear, color: Colors.white),
                                  ),
                                  labelStyle: TextStyle(color: Colors.white),
                                  hintText: 'Mot de pass',
                                  errorStyle: TextStyle(color: Colors.white),
                                  hintStyle: TextStyle(color: Colors.white)),
                            ),
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
                                          side:
                                              BorderSide(color: Colors.white))),
                                  onPressed: isWorking == true
                                      ? null
                                      : () async {
                                          //_login();
                                          //if(user)
                                                  Navigator.push(context,
            MaterialPageRoute(builder: (context) => ClientMainScreen()));
                                        },
                                  child: Center(
                                      child: Text('Se connecter',
                                          style: TextStyle(
                                              color: Theme.of(context)
                                                  .primaryColor))))),
                          const SizedBox(height: 10),
                          SizedBox(
                              width: MediaQuery.of(context).size.width,
                              child: ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.blue,
                                      shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(18.0),
                                          side:
                                              BorderSide(color: Colors.white))),
                                  onPressed: () {
                                    Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                            builder: (context) =>
                                                RegisterScreen()));
                                  },
                                  child: Center(
                                      child: Text('S\'inscrire',
                                          style: TextStyle(
                                              color: Colors.white))))),
                          const SizedBox(height: 20),
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
                          )*/
                        ],
                      ))
                ],
              ),
            )),
      )),
    );
  }
}


/**
 *   Future<void> signInWithEmailAndPassword() async {
    try {
      final account = Account(client);
      //client.users.
      //print('IIIIII');
      Session session = await account.createEmailSession(
          email: emailController.text, password: passwordController.text);

      if (session.current) {
        User user = await account.get();
        final prefs = await account.getPrefs();
        print(prefs.data);

        SharedPreferences preferences = await SharedPreferences.getInstance();
        //await preferences.setBool('login', true);

        if (prefs.data['accountType'] == 'Client') {
          final v = await databases.listDocuments(
              databaseId: DATABASE_ID,
              collectionId: CLIENT_COLLECTION_ID,
              queries: [Query.equal('user_id', user.$id)]);
          //print(v.documents);

          Document doc = v.documents[0];

          final result = await databases.createDocument(
            databaseId: DATABASE_ID,
            collectionId: ACTIVITE_COLLECTION_ID,
            documentId: ID.unique(),
            data: {
              'categorie': 'CONNECTIONCLIENT',
              'client': doc.$id,
              'description': 'Un client vient de se connecter'
            },
          );
          await preferences.setBool('login', true);
          await preferences.setString('username', user.name);
          await preferences.setString('password', passwordController.text);
          await preferences.setString('email', emailController.text);
          await preferences.setString('accountType', prefs.data['accountType']);
          Navigator.push(context,
              MaterialPageRoute(builder: (context) => ClientMainScreen()));
        }
        if (prefs.data['accountType'] == 'Pilote') {
          final v = await databases.listDocuments(
              databaseId: DATABASE_ID,
              collectionId: PILOTE_COLLECTION_ID,
              queries: [Query.equal('user_id', user.$id)]);
          //print(v.documents);
          print(v.documents);
          Document doc = v.documents[0];

          final result = await databases.createDocument(
            databaseId: DATABASE_ID,
            collectionId: ACTIVITE_COLLECTION_ID,
            documentId: ID.unique(),
            data: {
              'categorie': 'CONNECTIONPILOTE',
              'pilote': doc.$id,
              'description': 'Un pilote vient de se connecter'
            },
          );
          await preferences.setBool('login', true);
          await preferences.setString('username', user.name);
          await preferences.setString('password', passwordController.text);
          await preferences.setString('email', emailController.text);
          await preferences.setString('accountType', prefs.data['accountType']);
          Navigator.push(context,
              MaterialPageRoute(builder: (context) => PiloteMainScreen()));
        }
      }
    }

    //print(session.current);
    catch (e) {
      print(e.toString() ==
          'AppwriteException: general_argument_invalid, Invalid password: Password must be at least 8 characters');
      debugPrint(e.toString());
    }
  }
 */