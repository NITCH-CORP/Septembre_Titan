// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:titantrue/pilote/PiloteMainScreen.dart';
import '../../utils/constants.dart';

class CgangePasswordScreen extends StatefulWidget {
String password;
  CgangePasswordScreen(String this.password,{super.key});

  @override
  State<CgangePasswordScreen> createState() => _CgangePasswordScreenState();
}

class _CgangePasswordScreenState extends State<CgangePasswordScreen> {
  final passwordController = TextEditingController();
  bool isLoading = false;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Container(
      height: MediaQuery.of(context).size.height,
      decoration: const BoxDecoration(color: Colors.blue),
      child: Padding(
        padding: const EdgeInsets.all(10.0),
        child: SingleChildScrollView(
          child: Column(
            children: [
              Image.asset('assets/images/titan.png'),
              TextFormField(
                controller: passwordController,
                validator: (value) {
                  if (value!.length < 10) {
                    return 'Veuillez entrer un mot de pass de plus de 10 caracterers';
                    return null;
                  }
                  return null;
                },
                style: const TextStyle(
                  color: Colors.white,
                ),
                decoration: InputDecoration(
                    suffixIcon: IconButton(
                      onPressed: () {},
                      icon: const Icon(Icons.clear, color: Colors.white),
                    ),
                    labelStyle: const TextStyle(color: Colors.white),
                    hintText: 'Mot de pass',
                    errorStyle: const TextStyle(color: Colors.white),
                    hintStyle: const TextStyle(color: Colors.white)),
              ),
              const SizedBox(height: 10),
              SizedBox(
                width: MediaQuery.of(context).size.width,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(18.0),
                          side: const BorderSide(color: Colors.white))),
                  onPressed: isLoading == true
                      ? null
                      : () async {
                          try {
                            setState(() {
                              isLoading = true;
                            });
                            if (passwordController.text.toString().length <
                                10) {
                              showDialog<void>(
                                context: context,
                                barrierDismissible:
                                    false, // user must tap button!
                                builder: (BuildContext context) {
                                  return AlertDialog(
                                    // <-- SEE HERE
                                    title: const Text('Avertisement'),
                                    content: const SingleChildScrollView(
                                      child: ListBody(
                                        children: <Widget>[
                                          Text(
                                              'Votre mot de pass est trop court veuillez choisir un de plus de 10 caractere au moins'),
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
                                isLoading = false;
                              });
                              return;
                            }
                            final user = await account.get();
                            print(user.email);
                            print(user.phone);
                            await account.updatePassword(
                                oldPassword: '${widget.password}',
                                password: passwordController.text.toString());
                            SharedPreferences prefs =
                                await SharedPreferences.getInstance();

                            String piloteId =
                                prefs.getString('piloteId')!;
                            final doc = await databases.updateDocument(
                                databaseId: DATABASE_ID,
                                collectionId: PILOTE_COLLECTION_ID,
                                documentId: piloteId,
                                data: {'premiere_fois': false});
                            await prefs.setBool('login', true);

                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => const PiloteMainScreen()));
                            return;
                            /*setState(() {
                              isLoading = false;
                            });*/
                          } catch (e) {
                            setState(() {
                              isLoading = false;
                            });
                            showDialog<void>(
                              context: context,
                              barrierDismissible:
                                  false, // user must tap button!
                              builder: (BuildContext context) {
                                return AlertDialog(
                                  // <-- SEE HERE
                                  title: const Text('Erreur'),
                                  content: const SingleChildScrollView(
                                    child: ListBody(
                                      children: <Widget>[
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
                            print(e);
                          }
                        },
                  child: const Center(
                      child: Text('Suivant',
                          style: TextStyle(color: Colors.blue, fontSize: 18))),
                ),
              )
            ],
          ),
        ),
      ),
    ));
  }
}
