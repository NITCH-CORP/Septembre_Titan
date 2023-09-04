// ignore_for_file: prefer_const_literals_to_create_immutables, prefer_const_constructors, unused_local_variable

import 'package:flutter/material.dart';
import 'package:titantrue/utils/constants.dart';
import 'package:appwrite/appwrite.dart';

import 'SearchingPilote.dart';

class ChoosePilote extends StatefulWidget {
  const ChoosePilote({super.key});

  @override
  State<ChoosePilote> createState() => _ChoosePiloteState();
}

class _ChoosePiloteState extends State<ChoosePilote> {
  List<dynamic> entreprises = [];
  bool isLoading = true;
  Future<void> _loadEntreprise() async {
    try {
      await Future.delayed(const Duration(seconds: 2));
      final results = await databases.listDocuments(
          databaseId: DATABASE_ID, collectionId: ENTREPRISE_COLLECTION_ID,queries:[Query.equal('actif',true),Query.equal('supprime',false)]);
      for (int i = 0; i < results.documents.length; i++) {
        //print(document.data['nom']);
        //print('IIIIIIIIIIIIIIIIIIIIIIIIII');
        entreprises.add(results.documents[i]);
      }
      //print('XXXXXXXXXXXXXXXXXXXXXXXX');
      //print(results.documents[0].data);
      //print('UUUUUUUUUUUUUUUUUUUUUU');
      setState(() {
        entreprises = entreprises;
        isLoading = false;
      });
    } catch (e) {
      print(e);
      print('EEEEEEEEEEEEEEEEEEEEEE');
    }
  }

  @override
  void initState() {
    super.initState();
    _loadEntreprise();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Scaffold(
        appBar: AppBar(
            leading: IconButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                icon: const Icon(Icons.chevron_left, color: Colors.white)),
            backgroundColor: Colors.blue,
            title: Text('Taxi Moto', style: TextStyle(color: Colors.white))),
        body: Container(
            padding: const EdgeInsets.all(8),
            child: isLoading == true
                ? Center(child: CircularProgressIndicator())
                : ListView.builder(
                    itemCount: entreprises.length,
                    itemBuilder: (context, index) {
                      return GestureDetector(
                        onTap: () {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => SearchingPilote(
                                      entreprises[index].$id,
                                      entreprises[index].data['nom'],
                                      index.toString())));
                        },
                        child: Container(
                          width: size.width,
                          height: 60,
                          margin: const EdgeInsets.symmetric(vertical: 10),
                          padding: const EdgeInsets.all(5),
                          decoration: BoxDecoration(
                              color: const Color.fromARGB(255, 236, 234, 234),
                              borderRadius:
                                  BorderRadius.all(Radius.circular(10))),
                          child: Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              //crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Hero(
                                    tag: "${entreprises[index].$id}",
                                    child: SizedBox(
                                        width: 100,
                                        child: Image.asset(
                                            'assets/images/gozem3.png'))),
                                SizedBox(
                                    width: 120,
                                    child: Text(
                                        "${entreprises[index].data['nom']}",
                                        style: TextStyle(fontSize: 20))),
                                Spacer(),
                                IconButton(
                                    onPressed: () {},
                                    icon: Icon(Icons.chevron_right,
                                        color: Colors.black))
                                /*Text('Societe'),
                            const SizedBox(width: 5),
                            Text('Gozem',
                                style: TextStyle(fontWeight: FontWeight.bold))*/
                              ]),
                        ),
                      );
                    })));
  }
}
