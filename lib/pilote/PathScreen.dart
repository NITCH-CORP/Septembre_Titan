// ignore_for_file: prefer_const_constructors

import 'package:appwrite/models.dart';
import 'package:flutter/material.dart';
import 'package:flutter_osm_plugin/flutter_osm_plugin.dart';
import 'package:titantrue/utils/constants.dart';

import 'PiloteHistoryScreen.dart';

class PathScreen extends StatefulWidget {
  String rechercheId;
  String piloteId;
  PathScreen(this.rechercheId, this.piloteId, {super.key});

  @override
  State<PathScreen> createState() => _PathScreenState();
}

class _PathScreenState extends State<PathScreen> {
  bool isLoading = true;
  double distance = 0;
  Document? rechercheDoc;
  MapController mapController = MapController.withUserPosition(
      trackUserLocation: UserTrackingOption(
    enableTracking: true,
    unFollowUser: false,
  ));

  Future<GeoPoint> _getPosition() async {
    GeoPoint geoPoint = await mapController.myLocation();
    return geoPoint;
  }

  void _update(GeoPoint userPosition) async {
    await mapController.removeLastRoad();
    RoadInfo roadInfo = await mapController.drawRoad(
      GeoPoint(
          latitude: userPosition.latitude, longitude: userPosition.longitude),
      GeoPoint(
          latitude: rechercheDoc?.data['position']['latitude'],
          longitude: rechercheDoc?.data['position']['longitude']),
      roadType: RoadType.car,
      roadOption: RoadOption(
        roadWidth: 10,
        roadColor: Colors.red,
        zoomInto: true,
      ),
    );
    print(roadInfo.distance);
    print('LLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLL');

    setState(() {
      distance = roadInfo.distance!;
    });
  }

  void _initWork() async {
    try {
      /*setState(() {
        isLoading = true;
      });*/
      rechercheDoc = await databases.getDocument(
          databaseId: DATABASE_ID,
          collectionId: RECHERCHE_COLLECTION_ID,
          documentId: widget.rechercheId);
      GeoPoint point = GeoPoint(
          latitude: rechercheDoc?.data['position']['latitude'],
          longitude: rechercheDoc?.data['position']['longitude']);
      print(rechercheDoc?.data['position']);

      final userPosition = await _getPosition();

      ///print(userPosition);
      RoadInfo roadInfo = await mapController.drawRoad(
        GeoPoint(
            latitude: userPosition.latitude, longitude: userPosition.longitude),
        GeoPoint(
            latitude: rechercheDoc?.data['position']['latitude'],
            longitude: rechercheDoc?.data['position']['longitude']),
        roadType: RoadType.car,
        roadOption: RoadOption(
          roadWidth: 10,
          roadColor: Colors.blue,
          zoomInto: true,
        ),
      );
      await mapController.addMarker(
        point,
        markerIcon: MarkerIcon(
          icon: Icon(
            Icons.person,
            color: Colors.blue,
            size: 56,
          ),
        ),
      );
      print(roadInfo.distance);
      print('LLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLL');

      setState(() {
        distance = roadInfo.distance!;
      });
      print('HHHHHHHHHHHHHHHHHHH');
      /*setState(() {
        isLoading = false;
      });*/
    } catch (e) {
      print('CCCCCCCCCCCCCCCCCCCCCCCCCCCC');
      print(e);
    }
  }

  @override
  void initState() {
    super.initState();
    /*WidgetsBinding.instance.addPostFrameCallback((_) {
      // do something
      _initWork();
      print("Build Completed");
    });*/
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // do something
      Future.delayed(const Duration(seconds: 3)).then((value) {
        _initWork();
      });

      print("Build Completed");
    });
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Scaffold(
      body: /*isLoading == true
          ? Center(child: CircularProgressIndicator())
          : */
          Stack(
        children: [
          SizedBox(
            width: size.width,
            height: size.height,
            child: OSMFlutter(
                onLocationChanged: (GeoPoint point) {
                  _update(point);
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
                )),
          ),
          SizedBox(
              width: size.width,
              height: size.height,
              child: Column(
                children: [
                  Spacer(),
                  Container(
                    padding: const EdgeInsets.all(10),
                    height: 100,
                    decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(40),
                            topRight: Radius.circular(40))),
                    child: Column(
                      children: [
                        Text('${distance.toStringAsFixed(1)} km',
                            style: TextStyle(
                                fontSize: 18, fontWeight: FontWeight.bold)),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                    shape: RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(40))),
                                onPressed: () {
                                  //_accepter();
                                  showDialog<void>(
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
                                                  'Voulez vou notifier le client de votre arrive?'),
                                            ],
                                          ),
                                        ),
                                        actions: <Widget>[
                                          TextButton(
                                            child: const Text('Non'),
                                            onPressed: () async {
                                              Navigator.of(context).pop();
                                            },
                                          ),
                                          TextButton(
                                            child: const Text('Oui'),
                                            onPressed: () async {
                                              final rechercheDocUpdate =
                                                  await databases.updateDocument(
                                                      databaseId: DATABASE_ID,
                                                      collectionId:
                                                          RECHERCHE_COLLECTION_ID,
                                                      documentId: widget.rechercheId,
                                                      data: {
                                                    'notification': true
                                                  });
                                              // ignore: use_build_context_synchronously
                                              Navigator.push(
                                                  context,
                                                  MaterialPageRoute(
                                                      builder: (context) =>
                                                          PiloteHistoryScreen()));
                                            },
                                          ),
                                        ],
                                      );
                                    },
                                  );
                                },
                                child: Text('Notifier le client')),
                          ],
                        ),
                      ],
                    ),
                  )
                ],
              ))
        ],
      ),
    );
  }
}
