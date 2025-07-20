import 'package:flutter/material.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';

class MotivationalVideosPage extends StatefulWidget {
  const MotivationalVideosPage({super.key});

  @override
  State<MotivationalVideosPage> createState() => _MotivationalVideosPageState();
}

class _MotivationalVideosPageState extends State<MotivationalVideosPage> {
  final List<String> _videoIds = [
    'ZXsQAXx_ao0', // Replace with your motivational video IDs
    'mgmVOuLgFB0',
    'wnHW6o8WMas',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("🔥 Motivational Videos"),
        backgroundColor: Colors.deepPurple,
      ),
      body: ListView.builder(
        itemCount: _videoIds.length,
        itemBuilder: (context, index) {
          final videoId = _videoIds[index];
          return Padding(
            padding: const EdgeInsets.all(12.0),
            child: YoutubePlayer(
              controller: YoutubePlayerController(
                initialVideoId: videoId,
                flags: const YoutubePlayerFlags(
                  autoPlay: false,
                  mute: false,
                ),
              ),
              showVideoProgressIndicator: true,
              progressColors: const ProgressBarColors(
                playedColor: Colors.red,
                handleColor: Colors.redAccent,
              ),
            ),
          );
        },
      ),
    );
  }
}
