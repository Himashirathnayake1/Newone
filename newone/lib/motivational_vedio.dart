import 'package:flutter/material.dart';
import 'package:newone/vedio_player.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

Future<void> markVideoWatchedToday() async {
  final uid = FirebaseAuth.instance.currentUser?.uid;
  if (uid == null) return;

  final today = DateTime.now().toString().substring(0, 10);
  final doc = FirebaseFirestore.instance
      .collection('users')
      .doc(uid)
      .collection('progress')
      .doc(today);

  await doc.set({'video': true}, SetOptions(merge: true));
}


class MotivationVideoPage extends StatelessWidget {
  final List<String> videoIds = [
    'mgmVOuLgFB0',
    'wnHW6o8WMas',
    'SUXM8wN206E',
    'iuvtKtkv5fM',
    'tLULIzOj-Ew',
    'wCyyVuDIsrg',
    'v_kXdpG8PhM',
    '6lSseRcPSMY',
    'pNKYJZ4M46A',
    'VxhUQ1agA7w',
    'bo47JoSxl1s'
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("🎥 Daily English"),
        backgroundColor: Colors.teal,
      ),
      body: 
      Stack(
  children: [
    // 🌄 Background Image
    Positioned.fill(
      child: Image.asset(
        'assets/back.jpg',
        fit: BoxFit.cover,
      ),
    ),

    // 🧼 Semi-transparent overlay
    Positioned.fill(
      child: Container(
        color: Colors.white.withOpacity(0.85),
      ),
    ),ListView.builder(
        itemCount: videoIds.length,
        itemBuilder: (context, index) {
          final videoId = videoIds[index];
          final thumbnailUrl = 'https://img.youtube.com/vi/$videoId/0.jpg';

          return GestureDetector(
           onTap: () async {
  await markVideoWatchedToday(); // ✅ Mark progress
  Navigator.push(
    context,
    MaterialPageRoute(
      builder: (_) => VideoPlayerScreen(videoId: videoId),
    ),
  );
},

            child: Card(
              margin: const EdgeInsets.all(10),
              child: Column(
                children: [
                  Image.network(thumbnailUrl),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text("Tap to Watch", style: TextStyle(fontSize: 16)),
                  )
                ],
              ),
            ),
          );
        },
      ),],),
    );
  }
}
