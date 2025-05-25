import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class FirebaseCommon {
  final String userId;

  FirebaseCommon() : userId = FirebaseAuth.instance.currentUser!.uid;

  Future<void> saveLogToFirestore(String dateKey, List<String> logs) async {
    final docRef = FirebaseFirestore.instance
        .collection('cry_logs')
        .doc(userId)
        .collection('logs')
        .doc(dateKey);

    await docRef.set({'logs': logs});
  }

  Future<List<String>> loadLogsFromFirestore(String dateKey) async {
    final docRef = FirebaseFirestore.instance
        .collection('cry_logs')
        .doc(userId)
        .collection('logs')
        .doc(dateKey);

    final snapshot = await docRef.get();
    if (snapshot.exists) {
      final data = snapshot.data();
      return List<String>.from(data?['logs'] ?? []);
    } else {
      return [];
    }
  }

  Future<Map<String, List<String>>> getAllLogs() async {
    final collectionRef = FirebaseFirestore.instance
        .collection('cry_logs')
        .doc(userId)
        .collection('logs');

    final querySnapshot = await collectionRef.get();

    Map<String, List<String>> allLogs = {};

    for (var doc in querySnapshot.docs) {
      final data = doc.data();
      final logs = List<String>.from(data['logs'] ?? []);
      allLogs[doc.id] = logs;
    }

    return allLogs;
  }
}
