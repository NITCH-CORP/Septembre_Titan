// ignore_for_file: sized_box_for_whitespace, prefer_const_literals_to_create_immutables, prefer_const_constructors, unnecessary_this

import 'package:flutter/material.dart';
import 'package:appwrite/appwrite.dart';
import '../../utils/constants.dart';
import 'package:shared_preferences/shared_preferences.dart';
import './ActiviteScreen.dart';
import './NoteScreen.dart';
import './HistoryScreen.dart';

class StatistiqueScreen extends StatefulWidget {
  const StatistiqueScreen({super.key});

  @override
  State<StatistiqueScreen> createState() => _StatistiqueScreenState();
}

class _StatistiqueScreenState extends State<StatistiqueScreen> {
  bool isFetching = true;
  double distance = 0;
  int nombre_trajet = 0;
  int nombre_note = 0;
  int nombre_activite = 0;

  Future<void> _loadStatics() async {
    final prefs = await SharedPreferences.getInstance();
    String clientId = (prefs.getString('clientId'))!;

    final trajets = await databases.listDocuments(
        databaseId: DATABASE_ID,
        collectionId: TRAJET_COLLECTION_ID,
        queries: [
          Query.equal('client', clientId),
          Query.equal('status', 'Termine'),
        ]);
    for (int i = 0; i < trajets.total; i++) {
      distance = distance + trajets.documents[i].data['distance'];
    }
    nombre_trajet = trajets.total;

    final notes = await databases.listDocuments(
        databaseId: DATABASE_ID,
        collectionId: NOTE_COLLECTION_ID,
        queries: [
          Query.equal('client', clientId),
        ]);
    nombre_note = notes.total;

    final activites = await databases.listDocuments(
        databaseId: DATABASE_ID,
        collectionId: ACTIVITE_COLLECTION_ID,
        queries: [
          Query.equal('client', clientId),
        ]);
    nombre_activite = activites.total;
    setState(() {});
  }

  @override
  void initState() {
    super.initState();
    //_loadStatics();
  }

  String currentValue = '24h';
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(title: Text('Statistique')),
        body: SingleChildScrollView(
            child: Padding(
          padding: const EdgeInsets.all(10.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              MyCard(
                  icon: Icon(Icons.electric_bike, color: Colors.white),
                  value: '20',
                  title: 'Nombre de Trajet',
                  color: Colors.red),
              const SizedBox(height: 10),
              ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => HistoryScreen()));
                  },
                  child: Text('Consulter')),
              const SizedBox(height: 10),
              MyCard(
                  icon: Icon(Icons.pages, color: Colors.white),
                  value: '45 km',
                  title: 'Distance Prcourue',
                  color: Colors.green),
              const SizedBox(height: 10),
              MyCard(
                  icon: Icon(Icons.note, color: Colors.white),
                  value: '2',
                  title: 'Nombre de note',
                  color: Colors.blue),
              const SizedBox(height: 10),
              ElevatedButton(
                  onPressed: () {
                    Navigator.push(context,
                        MaterialPageRoute(builder: (context) => NoteScreen()));
                  },
                  child: Text('Consulter')),
              const SizedBox(height: 10),
              /*MyCard(
                  icon: Icon(Icons.local_activity, color: Colors.white),
                  value: '$nombre_activite',
                  title: 'Nombre d\'activite',
                  color: Colors.black),
              ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => ActiviteScreen()));
                  },
                  child: Text('Consulter')),*/
            ],
          ),
        )));
  }
}

class MyCard extends StatelessWidget {
  Icon icon;
  String value;
  String title;
  Color color;
  MyCard(
      {super.key,
      required this.icon,
      required this.value,
      required this.title,
      required this.color});

  @override
  Widget build(BuildContext context) {
    return Stack(children: [
      Card(
        elevation: 8,
        margin: const EdgeInsets.only(top: 20),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10.0),
        ),
        child: Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
                color: Colors.white, borderRadius: BorderRadius.circular(30)),
            width: double.infinity,
            height: 90,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.end,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(this.title, style: TextStyle(fontSize: 20)),
                const Divider(),
                Text(value,
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold))
              ],
            )),
      ),
      Container(
          width: 50,
          height: 50,
          margin: const EdgeInsets.only(left: 20),
          decoration: BoxDecoration(
              color: this.color, borderRadius: BorderRadius.circular(15)),
          child: this.icon)
    ]);
  }
}
