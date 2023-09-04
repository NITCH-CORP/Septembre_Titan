// ignore_for_file: prefer_const_constructors

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class CustomSearchScaffold extends StatefulWidget {
  const CustomSearchScaffold({super.key});

  @override
  State<CustomSearchScaffold> createState() => _CustomSearchScaffoldState();
}

class _CustomSearchScaffoldState extends State<CustomSearchScaffold> {
  void updatePlace() async {
    try {
      final uri = Uri.https(
          'maps.goggleapis.com',
          'maps/api/place/autocomplete/json',
          {"input": "Lome", "key": "AIzaSyBgqPNvME3H2J94XUYn1l5oc3LnyXVo_nk"});
      http.Response response = await http.get(Uri.parse('https://maps.googleapis.com/maps/api/place/details/json?place_id=ChIJrTLr-GyuEmsRBfy61i59si0&fields=address_components&key=AIzaSyBgqPNvME3H2J94XUYn1l5oc3LnyXVo_nk'));
      print(response.body);
    } catch (e) {
      ///print('ERROR');
      print(e);
    }
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
          title: TextField(
            onChanged: (value) {
              updatePlace();
              print(value);
            },
            decoration: InputDecoration(
                hintText: 'Chercher des endroits',
                hintStyle: TextStyle(color: Colors.white)),
            style: TextStyle(
              color: Colors.white,
            ),
          ),
        ),
        body: Padding(
            padding: const EdgeInsets.all(8),
            child: ListView.builder(
              itemBuilder: (context, index) {
                return ListTile(
                  onTap: (){
                    
                  },
                  leading: Icon(Icons.location_on),
                  title: Text('Hello'),
                  subtitle: Text('Hello'),
                );
              },
              itemCount: 10,
            )));
  }
}
