// ignore_for_file: prefer_const_literals_to_create_immutables, prefer_const_constructors

import 'package:appwrite/appwrite.dart';
import 'package:appwrite/models.dart';
import 'package:flutter/material.dart';
import 'package:sticky_grouped_list/sticky_grouped_list.dart';
import '../../utils/constants.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PiloteActiviteScreen extends StatefulWidget {
  const PiloteActiviteScreen({super.key});

  @override
  State<PiloteActiviteScreen> createState() => _PiloteActiviteScreenState();
}

class _PiloteActiviteScreenState extends State<PiloteActiviteScreen> {
  //List<Element> trajets = [];
  bool isLoading = true;
  String userId = '';
  String piloteId = '';
  late SharedPreferences preferences;
  List<Element> _elements = <Element>[
    /*Element(DateTime(2020, 6, 24, 18), 'Got to gym', Icons.fitness_center),
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
      //print('IIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIII');
      SharedPreferences preferences = await SharedPreferences.getInstance();
      piloteId = (preferences.getString('piloteId'))!;
      final realtime = Realtime(client);

      final subscription = realtime.subscribe([
        'databases.$DATABASE_ID.collections.$ACTIVITE_COLLECTION_ID.documents'
      ]);

      subscription.stream.listen((response) {
        print(response.payload['client']['\$id']);
        print(piloteId);
        if (response.payload['pilote']['\$id'] == piloteId) {
          print('IIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIII');
          //if(response.payload['client'])
          _initHistory();
        }
      });
      //print('IIIIIIIIIIIIIIIIIIIIII');
    } catch (e) {
      print(e);
    }
  }

////
//////
  ///CHANGER L"ID
  void _initHistory() async {
    try {
      SharedPreferences preferences = await SharedPreferences.getInstance();
      //print('PPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPP');
      userId = (preferences.getString('userId'))!;
      piloteId = (preferences.getString('piloteId'))!;
      //print(context.read<AppState>().myUser?.id);
      //print(clientId);

      final activiteDocs = await databases.listDocuments(
          databaseId: DATABASE_ID,
          collectionId: ACTIVITE_COLLECTION_ID,
          queries: [Query.equal('piloteId', piloteId)]);
      List<Element> el = activiteDocs.documents.map((e) {
        print(e.$createdAt);
        return Element(DateTime.parse(e.$createdAt), e);
      }).toList();
      setState(() {
        _elements = el;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      return showDialog<void>(
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
      print(e);
    }
  }

  @override
  void initState() {
    super.initState();
    _initWork();
    _initHistory();
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
        title: const Text('Activite',
            style: TextStyle(fontSize: 17, color: Colors.white)),
      ),
      body: isLoading == true
          ? const Center(child: CircularProgressIndicator())
          : _elements.isEmpty
              ? Center(
                  child: Text('Aucune activite',
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
                      element1.date.compareTo(element2.date),
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
        /*Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => TrajetScreen(element.trajet.$id)));*/
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
                        child: Center(
                            child: Icon(Icons.person, color: Colors.white))),
                    const SizedBox(width: 5),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        element.activite.data['categorie'] == 'CONNECTIONCLIENT'
                            ? Text('Connexion', style: TextStyle(fontSize: 20))
                            : Text(''),
                        Text(
                            '${DateTime.parse(element.activite.$createdAt).day}/${DateTime.parse(element.activite.$createdAt).month}/${DateTime.parse(element.activite.$createdAt).year},  ${DateTime.parse(element.activite.$createdAt).hour}:${DateTime.parse(element.activite.$createdAt).minute}:${DateTime.parse(element.activite.$createdAt).second}',
                            style: TextStyle(fontSize: 18, color: Colors.grey)),
                      ],
                    )
                  ],
                ),
                const SizedBox(height: 10),
                Text('Vous vous ete connecter a votre compte',
                    style: TextStyle(fontSize: 18)),
                const SizedBox(height: 10),
              ],
            )
            /*ListTile(
            onTap: () {
              /*Navigator.push(context,
                  MaterialPageRoute(builder: (context) => const TrajetScreen()));*/
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

  Document activite;
  Element(this.date, this.activite);
}
