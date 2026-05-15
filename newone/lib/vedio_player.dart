import 'package:flutter/material.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';
class VideoPlayerScreen extends StatelessWidget {
  final String videoId;

  const VideoPlayerScreen({super.key, required this.videoId});

  @override
  Widget build(BuildContext context) {
    final controller = YoutubePlayerController(
      initialVideoId: videoId,
      flags: const YoutubePlayerFlags(autoPlay: true),
    );

    return Scaffold(
      appBar: AppBar(title: Text("▶️ Now Playing")),
      body: YoutubePlayer(
        controller: controller,
        showVideoProgressIndicator: true,
      ),
    );
  }
}
