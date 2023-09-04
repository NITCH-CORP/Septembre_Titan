// ignore_for_file: avoid_unnecessary_containers, prefer_const_literals_to_create_immutables, prefer_const_constructors, use_build_context_synchronously, unused_element, no_leading_underscores_for_local_identifiers, dead_code, avoid_single_cascade_in_expression_statements, unnecessary_new, unused_local_variable, avoid_print

import 'package:appwrite/models.dart';
import 'package:flutter/material.dart';
import 'package:custom_map_markers/custom_map_markers.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:restart_app/restart_app.dart';
import 'package:titantrue/client/screens/BottomSheet.dart';
import 'package:provider/provider.dart';
import 'package:titantrue/client/screens/HistoryScreen.dart';
import 'package:flutter_google_places_hoc081098/flutter_google_places_hoc081098.dart';
import 'package:shared_preferences/shared_preferences.dart';
import './StatistiqueScreen.dart';
import 'package:flutter_osm_plugin/flutter_osm_plugin.dart';

import '../../state.dart';
import 'CustomSearchScaffold.dart';
import 'package:appwrite/appwrite.dart';
import '../../utils/constants.dart';

class ClientMainScreen extends StatefulWidget {
  const ClientMainScreen({super.key});

  @override
  State<ClientMainScreen> createState() => _ClientMainScreenState();
}

class _ClientMainScreenState extends State<ClientMainScreen> {
  final Mode _mode = Mode.overlay;
  //dynamic user;
  bool isAvailable = false;
  late SharedPreferences preferences;
  String nom = '';
  String prenom = '';
  String username = '';
  String email = '';
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  //String username ='';

  void _initActivite() async {
    if (context.read<AppState>().trajetId == '') return;

    final realtime = Realtime(client);
    final subscription = realtime.subscribe([
      'databases.$DATABASE_ID.collections.$TRAJET_COLLECTION_ID.documents.${context.read<AppState>().trajetId}',
    ]);

    subscription.stream.listen((response) async {
      if (response.payload['status'] == 'Annule') {
        context.read<AppState>().isAvailable = true;
        setState(() {
          context.read<AppState>().trajetId = '';
        });
        //_scaffoldKey.currentState?.sho
        showDialog<void>(
          context: context,
          barrierDismissible: false, // user must tap button!
          builder: (BuildContext context) {
            return AlertDialog(
              // <-- SEE HERE
              title: const Text('Information'),
              content: SingleChildScrollView(
                child: ListBody(
                  children: const <Widget>[
                    Text('Le trajet est annule!'),
                  ],
                ),
              ),
              actions: <Widget>[
                TextButton(
                  child: const Text('Ok'),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
              ],
            );
          },
        );
        await subscription.close();
        return;
      }
      if (response.payload['status'] == 'Termine') {
        context.read<AppState>().isAvailable = true;
        setState(() {
          context.read<AppState>().trajetId = '';
        });
        //_scaffoldKey.currentState?.sho
        showDialog<void>(
          context: context,
          barrierDismissible: false, // user must tap button!
          builder: (BuildContext context) {
            return AlertDialog(
              // <-- SEE HERE
              title: const Text('Information'),
              content: SingleChildScrollView(
                child: ListBody(
                  children: const <Widget>[
                    Text('le trajet est termine'),
                  ],
                ),
              ),
              actions: <Widget>[
                TextButton(
                  child: const Text('Ok'),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
              ],
            );
          },
        );
        await subscription.close();
        setState(() {});
        //return;
      }
    });
    /*
      if (response.payload['demarrer'] == true) {
        context.read<AppState>().isAvailable = true;
        /*setState(() {
          context.read<AppState>().trajetId = '';
        });*/
        showDialog<void>(
          context: context,
          barrierDismissible: false, // user must tap button!
          builder: (BuildContext context) {
            return AlertDialog(
              // <-- SEE HERE
              title: const Text('Information'),
              content: SingleChildScrollView(
                child: ListBody(
                  children: const <Widget>[
                    Text('le pilote a demarre le trajet'),
                  ],
                ),
              ),
              actions: <Widget>[
                TextButton(
                  child: const Text('Ok'),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
              ],
            );
          },
        );
      }
    });*/
  }

  void _initActivite2() async {
    if (context.read<AppState>().rechercheId == '') return;

    final realtime = Realtime(client);
    final subscription = realtime.subscribe([
      'databases.$DATABASE_ID.collections.$RECHERCHE_COLLECTION_ID.documents.${context.read<AppState>().rechercheId}',
    ]);

    subscription.stream.listen((response) async {
      if (response.payload['notification'] == true) {
        //context.read<AppState>().isAvailable = true;
        setState(() {
          //context.read<AppState>().rechercheId = '';
        });
        showDialog<void>(
          context: context,
          barrierDismissible: false, // user must tap button!
          builder: (BuildContext context) {
            return AlertDialog(
              // <-- SEE HERE
              title: const Text('Information'),
              content: SingleChildScrollView(
                child: ListBody(
                  children: const <Widget>[
                    Text('le pilote est arrive'),
                  ],
                ),
              ),
              actions: <Widget>[
                TextButton(
                  child: const Text('Ok'),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
              ],
            );
          },
        );
        await subscription.close();
        return;
      }
    });
  }

  void _logIn() async {
    try {
      //print('PPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPP');
      preferences = await SharedPreferences.getInstance();
      //username = await preferences.getString('username')!;
      email = preferences.getString('email')!;
      nom = preferences.getString('nom')!;
      prenom = preferences.getString('prenom')!;
      //String? telephone = preferences.getString('telephone')!;
      String? password = preferences.getString('password')!;
      String? accountType = preferences.getString('accountType')!;

      /*print(username);
      print(email);
      print(prenom);*/
      final account = Account(client);
      context.read<AppState>().myUser =
          MyUser(nom: nom, prenom: prenom, telephone: '');
      //Session session =
      String userId = '';

      //User? user = await account.get();
      //if (user == null) {
      Session session =
          await account.createEmailSession(email: email, password: password);
      userId = session.userId;
      context.read<AppState>().myUser?.userId = session.userId;
      //print(session.userId);
      //print(context.read<AppState>().myUser?.userId);
      //print('IIIIIIIIIIIIIIIIIIIIIIIIIIIIII');
      /*} else {
        userId = user.$id;
        context.read<AppState>().myUser?.userId = user.$id;
      }*/

      //print(session.userId);
      //print('IIIIIIIIIIIIII$userId');
      final clients = await databases.listDocuments(
          databaseId: DATABASE_ID,
          collectionId: CLIENT_COLLECTION_ID,
          queries: [Query.equal('user_id', userId)]);

      final trajets = await databases.listDocuments(
          databaseId: DATABASE_ID,
          collectionId: TRAJET_COLLECTION_ID,
          queries: [
            Query.equal('client', clients.documents[0].$id),
            Query.equal('status', 'En Cours'),
          ]);
      print('TTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTT');
      print(trajets.total);
      if (trajets.total == 0) {
        print(trajets);
        print('JJJJJJJJJJJJJJJJJJJJJJJ');
        context.read<AppState>().isAvailable = true;
      }
      if (trajets.total != 0) {
        context.read<AppState>().trajetId = trajets.documents[0].data['\$id'];
        print(context.read<AppState>().trajetId);
      }

      if (clients.documents[0].data['actif'] == false) {
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
                        'Votre compte a ete desactive,veuillez contacter l\'equipe Titan .'),
                  ],
                ),
              ),
              actions: <Widget>[
                TextButton(
                  child: const Text('OK'),
                  onPressed: () async {
                    await preferences.remove('login');
                    Navigator.of(context).pop();
                    Restart.restartApp();
                  },
                ),
              ],
            );
          },
        );
        /*await preferences.remove('login');
      await preferences.remove('clientId');
      await preferences.remove('userId');
      await preferences.remove('password');
      await preferences.remove('email');
      await preferences.remove('nom');
      await preferences.remove('prenom');
      await preferences.remove('telephone');
      await preferences.remove('accountType');*/
        return;
      }

      if (clients.documents[0].data['supprime'] == true) {
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
                    Text('Votre compte a ete supprime.'),
                  ],
                ),
              ),
              actions: <Widget>[
                TextButton(
                  child: const Text('OK'),
                  onPressed: () async {
                    await preferences.remove('login');
                    Navigator.of(context).pop();
                    Restart.restartApp();
                  },
                ),
              ],
            );
          },
        );
        /*await preferences.remove('login');
      await preferences.remove('clientId');
      await preferences.remove('userId');
      await preferences.remove('password');
      await preferences.remove('email');
      await preferences.remove('nom');
      await preferences.remove('prenom');
      await preferences.remove('telephone');
      await preferences.remove('accountType');*/
        return;
      }

      final result = await databases.createDocument(
        databaseId: DATABASE_ID,
        collectionId: ACTIVITE_COLLECTION_ID,
        documentId: ID.unique(),
        data: {
          'description':
              "Le client ${clients.documents[0].data['nom']} ${clients.documents[0].data['prenom']} s'est connecter",
          'categorie': 'CONNECTIONCLIENT',
          'client': clients.documents[0].$id
        },
      );

      /*final result = await databases.listDocuments(
        databaseId: DATABASE_ID,
        collectionId: NOTIFICATION_COLLECTION_ID,
      );*/
      //print(result);

      //print('UUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUU');
      setState(() {});
    } catch (e) {
      print('IIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIXXXXXX');
      print(e);
    }
  }

  void _loadUser() async {
    //print(user);
    //print('Here');
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
    markers.add(MarkerData(
        marker: Marker(
          onTap: () {},
          markerId: MarkerId('id-3'),
          position: LatLng(userPosition.latitude, userPosition.longitude),
        ),
        child: Container(
            decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(15),
                color: Colors.transparent),
            width: 30,
            height: 30,
            child: Icon(Icons.person, color: Colors.grey))));

    setState(() {
      //context.read<AppState>().userPosition = userPosition;
    });
    return userPosition;
  }

  void _initW() {
    if (context.read<AppState>().trajetId == '') return;

    final realtime = Realtime(client);
    final subscription = realtime.subscribe([
      'databases.$DATABASE_ID.collections.$TRAJET_COLLECTION_ID.documents.${context.read<AppState>().trajetId}',
    ]);

    subscription.stream.listen((response) async {
      if (response.payload['status'] == 'Annule') {
        context.read<AppState>().isAvailable = true;
        setState(() {
          context.read<AppState>().trajetId = '';
        });
      }
      showDialog<void>(
        context: context,
        barrierDismissible: false, // user must tap button!
        builder: (BuildContext context) {
          return AlertDialog(
            // <-- SEE HERE
            title: const Text('Information'),
            content: SingleChildScrollView(
              child: ListBody(
                children: const <Widget>[
                  Text('Le trajet est annule'),
                ],
              ),
            ),
            actions: <Widget>[
              TextButton(
                child: const Text('Ok'),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
            ],
          );
        },
      );
    });
  }

  @override
  void initState() {
    context.read<AppState>().distance = 0;
    context.read<AppState>().destinationPosition = null;
    super.initState();
   // _determinePosition();
    //_logIn();
    //_initActivite();
    /*_initActivite2();*/
    //_initWork();
    //print('OOOOOOOOOOOOOOOOOOOOOOOO');
    //context.read<AppState>().destinationPosition = null;
  }

  final scaffoldKey = GlobalKey<ScaffoldState>();
  final placeController = TextEditingController();
  List<MarkerData> markers = [
    MarkerData(
        marker: const Marker(
          markerId: MarkerId('id-2'),
          position: LatLng(37.41796133580664, -122.085749655962),
        ),
        child: SizedBox(
            width: 30,
            height: 30,
            child: Image.asset('assets/images/icon.png'))),
  ];
  // default constructor
  MapController mapController = MapController.withUserPosition(
      trackUserLocation: UserTrackingOption(
    enableTracking: true,
    unFollowUser: false,
  ));

  Future<GeoPoint> _getPosition() async {
    GeoPoint geoPoint = await mapController.myLocation();
    return geoPoint;
  }

  void _initWork() {
    if (context.read<AppState>().rechercheId == "") return;

    final realtime = Realtime(client);
    final subscription = realtime.subscribe([
      'databases.$DATABASE_ID.collections.$RECHERCHE_COLLECTION_ID.documents.${context.read<AppState>().rechercheId}',
    ]);
    subscription.stream.listen((response) async {
      if (response.payload['notification'] == true) {
        context.read<AppState>().rechercheId = '';
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
                    Text('Le pilote est arrive.'),
                  ],
                ),
              ),
              actions: <Widget>[
                TextButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    child: const Text('OK')),
              ],
            );
          },
        );
        /*ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(duration:Duration(seconds:5),content: Text('Le pilote est arrive')));
        ;*/
        await subscription.close();
        return;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final _size = MediaQuery.of(context).size;
    return Scaffold(
      key: scaffoldKey,
      drawer: Drawer(
          width: _size.width * 0.8,
          //height: _size.height,
          child: Container(
              /*height: _size.height,*/
              decoration: BoxDecoration(color: Colors.white),
              child: Column(
                children: [
                  Container(
                      padding: const EdgeInsets.all(10),
                      height: _size.height * 0.2,
                      width: _size.width * 0.8,
                      decoration: const BoxDecoration(color: Colors.blue),
                      child: Column(
                        children: [
                          const Spacer(),
                          Row(
                            children: [
                              CircleAvatar(
                                  backgroundColor: Colors.white,
                                  radius: 30,
                                  child: Icon(Icons.person,
                                      size: 30, color: Colors.grey)),
                              const SizedBox(
                                width: 10,
                              ),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  SizedBox(
                                    width: _size.width * 0.50,
                                    child: Text('$nom $prenom',
                                        softWrap: false,
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: TextStyle(
                                            color: Colors.white,
                                            fontWeight: FontWeight.bold,
                                            fontSize: 18)),
                                  ),
                                  SizedBox(
                                    width: _size.width * 0.50,
                                    child: Text(email,
                                        overflow: TextOverflow.ellipsis,
                                        maxLines: 1,
                                        softWrap: false,
                                        style: TextStyle(color: Colors.white)),
                                  ),
                                ],
                              )
                            ],
                          ),
                          const SizedBox(
                            height: 10,
                          ),
                        ],
                      )),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.all(10.0),
                      child: Column(
                        children: [
                          GestureDetector(
                            onTap: () {
                              Navigator.of(context).pop();
                            },
                            child: Row(children: [
                              Icon(Icons.home, color: Colors.blue),
                              const SizedBox(
                                width: 10,
                              ),
                              Text('Acceuil', style: TextStyle(fontSize: 18))
                            ]),
                          ),

                          /*GestureDetector(
                            onTap: () {},
                            child: Row(children: [
                              Icon(Icons.notifications, color: Colors.blue),
                              const SizedBox(
                                width: 10,
                              ),
                              Text('Notification', style: TextStyle(fontSize: 18))
                            ]),
                          ),*/
                          Divider(),
                          const SizedBox(
                            height: 10,
                          ),

                          GestureDetector(
                            onTap: () {
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => HistoryScreen()));
                            },
                            child: Row(children: [
                              Icon(Icons.history, color: Colors.blue),
                              const SizedBox(
                                width: 10,
                              ),
                              Text('Historique', style: TextStyle(fontSize: 18))
                            ]),
                          ),
                          Divider(),
                          const SizedBox(
                            height: 10,
                          ),

                          GestureDetector(
                            onTap: () {
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) =>
                                          StatistiqueScreen()));
                            },
                            child: Row(children: [
                              Icon(Icons.settings, color: Colors.blue),
                              const SizedBox(
                                width: 10,
                              ),
                              Text('Statistique',
                                  style: TextStyle(fontSize: 18))
                            ]),
                          ),
                          /*Divider(),
                          const SizedBox(
                            height: 10,
                          ),
                          GestureDetector(
                            onTap: () {
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => SettingScreen()));
                            },
                            child: Row(children: [
                              Icon(Icons.settings, color: Colors.blue),
                              const SizedBox(
                                width: 10,
                              ),
                              Text('Parametre', style: TextStyle(fontSize: 18))
                            ]),
                          ),*/
                          Divider(),
                          const SizedBox(
                            height: 10,
                          ),
                          //Spacer(),

                          const Spacer(),
                          GestureDetector(
                            onTap: () async {
                              return showDialog<void>(
                                context: context,
                                barrierDismissible:
                                    false, // user must tap button!
                                builder: (BuildContext context) {
                                  return AlertDialog(
                                    // <-- SEE HERE
                                    title: const Text('Avertisement'),
                                    content: SingleChildScrollView(
                                      child: ListBody(
                                        children: const <Widget>[
                                          Text(
                                              'Voulez vous vous deconnecter a la prochaine ouverture de l\'application vous serrez obliger de renter vos informations de connexion.Voulez vous vous decoonecter?'),
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
                                            await preferences.remove('login');
                                            await preferences
                                                .remove('clientId');
                                            await preferences.remove('userId');
                                            await preferences
                                                .remove('password');
                                            await preferences.remove('email');
                                            await preferences.remove('nom');
                                            await preferences.remove('prenom');
                                            await preferences
                                                .remove('telephone');
                                            await preferences
                                                .remove('accountType');
                                            //Restart.restartApp();
                                          } catch (e) {
                                            print(e);
                                          }
                                          Navigator.of(context).pop();
                                          Restart.restartApp();
                                        },
                                      ),
                                    ],
                                  );
                                },
                              );
                            },
                            child: Row(children: [
                              Icon(Icons.logout, color: Colors.blue),
                              const SizedBox(
                                width: 10,
                              ),
                              Text('Se deconnecter',
                                  style: TextStyle(fontSize: 18))
                            ]),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ))),
      body: SafeArea(
        top: false,
        child: Stack(children: [
          Container(
              width: _size.width,
              height: _size.height,
              decoration: const BoxDecoration(),
              child: OSMFlutter(
                  controller: mapController,
                  osmOption: OSMOption(
                    userTrackingOption: UserTrackingOption(
                      enableTracking: false,
                      unFollowUser: true,
                    ),
                    zoomOption: ZoomOption(
                      initZoom: 15,
                      minZoomLevel: 3,
                      maxZoomLevel: 19,
                      stepZoom: 1.0,
                    ),
                    userLocationMarker: UserLocationMaker(
                      personMarker: MarkerIcon(
                        icon: Icon(
                          Icons.location_history_rounded,
                          color: Colors.red,
                          size: 68,
                        ),
                      ),
                      directionArrowMarker: MarkerIcon(
                        icon: Icon(
                          Icons.double_arrow,
                          size: 48,
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
                  )) /*CustomGoogleMapMarkerBuilder(
                //screenshotDelay: const Duration(seconds: 4),
                customMarkers: markers,
                builder: (BuildContext context, Set<Marker>? markers) {
                  if (markers == null) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (context.read<AppState>().userPosition == null) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  return GoogleMap(
                    initialCameraPosition: CameraPosition(
                      target: LatLng(
                          context.read<AppState>().userPosition!.latitude,
                          context.read<AppState>().userPosition!.longitude),
                      zoom: 20.4746,
                    ),
                    markers: markers,
                    onMapCreated: (GoogleMapController controller) {},
                  );
                },
              )*/
              ),
          Container(
            padding: const EdgeInsets.only(left: 8, right: 8, top: 20),
            height: _size.height,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    GestureDetector(
                      onTap: () {
                        scaffoldKey.currentState!.openDrawer();
                      },
                      child: Container(
                        width: 30,
                        height: 30,
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(15),
                            color: Colors.white),
                        child: const Icon(Icons.menu,
                            color: Colors.black, size: 20),
                      ),
                    ),
                    /*SizedBox(
                      width: _size.width * 0.7,
                      height: 40,
                      child: TextField(
                        onTap: () {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) =>
                                      CustomSearchScaffold()));
                        },
                        controller: placeController,
                        //textAlign: TextAlign.center,
                        style:
                            const TextStyle(fontSize: 15, color: Colors.black),
                        decoration: InputDecoration(
                            contentPadding: const EdgeInsets.all(10),
                            filled: true,
                            fillColor: Colors.white,
                            hintText: 'Chercher votre prochaine destination',
                            hintStyle: const TextStyle(
                                color: Colors.black,
                                fontWeight: FontWeight.normal),
                            border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(23))),
                      ),
                    ),
                    const Badge(
                      child: Icon(Icons.notifications,
                          color: Color.fromARGB(255, 255, 255, 255)),
                    )*/
                  ],
                ),
                Spacer(),
                GestureDetector(
                  onTap: context.read<AppState>().isAvailable == false
                      ? null
                      : () async {
                          showModalBottomSheet(
                              backgroundColor: Colors.transparent,
                              elevation: 100,
                              context: context,
                              builder: (context) {
                                //return ListMoto(size:_size);
                                return MyBottomSheet();
                              });
                        },
                  child: Center(
                    child: Container(
                        padding: EdgeInsets.all(10),
                        decoration: BoxDecoration(
                            color: context.read<AppState>().isAvailable == false
                                ? Colors.grey
                                : Colors.blue,
                            borderRadius: BorderRadius.circular(20)),
                        child: Text('Reserver une motO',
                            style:
                                TextStyle(color: Colors.white, fontSize: 18))),
                  ),
                ),
                const SizedBox(height: 20)
              ],
            ),
          ),
        ]),
      ),
    );
  }
}
