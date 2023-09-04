// ignore_for_file: prefer_const_constructors

import 'package:appwrite/appwrite.dart';
import 'package:appwrite/models.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:flutter_osm_plugin/flutter_osm_plugin.dart';

import '../../utils/constants.dart';

class SuivreScreen extends StatefulWidget {
  //GeoPoint? destination;
  Document? trajet;
  SuivreScreen({super.key, required this.trajet});

  @override
  State<SuivreScreen> createState() => _SuivreScreenState();
}

class _SuivreScreenState extends State<SuivreScreen> {
  double distance = 0;
  //PolylinePoints polylinePoints = PolylinePoints();
  bool isLoading = true;
  String googleAPiKey = "AIzaSyBgqPNvME3H2J94XUYn1l5oc3LnyXVo_nk";
  Map<PolylineId, Polyline> polylines = {};
  final mapController = MapController.withUserPosition(
      trackUserLocation: UserTrackingOption(
    enableTracking: true,
    unFollowUser: false,
  ));

  //LatLng startLocation = LatLng(27.6683619, 85.3101895);
  //LatLng endLocation = LatLng(27.6688312, 85.3077329);
  //List<LatLng> polylineCoordinates = [];
  final scaffoldKey = GlobalKey<ScaffoldState>();

  Future<Position> _determinePosition() async {
    bool serviceEnabled;
    LocationPermission permission;

    // Test if location services are enabled.
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      // Location services are not enabled don't continue
      // accessing the position and request users of the
      // App to enable the location services.
      return Future.error('Location services are disabled.');
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        // Permissions are denied, next time you could try
        // requesting permissions again (this is also where
        // Android's shouldShowRequestPermissionRationale
        // returned true. According to Android guidelines
        // your App should show an explanatory UI now.
        return Future.error('Location permissions are denied');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      // Permissions are denied forever, handle appropriately.
      return Future.error(
          'Location permissions are permanently denied, we cannot request permissions.');
    }

    // When we reach here, permissions are granted and we can
    // continue accessing the position of the device.
    final userPosition = await Geolocator.getCurrentPosition();
    //context.read<AppState>().userPosition = userPosition;
    //print(typeof(userPosition));
    print(userPosition.runtimeType);
    return userPosition;
  }

  /*addPolyLine(List<LatLng> polylineCoordinates) {
    PolylineId id = PolylineId("poly");
    Polyline polyline = Polyline(
      polylineId: id,
      color: Colors.deepPurpleAccent,
      points: polylineCoordinates,
      width: 8,
    );
    polylines[id] = polyline;
    setState(() {});
  }*/

  /*double calculateDistance(lat1, lon1, lat2, lon2) {
    var p = 0.017453292519943295;
    var a = 0.5 -
        cos((lat2 - lat1) * p) / 2 +
        cos(lat1 * p) * cos(lat2 * p) * (1 - cos((lon2 - lon1) * p)) / 2;
    setState(() {
      distance = 12742 * asin(sqrt(a));
    });
    return 12742 * asin(sqrt(a));
  }*/

  Future<void> getPath(GeoPoint point) async {
    /*calculateDistance(
        widget.destination.latitude,
        widget.destination.longitude,
        context.read<AppState>().userPosition!.latitude,
        context.read<AppState>().userPosition!.longitude);*/
    /*PolylineResult result = await polylinePoints.getRouteBetweenCoordinates(
      googleAPiKey,
      PointLatLng(startLocation.latitude, startLocation.longitude),
      PointLatLng(endLocation.latitude, endLocation.longitude),
      travelMode: TravelMode.driving,
    );*/
    /*if (result.points.isNotEmpty) {
      for (var point in result.points) {
        polylineCoordinates.add(LatLng(point.latitude, point.longitude));
      }
    } else {
      print(result.errorMessage);
      print('XXXXXXXXXXXXXX');
    }
    addPolyLine(polylineCoordinates);*/

    try {
      setState(() {
        isLoading = true;
      });
      await mapController.removeLastRoad();

      RoadInfo roadInfo = await mapController.drawRoad(
        await mapController.myLocation(),
        GeoPoint(latitude: point.latitude, longitude: point.longitude),
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
        isLoading = false;
      });
    }
  }

  /*void _update(GeoPoint point) {
    GeoPoint point = GeoPoint(
        latitude: widget.trajet?.data['pilote']['position_actuelle']
            ['latitude'],
        longitude: widget.trajet?.data['pilote']['position_actuelle']
            ['longitude']);
    getPath(point);
  }*/

  void _initWork() {
    final realtime = Realtime(client);
    final subscription = realtime.subscribe([
      'databases.$DATABASE_ID.collections.$PILOTE_COLLECTION_ID.documents.${widget.trajet!.$id}',
    ]);
    subscription.stream.listen((response) async {
      GeoPoint point = GeoPoint(
          latitude: response.payload['position_actuelle']['latitude'],
          longitude: response.payload['position_actuelle']['longitude']);
      getPath(point);
    });
  }

  @override
  void initState() {
    super.initState();
    /*WidgetsBinding.instance.addPostFrameCallback((_) {

    });*/
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // do something
      Future.delayed(const Duration(seconds: 3)).then((value) {
        GeoPoint point = GeoPoint(
            latitude: widget.trajet?.data['pilote']['position_actuelle']
                ['latitude'],
            longitude: widget.trajet?.data['pilote']['position_actuelle']
                ['longitude']);
        getPath(point);
      });
    });
    //_determinePosition();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Scaffold(
        bottomSheet: Container(
            padding: const EdgeInsets.all(10),
            height: 120,
            width: double.infinity,
            decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(40),
                    topRight: Radius.circular(40))),
            child: Column(
              children: [
                const SizedBox(height: 10),
                Text('Distance: $distance Km',
                    style:
                        TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(height: 10),
              ],
            )),
        key: scaffoldKey,
        appBar: AppBar(
          backgroundColor: Colors.blue,
          leading: IconButton(
              onPressed: () {
                Navigator.pop(context);
              },
              icon: const Icon(Icons.chevron_left, color: Colors.white)),
          title: const Text('Parcour du pilote',
              style: TextStyle(fontSize: 17, color: Colors.white)),
        ),
        body: SizedBox(
          height: size.height,
          width: size.width,
          child: /*isLoading == true
              ? const Center(child: CircularProgressIndicator())
              : */
              Stack(
            children: [
              OSMFlutter(
                  controller: mapController,
                  onLocationChanged: (GeoPoint point) {
                    //_update(point);
                  },
                  osmOption: OSMOption(
                    showZoomController: true,
                    userTrackingOption: UserTrackingOption(
                      enableTracking: true,
                      unFollowUser: true,
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
                          Icons.location_history_rounded,
                          color: Colors.red,
                          size: 56,
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
                        Icons.electric_bike,
                        color: Colors.blue,
                        size: 56,
                      ),
                    )),
                  ))
              /*GoogleMap(
                polylines: Set<Polyline>.of(polylines.values),
                initialCameraPosition: const CameraPosition(
                  target: LatLng(37.42796133580664, -122.085749655962),
                  zoom: 14.4746,
                ),
                onMapCreated: (GoogleMapController controller) {},
              )*/
              ,
            ],
          ),
        ));
  }
}
