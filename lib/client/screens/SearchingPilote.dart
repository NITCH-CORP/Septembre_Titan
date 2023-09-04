// ignore_for_file: sort_child_properties_last, prefer_const_literals_to_create_immutables, prefer_const_constructors, avoid_print, use_build_context_synchronously, unused_local_variable, unnecessary_null_comparison

import 'dart:async';

import 'package:appwrite/models.dart';
import 'package:flutter/material.dart';
import 'package:simple_ripple_animation/simple_ripple_animation.dart';
import 'package:provider/provider.dart';
import '../../state.dart';
import '../../utils/constants.dart';
import 'package:appwrite/appwrite.dart';
import 'package:geolocator/geolocator.dart';
import 'ClientMainScreen.dart';
import 'TrajetScreen.dart';
import 'package:flutter_osm_plugin/flutter_osm_plugin.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SearchingPilote extends StatefulWidget {
  String entrepriseId;
  String entrepriseNom;
  String index;
  SearchingPilote(this.entrepriseId, this.entrepriseNom, this.index,
      {super.key});

  @override
  State<SearchingPilote> createState() => _SearchingPiloteState();
}

class _SearchingPiloteState extends State<SearchingPilote> {
  GeoPoint? depart;
  Document? departDoc;
  Document? positionDoc;
  String trajetId = '';
  String rechercheId = '';
  //late SharedPreferences prefs;
  /*MapController mapController = MapController(
                            initPosition: GeoPoint(latitude: 47.4358055, longitude: 8.4737324),
                            areaLimit: BoundingBox( 
                                east: 10.4922941, 
                                north: 47.8084648, 
                                south: 45.817995, 
                                west:  5.9559113,
                      ),
            );*/
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

  void _unsbscribe() {
    /*final realtime = Realtime(client);
  realtime.subscribe([
      'databases.$DATABASE_ID.collections.$RECHERCHE_COLLECTION_ID.documents.$id',
    ]);*/
  }
  void _initWork(String id) async {
    final preferences = await SharedPreferences.getInstance();
    final realtime = Realtime(client);
    //String entrepriseId = await preferences.getString('entrepriseId')!;

    final subscription = realtime.subscribe([
      'databases.$DATABASE_ID.collections.$RECHERCHE_COLLECTION_ID.documents.$id',
    ]);

    subscription.stream.listen((response) async {
      // Callback will be executed on changes for documents A and all files.
      if (response.payload['pilote'] != null) {
        context.read<AppState>().rechercheId = id;
        if (true) {
          if (context.read<AppState>().destinationPosition == null) {
            String clientId = (preferences.getString('clientId'))!;
            print('OOOOOOOOOOOOOOOOOOOOOOOO');
            /*final trajet = await databases.createDocument(
              databaseId: DATABASE_ID,
              collectionId: '64d8fb6a7cf7a706070d',
              documentId: ID.unique(),
              data: {
                'client': clientId,
                'distance': 20,
                'pilote': response.payload['pilote']['\$id'],
              });
          trajetId = trajet.$id;*/
            final depart = await _determinePosition();

            final departDoc = await databases.createDocument(
                databaseId: DATABASE_ID,
                collectionId: POSITION_COLLECTION_ID,
                documentId: ID.unique(),
                data: {
                  'latitude': depart.latitude,
                  'longitude': depart.longitude,
                });

            final trajet = await databases.createDocument(
                databaseId: DATABASE_ID,
                collectionId: TRAJET_COLLECTION_ID,
                documentId: ID.unique(),
                data: {
                  'status': 'En Cours',
                  'pilote': response.payload['pilote']['\$id'],
                  'client': clientId,
                  'depart': departDoc.$id
                });
            trajetId = trajet.$id;

            print(trajet.data['client']);
            print(trajet.data['pilote']);
            print(trajet.data['depart']);

            context.read<AppState>().trajetId = trajet.$id;
            context.read<AppState>().isAvailable = false;
          } else {
            String clientId = (preferences.getString('clientId'))!;
            final destinationDoc = await databases.createDocument(
                databaseId: DATABASE_ID,
                collectionId: POSITION_COLLECTION_ID,
                documentId: ID.unique(),
                data: {
                  'latitude':
                      context.read<AppState>().destinationPosition?.latitude,
                  'longitude':
                      context.read<AppState>().destinationPosition?.longitude,
                });

            final depart = await _determinePosition();

            final departDoc = await databases.createDocument(
                databaseId: DATABASE_ID,
                collectionId: POSITION_COLLECTION_ID,
                documentId: ID.unique(),
                data: {
                  'latitude': depart.latitude,
                  'longitude': depart.longitude,
                });

            final trajet = await databases.createDocument(
                databaseId: DATABASE_ID,
                collectionId: TRAJET_COLLECTION_ID,
                documentId: ID.unique(),
                data: {
                  'status': 'En Cours',
                  'client': clientId,
                  'destination': destinationDoc.$id,
                  'pilote': response.payload['pilote']['\$id'],
                  'depart': departDoc.$id
                });
            trajetId = trajet.$id;
            context.read<AppState>().trajetId = trajet.$id;
            context.read<AppState>().isAvailable = false;
            /*final res = await http.get(Uri.parse(
              "http://192.168.43.187:2023/create-trajet/?pilote=${response.payload['pilote']}&client=$clientId&destination=${destinationDoc.$id}"));
          final res2 = jsonDecode(res.body);*/
            /*if (res2['success'] == "OK") {
            print('LLLLLLLLLLLLLLLLLLLLLL');
          }*/
          }
          await subscription.close();
          showDialog(
            context: context,
            barrierDismissible: false, // user must tap button!
            builder: (BuildContext context) {
              return AlertDialog(
                // <-- SEE HERE
                title: const Text('Information'),
                content: SingleChildScrollView(
                  child: ListBody(
                    children: const <Widget>[
                      Text('Un Pilote arrive vers votre position.'),
                    ],
                  ),
                ),
                actions: <Widget>[
                  TextButton(
                    child: const Text('Ok'),
                    onPressed: () async {
                      try {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => ClientMainScreen()),
                        );
                      } catch (e) {
                        print(e);
                      }
                      //Navigator.of(context).pop();
                    },
                  ),
                  /*TextButton(
                    child: const Text('Oui'),
                    onPressed: () async {
                      try {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => TrajetScreen(trajetId)),
                        );
                      } catch (e) {
                        print(e);
                      }
                      //Navigator.of(context).pop();
                    },
                  ),*/
                ],
              );
            },
          );
        }
        await subscription.close();
        //return;
      }
    });
  }

  Future<void> _initMainActivity() async {
    Future.delayed(const Duration(seconds: 0)).then((value) {
      /*return showDialog(
        context: context,
        barrierDismissible: false, // user must tap button!
        builder: (BuildContext context) {
          return AlertDialog(
            // <-- SEE HERE
            title: const Text('Information'),
            content: SingleChildScrollView(
              child: ListBody(
                children: const <Widget>[
                  Text(
                      'Un Pilote arrive vers votre position,Vous pouvez le consulter dans les historique.Voulez vous suivre sa position?'),
                ],
              ),
            ),
            actions: <Widget>[
              TextButton(
                child: const Text('Non'),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => HistoryScreen()),
                  );
                },
              ),
              TextButton(
                child: const Text('Oui'),
                onPressed: () async {
                  try {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => SuivreScreen(trajetId)),
                    );
                  } catch (e) {
                    print(e);
                  }
                  //Navigator.of(context).pop();
                },
              ),
            ],
          );
        },
      );*/
    });
    try {
      final preferences = await SharedPreferences.getInstance();
      Position ps = await _determinePosition();
      print(ps.latitude);
      depart = GeoPoint(latitude: ps.latitude, longitude: ps.longitude);
      String? clientId = await (preferences.getString('clientId'))!;
      print(depart);
      print(clientId);

      positionDoc = await databases.createDocument(
          databaseId: DATABASE_ID,
          collectionId: POSITION_COLLECTION_ID,
          documentId: ID.unique(),
          data: {
            'latitude': depart?.latitude,
            'longitude': depart?.longitude,
          });

      //print(positionDoc?.data);
      print('PPPPPPPPPPPPPPPPPPPPP');

      //print(positionDoc?.$id);

      final recherche = await databases.createDocument(
          databaseId: DATABASE_ID,
          collectionId: RECHERCHE_COLLECTION_ID,
          documentId: ID.unique(),
          data: {
            'client': clientId,
            'entreprise': widget.entrepriseId,
            'position': positionDoc?.$id
          });
      print(recherche.data['position']);
      print('XXXXXXXXXXXXXXXXXXXXXXXXX');
      rechercheId = recherche.$id;
      final rechercheUpdate = await databases.updateDocument(
          databaseId: DATABASE_ID,
          collectionId: RECHERCHE_COLLECTION_ID,
          documentId: recherche.$id,
          data: {'position': positionDoc?.$id});

      print('AAAAAAAAAAAAAAAAAAAa');
      print(rechercheUpdate.data['position']);
      _initWork(recherche.$id);

      /*final activite = await databases.createDocument(
          databaseId: DATABASE_ID,
          collectionId: ACTIVITE_COLLECTION_ID,
          documentId: ID.unique(),
          data: {
            'client': clientId,
            'categorie': 'RECHERCHEPILOTE',
            'description': 'Un client est a la recherche d\'un pilote'
          });*/
    } catch (e) {
      print('XXXXXXXXXXXXXXXXXXXXXXX');
      print(e);
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
                      'Une erreur et survenue veuillez verifier votre connexion internet!'),
                ],
              ),
            ),
            actions: <Widget>[
              TextButton(
                child: const Text('OK'),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
            ],
          );
        },
      );
      print(e);
    }
  }

  void _annulerRecherche(String id) async {
    try {
      final rechercuUpdate = await databases.updateDocument(
          databaseId: DATABASE_ID,
          collectionId: RECHERCHE_COLLECTION_ID,
          documentId: id,
          data: {'status': 'Annule'});
      Navigator.pop(context);
      Navigator.pop(context);
      Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => ClientMainScreen()),
                  );
    } catch (e) {
      print(e);
    }
  }

  @override
  void initState() {
    super.initState();
    _initMainActivity();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return WillPopScope(
      onWillPop: () {
        //print('');
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => ClientMainScreen()),
        );
        return Future.value(true);
      },
      child: Scaffold(
          appBar: AppBar(
              leading: IconButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  icon: const Icon(Icons.chevron_left, color: Colors.white)),
              backgroundColor: Colors.blue,
              title: Text('Taxi Moto', style: TextStyle(color: Colors.white))),
          body: SizedBox(
            width: size.width,
            height: size.height,
            child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  RippleAnimation(
                    child: CircleAvatar(
                        minRadius: 75,
                        maxRadius: 75,
                        child: Hero(
                            tag: widget.index,
                            child: Image.asset('assets/images/gozem3.png'))),
                    color: Colors.blue,
                    delay: const Duration(milliseconds: 300),
                    repeat: true,
                    minRadius: 75,
                    ripplesCount: 6,
                    duration: const Duration(milliseconds: 6 * 300),
                  ),
                  const SizedBox(
                    height: 30,
                  ),
                  /*SizedBox(
                      height: 60, child: Image.asset('assets/images/gozem.png')),*/
                  Text('Recherche de Taxi moto',
                      style: TextStyle(fontSize: 18)),
                  Text('${widget.entrepriseNom}',
                      style:
                          TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                  const SizedBox(
                    height: 50,
                  ),
                  Padding(
                    padding: const EdgeInsets.only(left: 18.0, right: 18.0),
                    child: ElevatedButton(
                        onPressed: () async {
                          return showDialog<void>(
                            context: context,
                            barrierDismissible: false, // user must tap button!
                            builder: (BuildContext context) {
                              return AlertDialog(
                                // <-- SEE HERE
                                title: const Text('Avertiseement'),
                                content: SingleChildScrollView(
                                  child: ListBody(
                                    children: const <Widget>[
                                      Text('Voulez vous annuler la recherche?'),
                                    ],
                                  ),
                                ),
                                actions: <Widget>[
                                  TextButton(
                                    child: const Text('Non'),
                                    onPressed: () {
                                      Navigator.of(context).pop();
                                    },
                                  ),
                                  TextButton(
                                    child: const Text('Oui'),
                                    onPressed: () async {
                                      try {
                                        _annulerRecherche(rechercheId);
                                      } catch (e) {
                                        print(e);
                                      }
                                      Navigator.of(context).pop();
                                    },
                                  ),
                                ],
                              );
                            },
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                        ),
                        child: Center(
                            child: Text('Annuler',
                                style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 17)))),
                  )
                ]),
          )),
    );
  }
}
