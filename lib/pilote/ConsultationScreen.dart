// ignore_for_file: prefer_const_constructors, use_build_context_synchronously

import 'package:appwrite/appwrite.dart';
import 'package:appwrite/models.dart';
import 'package:flutter/material.dart';
import 'package:flutter_osm_plugin/flutter_osm_plugin.dart';
import 'package:titantrue/utils/constants.dart';

import 'PathScreen.dart';

class ConsultationScreen extends StatefulWidget {
  String rechercheId;
  String piloteId;
  ConsultationScreen(this.rechercheId, this.piloteId, {super.key});

  @override
  State<ConsultationScreen> createState() => _ConsultationScreenState();
}

class _ConsultationScreenState extends State<ConsultationScreen> {
  bool isLoading = true;
  double distance = 0;
  Document? rechercheDoc;
  MapController mapController = MapController.withUserPosition(
      trackUserLocation: UserTrackingOption(
    enableTracking: true,
    unFollowUser: true,
  ));

  Future<GeoPoint> _getPosition() async {
    GeoPoint geoPoint = await mapController.myLocation();
    return geoPoint;
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
      //print(rechercheDoc);

      final userPosition = await _getPosition();
      print('::::::::::::::::::::::::::');

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

  void _rejetter() async {
    try {
      final blackList = rechercheDoc?.data['black_list'];
      List<String> newBlackList = [];
      for (var element in blackList) {
        newBlackList.add(element);
      }
      newBlackList.add(widget.piloteId);
      final rechercheDocUpdate = await databases.updateDocument(
          databaseId: DATABASE_ID,
          collectionId: RECHERCHE_COLLECTION_ID,
          documentId: rechercheDoc!.$id,
          data: {'black_list': newBlackList});
      Navigator.pop(context);
    } catch (e) {
      print(e);
    }

    //print(black_list);
  }

  void _accepter() async {
    final rechercheDocUpdate = await databases.updateDocument(
        databaseId: DATABASE_ID,
        collectionId: RECHERCHE_COLLECTION_ID,
        documentId: rechercheDoc!.$id,
        data: {'pilote': widget.piloteId, 'status': 'Termine'});

    final piloeDocUpdate = await databases.updateDocument(
        databaseId: DATABASE_ID,
        collectionId: PILOTE_COLLECTION_ID,
        documentId: widget.piloteId,
        data: {'occupe': true});
    Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) =>
                PathScreen(rechercheDoc!.$id, widget.piloteId)));
  }

  @override
  void initState() {
    super.initState();
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
                onLocationChanged: (GeoPoint point) async {
                  final position = await databases.createDocument(
                      databaseId: DATABASE_ID,
                      collectionId: POSITION_COLLECTION_ID,
                      documentId: ID.unique(),
                      data: {
                        'latitude': point.latitude,
                        'longitude': point.longitude
                      });

                  /*final piloteDoc = await databases.updateDocument(
                        databaseId: DATABASE_ID,
                        collectionId: PILOTE_COLLECTION_ID,
                        documentId: piloteId,
                        data: {'position_actuelle': position.$id});*/
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
                        Icons.electric_bike,
                        color: Colors.red,
                        size: 56,
                      ),
                    ),
                    directionArrowMarker: MarkerIcon(
                      icon: Icon(
                        Icons.arrow_back,
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
                    height: 140,
                    decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(40),
                            topRight: Radius.circular(40))),
                    child: Column(
                      children: [
                        Text('Distance entre vous et le client : ${distance.toStringAsFixed(1)} km',
                            style: TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 18)),
                        const SizedBox(height: 10),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.red,
                                    shape: RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(40))),
                                onPressed: () {
                                  _rejetter();
                                  Navigator.pop(context);
                                },
                                child: Text('Rejetter')),
                            const SizedBox(width: 10),
                            ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                    shape: RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(40))),
                                onPressed: () {
                                  _accepter();
                                },
                                child: Text('Accepter')),
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
