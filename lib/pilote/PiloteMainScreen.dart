// ignore_for_file: avoid_unnecessary_containers, prefer_const_literals_to_create_immutables, prefer_const_constructors, use_build_context_synchronously, unused_element, no_leading_underscores_for_local_identifiers, dead_code, avoid_single_cascade_in_expression_statements, unnecessary_new, unused_local_variable, avoid_print

import 'package:appwrite/models.dart';
import 'package:flutter/material.dart';
import 'package:custom_map_markers/custom_map_markers.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:titantrue/client/screens/BottomSheet.dart';
import 'package:provider/provider.dart';
import 'package:flutter_google_places_hoc081098/flutter_google_places_hoc081098.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:titantrue/pilote/ConsultationScreen.dart';
//import '../StatistiqueScreen.dart';
import 'package:flutter_osm_plugin/flutter_osm_plugin.dart';
import 'package:restart_app/restart_app.dart';
import './PiloteStatistiqueScreen.dart';
import '../../state.dart';
//import 'CustomSearchScaffold.dart';
import 'package:appwrite/appwrite.dart';
import '../../utils/constants.dart';
import './PiloteHistoryScreen.dart';

class PiloteMainScreen extends StatefulWidget {
  const PiloteMainScreen({super.key});

  @override
  State<PiloteMainScreen> createState() => _PiloteMainScreenState();
}

class _PiloteMainScreenState extends State<PiloteMainScreen> {
  final Mode _mode = Mode.overlay;
  //dynamic user;
  Document? piloteDoc;
  late SharedPreferences preferences;
  String nom = '';
  String prenom = '';
  String username = '';
  String email = '';
  String piloteId = '';
  bool _value = true;
  bool isLoading = true;
  bool modal = false;
  bool isWorking = false;
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  PersistentBottomSheetController? controller;

  //String username ='';

  void _logIn() async {
    try {
      _initWork();

      setState(() {
        isLoading = true;
      });
      preferences = await SharedPreferences.getInstance();
      //username = await preferences.getString('username')!;
      email = preferences.getString('email')!;
      //print(email);
      nom = preferences.getString('nom')!;
      prenom = preferences.getString('prenom')!;
      piloteId = preferences.getString('piloteId')!;
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

      final pilotes = await databases.listDocuments(
          databaseId: DATABASE_ID,
          collectionId: PILOTE_COLLECTION_ID,
          queries: [Query.equal('user_id', userId)]);
      piloteDoc = pilotes.documents[0];

      print('RRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRR');

      if (pilotes.documents[0].data['actif'] == false) {
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
                        'Votre compte a ete desactive,veuillez contacter l\'administrateur de votre entreprise .'),
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

      if (pilotes.documents[0].data['supprime'] == true) {
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
                        'Votre compte a ete supprime,veuillez contacter l\'administrateur de votre entreprise .'),
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
              "Le pilote ${pilotes.documents[0].data['nom']} ${pilotes.documents[0].data['prenom']} s'est connecter",
          'categorie': 'CONNECTIONPILOTE',
          'pilote': pilotes.documents[0].$id
        },
      );
      _value = pilotes.documents[0].data['en_ligne'];
      setState(() {
        isLoading = false;
      });
    } catch (e) {
      print('IIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIXXXXXX');
      print(e);
      setState(() {
        isLoading = false;
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
                      'Impossible de se connecter au serveur,veuillez verifier votre connexion internet.'),
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

  void showMyBottomSheet() {
    showModalBottomSheet(
        backgroundColor: Colors.transparent,
        elevation: 100,
        context: context,
        builder: (context) {
          //return ListMoto(size:_size);
          return MyBottomSheet();
        });
  }

  void showMyBottomSheet2() {
    showModalBottomSheet(
        backgroundColor: Colors.transparent,
        elevation: 100,
        context: context,
        builder: (context) {
          //return ListMoto(size:_size);
          return MyBottomSheet();
        });
  }
  //bruce-mars

  void _update(GeoPoint point) async {
    final position = await databases.createDocument(
        databaseId: DATABASE_ID,
        collectionId: POSITION_COLLECTION_ID,
        documentId: piloteId,
        data: {'latitude': point.latitude, 'longitude': point.longitude});
    final piloteUpdate = await databases.updateDocument(
        databaseId: DATABASE_ID,
        collectionId: PILOTE_COLLECTION_ID,
        documentId: piloteId,
        data: {'position_actuelle': position.$id});
  }

  void _initWork() async {
    try {
      preferences = await SharedPreferences.getInstance();

      piloteId = preferences.getString('piloteId')!;
      piloteDoc = await databases.getDocument(
          databaseId: DATABASE_ID,
          collectionId: PILOTE_COLLECTION_ID,
          documentId: piloteId);
      //print('IIIIIIIIIIIIIIIIIIIIIIIII');
      //print(piloteDoc?.data);
      if (piloteDoc?.data['en_ligne'] == false) {
        return;
      }
      //print('XXXXXXXXXXXXXXXXXXXXXXXXXXX');
      final realtime = Realtime(client);
      final subscription = realtime.subscribe([
        'databases.$DATABASE_ID.collections.$RECHERCHE_COLLECTION_ID.documents'
      ]);

      subscription.stream.listen((response) async {
        //print(response.payload);
        //64d52022c25cd5b4a6c5
        //print(response.payload['pilote']['\$id']);
        //print(response.payload); response.payload['entreprise']['\$id'] == piloteDoc?.data['entreprises']['\$id']
        /*if (response.payload['black_list'].contains(piloteDoc?.data['\$id'])) {
          print(response.payload['black_list']);
          print(piloteDoc?.data['\$id']);
          return;
        }*/
        print(response.payload['entreprise']);

        /*if (isWorking == true) {
          print('IIIIIIIIIIIIIIIIIISSSSSSSSSSSSSWWWWWWWW');
          return;
        }*/
        isWorking = true;
        print('IIIIIIIIIIIIIIIIIISSSSSSSSSSSSSWWWWWWWW');
        if (response.payload['entreprise']['\$id'] ==
            piloteDoc?.data['entreprises']['\$id']) {
          for (var element in response.payload['black_list']) {
            if (element == piloteDoc?.data['\$id']) return;
          }
          if (response.payload['status'] == 'Termine') {
            return;
          }
          print('OOOOOOOOOOOOOOOOO');
          GeoPoint userPosition = await mapController.myLocation();
          print('QQQQQQQQQQQQQQQQQQQQ');
          print(userPosition);

          RoadInfo roadInfo = await mapController.drawRoad(
            GeoPoint(
                latitude: userPosition.latitude,
                longitude: userPosition.longitude),
            GeoPoint(
                latitude: response.payload['position']['latitude'],
                longitude: response.payload['position']['longitude']),
            roadType: RoadType.car,
            roadOption: RoadOption(
              roadWidth: 10,
              roadColor: Colors.red,
              zoomInto: true,
            ),
          );
          double distance = roadInfo.distance!;
          await mapController.removeLastRoad();

          String rechercheId = response.payload['\$id'];

          //print('ERRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRROR');

          final pilotes = await databases.listDocuments(
              databaseId: DATABASE_ID,
              collectionId: PILOTE_COLLECTION_ID,
              queries: [
                Query.equal(
                    'entreprises', piloteDoc?.data['entreprises']['\$id']),
                Query.equal('en_ligne', true),
                Query.equal('occupe', false),
                Query.equal('actif', true),
                Query.equal('supprime', false),
              ]);
          for (var pilote in pilotes.documents) {
            if (pilote.$id == piloteId) continue;
            if (pilote.data['position_actuelle'] == null) continue;
            RoadInfo roadInfo2 = await mapController.drawRoad(
              GeoPoint(
                  latitude: userPosition.latitude,
                  longitude: userPosition.longitude),
              GeoPoint(
                  latitude: pilote.data['position_actuelle']['latitude'],
                  longitude: pilote.data['position_actuelle']['longitude']),
              roadType: RoadType.car,
              roadOption: RoadOption(
                roadWidth: 10,
                roadColor: Colors.red,
                zoomInto: true,
              ),
            );
            //await mapController.removeLastRoad();
            double? distance2 = roadInfo2.distance;
            if (distance > distance2!) {
              break;
            }
          }
          print('SSSSSSSSSSSSSSSSSSSSSSS');
          controller = _scaffoldKey.currentState?.showBottomSheet<void>(
              backgroundColor: Colors.transparent, (BuildContext context) {
            final size = MediaQuery.of(context).size;
            return Container(
              padding: const EdgeInsets.all(10),
              height: size.height * 0.2,
              decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(40),
                      topRight: Radius.circular(40))),
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const SizedBox(height: 10),
                    Text(
                        "Un client est a la recherche de taxi moto,voulez vous gerer sa demande??",
                        style: TextStyle(
                          fontSize: 16,
                        )),
                    Expanded(child: Text('')),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        ElevatedButton(
                            onPressed: () async {
                              try {
                                print('OOOOOOOOOOO');
                                final blackList =
                                    response.payload['black_list'];
                                List<String> newBlackList = [];
                                for (var element in blackList) {
                                  newBlackList.add(element);
                                }
                                newBlackList.add(piloteId);
                                final rechercheDocUpdate = await databases
                                    .updateDocument(
                                        databaseId: DATABASE_ID,
                                        collectionId: RECHERCHE_COLLECTION_ID,
                                        documentId: response.payload['\$id'],
                                        data: {'black_list': newBlackList});
                                print(newBlackList);
                                /*var state = context
                                        .findAncestorStateOfType<State>();
                                    print(state);*/
                                isWorking = false;
                                Navigator.pop(context);

                                return;
                              } catch (e) {
                                isWorking = false;
                                print(e);
                                Navigator.pop(context);
                              }
                            },
                            style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.red,
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(40))),
                            child: const Text('Rejetter',
                                style: TextStyle(fontSize: 18))),
                        const SizedBox(width: 10),
                        ElevatedButton(
                            onPressed: () async {
                              Navigator.pop(context);
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => ConsultationScreen(
                                          rechercheId, piloteId)));
                              /*final t = await databases.updateDocument(
                                  databaseId: DATABASE_ID,
                                  collectionId: RECHERCHE_COLLECTION_ID,
                                  documentId: rechercheId,
                                  data: {
                                    'black_liste': [piloteId]
                                  });*/
                            },
                            style: ElevatedButton.styleFrom(
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(40))),
                            child: const Text('Consulter',
                                style: TextStyle(fontSize: 18))),
                      ],
                    )
                  ]),
            );
          }); /*showModalBottomSheet(
              backgroundColor: Colors.transparent,
              elevation: 100,
              context: context,
              builder: (context) {
                //return ListMoto(size:_size);
                final size = MediaQuery.of(context).size;
                return Container(
                  padding: const EdgeInsets.all(10),
                  height: size.height * 0.2,
                  decoration: const BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(40),
                          topRight: Radius.circular(40))),
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const SizedBox(height: 10),
                        Text(
                            "Un client est a la recherche de taxi moto,voulez vous gerer sa demande??",
                            style: TextStyle(
                              fontSize: 16,
                            )),
                        Expanded(child: Text('')),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            ElevatedButton(
                                onPressed: () async {
                                  try {
                                    print('OOOOOOOOOOO');
                                    final black_list =
                                        response.payload['black_list'];
                                    List<String> new_black_list = [];
                                    for (var element in black_list) {
                                      new_black_list.add(element);
                                    }
                                    new_black_list.add(piloteId);
                                    final rechercheDocUpdate = await databases
                                        .updateDocument(
                                            databaseId: DATABASE_ID,
                                            collectionId:
                                                RECHERCHE_COLLECTION_ID,
                                            documentId:
                                                response.payload['\$id'],
                                            data: {
                                          'black_list': new_black_list
                                        });
                                    print(new_black_list);
                                    /*var state = context
                                        .findAncestorStateOfType<State>();
                                    print(state);*/
                                    Navigator.pop(context);

                                    return;
                                  } catch (e) {
                                    print(e);
                                    Navigator.pop(context);
                                  }
                                },
                                style: ElevatedButton.styleFrom(
                                    primary: Colors.red,
                                    shape: RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(40))),
                                child: const Text('Rejetter',
                                    style: TextStyle(fontSize: 18))),
                            const SizedBox(width: 10),
                            ElevatedButton(
                                onPressed: () async {
                                  Navigator.pop(context);
                                  Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) =>
                                              ConsultationScreen(
                                                  rechercheId, piloteId)));
                                  /*final t = await databases.updateDocument(
                                  databaseId: DATABASE_ID,
                                  collectionId: RECHERCHE_COLLECTION_ID,
                                  documentId: rechercheId,
                                  data: {
                                    'black_liste': [piloteId]
                                  });*/
                                },
                                style: ElevatedButton.styleFrom(
                                    shape: RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(40))),
                                child: const Text('Consulter',
                                    style: TextStyle(fontSize: 18))),
                          ],
                        )
                      ]),
                );
              });*/
          isWorking = false;
          return;
          //print(response.payload);
          //if(response.payload['entreprise']['\$id'] == piloteDoc?.data['entreprises']['\$id'])
        }
      });
      //print('IIIIIIIIIIIIIIIIIIIIII');
    } catch (e) {
      isWorking = false;
      print('!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!');
      print(e);
    }
  }

  void accepter() async {}
  @override
  void initState() {
    /*WidgetsBinding.instance.addPostFrameCallback((_) {
      // do something
      Future.delayed(const Duration(seconds: 3)).then((value) {
        _initWork();
      });


    });*/
    context.read<AppState>().distance = 0;
    context.read<AppState>().destinationPosition = null;
    super.initState();
    //print('WWWWWWWWWWWWWWWWWWWWWWWWWW');
    //_determinePosition();
    //_logIn();
    //_init();
    //_initWork();
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

  @override
  Widget build(BuildContext context) {
    final _size = MediaQuery.of(context).size;
    _initWork();
    return Scaffold(
      key: _scaffoldKey,
      drawer: Drawer(
          width: _size.width * 0.8,
          child: Container(
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
                          /*Divider(),
                          const SizedBox(
                            height: 10,
                          ),
                  
                          GestureDetector(
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
                                      builder: (context) =>
                                          PiloteHistoryScreen()));
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
                                          PiloteStatistiqueScreen()));
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
                          Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              Switch(
                                  value: _value,
                                  onChanged: (value) {
                                    showDialog<void>(
                                      context: context,
                                      barrierDismissible:
                                          false, // user must tap button!
                                      builder: (BuildContext context) {
                                        return AlertDialog(
                                          // <-- SEE HERE
                                          title: const Text('Avertissement'),
                                          content: SingleChildScrollView(
                                            child: ListBody(
                                              children: const <Widget>[
                                                Text(
                                                    'Voulez vous vous activer la visibilite, des clients pourrons effectuer des reservations chez vous '),
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
                                                  final pilote = await databases
                                                      .updateDocument(
                                                          databaseId:
                                                              DATABASE_ID,
                                                          collectionId:
                                                              PILOTE_COLLECTION_ID,
                                                          documentId: piloteId,
                                                          data: {
                                                        'en_ligne': value
                                                      });
                                                  setState(() {
                                                    _value = value;
                                                  });
                                                  final activite = await databases
                                                      .createDocument(
                                                          databaseId:
                                                              DATABASE_ID,
                                                          collectionId:
                                                              ACTIVITE_COLLECTION_ID,
                                                          documentId:
                                                              ID.unique(),
                                                          data: {
                                                        'categorie': value ==
                                                                true
                                                            ? 'ACTIVATIONVISIBILITE'
                                                            : 'DESACTIVATIONVISIBILITE',
                                                        'description': value ==
                                                                true
                                                            ? 'Le pilote ${pilote.data['nom']} ${pilote.data['prenom']} vient d\'entrer est en ligne'
                                                            : 'Le pilote ${pilote.data['nom']} ${pilote.data['prenom']} vient d\'etre hors ligne',
                                                      });
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
                                  }),
                              _value == false
                                  ? Text('Activer La visibilite',
                                      style: TextStyle(fontSize: 18))
                                  : Text('Desactiver La visibilite',
                                      style: TextStyle(fontSize: 18))
                            ],
                          ),
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
                                              'Voulez vous vous deconnecter? A la prochaine ouverture de l\'application vous serrez obliger de renter vos informations de connexion.Voulez vous vous decoonecter?'),
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
                                                .remove('PiloteId');
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
                                            final pilote =
                                                await databases.getDocument(
                                                    databaseId: DATABASE_ID,
                                                    collectionId:
                                                        PILOTE_COLLECTION_ID,
                                                    documentId: piloteId);
                                            final result = await databases
                                                .updateDocument(
                                                    databaseId: DATABASE_ID,
                                                    collectionId:
                                                        PILOTE_COLLECTION_ID,
                                                    documentId: pilote.$id,
                                                    data: {'en_ligne': false});

                                            final doc = await databases
                                                .createDocument(
                                                    databaseId: DATABASE_ID,
                                                    collectionId:
                                                        ACTIVITE_COLLECTION_ID,
                                                    documentId: ID.unique(),
                                                    data: {
                                                  'description':
                                                      'Le pilote ${pilote.data['nom']} ${pilote.data['prenom']} vient de se deconnecter',
                                                  'categorie':
                                                      'DECONNECTIONPILOTE',
                                                  'pilote': pilote.$id
                                                });
                                            Restart.restartApp();
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
                  onLocationChanged: (GeoPoint point) async {
                    final position = await databases.createDocument(
                        databaseId: DATABASE_ID,
                        collectionId: POSITION_COLLECTION_ID,
                        documentId: ID.unique(),
                        data: {
                          'latitude': point.latitude,
                          'longitude': point.longitude
                        });

                    final piloteDoc = await databases.updateDocument(
                        databaseId: DATABASE_ID,
                        collectionId: PILOTE_COLLECTION_ID,
                        documentId: piloteId,
                        data: {'position_actuelle': position.$id});
                  },
                  controller: mapController,
                  osmOption: OSMOption(
                    userTrackingOption: UserTrackingOption(
                      enableTracking: true,
                      unFollowUser: false,
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
                          Icons.electric_bike,
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
                        _scaffoldKey.currentState!.openDrawer();
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
                    const SizedBox(
                      width:5,height:5),
                    
                  ],
                ),
                Spacer(),
                /*GestureDetector(
                  onTap: () async {
                    showModalBottomSheet(
                        backgroundColor: Colors.transparent,
                        elevation: 100,
                        context: context,
                        builder: (context) {
                          //return ListMoto(size:_size);
                          return MyBottomSheet();
                        });
                  },
                  child: Container(
                      padding: EdgeInsets.all(10),
                      decoration: BoxDecoration(
                          color: Colors.blue,
                          borderRadius: BorderRadius.circular(20)),
                      child: Text('Reserver une mote',
                          style: TextStyle(color: Colors.white, fontSize: 18))),
                ),
                const SizedBox(height: 20)*/
              ],
            ),
          ),
        ]),
      ),
    );
  }
}
