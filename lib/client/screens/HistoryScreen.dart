// ignore_for_file: prefer_const_literals_to_create_immutables, prefer_const_constructors, sort_child_properties_last

import 'package:appwrite/appwrite.dart';
import 'package:appwrite/models.dart';
import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import 'package:sticky_grouped_list/sticky_grouped_list.dart';
import 'package:provider/provider.dart';
import '../../state.dart';
import '../../utils/constants.dart';
import './TrajetScreen.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  //List<Element> trajets = [];
  bool isLoading = true;
  String userId = '';
  String clientId = '';
  int l = 0;
  late SharedPreferences preferences;
  List<Element> _elements = <Element>[
    /*Element(DateTime.parse(e.$createdAt), '', Icons.fitness_center,
            e.data['status'], e.$id, e),Element(DateTime.parse(e.$createdAt), '', Icons.fitness_center,
            e.data['status'], e.$id, e),Element(DateTime.parse(e.$createdAt), '', Icons.fitness_center,
            e.data['status'], e.$id, e),
    Element(DateTime(2020, 6, 24, 18), 'Got to gym', Icons.fitness_center),
    Element(DateTime(2020, 6, 24, 9), 'Work', Icons.work),
    Element(DateTime(2020, 6, 25, 8), 'Buy groceries', Icons.shopping_basket),
    Element(DateTime(2020, 6, 25, 16), 'Cinema', Icons.movie),
    Element(DateTime(2020, 6, 25, 20), 'Eat', Icons.fastfood),
    Element(DateTime(2020, 6, 26, 12), 'Car wash', Icons.local_car_wash),
    Element(DateTime(2020, 6, 27, 12), 'Car wash', Icons.local_car_wash),
    Element(DateTime(2020, 6, 27, 13), 'Car wash', Icons.local_car_wash),
    Element(DateTime(2020, 6, 27, 14), 'Car wash', Icons.local_car_wash),
    Element(DateTime(2020, 6, 27, 15), 'Car wash', Icons.local_car_wash),
    Element(DateTime(2020, 6, 28, 12), 'Car wash', Icons.local_car_wash),
    Element(DateTime(2020, 6, 29, 12), 'Car wash', Icons.local_car_wash),
    Element(DateTime(2020, 6, 29, 12), 'Car wash', Icons.local_car_wash),
    Element(DateTime(2020, 6, 30, 12), 'Car wash', Icons.local_car_wash),*/
  ];

  void _initWork() async {
    try {
      SharedPreferences preferences = await SharedPreferences.getInstance();
      clientId = (preferences.getString('clientId'))!;
      final realtime = Realtime(client);

      final subscription = realtime.subscribe([
        'databases.$DATABASE_ID.collections.$TRAJET_COLLECTION_ID.documents'
      ]);

      subscription.stream.listen((response) {
        print(response.payload['client']['\$id']);
        print(clientId);
        if (response.payload['client']['\$id'] == clientId) {
          print('IIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIII');
          //if(response.payload['client'])
          _initHistory();
        }
      });
      //print('IIIIIIIIIIIIIIIIIIIIII');
    } catch (e) {
      print(e);
      print('IIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIII');
    }
  }

////
//////
  ///CHANGER L"ID
  void _initHistory() async {
    try {
      SharedPreferences preferences = await SharedPreferences.getInstance();
      print('PPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPP');
      userId = (preferences.getString('userId'))!;
      //await preferences.setString('userId', userId);
      print('HHHHHHHHHHHHHHHHHHHHH');
      clientId = (preferences.getString('clientId'))!;
      //await preferences.setString('clientId', clientId);
      //print(context.read<AppState>().myUser?.id);
      print(clientId);

      final trajetDocs = await databases.listDocuments(
          databaseId: DATABASE_ID,
          collectionId: TRAJET_COLLECTION_ID,
          queries: [
            Query.equal('client', clientId),
            Query.limit(100),
            Query.orderDesc('\$createdAt')
          ]);
      final list = trajetDocs.documents.reversed.toList();
      List<Element> el = trajetDocs.documents.map((e) {
        print(context.read<AppState>().myUser?.userId);
        return Element(DateTime.parse(e.$createdAt), '', Icons.fitness_center,
            e.data['status'], e.$id, e);
      }).toList();
      if (this.mounted) {
        setState(() {
          _elements = el;
          isLoading = false;
          l = trajetDocs.total;
        });
      }
    } catch (e) {
      print(e);
      if (this.mounted) {
        setState(() {
          isLoading = false;
        });
        showDialog<void>(
          context: context,
          barrierDismissible: false, // user must tap button!
          builder: (BuildContext context) {
            return AlertDialog(
              // <-- SEE HERE
              title: const Text('Erreur'),
              content: SingleChildScrollView(
                child: ListBody(
                  children: const <Widget>[
                    Text(
                        'Impossible de se connecter au serveur veuillez verifier votre connection internet.....'),
                  ],
                ),
              ),
              actions: <Widget>[
                TextButton(
                  child: const Text('Ok'),
                  onPressed: () async {
                    Navigator.of(context).pop();
                  },
                ),
              ],
            );
          },
        );
      }

      print(e);
      print('IIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIII');
    }
  }

  @override
  void initState() {
    super.initState();
    //_initWork();
    //_initHistory();
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
        title: Text('Historique: 3 trajets',
            style: TextStyle(fontSize: 17, color: Colors.white)),
      ),
      body: isLoading == true
          ? const Center(child: CircularProgressIndicator())
          : _elements.isEmpty
              ? Center(
                  child: Text('Aucun trajet',
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.bold)))
              : StickyGroupedListView<Element, DateTime>(
                  elements: _elements,
                  order: StickyGroupedListOrder.ASC,
                  groupBy: (Element element) => DateTime(
                    element.date.year,
                    element.date.month,
                    element.date.day,
                  ),
                  groupComparator: (DateTime value1, DateTime value2) =>
                      value2.compareTo(value1),
                  itemComparator: (Element element1, Element element2) =>
                      element2.date.compareTo(element1.date),
                  floatingHeader: false,
                  groupSeparatorBuilder: _getGroupSeparator,
                  itemBuilder: _getItem,
                ),
    );
  }

  Widget _getGroupSeparator(Element element) {
    return SizedBox(
      height: 50,
      child: Align(
        alignment: Alignment.center,
        child: Container(
          width: 120,
          decoration: BoxDecoration(
            color: Colors.blue[300],
            border: Border.all(
              color: Colors.blue[300]!,
            ),
            borderRadius: const BorderRadius.all(Radius.circular(20.0)),
          ),
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              style: TextStyle(color: Colors.white),
              '${element.date.day}/${element.date.month}/${element.date.year}',
              textAlign: TextAlign.center,
            ),
          ),
        ),
      ),
    );
  }

  Widget _getItem(BuildContext ctx, Element element) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => TrajetScreen(element.trajet.$id)));
      },
      child: Card(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(6.0),
        ),
        elevation: 8.0,
        margin: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 6.0),
        child: Container(
            padding: const EdgeInsets.all(10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                        width: 50,
                        height: 50,
                        decoration: BoxDecoration(
                            color: Colors.grey,
                            borderRadius: BorderRadius.circular(15)),
                        child: Icon(Icons.person, color: Colors.white)),
                    const SizedBox(width: 5),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Text(
                            '${element.trajet.data['pilote']['entreprises']['nom']}',
                            style: TextStyle(fontSize: 20)),
                        Text(
                            '${DateTime.parse(element.trajet.$createdAt).day}/${DateTime.parse(element.trajet.$createdAt).month}/${DateTime.parse(element.trajet.$createdAt).year}',
                            style: TextStyle(fontSize: 18, color: Colors.grey)),
                      ],
                    )
                  ],
                ),
                Row(
                  children: [
                    Icon(Icons.location_on),
                    Text(
                        '${element.trajet.data['depart']['latitude']}, ${element.trajet.data['depart']['longitude']}')
                  ],
                ),
                const SizedBox(height: 10),
                Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Container(
                        margin: const EdgeInsets.only(left: 11),
                        width: 2,
                        height: 10,
                        decoration: BoxDecoration(color: Colors.black),
                      ),
                      const SizedBox(height: 2),
                      Container(
                        margin: const EdgeInsets.only(left: 11),
                        width: 2,
                        height: 10,
                        decoration: BoxDecoration(
                            color: const Color.fromARGB(255, 99, 94, 94)),
                      ),
                      const SizedBox(height: 2),
                      Container(
                        margin: const EdgeInsets.only(left: 11),
                        width: 2,
                        height: 10,
                        decoration: BoxDecoration(color: Colors.black),
                      ),
                      const SizedBox(height: 2),
                      Container(
                        margin: const EdgeInsets.only(left: 11),
                        width: 2,
                        height: 10,
                        decoration: BoxDecoration(color: Colors.black),
                      ),
                    ]),
                const SizedBox(height: 10),
                element.trajet.data['status'] == 'Termine'
                    ? Row(
                        children: [
                          Icon(Icons.send),
                          Text(
                              '${element.trajet.data['depart']['latitude']}, ${element.trajet.data['depart']['longitude']}')
                        ],
                      )
                    : SizedBox(
                        width: 150,
                        height: 20,
                        child: Shimmer.fromColors(
                            child: SizedBox(
                                width: 150,
                                height: 20,
                                child: Container(
                                    decoration:
                                        BoxDecoration(color: Colors.grey))),
                            baseColor: Colors.grey,
                            highlightColor: Colors.white),
                      ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '${element.trajet.data['pilote']['nom']} ${element.trajet.data['pilote']['prenom']}',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(5),
                            color: element.trajet.data['status'] == 'En Cours'
                                ? Colors.red
                                : element.trajet.data['status'] == 'Termine'
                                    ? Colors.green
                                    : Colors.black),
                        child: Text(element.trajet.data['status'].toUpperCase(),
                            style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold)))
                  ],
                )
              ],
            )
            /*ListTile(
            onTap: () {
              Navigator.push(context,
                  MaterialPageRoute(builder: (context) => const TrajetScreen()));
            },
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
            leading: const Icon(Icons.history),
            title: const Text('Reservation de taxi moto'),
            subtitle: Text('Status: ${element.status}'),
            trailing: Text('${element.date.hour}:${element.date.minute}'),
          ),*/
            ),
      ),
    );
  }
}

class Element {
  DateTime date;
  String name;
  IconData icon;
  String status;
  String trajetId;
  Document trajet;
  Element(
      this.date, this.name, this.icon, this.status, this.trajetId, this.trajet);
}
