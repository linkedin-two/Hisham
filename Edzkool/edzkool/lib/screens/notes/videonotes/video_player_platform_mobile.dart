import 'package:flutter/material.dart';
import 'package:edzkool/screens/notes/videonotes/video_player_gdrive.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';

class VideoPlayer extends StatelessWidget {
  final String url;

  const VideoPlayer({super.key, required this.url});

  bool _isYouTubeUrl(String url) {
    final uri = Uri.tryParse(url);
    if (uri == null) return false;
    return uri.host.contains('youtube.com') || uri.host.contains('youtu.be');
  }

  bool _isGoogleDriveUrl(String url) {
    final uri = Uri.tryParse(url);
    if (uri == null) return false;
    return uri.host.contains('drive.google.com');
  }

  @override
  Widget build(BuildContext context) {
    if (_isGoogleDriveUrl(url)) {
      return GoogleDriveVideoPlayer(url: url);
    }

    if (_isYouTubeUrl(url)) {
      final videoId = YoutubePlayer.convertUrlToId(url);
      if (videoId != null && videoId.isNotEmpty) {
        final controller = YoutubePlayerController(
          initialVideoId: videoId,
          flags: const YoutubePlayerFlags(
            autoPlay: true,
            mute: false,
            showLiveFullscreenButton: true,
          ),
        );

        return YoutubePlayerBuilder(
          player: YoutubePlayer(controller: controller),
          builder: (context, player) {
            return Scaffold(
              body: SafeArea(
                child: Center(child: player),
              ),
            );
          },
        );
      }
    }

    return const Scaffold(
      body: SafeArea(
        child: Center(
          child: Text('Unsupported video URL'),
        ),
      ),
    );
  }
}
