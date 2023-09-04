// ignore_for_file: avoid_init_to_null

import 'package:flutter/material.dart';
import 'package:titantrue/client/screens/ChoosePilote.dart';
import 'package:flutter_osm_plugin/flutter_osm_plugin.dart';
import '../../state.dart';
import 'package:provider/provider.dart';

import 'PathScreen.dart';

class MyBottomSheet extends StatefulWidget {
  const MyBottomSheet({super.key});

  @override
  State<MyBottomSheet> createState() => _MyBottomSheetState();
}

class _MyBottomSheetState extends State<MyBottomSheet> {
  var position = null;
  final _keyDepart = GlobalKey();
  int counter = 0;
  String ps = '';
  final _controller = TextEditingController();

    @override
  void initState() {
  context.read<AppState>().distance = 0;
  context.read<AppState>().destinationPosition = null;
    super.initState();

  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Container(
      padding: const EdgeInsets.all(10),
      height: size.height * 0.2,
      decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
              topLeft: Radius.circular(40), topRight: Radius.circular(40))),
      child: Column(children: [
        TextFormField(
            initialValue: 'Votre Position',
            keyboardType: TextInputType.none,
            decoration: const InputDecoration(
                hintText: 'Depart',
                prefixIcon: Icon(Icons.location_on, color: Colors.red)),
            onTap: () {
              /*Navigator.push(context, MaterialPageRoute(builder: (context) {
                return CommandeScreen();
              }))*/
            }),
        /*TextFormField(
            controller: _controller,
            /*initialValue:ps,*/
            keyboardType: TextInputType.none,
            key: _keyDepart,
            decoration: const InputDecoration(
                hintText: 'Destination',
                prefixIcon: Icon(Icons.send, color: Colors.blue)),
            onTap: () async {
              /*position = await Navigator.push(context,
                  MaterialPageRoute(builder: (context) => const Destination()));
              print(position);*/
              GeoPoint? p = await showSimplePickerLocation(
                      context: context,
                      isDismissible: true,
                      title: "Choisir la destination",
                      textConfirmPicker: "Ok",
                      initCurrentUserPosition: const UserTrackingOption(
              enableTracking: true,
              unFollowUser: false,
            ),
                    );
                    print(p);
                context.read<AppState>().destinationPosition = p;
              //_keyDepart.currentState.
              //KeyboardListener(focusNode: FocusNode(), child: child)
              /*final position = await Navigator.push(context, MaterialPageRoute(builder: (context) {
                return Location();
              }));*/
              //print(position);
              //context.read<PositionProvider>().destinationPosition.longitude = position.longitude.toString();
              //context.read<PositionProvider>().destinationPosition.latitude = position.latitude.toString();
              setState(() {
                _controller.text = '${p!.latitude} ${p.longitude}';
              });
              /*showDialog(context: context, builder: (context) => AlertDialog(
                title: Text(_controller.text.toString()),
               ));*/
              setState(() {});
              //print(ps);
            }),*/
        const SizedBox(height: 20),
        Row(
          children: [
            const Spacer(),
            ElevatedButton(
                onPressed: () {
                  if (_controller.text != '') {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => PathScreen(
                                  destination: context.read<AppState>().destinationPosition
                                )));
                    return;
                  }

                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const ChoosePilote()));
                  setState(() {
                    //counter++;
                  });
                },
                style: ElevatedButton.styleFrom(
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(40))),
                child: const Text('Suivant', style: TextStyle(fontSize: 18))),
          ],
        )
      ]),
    );
  }
}
