import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:map_picker/map_picker.dart';

class Destination extends StatefulWidget {
  const Destination({super.key});

  @override
  State<Destination> createState() => _DestinationState();
}

class _DestinationState extends State<Destination> {
  final LatLng _center = const LatLng(45.521563, -122.677433);
  late GoogleMapController mapController;
  MapPickerController mapPickerController = MapPickerController();
  CameraPosition cameraPosition = const CameraPosition(
    target: LatLng(41.311158, 69.279737),
    zoom: 14.4746,
  );

  var textController = TextEditingController();

  void _onMapCreated(GoogleMapController controller) {
    mapController = controller;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.blue,
          leading: IconButton(
              onPressed: () {
                Navigator.pop(context);
              },
              icon: const Icon(Icons.chevron_left, color: Colors.white)),
          title: const Text('Choisir ma position',
              style: TextStyle(fontSize: 17, color: Colors.white)),
          actions: [
            TextButton(
                onPressed: () {
                  //print(cameraPosition.target.latitude);
                  //context.read<PositionProvider>().destinationPosition.latitude = cameraPosition.target.latitude.toString();
                  Navigator.pop(context);
                  setState(() {});
                  //print(cameraPosition.target.longitude.toString());
                  //print('HIIIIIIIIIIIIIII');
                  Navigator.pop(context, cameraPosition.target);
                },
                child: const Text(
                  'Ok',
                  style: TextStyle(color: Colors.white, fontSize: 18),
                )),
          ],
        ),
        body: MapPicker(
          // pass icon widget
          iconWidget: const Icon(Icons.location_on),
          //add map picker controller
          mapPickerController: mapPickerController,
          child: GoogleMap(
            onMapCreated: _onMapCreated,
            initialCameraPosition: CameraPosition(
              target: _center,
              zoom: 11.0,
            ),
            onCameraMoveStarted: () {
              // notify map is moving
              mapPickerController.mapMoving!();
              textController.text = "checking ...";
            },
            onCameraMove: (cameraPosition) {
              this.cameraPosition = cameraPosition;
            },
            onCameraIdle: () async {
              // notify map stopped moving
              mapPickerController.mapFinishedMoving!();
              //get address name from camera position
              /*List<Placemark> placemarks = await placemarkFromCoordinates(
                  cameraPosition.target.latitude,
                  cameraPosition.target.longitude,
                );*/

              // update the ui with the address
              /*textController.text =
                    '${placemarks.first.name}, ${placemarks.first.administrativeArea}, ${placemarks.first.country}';*/
            },
          ),
        ));
  }
}
