import 'package:flutter/material.dart';
import 'package:youtube_player_iframe/youtube_player_iframe.dart';



class Youtuber extends StatelessWidget {
  const Youtuber({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Cross-Platform YouTube Player',
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark(),
      home: const YouTubeHome(),
    );
  }
}

class YouTubeHome extends StatefulWidget {
  const YouTubeHome({super.key});

  @override
  State<YouTubeHome> createState() => _YouTubeHomeState();
}

class _YouTubeHomeState extends State<YouTubeHome> {
  final TextEditingController _urlController = TextEditingController(
    text: 'https://www.youtube.com/watch?v=dQw4w9WgXcQ', // default demo link
  );
  YoutubePlayerController? _controller;

  void _loadVideo() {
    final url = _urlController.text.trim();
    final videoId = YoutubePlayerController.convertUrlToId(url);

    if (videoId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Invalid YouTube URL')),
      );
      return;
    }

    _controller = YoutubePlayerController.fromVideoId(
      videoId: videoId,
      autoPlay: true,
      params: const YoutubePlayerParams(
        showFullscreenButton: true,
        enableCaption: true,
        strictRelatedVideos: false,
      ),
    );
    setState(() {});
  }

  @override
  void dispose() {
    _controller?.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('YouTube Full Player')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: _urlController,
              decoration: const InputDecoration(
                labelText: 'Enter YouTube URL',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: _loadVideo,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.redAccent,
              ),
              child: const Text('Play Video'),
            ),
            const SizedBox(height: 24),
            Expanded(
              child: _controller == null
                  ? const Center(child: Text('Enter a YouTube URL to play'))
                  : YoutubePlayerScaffold(
                      controller: _controller!,
                      builder: (context, player) => Center(child: player),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
