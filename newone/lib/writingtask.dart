import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class WritingTaskPage extends StatefulWidget {
  const WritingTaskPage({super.key});

  @override
  _WritingTaskPageState createState() => _WritingTaskPageState();
}

class _WritingTaskPageState extends State<WritingTaskPage> {
  final TextEditingController _controller = TextEditingController();
  final String taskTitle = "Describe a memorable day in your school life.";
  bool isLoading = false;

  void _submitAnswer() async {
    final userAnswer = _controller.text.trim();

    if (userAnswer.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text("Please write your answer before submitting.")),
      );
      return;
    }

    setState(() => isLoading = true);

    try {
      await FirebaseFirestore.instance.collection('writing_tasks').add({
        'title': taskTitle,
        'userAnswer': userAnswer,
        'timestamp': Timestamp.now(),
      });

      String feedback = _generateFeedback(userAnswer);
      if (feedback.isEmpty) {
        feedback = "";
      }
      await markWritingTaskComplete(); // ✅ Save progress

      showDialog(
        context: context,
        builder: (_) => AlertDialog(
          title: Text("✅ Feedback"),
          content: Text(feedback),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text("OK"),
            ),
          ],
        ),
      );

      _controller.clear();
    } catch (e) {
      print("Error saving answer: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text("Error submitting answer. Please try again.")),
      );
    } finally {
      setState(() => isLoading = false);
    }
  }
Future<void> markWritingTaskComplete() async {
  final uid = FirebaseAuth.instance.currentUser!.uid;
  final today = DateTime.now().toString().substring(0, 10);

  await FirebaseFirestore.instance
      .collection('users')
      .doc(uid)
      .collection('progress')
      .doc(today)
      .set({'writing': true}, SetOptions(merge: true));
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Writing Task"),
        backgroundColor: Colors.teal,
      ),
      body: Stack(
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
    ),
      Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("Today's Task",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.teal.shade50,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.teal),
              ),
              child: Text(
                taskTitle,
                style: const TextStyle(fontSize: 18),
              ),
            ),
            const SizedBox(height: 24),
            const Text("Your Answer",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500)),
            const SizedBox(height: 12),
            Expanded(
              child: TextField(
                controller: _controller,
                maxLines: null,
                expands: true,
                textAlignVertical: TextAlignVertical.top,
                decoration: InputDecoration(
                  hintText: "Start writing here...",
                  filled: true,
                  fillColor: Colors.grey.shade100,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: Colors.teal),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: isLoading ? null : _submitAnswer,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.teal,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                icon: const Icon(Icons.send),
                label: Text(
                  isLoading ? "Submitting..." : "Submit",
                  style: const TextStyle(fontSize: 18),
                ),
              ),
            ),
          ],
        ),
      ),],),
    );
  }
}

String _generateFeedback(String text) {
  final wordCount = text.trim().split(RegExp(r'\s+')).length;
  String feedback = "";

  if (wordCount < 50) {
    feedback += "📝 Try to write more. Your answer is quite short.\n\n";
  } else {
    feedback += "✅ Good length!\n\n";
  }

  if (text.contains(RegExp(r"\bi\b"))) {
    feedback += "🔠 Remember to capitalize 'I'.\n";
  }

  if (!text.contains(RegExp(r"[.,!?]"))) {
    feedback += "🧩 Try using punctuation like periods or commas.\n";
  }

  if (feedback.trim().isEmpty) {
    feedback = "🎉 Great job! Your writing looks clean.";
  }
  return feedback;
}
