import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:share_plus/share_plus.dart';

class DailyTipPage extends StatefulWidget {
  const DailyTipPage({super.key});

  @override
  State<DailyTipPage> createState() => _DailyTipPageState();
}

class _DailyTipPageState extends State<DailyTipPage>
    with SingleTickerProviderStateMixin {
  Map<String, dynamic>? tip;
  bool isSaving = false;
  bool loading = true;
  late AnimationController _fadeController;

  @override
  void initState() {
    super.initState();
    _fadeController =
        AnimationController(vsync: this, duration: const Duration(milliseconds: 800));
    fetchRandomTip();
  }

  Future<void> fetchRandomTip() async {
    setState(() => loading = true);
    final snapshot =
        await FirebaseFirestore.instance.collection('daily_tips').get();
    if (snapshot.docs.isEmpty) return;
    final docs = snapshot.docs;
    final randomDoc = (docs..shuffle()).first;
    setState(() {
      tip = randomDoc.data();
      loading = false;
    });
    _fadeController.forward(from: 0);
  }

  Future<void> saveTip() async {
    if (tip == null || isSaving) return;
    setState(() => isSaving = true);

    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;

    try {
      await FirebaseFirestore.instance.collection('saved_tips').add({
        'uid': uid,
        'tip': tip!['text'],
        'timestamp': Timestamp.now(),
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("✅ Tip saved!")),
      );
    } catch (e) {
      print("Error saving tip: $e");
    } finally {
      setState(() => isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final quote = tip?['text'] ?? "";
    final author = tip?['author'] ?? "";
    final imageUrl = tip?['image']; // Optional: Firestore tip image URL

    return Scaffold(
      appBar: AppBar(
        title: const Text("💡 Daily Tip"),
        backgroundColor: Colors.teal,
      ),
      backgroundColor: const Color(0xFFF0F4F8),
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
    ), loading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const SizedBox(height: 20),
                    if (imageUrl != null && imageUrl.isNotEmpty)
                      ClipRRect(
                        borderRadius: BorderRadius.circular(16),
                        child: Image.network(
                          imageUrl,
                          height: 180,
                          width: double.infinity,
                          fit: BoxFit.cover,
                        ),
                      ),
                    const SizedBox(height: 20),
                    AnimatedBuilder(
                      animation: _fadeController,
                      builder: (context, child) {
                        return Opacity(
                          opacity: _fadeController.value,
                          child: child,
                        );
                      },
                      child: Container(
                        padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(colors: [
                            Colors.teal.shade100,
                            Colors.teal.shade300
                          ]),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Column(
                          children: [
                            Text(
                              '"$quote"',
                              style: const TextStyle(
                                  fontSize: 24,
                                  fontStyle: FontStyle.italic,
                                  color: Colors.teal),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 12),
                            Text(
                              "- $author",
                              style: const TextStyle(
                                  fontSize: 16, color: Colors.teal),
                              textAlign: TextAlign.right,
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 30),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        ElevatedButton.icon(
                          onPressed: fetchRandomTip,
                          icon: const Icon(Icons.refresh),
                          label: const Text("Another Tip"),
                          style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.teal),
                        ),
                        ElevatedButton.icon(
                          onPressed: saveTip,
                          icon: const Icon(Icons.favorite_border),
                          label: const Text("Save"),
                          style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.pinkAccent),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: () {
                          Share.share('💡 $quote\n\n– $author',
                              subject: 'Today\'s English Learning Tip');
                        },
                        icon: const Icon(Icons.share),
                        label: const Text("Share"),
                        style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blueAccent),
                      ),
                      
                    )
                  ],
                ),
              ),
            ),],)
    );
  }

  @override
  void dispose() {
    _fadeController.dispose();
    super.dispose();
  }
}
