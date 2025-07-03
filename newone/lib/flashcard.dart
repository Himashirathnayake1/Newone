import 'package:flutter/material.dart';
import 'package:flip_card/flip_card.dart'; // ✅ NEW PACKAGE
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class FlashcardScreen extends StatefulWidget {
  const FlashcardScreen({super.key});

  @override
  State<FlashcardScreen> createState() => _FlashcardScreenState();
}

class _FlashcardScreenState extends State<FlashcardScreen> {
  int currentIndex = 0;
  List<Map<String, String>> flashcards = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadFlashcards();
  }

  // 🔄 Load flashcards from Firestore
  Future<void> _loadFlashcards() async {
    final snapshot = await FirebaseFirestore.instance.collection('flashcards').get();
    final data = snapshot.docs.map((doc) {
      final map = doc.data();
      return {
        'word': map['word']?.toString() ?? '',
        'meaning': map['meaning']?.toString() ?? '',
      };
    }).toList();

    setState(() {
      flashcards = data.cast<Map<String, String>>();
      isLoading = false;
    });
  }

  // ➡️ Next button logic
  void nextCard() async {
    if (currentIndex < flashcards.length - 1) {
      setState(() {
        currentIndex++;
      });
    } else {
      await _updateProgress(1.0 / flashcards.length);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("🎉 Well done! Progress updated.")),
      );
      setState(() {
        currentIndex = 0;
      });
    }
  }

  // 🔄 Update progress in Firestore
  Future<void> _updateProgress(double valueToAdd) async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;

    final userDoc = FirebaseFirestore.instance.collection('users').doc(uid);
    final snapshot = await userDoc.get();
    final current = (snapshot.data()?['progress'] ?? 0.0).toDouble();
    final updated = (current + valueToAdd).clamp(0.0, 1.0);

    await userDoc.update({'progress': updated});
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return Scaffold(
        appBar: AppBar(title: const Text("Flashcards"), backgroundColor: Colors.teal),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    if (flashcards.isEmpty) {
      return Scaffold(
        appBar: AppBar(title: const Text("Flashcards"), backgroundColor: Colors.teal),
        body: const Center(child: Text("No flashcards found.")),
      );
    }

    final card = flashcards[currentIndex];

    return Scaffold(
      appBar: AppBar(
        title: const Text("Flashcards"),
        backgroundColor: Colors.teal,
      ),
      backgroundColor: const Color(0xFFF9FAFB),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            const SizedBox(height: 40),
            Expanded(
              child: FlipCard(
                direction: FlipDirection.HORIZONTAL,
                front: _cardFace(card['word']!, isFront: true),
                back: _cardFace(card['meaning']!, isFront: false),
              ),
            ),
            const SizedBox(height: 30),
            ElevatedButton(
              onPressed: nextCard,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.teal,
                minimumSize: const Size(double.infinity, 50),
              ),
              child: Text(currentIndex == flashcards.length - 1 ? "Finish" : "Next"),
            ),
          ],
        ),
      ),
    );
  }

  // 📇 Flashcard UI
  Widget _cardFace(String text, {required bool isFront}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(30),
      decoration: BoxDecoration(
        color: isFront ? Colors.white : Colors.teal[100],
        borderRadius: BorderRadius.circular(20),
        boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 6, offset: Offset(0, 2))],
      ),
      child: Center(
        child: Text(
          text,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: isFront ? Colors.teal[800] : Colors.black87,
          ),
        ),
      ),
    );
  }
}
