import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:flutter_tts/flutter_tts.dart';
import 'package:google_fonts/google_fonts.dart';

class SpeakingPracticePage extends StatefulWidget {
  @override
  _SpeakingPracticePageState createState() => _SpeakingPracticePageState();
}

class _SpeakingPracticePageState extends State<SpeakingPracticePage> {
  List<String> sentences = [];
  int currentIndex = 0;
  bool isListening = false;
  String spokenText = '';

  final stt.SpeechToText _speech = stt.SpeechToText();
  final FlutterTts _flutterTts = FlutterTts();

  @override
  void initState() {
    super.initState();
    fetchSentences();
  }

  Future<void> fetchSentences() async {
    final snapshot = await FirebaseFirestore.instance.collection('sentences').get();
    final data = snapshot.docs.map((doc) => doc['text'].toString()).toList();
    setState(() {
      sentences = data;
    });
  }

  void nextSentence() {
    setState(() {
      currentIndex = (currentIndex + 1) % sentences.length;
      spokenText = '';
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

  void stopListening() {
    setState(() => isListening = false);
    _speech.stop();
  }

  // Future<void> speakText(String text) async {
  //   await _flutterTts.setLanguage("en-US");
  //   await _flutterTts.setPitch(1.0);
  //   await _flutterTts.speak(text);
  // }
  Future<void> speakText(String text) async {
  try {
    await _flutterTts.setLanguage('en-US');
    await _flutterTts.setPitch(0.5);
    await _flutterTts.speak(text);
  } catch (e) {
    print("TTS error: $e");
  }
}


  @override
  Widget build(BuildContext context) {
    final sentence = sentences.isNotEmpty ? sentences[currentIndex] : 'Loading...';

    return Scaffold(
      backgroundColor: Color(0xFFF0F4F8),
      appBar: AppBar(
        title: Text("Speaking Practice"),
        backgroundColor: Colors.deepPurple,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            SizedBox(height: 40),
            Container(
              padding: EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: LinearGradient(colors: [Colors.purple[100]!, Colors.purple[300]!]),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Center(
                child: Text(
                  '"$sentence"',
                  style: GoogleFonts.lato(
                    textStyle: TextStyle(
                      fontSize: 24,
                      color: Colors.deepPurple[900],
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
                  style: ElevatedButton.styleFrom(backgroundColor: const Color.fromARGB(255, 188, 155, 245)),
                ),
                ElevatedButton.icon(
                  onPressed: isListening ? stopListening : startListening,
                  icon: Icon(isListening ? Icons.stop : Icons.mic),
                  label: Text(isListening ? "Stop" : "Speak"),
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.deepPurple),
                ),
              ],
            ),
            SizedBox(height: 20),
            Text(
              spokenText.isNotEmpty ? "You said: $spokenText" : "",
              style: TextStyle(fontSize: 18, color: Colors.grey[800]),
              textAlign: TextAlign.center,
            ),
            Spacer(),
            ElevatedButton.icon(
              onPressed: nextSentence,
              icon: Icon(Icons.navigate_next),
              label: Text("Next Sentence"),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.deepPurple,
                minimumSize: Size(double.infinity, 50),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
