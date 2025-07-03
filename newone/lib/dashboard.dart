import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:newone/flashcard.dart';
import 'package:newone/speakingpractice.dart';
import 'package:newone/vocabulary.dart';
import 'package:newone/writingtask.dart';
import 'package:animate_do/animate_do.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';

class HomeDashboard extends StatelessWidget {
  final String userId = FirebaseAuth.instance.currentUser!.uid;

  HomeDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF0F4F8),
      body: SafeArea(
        child: Stack(
          children: [
            // Wave background
            _buildWaveBackground(),
            StreamBuilder<DocumentSnapshot>(
              stream: FirebaseFirestore.instance.collection('users').doc(userId).snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator(color: Colors.teal));
                }

                final data = snapshot.data!.data() as Map<String, dynamic>;
                final String userName = data['username'] ?? 'User';
                final double progress = (data['progress'] ?? 0.0).toDouble();
                final int streakDays = data['streakDays'] ?? 0;
                final int completedTasks = (data['completedTasks'] ?? 0);

                return SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(20, 80, 20, 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ZoomIn(
                        child: _buildHeader(context, userName, streakDays),
                      ),
                      const SizedBox(height: 20),
                      FadeInUp(
                        child: _motivationalQuoteCard(),
                      ),
                      const SizedBox(height: 20),
                      FadeInLeft(
                        child: _progressCard(progress, completedTasks),
                      ),
                      const SizedBox(height: 30),
                      FadeInUp(
                        child: Text(
                          "Your Learning Plan",
                          style: GoogleFonts.poppins(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: Colors.teal[900],
                          ),
                        ),
                      ),
                      const SizedBox(height: 10),
                      _buildTaskList(context),
                      const SizedBox(height: 30),
                      FadeInUp(
                        child: Row(
                          children: [
                            _miniCard("🔥 $streakDays-day Streak", Colors.orange[200]!, Icons.local_fire_department),
                            const SizedBox(width: 16),
                            _miniCard("💡 Daily Tip: Speak confidently!", Colors.yellow[200]!, Icons.lightbulb),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWaveBackground() {
    return Container(
      height: 200,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.teal[700]!, Colors.teal[400]!],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
      child: CustomPaint(
        painter: WavePainter(),
        child: Container(),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, String userName, int streakDays) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Flexible(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Hello, $userName! 👋",
                style: GoogleFonts.poppins(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
                overflow: TextOverflow.ellipsis,
                maxLines: 1,
              ),
              Text(
                "Ready to master English?",
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  color: Colors.white70,
                ),
                overflow: TextOverflow.ellipsis,
                maxLines: 1,
              ),
            ],
          ),
        ),
        const SizedBox(width: 16),
        ZoomIn(
          child: CircleAvatar(
            radius: 24,
            backgroundColor: Colors.teal[100],
            child: Text(
              userName[0].toUpperCase(),
              style: GoogleFonts.poppins(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.teal[900],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _motivationalQuoteCard() {
    const quotes = [
      "Language is the key to the heart of culture.",
      "Every word you learn is a step forward.",
      "Speak, learn, grow—every day!",
    ];
    final randomQuote = quotes[DateTime.now().day % quotes.length];

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.blue[100]!, Colors.blue[300]!],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: const [
          BoxShadow(
            blurRadius: 10,
            color: Colors.black12,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Daily Inspiration",
            style: GoogleFonts.poppins(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.teal[900],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            randomQuote,
            style: GoogleFonts.poppins(
              fontSize: 16,
              fontStyle: FontStyle.italic,
              color: Colors.teal[800],
            ),
          ),
        ],
      ),
    );
  }

  Widget _progressCard(double progress, int completedTasks) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: const [
          BoxShadow(
            blurRadius: 10,
            color: Colors.black12,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          CircularPercentIndicator(
            radius: 50.0,
            lineWidth: 12.0,
            percent: progress,
            center: Text(
              "${(progress * 100).toStringAsFixed(0)}%",
              style: GoogleFonts.poppins(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.teal[900],
              ),
            ),
            progressColor: Colors.teal[600],
            backgroundColor: Colors.grey[200]!,
            circularStrokeCap: CircularStrokeCap.round,
          ),
          const SizedBox(width: 20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Today's Progress",
                  style: GoogleFonts.poppins(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.teal[900],
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  "$completedTasks of 3 tasks completed",
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    color: Colors.grey[700],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTaskList(BuildContext context) {
    return Column(
      children: [
        FadeInUp(
          delay: const Duration(milliseconds: 200),
          child: _taskCard(
            context,
            "🗣️ Speaking Practice",
            "10-minute conversation",
            Icons.mic,
            () => Navigator.push(context, MaterialPageRoute(builder: (context) => SpeakingPracticePage())),
            "Speaking Practice tapped!",
          ),
        ),
        FadeInUp(
          delay: const Duration(milliseconds: 400),
          child: _taskCard(
            context,
            "📖 Vocabulary Quiz",
            "Learn 10 new words",
            Icons.book,
            () => Navigator.push(context, MaterialPageRoute(builder: (context) => VocabularyQuizPage())),
            "Vocabulary tapped!",
          ),
        ),
        FadeInUp(
          delay: const Duration(milliseconds: 600),
          child: _taskCard(
            context,
            "✍️ Writing Task",
            "Write a short paragraph",
            Icons.edit,
            () => Navigator.push(context, MaterialPageRoute(builder: (context) => WritingTaskPage())),
            "Writing Task tapped!",
          ),
        ),
        FadeInUp(
          delay: const Duration(milliseconds: 800),
          child: _taskCard(
            context,
            "🧠 Flashcards",
            "Review key phrases",
            Icons.style,
            () => Navigator.push(context, MaterialPageRoute(builder: (context) => FlashcardScreen())),
            "Flashcards tapped!",
          ),
        ),
      ],
    );
  }

  Widget _taskCard(
    BuildContext context,
    String title,
    String subtitle,
    IconData icon,
    VoidCallback onTap,
    String snackBarMessage,
  ) {
    return GestureDetector(
      onTap: () {
        onTap();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(snackBarMessage)),
        );
      },
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 8),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.teal[50]!, Colors.teal[100]!],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(20),
          boxShadow: const [
            BoxShadow(
              blurRadius: 8,
              color: Colors.black12,
              offset: Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.teal[600],
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: Colors.white, size: 28),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: GoogleFonts.poppins(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: Colors.teal[900],
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      color: Colors.grey[700],
                    ),
                  ),
                ],
              ),
            ),
            Icon(Icons.arrow_forward_ios, color: Colors.teal[600], size: 20),
          ],
        ),
      ),
    );
  }

  Widget _miniCard(String text, Color bgColor, IconData icon) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(16),
          boxShadow: const [
            BoxShadow(
              blurRadius: 6,
              color: Colors.black12,
              offset: Offset(0, 3),
            ),
          ],
        ),
        child: Row(
          children: [
            Icon(icon, color: Colors.teal[800], size: 20),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                text,
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Colors.teal[800],
                ),
                overflow: TextOverflow.ellipsis,
                maxLines: 1,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class WavePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withOpacity(0.1)
      ..style = PaintingStyle.fill;

    final path = Path();
    path.moveTo(0, size.height * 0.6);
    path.quadraticBezierTo(
      size.width * 0.25,
      size.height * 0.8,
      size.width * 0.5,
      size.height * 0.6,
    );
    path.quadraticBezierTo(
      size.width * 0.75,
      size.height * 0.4,
      size.width,
      size.height * 0.6,
    );
    path.lineTo(size.width, size.height);
    path.lineTo(0, size.height);
    path.close();

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}