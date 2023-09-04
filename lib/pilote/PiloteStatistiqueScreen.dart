// ignore_for_file: sized_box_for_whitespace, prefer_const_literals_to_create_immutables, prefer_const_constructors, unnecessary_this, sort_child_properties_last, prefer_final_fields

import 'package:flutter/material.dart';
import 'package:appwrite/appwrite.dart';
import 'package:appwrite/models.dart';
import 'package:graphic/graphic.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:syncfusion_flutter_charts/sparkcharts.dart';
import '../../utils/constants.dart';
import 'package:shared_preferences/shared_preferences.dart';
import './PiloteActiviteScreen.dart';
import './PiloteNoteScreen.dart';
import './PiloteHistoryScreen.dart';
//import 'package:graphic/graphic.dart';

class Data {
  int nombre;
  String periode;
  Data(this.periode, this.nombre);
}

class PiloteStatistiqueScreen extends StatefulWidget {
  const PiloteStatistiqueScreen({super.key});

  @override
  State<PiloteStatistiqueScreen> createState() =>
      _PiloteStatistiqueScreenState();
}

class _PiloteStatistiqueScreenState extends State<PiloteStatistiqueScreen> {
  bool isFetching = true;
  double distance = 0;
  int nombre_trajet = 0;
  int nombre_note = 0;
  int nombre_activite = 0;
  List<Data> _trajet = [
    Data('00-02', 45),
    Data('03-05', 245),
    Data('06-08', 5),
    Data('09-11', 7),
    Data('12-14', 45),
    Data('15-17', 245),
    Data('18-19', 5),
    Data('20-22', 7),
    Data('23-24', 45),
  ];
  List<Map<String, dynamic>> _datax = [
    {'periode': '00-04', 'nombre': 0},
    {'periode': '05-09', 'nombre': 0},
    {'periode': '10-14', 'nombre': 0},
    {'periode': '15-19', 'nombre': 0},
    {'periode': '20-24', 'nombre': 0},
  ];
  bool isLoading = true;
  String piloteId = '';

  void _loadGraph(String periode) async {
    final trajets = await databases.listDocuments(
        databaseId: DATABASE_ID,
        collectionId: TRAJET_COLLECTION_ID,
        queries: [
          Query.equal('pilote', piloteId),
          Query.equal('status', 'Termine'),
        ]);

    switch (periode) {
      case '24h':
        {
          _datax = [
            {'periode': '00-04', 'nombre': 0},
            {'periode': '05-09', 'nombre': 0},
            {'periode': '10-14', 'nombre': 0},
            {'periode': '15-19', 'nombre': 0},
            {'periode': '20-24', 'nombre': 0},
          ];
          for (int i = 0; i < trajets.total; i++) {
            //_datax[0]['nombre'] = _datax[0]['nombre'] + 1;
            distance = distance + trajets.documents[i].data['distance'];
            final dt = DateTime.parse(trajets.documents[i].$createdAt);
            int t = dt.compareTo(DateTime.now());
            print(t);
            if (t > 0) {
              if (dt.hour >= 0 && dt.hour <= 4) {
                _datax[0]['nombre'] = _datax[0]['nombre'] + 1;
              }
              if (dt.hour >= 5 && dt.hour <= 9) {
                _datax[1]['nombre'] = _datax[1]['nombre'] + 1;
              }
              if (dt.hour >= 10 && dt.hour <= 14) {
                _datax[3]['nombre'] = _datax[3]['nombre'] + 1;
              }
              if (dt.hour >= 15 && dt.hour <= 19) {
                _datax[4]['nombre'] = _datax[4]['nombre'] + 1;
              }
              if (dt.hour >= 20 && dt.hour <= 24) {
                _datax[5]['nombre'] = _datax[5]['nombre'] + 1;
              }
            }
          }
          setState(() {
            _datax = [
              {'periode': '00-04', 'nombre': 0},
              {'periode': '05-09', 'nombre': 0},
              {'periode': '10-14', 'nombre': 0},
              {'periode': '15-19', 'nombre': 0},
              {'periode': '20-24', 'nombre': 0},
            ];
          });
          break;
        }
      case 'mois':
        {
          _datax = [
            {'periode': '01-07', 'nombre': 0},
            {'periode': '08-15', 'nombre': 0},
            {'periode': '16-23', 'nombre': 0},
            {'periode': '24-31', 'nombre': 0},
          ];
          for (int i = 0; i < trajets.total; i++) {
            //_datax[0]['nombre'] = _datax[0]['nombre'] + 1;
            distance = distance + trajets.documents[i].data['distance'];
            final dt = DateTime.parse(trajets.documents[i].$createdAt);
            final d = dt.difference(DateTime.now());
            //d.inDays;

            if (d.inDays < 30) {
              print(d.inDays);
              print(dt.day);
              if (dt.day >= 1 && dt.day <= 7) {
                _datax[0]['nombre'] = _datax[0]['nombre'] + 1;
              }
              if (dt.day >= 8 && dt.day <= 15) {
                _datax[1]['nombre'] = _datax[1]['nombre'] + 1;
              }
              if (dt.day >= 16 && dt.day <= 23) {
                _datax[3]['nombre'] = _datax[3]['nombre'] + 1;
              }
              if (dt.day >= 24 && dt.day <= 31) {
                _datax[4]['nombre'] = _datax[4]['nombre'] + 1;
              }
            }
          }
          setState(() {});
          break;
        }
      case 'annee':
        {
          _datax = [
            {'periode': 'Jan-Mars', 'nombre': 0},
            {'periode': 'Avr-Juin', 'nombre': 0},
            {'periode': 'Juil-Sept', 'nombre': 0},
            {'periode': 'Oct-Dec', 'nombre': 0},
          ];
          for (int i = 0; i < trajets.total; i++) {
            //_datax[0]['nombre'] = _datax[0]['nombre'] + 1;
            distance = distance + trajets.documents[i].data['distance'];
            final dt = DateTime.parse(trajets.documents[i].$createdAt);
            final last_year =
                DateTime.now().subtract(const Duration(days: 365));
            int t = dt.compareTo(last_year);
            //d.inDays;
            //print(d.inDays);
            print(dt.month);
            if (t > 0) {
              if (dt.month >= 1 && dt.month <= 3) {
                _datax[0]['nombre'] = _datax[0]['nombre'] + 1;
                break;
              }
              if (dt.month >= 4 && dt.month <= 6) {
                _datax[1]['nombre'] = _datax[1]['nombre'] + 1;
                break;
              }
              if (dt.month >= 7 && dt.month <= 9) {
                _datax[2]['nombre'] = _datax[3]['nombre'] + 1;
                break;
              }
              if (dt.month >= 10 && dt.month <= 12) {
                _datax[3]['nombre'] = _datax[4]['nombre'] + 1;
                break;
              }
            }
          }
          setState(() {});
          break;
        }
      default:
        break;
    }
    setState(() {});
  }

  Future<void> _loadStatics(String periode) async {
    setState(() {
      isLoading = true;
    });

    try {
      final prefs = await SharedPreferences.getInstance();
      piloteId = (await prefs.getString('piloteId'))!;

      switch (periode) {
        case 'all':
          {
            final trajets = await databases.listDocuments(
                databaseId: DATABASE_ID,
                collectionId: TRAJET_COLLECTION_ID,
                queries: [
                  Query.equal('pilote', piloteId),
                  Query.equal('status', 'Termine'),
                ]);

            for (int i = 0; i < trajets.total; i++) {
              //_datax[0]['nombre'] = _datax[0]['nombre'] + 1;
              distance = distance + trajets.documents[i].data['distance'];
            }
            nombre_trajet = trajets.total;

            final notes = await databases.listDocuments(
                databaseId: DATABASE_ID,
                collectionId: NOTE_COLLECTION_ID,
                queries: [
                  Query.equal('pilote', piloteId),
                ]);
            nombre_note = notes.total;

            /*final activites = await databases.listDocuments(
                databaseId: DATABASE_ID,
                collectionId: ACTIVITE_COLLECTION_ID,
                queries: [
                  Query.equal('pilote', piloteId),
                ]);
            nombre_activite = activites.total;*/
            break;
          }
        case '24h':
          {
            distance = 0;
            final trajets = await databases.listDocuments(
                databaseId: DATABASE_ID,
                collectionId: TRAJET_COLLECTION_ID,
                queries: [
                  Query.equal('pilote', piloteId),
                  Query.equal('status', 'Termine'),
                ]);
            int total = 0;

            for (int i = 0; i < trajets.documents.length; i++) {
              //_datax[0]['nombre'] = _datax[0]['nombre'] + 1;

              final dt = DateTime.parse(trajets.documents[i].$createdAt);
              int t = dt
                  .compareTo(DateTime.now().subtract(const Duration(days: 1)));
              //print(t);
              if (t > 0) {
                distance = distance + trajets.documents[i].data['distance'];
                total = total + 1;
              }
            }
            nombre_trajet = total;

            int total2 = 0;

            final notes = await databases.listDocuments(
                databaseId: DATABASE_ID,
                collectionId: NOTE_COLLECTION_ID,
                queries: [
                  Query.equal('pilote', piloteId),
                ]);
            for (int i = 0; i < notes.documents.length; i++) {
              //_datax[0]['nombre'] = _datax[0]['nombre'] + 1;

              final dt = DateTime.parse(notes.documents[i].$createdAt);
              int t = dt
                  .compareTo(DateTime.now().subtract(const Duration(days: 1)));
              //print(t);
              if (t > 0) {
                total2 = total2 + 1;
              }
            }

            nombre_note = total2;

            int total3 = 0;

            var activites = await databases.listDocuments(
                databaseId: DATABASE_ID,
                collectionId: ACTIVITE_COLLECTION_ID,
                queries: [
                  Query.equal('pilote', piloteId),
                  Query.orderDesc('\$createdAt'),
                  Query.limit(100)
                ]);

            /*activites = await databases.listDocuments(
                databaseId: DATABASE_ID,
                collectionId: ACTIVITE_COLLECTION_ID,
                queries: [
                  Query.equal('pilote', piloteId),
                  Query.limit(activites.total)
                ]);*/

            print(activites.total);

            for (int i = 0; i < activites.documents.length; i++) {
              if (i == activites.total) break;
              //_datax[0]['nombre'] = _datax[0]['nombre'] + 1;
              print(i);
              final dt = DateTime.parse(activites.documents[i].$createdAt);
              int t = dt
                  .compareTo(DateTime.now().subtract(const Duration(days: 1)));
              //print(t);

              if (t > 0) {
                total3 = total3 + 1;
              }
            }
            nombre_activite = total3;

            break;
          }
      }

      setState(() {
        isLoading = false;
      });
    } catch (e) {
      print(e);
    }
  }

  @override
  void initState() {
    super.initState();
    _loadStatics('all');
  }

  String currentValue = 'all';
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(title: Text('Statistique')),
        body: isLoading == true
            ? Center(child: CircularProgressIndicator())
            : SingleChildScrollView(
                child: Padding(
                padding: const EdgeInsets.all(10.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    /*Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Periode'),
                        DropdownButton(
                            value: currentValue,
                            items: [
                              DropdownMenuItem(
                                  value: 'all',
                                  child: Text('Depuis la creation du compte')),
                              DropdownMenuItem(
                                  value: '24h', child: Text('24h')),
                              DropdownMenuItem(
                                  value: 'semaine',
                                  child: Text('7 derniers jours')),
                              DropdownMenuItem(
                                  value: 'mois',
                                  child: Text('30 derniers jour')),
                              DropdownMenuItem(
                                  value: 'annee',
                                  child: Text('365 derniers jours'))
                            ],
                            onChanged: (var value) {
                              print(value);
                              if (value == 'all') _loadStatics('all');
                              if (value == '24h') _loadStatics('24h');
                              if (value == 'semaine') _loadStatics('semaine');
                              if (value == 'mois') _loadStatics('mois');
                              if (value == 'annee') _loadStatics('annee');
                              setState(() {
                                currentValue = value!;
                              });
                            })
                      ],
                    ),*/
                    const SizedBox(height: 5),
                    MyCard(
                        icon: Icon(Icons.electric_bike, color: Colors.white),
                        value: '70',
                        title: 'Nombre de Trajet',
                        color: Colors.red),
                    const SizedBox(height: 10),
                    ElevatedButton(
                        onPressed: () {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => PiloteHistoryScreen()));
                        },
                        child: Text('Consulter')),
                    const SizedBox(height: 10),
                    MyCard(
                        icon: Icon(Icons.pages, color: Colors.white),
                        value: '2 km',
                        title: 'Distance Prcourue',
                        color: Colors.green),
                    const SizedBox(height: 10),
                    MyCard(
                        icon: Icon(Icons.note, color: Colors.white),
                        value: '17',
                        title: 'Nombre de note',
                        color: Colors.blue),
                    const SizedBox(height: 10),
                    ElevatedButton(
                        onPressed: () {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => PiloteNoteScreen()));
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
                                  builder: (context) =>
                                      PiloteActiviteScreen()));
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
/**
 * child: Chart(
                    data: [
                      {'genre': 'Sports', 'sold': 275},
                      {'genre': 'Strategy', 'sold': 115},
                      {'genre': 'Action', 'sold': 120},
                      {'genre': 'Shooter', 'sold': 350},
                      {'genre': 'Other', 'sold': 150},
                    ],
                    variables: {
                      'genre': Variable(
                        accessor: (Map map) => map['genre'] as String,
                      ),
                      'sold': Variable(
                        accessor: (Map map) => map['sold'] as num,
                      ),
                    },
                    marks: [IntervalMark()],
                    axes: [
                      Defaults.horizontalAxis,
                      Defaults.verticalAxis,
                    ],
                  )
 */