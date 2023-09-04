// ignore_for_file: prefer_const_literals_to_create_immutables, prefer_const_constructors, sort_child_properties_last, avoid_print, use_build_context_synchronously

import 'package:appwrite/appwrite.dart';
import 'package:appwrite/models.dart';
import 'package:flutter/material.dart';
import 'package:flutter_osm_plugin/flutter_osm_plugin.dart';
import 'package:geolocator/geolocator.dart';
import '../../utils/constants.dart';
//import 'SuivreScreen.dart';
//import 'TrajetMapScreen.dart';

import '../client/screens/TrajetMapScreen.dart';
import 'ClientPathScreen.dart';
import 'package:intl/intl.dart';

class PiloteTrajetScreen extends StatefulWidget {
  String id;
  PiloteTrajetScreen(this.id, {super.key});

  @override
  State<PiloteTrajetScreen> createState() => _PiloteTrajetScreen();
}

class _PiloteTrajetScreen extends State<PiloteTrajetScreen> {
  bool isLoading = true;
  String trajetId = '';
  Document? trajetDoc;
  double avg = 0;
  Document? note;
  MapController mapController = MapController(
      initPosition: GeoPoint(
    latitude: 1.23554,
    longitude: 1.12157,
  ));

  void _loadTrajet(String trajetId) async {
    try {
      final trajet = await databases.getDocument(
          databaseId: DATABASE_ID,
          collectionId: TRAJET_COLLECTION_ID,
          documentId: widget.id);
      final notes = await databases.listDocuments(
          databaseId: DATABASE_ID,
          collectionId: NOTE_COLLECTION_ID,
          queries: [Query.equal('trajet', trajet.$id)]);

      if (notes.total != 0) {
        note = notes.documents[0];
      }

      //print(trajet.data['pilote']['entreprises']);
      setState(() {
        isLoading = false;
        trajetDoc = trajet;
      });
    } catch (e) {
      print(e);
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
                  _loadTrajet('');
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

  @override
  void initState() {
    super.initState();
    _loadTrajet('');
  }

  DateFormat dateFormat = DateFormat("HH:mm:ss");
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
                              const Text('Client',
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
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    children: [
                                      Row(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        mainAxisAlignment:
                                            MainAxisAlignment.start,
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
                                                    '${trajetDoc!.data['client']['nom']} ${trajetDoc!.data['client']['prenom']}',
                                                    style: TextStyle(
                                                        fontSize: 18,
                                                        fontWeight:
                                                            FontWeight.bold)),
                                                Text(
                                                    'Client depuis ${DateTime.parse(trajetDoc!.data['client']['\$createdAt']).day}/${DateTime.parse(trajetDoc!.data['client']['\$createdAt']).month}/${DateTime.parse(trajetDoc!.data['client']['\$createdAt']).year}',
                                                    style: TextStyle(
                                                        fontSize: 15,
                                                        color: Colors.grey))
                                              ])
                                        ],
                                      ),
                                      const SizedBox(height: 5),
                                      Row(
                                        children: [
                                          note == null
                                              ? Text('Pas de note',
                                                  style: TextStyle(
                                                      fontSize: 16,
                                                      fontWeight:
                                                          FontWeight.bold))
                                              : Row(
                                                  children: [
                                                    Icon(Icons.star,
                                                        color: Colors.orange),
                                                    Text(
                                                        '${note?.data['note']}/5',
                                                        style: TextStyle(
                                                            fontSize: 18,
                                                            fontWeight:
                                                                FontWeight
                                                                    .bold)),
                                                  ],
                                                ),
                                          const Spacer(),
                                          Container(
                                              child: Center(
                                                  child: Text(
                                                      style: TextStyle(
                                                          fontWeight:
                                                              FontWeight.bold,
                                                          fontSize: 18),
                                                      'Titan')))
                                        ],
                                      ),
                                    ]),
                              ),

                              const SizedBox(height: 10),
                              ElevatedButton(
                                  onPressed: trajetDoc!.data['demarrer'] == true
                                      ? null
                                      : trajetDoc!.data['status'] == 'Annule'
                                          ? null
                                          : () {
                                              Navigator.push(
                                                  context,
                                                  MaterialPageRoute(
                                                      builder: (context) =>
                                                          ClientPathScreen(
                                                            trajet: trajetDoc,
                                                          )));
                                            },
                                  child: SizedBox(
                                      width: double.infinity,
                                      child: Center(
                                          child: Text(
                                              'Afficher la route vers le client')))),
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
                                                        _loadTrajet(trajetId);
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
                                  child: SizedBox(
                                      width: double.infinity,
                                      child: Center(child: Text('Annuler')))),
                              const SizedBox(height: 10),
                              ElevatedButton(
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

                                                                        final trajet = await databases.getDocument(
                                                                        databaseId:
                                                                            DATABASE_ID,
                                                                        collectionId:
                                                                            TRAJET_COLLECTION_ID,
                                                                        documentId:
                                                                            widget.id);

                                                                        RoadInfo roadInfo = await mapController.drawRoad(
                                                                            GeoPoint(
                                                                                latitude: trajet.data['depart']['latitude'], longitude: trajet.data['depart']['longitude']),
                                                                            GeoPoint(
                                                                                latitude: positionDoc.data['latitude'],
                                                                                longitude: positionDoc.data['longitude']),
                                                                            roadType: RoadType.car,
                                                                            roadOption: RoadOption(
                                                                              roadWidth: 10,
                                                                              roadColor: Colors.blue,
                                                                              zoomInto: true,
                                                                            ),
                                                                          );

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
                                                                              roadInfo.distance?.toStringAsFixed(1),
                                                                          'destination':
                                                                              positionDoc.$id,
                                                                        });

                                                                    
                                                                    final piloteUpdate = await databases.updateDocument(
                                                                        databaseId:
                                                                            DATABASE_ID,
                                                                        collectionId: PILOTE_COLLECTION_ID,
                                                                        documentId: trajetDoc!.data['pilote']['\$id'],
                                                                        data: {
                                                                          'occupe':
                                                                              false
                                                                        });

                                                                    _loadTrajet(
                                                                        trajetId);
                                                                        Navigator.of(
                                                                          context)
                                                                      .pop();
                                                                    // show the dialog
                                                                  } catch (e) {
                                                                    print(e);
                                                                      Navigator.of(
                                                                          context)
                                                                      .pop();
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
                                                                      'Impossible de se connecter au serveur,veuillez ressayer!'),
                                                                ],
                                                              ),
                                                            ),
                                                            actions: <Widget>[
                                                              TextButton(
                                                                child:
                                                                    const Text(
                                                                        'OK'),
                                                                onPressed: () {
                                                                  Navigator.of(
                                                                          context)
                                                                      .pop();
                                                                },
                                                              ),
                                                             
                                                            ],
                                                          );
                                                        },
                                                      );
                                                                    print('TTTTTTTTTTTTTTTTTTTTTTTTTTTT');
                                                                  }
                                                                
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
                                              Text('Marque comme termine')))),
                              const SizedBox(height: 10),
                              ElevatedButton(
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
                                                                /*final piloteUpdate = await databases.updateDocument(
                                                                databaseId:
                                                                    DATABASE_ID,
                                                                collectionId:
                                                                    PILOTE_COLLECTION_ID,
                                                                documentId: widget.id,
                                                                data: {
                                                                  'demarrer':
                                                                      true,
                                                                  'heure_debut':
                                                                      DateTime.now()
                                                                          .toIso8601String()
                                                                });*/
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
                                  child: SizedBox(
                                      width: double.infinity,
                                      child: Center(
                                          child: Text('Demarrer le trajet')))),
                                        SizedBox(
                            width:double.infinity,height:800,
                            child:OSMFlutter(
                onLocationChanged: (GeoPoint point) {
                  //_update(point);
                },
                controller: mapController,
                osmOption: OSMOption(
                  userTrackingOption: UserTrackingOption(
                    enableTracking: true,
                    unFollowUser: false,
                  ),
                  zoomOption: ZoomOption(
                    initZoom: 8,
                    minZoomLevel: 3,
                    maxZoomLevel: 19,
                    stepZoom: 1.0,
                  ),
                  userLocationMarker: UserLocationMaker(
                    personMarker: MarkerIcon(
                      icon: Icon(
                        Icons.bike_scooter,
                        color: Colors.red,
                        size: 56,
                      ),
                    ),
                    directionArrowMarker: MarkerIcon(
                      icon: Icon(
                        Icons.bike_scooter,
                        size: 56,
                      ),
                    ),
                  ),
                  roadConfiguration: RoadOption(
                    roadColor: Colors.yellowAccent,
                  ),
                  markerOption: MarkerOption(
                      defaultMarker: MarkerIcon(
                    icon: Icon(
                      Icons.person_pin_circle,
                      color: Colors.blue,
                      size: 56,
                    ),
                  )),
                ))),
                            ])),
                  )));
  }
}
////http://bourse.uemoa.int/bourseonline/inscription.php