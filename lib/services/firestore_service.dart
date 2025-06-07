import 'package:cloud_firestore/cloud_firestore.dart';

class FirestoreService {
  final CollectionReference events = FirebaseFirestore.instance.collection('events');

  Stream<QuerySnapshot> getUserEvents(String uid) {
    return events.where('createdBy', isEqualTo: uid).snapshots();
  }

  Future<void> addEvent(Map<String, dynamic> data) async {
    await events.add(data);
  }

  Future<void> updateEvent(String docId, Map<String, dynamic> data) async {
    await events.doc(docId).update(data);
  }

  Future<void> deleteEvent(String docId) async {
    await events.doc(docId).delete();
  }
}
