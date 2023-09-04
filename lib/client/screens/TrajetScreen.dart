// ignore_for_file: prefer_const_literals_to_create_immutables, prefer_const_constructors, sort_child_properties_last, avoid_print, use_build_context_synchronously

import 'package:appwrite/appwrite.dart';
import 'package:appwrite/models.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import '../../state.dart';
import '../../utils/constants.dart';
import 'ClientMainScreen.dart';
import 'SuivreScreen.dart';
import 'TrajetMapScreen.dart';
import 'package:rating_dialog/rating_dialog.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class TrajetScreen extends StatefulWidget {
  String id;
  TrajetScreen(this.id, {super.key});

  @override
  State<TrajetScreen> createState() => _TrajetScreen();
}

class _TrajetScreen extends State<TrajetScreen> {
  bool isLoading = true;
  bool isMarked = false;
  String trajetId = '';
  Document? trajetDoc;
  int avg = 0;

  void _loadTrajet(String trajetId) async {
    //print(widget.id);

    try {
      //print('YYYYYYYYYYYYYYYYYYYYYYYYYY');
      final trajet = await databases.getDocument(
          databaseId: DATABASE_ID,
          collectionId: TRAJET_COLLECTION_ID,
          documentId: widget.id);

      final notes = await databases.listDocuments(
          databaseId: DATABASE_ID,
          collectionId: NOTE_COLLECTION_ID,
          queries: [Query.equal('trajet', trajet.$id)]);
      if (notes.total != 0) {
        isMarked = true;
        avg = notes.documents[0].data['note'];
      }

      //print(trajet.data['pilote']['entreprises']);
      //if (trajetDoc?.data['status'] != 'Termine') {
      final realtime = Realtime(client);
      //String entrepriseId = await preferences.getString('entrepriseId')!;
      final subscription = realtime.subscribe([
        'databases.$DATABASE_ID.collections.$TRAJET_COLLECTION_ID.documents'
      ]);

      subscription.stream.listen((response) {
        /*print(response.payload['client']['\$id']);
        print(clientId);
        if (response.payload['client']['\$id'] == clientId) {
          print('IIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIII');
          //if(response.payload['client'])
          _initHistory();
        }*/
      });

      setState(() {
        isLoading = false;
        trajetDoc = trajet;
      });
    } catch (e) {
      print(e);
      print('WWWWWWWWWWWWWWWW');
      return showDialog<void>(
        context: context,
        barrierDismissible: false, // user must tap button!
        builder: (BuildContext context) {
          return AlertDialog(
            // <-- SEE HERE
            title: const Text('Erreur'),
            content: SingleChildScrollView(
              child: ListBody(
                children: const <Widget>[
                  Text(
                      'Impossible de se connecter au serveur veuillez verifier votre connection internet.....'),
                ],
              ),
            ),
            actions: <Widget>[
              TextButton(
                child: const Text('Ok'),
                onPressed: () async {
                  //_loadTrajet('');
                  Navigator.of(context).pop();
                },
              ),
            ],
          );
        },
      );
    }
  }

  Future<Position> _determinePosition() async {
    bool serviceEnabled;
    LocationPermission permission;

    // Test if location services are enabled.
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return Future.error('Location services are disabled.');
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return Future.error('Location permissions are denied');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      // Permissions are denied forever, handle appropriately.
      return Future.error(
          'Location permissions are permanently denied, we cannot request permissions.');
    }

    final userPosition = await Geolocator.getCurrentPosition();
    return userPosition;
  }

  DateFormat dateFormat = DateFormat("HH:mm:ss");

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadTrajet('');
    });
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    //print('XXXXXXXXXXXXXX');
    return Scaffold(
        appBar: AppBar(
            leading: IconButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                icon: const Icon(Icons.chevron_left, color: Colors.white)),
            title: Text('Trajet')),
        body: Padding(
            padding: const EdgeInsets.only(top: 10, left: 10, right: 10),
            child: isLoading == true
                ? const Center(child: CircularProgressIndicator())
                : SingleChildScrollView(
                    child: Container(
                        width: size.width,
                        decoration: BoxDecoration(
                          color: Colors.white,
                        ),
                        child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('Status',
                                  style: TextStyle(fontSize: 16)),
                              Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                    color: trajetDoc!.data['status'] ==
                                            'En Cours'
                                        ? Colors.red
                                        : trajetDoc!.data['status'] == 'Termine'
                                            ? Colors.green
                                            : Colors.black,
                                    borderRadius: BorderRadius.circular(5)),
                                child: Text(
                                    trajetDoc!.data['status'].toUpperCase(),
                                    style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white)),
                              ),
                              const SizedBox(height: 10),
                              trajetDoc?.data['status'] == 'Termine'
                                  ? Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        const Text('Distance',
                                            style: TextStyle(fontSize: 16)),
                                        Container(
                                            alignment: Alignment.centerLeft,
                                            child: Text(
                                                '${trajetDoc!.data['distance']} km',
                                                style: TextStyle(
                                                    fontSize: 18,
                                                    fontWeight:
                                                        FontWeight.bold)),
                                            height: 40,
                                            width: size.width,
                                            decoration: BoxDecoration(
                                              borderRadius:
                                                  BorderRadius.circular(10),
                                              border: Border.all(
                                                  width: 1, color: Colors.grey),
                                            )),
                                        const SizedBox(height: 20),
                                        const Text('Heure Depart',
                                            style: TextStyle(fontSize: 16)),
                                        Container(
                                            alignment: Alignment.centerLeft,
                                            child: Text(
                                                dateFormat.format(
                                                    DateTime.parse(trajetDoc!
                                                        .data['heure_debut'])),
                                                style: TextStyle(
                                                    fontSize: 18,
                                                    fontWeight:
                                                        FontWeight.bold)),
                                            height: 40,
                                            width: size.width,
                                            decoration: BoxDecoration(
                                              borderRadius:
                                                  BorderRadius.circular(10),
                                              border: Border.all(
                                                  width: 1, color: Colors.grey),
                                            )),
                                        const SizedBox(height: 20),
                                        const Text('Heure Arrivee',
                                            style: TextStyle(fontSize: 16)),
                                        Container(
                                            alignment: Alignment.centerLeft,
                                            child: Text(
                                                dateFormat.format(
                                                    DateTime.parse(trajetDoc!
                                                        .data['heure_arrive'])),
                                                style: TextStyle(
                                                    fontSize: 18,
                                                    fontWeight:
                                                        FontWeight.bold)),
                                            height: 40,
                                            width: size.width,
                                            decoration: BoxDecoration(
                                              borderRadius:
                                                  BorderRadius.circular(10),
                                              border: Border.all(
                                                  width: 1, color: Colors.grey),
                                            )),
                                      ],
                                    )
                                  : Text(''),
                              const SizedBox(height: 10),
                              const Text('Pilote',
                                  style: TextStyle(fontSize: 16)),
                              const SizedBox(height: 10),
                              Container(
                                padding: const EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.grey,
                                        blurRadius: 15.0, // soften the shadow
                                        spreadRadius: 5.0, //extend the shadow
                                        offset: Offset(
                                          10.0, // Move to right 5  horizontally
                                          5.0, // Move to bottom 5 Vertically
                                        ),
                                      )
                                    ],
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(30),
                                    border: Border.all(
                                        width: 2, color: Colors.grey)),
                                child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          Container(
                                              width: 50,
                                              height: 50,
                                              child: Center(
                                                  child: Icon(Icons.person,
                                                      color: Colors.white)),
                                              decoration: BoxDecoration(
                                                  color: Colors.grey,
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          35))),
                                          const SizedBox(width: 10),
                                          Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              mainAxisAlignment:
                                                  MainAxisAlignment.start,
                                              children: [
                                                Text(
                                                    '${trajetDoc!.data['pilote']['nom']} ${trajetDoc!.data['pilote']['prenom']}',
                                                    style: TextStyle(
                                                        fontSize: 18,
                                                        fontWeight:
                                                            FontWeight.bold)),
                                                Text(
                                                    'Pilote depuis ${DateTime.parse(trajetDoc!.data['pilote']['\$createdAt']).day}/${DateTime.parse(trajetDoc!.data['pilote']['\$createdAt']).month}/${DateTime.parse(trajetDoc!.data['pilote']['\$createdAt']).year}',
                                                    style: TextStyle(
                                                        fontSize: 15,
                                                        color: Colors.grey))
                                              ])
                                        ],
                                      ),
                                      const SizedBox(height: 5),
                                      Text(
                                          '${trajetDoc!.data['pilote']['nom']} ${trajetDoc!.data['pilote']['prenom']}  est un pilote de la societe  ${trajetDoc!.data['pilote']['entreprises']['nom']}. ${trajetDoc!.data['pilote']['entreprises']['nom']} est une entreprise specialiser dans le transport'),
                                      const SizedBox(height: 5),
                                      Row(
                                        children: [
                                          Icon(Icons.star,
                                              color: Colors.orange),
                                          isMarked == true
                                              ? Text('$avg/5',
                                                  style: TextStyle(
                                                      fontSize: 18,
                                                      fontWeight:
                                                          FontWeight.bold))
                                              : Text("Pas de note",
                                                  style: TextStyle(
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      fontSize: 16)),
                                          const Spacer(),
                                          Container(
                                              child: Center(
                                                  child: Text(
                                                      style: TextStyle(
                                                          fontWeight:
                                                              FontWeight.bold,
                                                          fontSize: 18),
                                                      '${trajetDoc!.data['pilote']['entreprises']['nom']}')))
                                        ],
                                      ),
                                    ]),
                              ),
                              const SizedBox(height: 20),
                              /*trajetDoc!.data['status'] == 'Termine'
                                  ? Column(children: [
                                      Text('Carte',
                                          style: TextStyle(
                                              fontSize: 18,
                                              fontWeight: FontWeight.bold)),
                                      const SizedBox(height: 10),
                                      GestureDetector(
                                        onTap: () {
                                          Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                  builder: (context) =>
                                                      TrajetMapScreen(
                                                          trajetDoc)));
                                        },
                                        child: Container(
                                            child: Hero(
                                                tag: 'trajet',
                                                child: Container(
                                                    width: double.infinity,
                                                    height: double.infinity,
                                                    decoration: BoxDecoration(
                                                        color: Colors.blue))),
                                            height: 200,
                                            decoration: BoxDecoration(
                                                color: Colors.blue)),
                                      )
                                    ])
                                  : Text(''),*/
                              const SizedBox(height: 10),
                              ElevatedButton(
                                  onPressed: trajetDoc!.data['status'] !=
                                          'En Cours'
                                      ? null
                                      : () {
                                          Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                  builder: (context) =>
                                                      SuivreScreen(
                                                          trajet: trajetDoc)));
                                        },
                                  child: SizedBox(
                                      width: double.infinity,
                                      child: Center(
                                          child: Text('Suivre le pilote')))),
                              const SizedBox(height: 10),
                              ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.red),
                                  onPressed: trajetDoc!.data['status'] !=
                                          'En Cours'
                                      ? null
                                      : () {
                                          showDialog(
                                            context: context,
                                            barrierDismissible:
                                                false, // user must tap button!
                                            builder: (BuildContext context) {
                                              return AlertDialog(
                                                // <-- SEE HERE
                                                title:
                                                    const Text('Avertisement'),
                                                content: SingleChildScrollView(
                                                  child: ListBody(
                                                    children: const <Widget>[
                                                      Text(
                                                          'Voulez vous vous annuler le trajet en cours?'),
                                                    ],
                                                  ),
                                                ),
                                                actions: <Widget>[
                                                  TextButton(
                                                    child: const Text('Non'),
                                                    onPressed: () {
                                                      Navigator.of(context)
                                                          .pop();
                                                    },
                                                  ),
                                                  TextButton(
                                                    child: const Text('Oui'),
                                                    onPressed: () async {
                                                      try {
                                                        final trajetUpdate =
                                                            await databases.updateDocument(
                                                                databaseId:
                                                                    DATABASE_ID,
                                                                collectionId:
                                                                    TRAJET_COLLECTION_ID,
                                                                documentId: widget.id,
                                                                data: {
                                                              'status': 'Annule'
                                                            });
                                                        final piloteUpdate =
                                                            await databases.updateDocument(
                                                                databaseId:
                                                                    DATABASE_ID,
                                                                collectionId:
                                                                    PILOTE_COLLECTION_ID,
                                                                documentId: trajetUpdate.data['pilote']['\$id'],
                                                                data: {
                                                              'occupe': false
                                                            });
                                                        context
                                                            .read<AppState>()
                                                            .isAvailable = true;
                                                        context
                                                            .read<AppState>()
                                                            .trajetId = '';
                                                        context
                                                            .read<AppState>()
                                                            .rechercheId = '';
                                                        Navigator.of(context)
                                                            .pop();
                                                        Navigator.push(
                                                            context,
                                                            MaterialPageRoute(
                                                                builder:
                                                                    (context) =>
                                                                        ClientMainScreen()));
                                                        //_loadTrajet(trajetId);
                                                        /*Future.delayed(
                                                                const Duration(
                                                                    seconds: 5))
                                                            .then((value) {
                                                          Navigator.push(
                                                              context,
                                                              MaterialPageRoute(
                                                                  builder:
                                                                      (context) =>
                                                                          ClientMainScreen()));
                                                        });*/
                                                      } catch (e) {
                                                        print(e);
                                                      }
                                                      /*Navigator.of(context)
                                                          .pop();*/
                                                    },
                                                  ),
                                                ],
                                              );
                                            },
                                          );
                                        },
                                  child: SizedBox(
                                      width: double.infinity,
                                      child: Center(child: Text('Annuler')))),
                              const SizedBox(height: 10),
                              /*ElevatedButton(
                                  onPressed:
                                      trajetDoc!.data['demarrer'] == false
                                          ? null
                                          : trajetDoc!.data['status'] ==
                                                  'Annule'
                                              ? null
                                              : trajetDoc!.data['status'] ==
                                                      'Termine'
                                                  ? null
                                                  : () {
                                                      showDialog(
                                                        context: context,
                                                        barrierDismissible:
                                                            false, // user must tap button!
                                                        builder: (BuildContext
                                                            context) {
                                                          return AlertDialog(
                                                            // <-- SEE HERE
                                                            title: const Text(
                                                                'Avertiseement'),
                                                            content:
                                                                SingleChildScrollView(
                                                              child: ListBody(
                                                                children: const <Widget>[
                                                                  Text(
                                                                      'Voulez vous vous Terminer le trajet ?'),
                                                                ],
                                                              ),
                                                            ),
                                                            actions: <Widget>[
                                                              TextButton(
                                                                child:
                                                                    const Text(
                                                                        'Non'),
                                                                onPressed: () {
                                                                  Navigator.of(
                                                                          context)
                                                                      .pop();
                                                                },
                                                              ),
                                                              TextButton(
                                                                child:
                                                                    const Text(
                                                                        'Oui'),
                                                                onPressed:
                                                                    () async {
                                                                  try {
                                                                    final position =
                                                                        await _determinePosition();

                                                                    final positionDoc = await databases.createDocument(
                                                                        databaseId:
                                                                            DATABASE_ID,
                                                                        collectionId: POSITION_COLLECTION_ID,
                                                                        documentId: ID.unique(),
                                                                        data: {
                                                                          'latitude':
                                                                              position.latitude,
                                                                          'longitude':
                                                                              position.longitude
                                                                        });

                                                                    final trajetUpdate = await databases.updateDocument(
                                                                        databaseId:
                                                                            DATABASE_ID,
                                                                        collectionId:
                                                                            TRAJET_COLLECTION_ID,
                                                                        documentId:
                                                                            widget.id,
                                                                        data: {
                                                                          'status':
                                                                              'Termine',
                                                                          'heure_arrive':
                                                                              DateTime.now().toIso8601String(),
                                                                          'distance':
                                                                              12,
                                                                          'destination':
                                                                              positionDoc.$id,
                                                                        });

                                                                    Navigator.pop(
                                                                        context);
                                                                    final dialog =
                                                                        RatingDialog(
                                                                      initialRating:
                                                                          4.0,
                                                                      // your app's name?
                                                                      title:
                                                                          Text(
                                                                        'Note',
                                                                        textAlign:
                                                                            TextAlign.center,
                                                                        style:
                                                                            const TextStyle(
                                                                          fontSize:
                                                                              25,
                                                                          fontWeight:
                                                                              FontWeight.bold,
                                                                        ),
                                                                      ),
                                                                      // encourage your user to leave a high rating?
                                                                      message:
                                                                          Text(
                                                                        'Pouvez vous prendre quelques secondes pour noter le pilote s\'il vous plait.',
                                                                        textAlign:
                                                                            TextAlign.center,
                                                                        style: const TextStyle(
                                                                            fontSize:
                                                                                15),
                                                                      ),
                                                                      // your app's logo?
                                                                      image: Image.asset(
                                                                          'assets/images/titan.png',
                                                                          width:
                                                                              30,
                                                                          height:
                                                                              30),
                                                                      submitButtonText:
                                                                          'Soumettre',
                                                                      commentHint:
                                                                          'Merci',
                                                                      onCancelled:
                                                                          () =>
                                                                              print('Annule'),
                                                                      onSubmitted:
                                                                          (response) async {
                                                                        final noteDoc = await databases.createDocument(
                                                                            databaseId:
                                                                                DATABASE_ID,
                                                                            collectionId:
                                                                                NOTE_COLLECTION_ID,
                                                                            documentId:
                                                                                ID.unique(),
                                                                            data: {
                                                                              'client': trajetDoc!.data['client']['\$id'],
                                                                              'pilote': trajetDoc!.data['pilote']['\$id'],
                                                                              'trajet': trajetDoc!.$id,
                                                                              'note': response.rating
                                                                            });
                                                                        print(
                                                                            'SSSSSSSSSSSSSSSSSS');

                                                                        // TODO: add your own logic
                                                                      },
                                                                    );

                                                                    _loadTrajet(
                                                                        trajetId);
                                                                    // show the dialog
                                                                    return showDialog(
                                                                      context:
                                                                          context,
                                                                      barrierDismissible:
                                                                          true, // set to false if you want to force a rating
                                                                      builder:
                                                                          (context) =>
                                                                              dialog,
                                                                    );
                                                                  } catch (e) {
                                                                    print(e);
                                                                  }
                                                                  Navigator.of(
                                                                          context)
                                                                      .pop();
                                                                },
                                                              ),
                                                            ],
                                                          );
                                                        },
                                                      );
                                                    },
                                  child: SizedBox(
                                      width: double.infinity,
                                      child: Center(
                                          child:
                                              Text('Marque comme termine')))),*/
                              const SizedBox(height: 10),
                              ElevatedButton(
                                  onPressed: trajetDoc!.data['status'] !=
                                          'Termine'
                                      ? null
                                      : isMarked == true
                                          ? null
                                          : () {
                                              print(
                                                  'NNNNNNNNNNNNNNNNNNNNNNNNNNNNN');
                                              final dialog = RatingDialog(
                                                initialRating: 4.0,
                                                // your app's name?
                                                title: Text(
                                                  'Note',
                                                  textAlign: TextAlign.center,
                                                  style: const TextStyle(
                                                    fontSize: 25,
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                ),
                                                // encourage your user to leave a high rating?
                                                message: Text(
                                                  'Pouvez vous prendre quelques secondes pour noter le pilote s\'il vous plait.',
                                                  textAlign: TextAlign.center,
                                                  style: const TextStyle(
                                                      fontSize: 15),
                                                ),
                                                // your app's logo?
                                                image: Image.asset(
                                                    'assets/images/titan.png',
                                                    width: 30,
                                                    height: 30),
                                                submitButtonText: 'Soumettre',
                                                commentHint: 'Merci',
                                                onCancelled: () =>
                                                    print('Annule'),
                                                onSubmitted: (response) async {
                                                  final noteDoc = await databases
                                                      .createDocument(
                                                          databaseId:
                                                              DATABASE_ID,
                                                          collectionId:
                                                              NOTE_COLLECTION_ID,
                                                          documentId:
                                                              ID.unique(),
                                                          data: {
                                                        'client': trajetDoc!
                                                                .data['client']
                                                            ['\$id'],
                                                        'pilote': trajetDoc!
                                                                .data['pilote']
                                                            ['\$id'],
                                                        'trajet':
                                                            trajetDoc!.$id,
                                                        'note': response.rating
                                                      });
                                                  print('SSSSSSSSSSSSSSSSSS');

                                                  _loadTrajet('');

                                                  // TODO: add your own logic
                                                },
                                              );
                                              //dialog.sho
                                              showDialog(
                                                context: context,
                                                barrierDismissible:
                                                    true, // set to false if you want to force a rating
                                                builder: (context) => dialog,
                                              );
                                            },
                                  child: SizedBox(
                                      width: double.infinity,
                                      child: Center(
                                          child: Text('Noter le service'))))
                              /*ElevatedButton(
                                  onPressed: trajetDoc!.data['demarrer'] == true
                                      ? null
                                      : trajetDoc!.data['status'] != 'En Cours'
                                          ? null
                                          : () {
                                              showDialog(
                                                context: context,
                                                barrierDismissible:
                                                    false, // user must tap button!
                                                builder:
                                                    (BuildContext context) {
                                                  return AlertDialog(
                                                    // <-- SEE HERE
                                                    title: const Text(
                                                        'Avertiseement'),
                                                    content:
                                                        SingleChildScrollView(
                                                      child: ListBody(
                                                        children: const <Widget>[
                                                          Text(
                                                              'Voulez vous vous debuter le trajet ?'),
                                                        ],
                                                      ),
                                                    ),
                                                    actions: <Widget>[
                                                      TextButton(
                                                        child:
                                                            const Text('Non'),
                                                        onPressed: () {
                                                          Navigator.of(context)
                                                              .pop();
                                                        },
                                                      ),
                                                      TextButton(
                                                        child:
                                                            const Text('Oui'),
                                                        onPressed: () async {
                                                          try {
                                                            final trajetUpdate = await databases.updateDocument(
                                                                databaseId:
                                                                    DATABASE_ID,
                                                                collectionId:
                                                                    TRAJET_COLLECTION_ID,
                                                                documentId: widget.id,
                                                                data: {
                                                                  'demarrer':
                                                                      true,
                                                                  'heure_debut':
                                                                      DateTime.now()
                                                                          .toIso8601String()
                                                                });
                                                            _loadTrajet(
                                                                trajetId);
                                                          } catch (e) {
                                                            print(e);
                                                          }
                                                          Navigator.of(context)
                                                              .pop();
                                                        },
                                                      ),
                                                    ],
                                                  );
                                                },
                                              );
                                            },
                                  child: Container(
                                      width: double.infinity,
                                      child: Center(
                                          child: Text('Demarrer le trajet')))),*/
                            ])),
                  )));
  }
}
////http://bourse.uemoa.int/bourseonline/inscription.php