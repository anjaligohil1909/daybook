import 'package:cloud_firestore/cloud_firestore.dart';
import 'auth_service.dart';

String email = getUserEmail();

DocumentReference userDoc =
    FirebaseFirestore.instance.collection('users').doc(email);

Future<DocumentReference> createJourney(String title, String description,
    DateTime startDate, DateTime endDate) async {
  DateTime now = new DateTime.now();
  bool isActive = false;
  if (endDate.isAfter(now)) {
    isActive = true;
  }
  Future<DocumentReference> query = userDoc.collection('journeys').add({
    'title': title,
    'description': description,
    'dateCreated': DateTime(now.year, now.month, now.day).toString(),
    'startDate': startDate.toString(),
    'endDate': endDate.toString(),
    'isActive': isActive,
    'isFavourite': false,
    'entries': []
  });
  return query;
}

void onCheckFavourite(String journeyId, bool checkedValue) {
  userDoc.collection('journeys').doc(journeyId).update({
    'isFavourite': checkedValue,
  });
}

Stream<QuerySnapshot> getJourneys() {
  Stream<QuerySnapshot> query = userDoc.collection('journeys').snapshots();
  return query;
}

Future<DocumentSnapshot> getJourney(String journeyId) async {
  DocumentSnapshot doc =
      await userDoc.collection('journeys').doc(journeyId).get();
  return doc;
}

Future<void> editJourney(String journeyId, String title, String description,
    DateTime startDate, DateTime endDate) async {
  DateTime now = new DateTime.now();
  bool isActive = false;
  if (endDate.isAfter(now)) {
    isActive = true;
  }
  Future<void> query = userDoc.collection('journeys').doc(journeyId).update({
    'title': title,
    'description': description,
    'dateCreated': DateTime(now.year, now.month, now.day).toString(),
    'startDate': startDate.toString(),
    'endDate': endDate.toString(),
    'isActive': isActive,
  });
  print(query);
}

void deleteJourney(DocumentSnapshot documentSnapshot) async {
  await FirebaseFirestore.instance
      .runTransaction((Transaction myTransaction) async {
    myTransaction.delete(documentSnapshot.reference);
  });
}

Future<Stream<QuerySnapshot>> getEntriesOfJourney(String journeyId) async {
  DocumentSnapshot journeyDoc = await getJourney(journeyId);

  List<dynamic> entries = journeyDoc['entries'];

  if(entries.length == 0){
    entries =  ['Null'];
  }

  Stream<QuerySnapshot> filteredEntries = userDoc
      .collection('entries')
      .where('docId', whereIn: entries)
      .snapshots();

  return filteredEntries;
}

void addEntriestoJourney(String journeyId, List<dynamic> entries) async {
  List<String> ens = [];
  for (dynamic i in entries) {
    ens.add(i.toString());
  }
  userDoc.collection('journeys').doc(journeyId).update({"entries": ens});
}
