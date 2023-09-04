import 'package:appwrite/models.dart';
import 'package:flutter/material.dart';

import 'package:flutter_osm_plugin/flutter_osm_plugin.dart';

/*class PositionProvider extends ChangeNotifier {
  //late CameraPosition departCameraPosition;
  GeoPoint departPosition = null //Position(latitude: '2.5655', longitude: '2.548');
  GeoPoint destinationPosition = null // Position(latitude: '', longitude: '');
  late GeoPoint userPosition;
}

class Position {
  String latitude;
  String longitude;
  Position({required this.latitude, required this.longitude});
}*/

class AppState extends ChangeNotifier {
  //late CameraPosition departCameraPosition;
  User? user;
  double distance = 0;
  String current = '';
  //geo.Position? userPosition;
  //geo.Position? destinationPosition;
  MyUser? myUser;
  GeoPoint? departPosition; //Position(latitude: '2.5655', longitude: '2.548');
  GeoPoint? destinationPosition; // Position(latitude: '', longitude: '');
  late GeoPoint userPosition;
  String rechercheId = '';
  String trajetId = '';
  bool isAvailable = false;
}

class MyUser {
  String id = '';
  String nom;
  String prenom;
  String telephone;
  String email = '';
  String password = '';
  String userId = '';

  MyUser({required this.nom, required this.prenom, required this.telephone});
}
