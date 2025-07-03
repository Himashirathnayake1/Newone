import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class FirestoreService {
  final String uid = FirebaseAuth.instance.currentUser!.uid;

  Future<void> updateProgress(double newProgress) async {
    final userRef = FirebaseFirestore.instance.collection('users').doc(uid);

    await userRef.update({'progress': newProgress});
  }
}
