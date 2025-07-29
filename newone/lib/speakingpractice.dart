import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:flutter_tts/flutter_tts.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lottie/lottie.dart';

class SpeakingPracticePage extends StatefulWidget {
  @override
  _SpeakingPracticePageState createState() => _SpeakingPracticePageState();
}

class _SpeakingPracticePageState extends State<SpeakingPracticePage> {
  List<String> sentences = [];
  int currentIndex = 0;
  bool isListening = false;
  String spokenText = '';
  String feedback = '';
  int accuracy = 0;

  final stt.SpeechToText _speech = stt.SpeechToText();
  final FlutterTts _flutterTts = FlutterTts();

  @override
  void initState() {
    super.initState();
    fetchSentences();
  }

  Future<void> fetchSentences() async {
    final snapshot =
        await FirebaseFirestore.instance.collection('sentences').get();
    final data = snapshot.docs.map((doc) => doc['text'].toString()).toList();
    setState(() {
      sentences = data;
    });
  }

  void nextSentence() {
    setState(() {
      currentIndex = (currentIndex + 1) % sentences.length;
      spokenText = '';
      feedback = '';
      accuracy = 0;
    });
  }

  Future<void> startListening() async {
    bool available = await _speech.initialize();
    if (available) {
      setState(() => isListening = true);
      _speech.listen(onResult: (val) {
        setState(() => spokenText = val.recognizedWords);
      });
    }
  }

  Future<void> stopListening() async {
    _speech.stop();
    setState(() => isListening = false);

    if (sentences.isNotEmpty && spokenText.isNotEmpty) {
      final expected = sentences[currentIndex];
      accuracy = calculateAccuracy(expected, spokenText);
      feedback = feedbackMessage(accuracy);
      if (accuracy < 70) {
        _flutterTts.speak("Try again. The correct sentence is: $expected");
      } else {
        markSpeakingTaskComplete(); // ✅ Save progress
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Accuracy: $accuracy% — $feedback")),
      );
    }
  }

  Future<void> speakText(String text) async {
    try {
      await _flutterTts.setLanguage('en-US');
      await _flutterTts.setPitch(0.8);
      await _flutterTts.setSpeechRate(0.4);
      await _flutterTts.speak(text);
    } catch (e) {
      print("TTS error: $e");
    }
  }

  int calculateAccuracy(String expected, String actual) {
    expected = expected.toLowerCase().trim();
    actual = actual.toLowerCase().trim();

    int matches = 0;
    final expectedWords = expected.split(' ');
    final actualWords = actual.split(' ');

    for (int i = 0; i < expectedWords.length; i++) {
      if (i < actualWords.length && expectedWords[i] == actualWords[i]) {
        matches++;
      }
    }

    return ((matches / expectedWords.length) * 100).round();
  }

  String feedbackMessage(int accuracy) {
    if (accuracy >= 90) return "🌟 Excellent pronunciation!";
    if (accuracy >= 70) return "✅ Good! Try to speak clearer.";
    return "📢 Try again, speak slowly and clearly.";
  }

  Future<void> markSpeakingTaskComplete() async {
    final uid = FirebaseAuth.instance.currentUser!.uid;
    final today = DateTime.now().toString().substring(0, 10);

    await FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .collection('progress')
        .doc(today)
        .set({'speaking': true}, SetOptions(merge: true));
  }

  @override
  Widget build(BuildContext context) {
    final sentence =
        sentences.isNotEmpty ? sentences[currentIndex] : 'Loading...';

    return Scaffold(
      backgroundColor: Color(0xFFF0F4F8),
      appBar: AppBar(
        title: Text("Speaking Practice"),
        backgroundColor: Colors.teal[300],
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

          // 🌟 Actual content
          Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              children: [
                SizedBox(height: 40),
                Container(
                  padding: EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Colors.green[100]!, Colors.teal[100]!],
                    ),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Center(
                    child: Text(
                      '"$sentence"',
                      style: GoogleFonts.lato(
                        textStyle: TextStyle(
                          fontSize: 24,
                          color: Colors.green[900],
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
                SizedBox(height: 30),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    ElevatedButton.icon(
                      onPressed: () => speakText(sentence),
                      icon: Icon(Icons.volume_up),
                      label: Text("Listen"),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green.shade200,
                      ),
                    ),
                    ElevatedButton.icon(
                      onPressed: isListening ? stopListening : startListening,
                      icon: Icon(isListening ? Icons.stop : Icons.mic),
                      label: Text(isListening ? "Stop" : "Speak"),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 20),
                if (spokenText.isNotEmpty)
                  Column(
                    children: [
                      Text(
                        "You said: $spokenText",
                        style: TextStyle(fontSize: 18, color: Colors.grey[800]),
                        textAlign: TextAlign.center,
                      ),
                      SizedBox(height: 8),
                      Text(
                        "Accuracy: $accuracy% — $feedback",
                        style: TextStyle(fontSize: 16, color: Colors.teal),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                SizedBox(height: 70),
                Lottie.asset(
                  'assets/jump.json',
                  height: 180,
                  repeat: true,
                ),
                Spacer(),
                ElevatedButton.icon(
                  onPressed: nextSentence,
                  icon: Icon(Icons.navigate_next),
                  label: Text("Next Sentence"),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.teal[100],
                    minimumSize: Size(double.infinity, 50),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
