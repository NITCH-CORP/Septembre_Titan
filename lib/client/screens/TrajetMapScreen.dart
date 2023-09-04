// ignore_for_file: sort_child_properties_last, prefer_const_constructors

import 'package:appwrite/models.dart';
import 'package:flutter/material.dart';
import 'package:flutter_osm_plugin/flutter_osm_plugin.dart';

class TrajetMapScreen extends StatefulWidget {
  Document? trajet;
  TrajetMapScreen(this.trajet, {super.key});

  @override
  State<TrajetMapScreen> createState() => _TrajetMapScreenState();
}

class _TrajetMapScreenState extends State<TrajetMapScreen> {
  double distance = 0;
  //PolylinePoints polylinePoints = PolylinePoints();
  bool isLoading = true;
  //Document trajetDoc = widget.trajet?;

  final mapController = MapController.withPosition(
    initPosition: GeoPoint(
      latitude: 6.161923,
      longitude: 1.235236,
    ),
  );

  //LatLng startLocation = LatLng(27.6683619, 85.3101895);
  //LatLng endLocation = LatLng(27.6688312, 85.3077329);
  //List<LatLng> polylineCoordinates = [];
  final scaffoldKey = GlobalKey<ScaffoldState>();

  Future<void> getPath() async {
    try {
      setState(() {
        isLoading = true;
      });
      //await mapController.removeLastRoad();

      RoadInfo roadInfo = await mapController.drawRoad(
        GeoPoint(
            latitude: widget.trajet?.data['depart']['latitude']!,
            longitude: widget.trajet?.data['depart']['latitude']),
        GeoPoint(
            latitude: widget.trajet?.data['destination']['latitude']!,
            longitude: widget.trajet?.data['destination']['latitude']),
        roadType: RoadType.car,
        roadOption: RoadOption(
          roadWidth: 10,
          roadColor: Colors.red,
          zoomInto: true,
        ),
      );
      setState(() {
        isLoading = false;
        distance = roadInfo.distance!;
      });
    } catch (e) {
      print(e);
      setState(() {
        //isLoading = false;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    /*WidgetsBinding.instance.addPostFrameCallback((_) {
      getPath();
    });*/
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // do something
      Future.delayed(const Duration(seconds: 3)).then((value) {
        getPath();
      });

      print("Build Completed");
    });
    //_determinePosition();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
            leading: IconButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                icon: const Icon(Icons.chevron_left, color: Colors.white)),
            title: const Text('Trajet')),
        body: Stack(
          children: [
            SizedBox(
                width: double.infinity,
                height: double.infinity,
                child: Hero(
                    tag: 'trajet',
                    child: Container(
                        width: double.infinity,
                        height: double.infinity,
                        child: OSMFlutter(
                            controller: mapController,
                            osmOption: OSMOption(
                              zoomOption: ZoomOption(
                                initZoom: 8,
                                minZoomLevel: 3,
                                maxZoomLevel: 19,
                                stepZoom: 1.0,
                              ),
                              userLocationMarker: UserLocationMaker(
                                personMarker: MarkerIcon(
                                  icon: Icon(
                                    Icons.location_history_rounded,
                                    color: Colors.red,
                                    size: 48,
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
                                  Icons.location_on,
                                  color: Colors.blue,
                                  size: 56,
                                ),
                              )),
                            )),
                        decoration: BoxDecoration(color: Colors.black)))),
            SizedBox(
                width: double.infinity,
                height: double.infinity,
                child: Column(children: [
                  Spacer(),
                  Container(
                      decoration: BoxDecoration(color: Colors.white),
                      height: 100,
                      width: double.infinity,
                      child: Center(
                        child: Text('Distance: $distance km',
                            style: TextStyle(
                                fontSize: 18, fontWeight: FontWeight.bold)),
                      ))
                ]))
          ],
        ));
  }
}
