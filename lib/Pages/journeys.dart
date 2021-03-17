import 'package:daybook/Services/journeyService.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class JourneysScreen extends StatefulWidget {
  @override
  _JourneysScreenState createState() => _JourneysScreenState();
}

class _JourneysScreenState extends State<JourneysScreen> {
  final List<int> colorCodes = <int>[400, 300, 200];
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Container(
        color: Color(0xFF111111),
        child: Stack(
          children: [
            StreamBuilder(
                stream: getJourneys(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return Container(
                        height: double.infinity,
                        width: double.infinity,
                        child: CircularProgressIndicator());
                  }
                  if (snapshot.data.docs.length == 0) {
                    return Container(
                        height: double.infinity,
                        width: double.infinity,
                        child: Center(
                          child: Text(
                            "No journeys created !! \n Click on + to get started",
                            style: TextStyle(
                              fontSize: 27,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ));
                  }
                  return new ListView.builder(
                      padding: EdgeInsets.fromLTRB(17, 10, 17, 25),
                      itemCount: snapshot.data.docs.length,
                      itemBuilder: (context, index) {
                        DocumentSnapshot ds = snapshot.data.docs[index];
                        return JourneyCard(
                            colorCodes: colorCodes,
                            // title: ds["title"],
                            // description: ds["description"],
                            index: index,
                            // dateCreated: ds["dateCreated"],
                            // journeyId: ds.id,
                            documentSnapshot: ds);
                      });
                }),
            Positioned(
              bottom: 15,
              right: 15,
              child: FloatingActionButton(
                child: Icon(
                  Icons.add,
                  size: 40,
                ),
                onPressed: () => {
                  Navigator.pushNamed(context, '/createEntry', arguments: [])
                  // print('Button pressed!');
                },
              ),
            ),
          ],
        ),
      ),
    );
    // Column(
    //   mainAxisAlignment: MainAxisAlignment.center,
    //   children: [
    //     Text("Tab Journeys !"),
    //     SizedBox(height: 15),
    //     RaisedButton(
    //       onPressed: () {
    //         final provider =
    //             Provider.of<GoogleSignInProvider>(context, listen: false);
    //         provider.logout();
    //         Navigator.push(
    //           context,
    //           MaterialPageRoute(builder: (context) => StartPage()),
    //         );
    //       },
    //       child: Text('Logout'),
    //     )
    //   ],
    // ));
  }
}

class JourneyCard extends StatelessWidget {
  JourneyCard({
    Key key,
    @required this.colorCodes,
    @required this.index,
    @required this.documentSnapshot,
  }) : super(key: key);

  final List<int> colorCodes;
  final int index;
  final DocumentSnapshot documentSnapshot;

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 5,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15.0),
      ),
      margin: EdgeInsets.fromLTRB(0, 0, 0, 20),
      color: Colors.amber[colorCodes[index % 3]],
      clipBehavior: Clip.antiAlias,
      child: Padding(
        padding: const EdgeInsets.all(17.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            GestureDetector(
                onTap: () {
                  print("Tapped on journey " + documentSnapshot.id);
                },
                onLongPress: () {
                  showDialog(
                    context: context,
                    barrierDismissible: false,
                    builder: (context) => AlertDialog(
                      title: Text("Detele Journey ?"),
                      content:
                          Text("This will delete the Journey permanently."),
                      actions: <Widget>[
                        Row(
                          children: [
                            FlatButton(
                              onPressed: () {
                                deleteJourney(documentSnapshot);
                                Navigator.of(context).pop();
                              },
                              child: Text("Delete"),
                            ),
                            FlatButton(
                              onPressed: () {
                                Navigator.of(context).pop();
                              },
                              child: Text("Cancel"),
                            ),
                          ],
                        ),
                      ],
                    ),
                  );
                },
                child: Row(
                  children: [
                    Container(
                      // padding: EdgeInsets.fromLTRB(16, 10, 16, 0),
                      width: 220,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Text(
                            documentSnapshot['title'],
                            style: TextStyle(
                                fontSize: 17, fontWeight: FontWeight.bold),
                            overflow: TextOverflow.fade,
                            maxLines: 1,
                          ),
                          SizedBox(height: 6),
                          Padding(
                            padding: const EdgeInsets.fromLTRB(0, 5, 0, 5),
                            child: Text(
                              documentSnapshot['description'],
                              style: TextStyle(
                                  fontSize: 15,
                                  color: Colors.black.withOpacity(0.6)),
                              overflow: TextOverflow.fade,
                              maxLines: 3,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                )),
            SizedBox(height: 20),
            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
              Container(
                width: 60,
                child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      GestureDetector(
                        onTap: () {
                          documentSnapshot['isFavourite']
                              ? onCheckFavourite(documentSnapshot.id, false)
                              : onCheckFavourite(documentSnapshot.id, true);
                        },
                        child: Icon(
                          documentSnapshot['isFavourite']
                              ? Icons.favorite
                              : Icons.favorite_outline_rounded,
                          size: 20,
                        ),
                      ),
                      GestureDetector(
                        child: Icon(
                          Icons.edit,
                          size: 20,
                        ),
                        onTap: () {
                          Navigator.pushNamed(context, '/createEntry',
                              arguments: [
                                documentSnapshot['title'],
                                documentSnapshot['description'],
                                documentSnapshot.id,
                              ]);
                        },
                      ),
                    ]),
              ),
              SizedBox(
                width: 20,
              ),
              Text(
                documentSnapshot['dateCreated'],
                style: TextStyle(
                    fontSize: 15, color: Colors.black.withOpacity(0.6)),
              ),
            ]),
          ],
        ),
      ),
    );
  }
}