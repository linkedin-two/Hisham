import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'package:chewie/chewie.dart';

class GoogleDriveVideoPlayer extends StatefulWidget {
  final String url;

  const GoogleDriveVideoPlayer({super.key, required this.url});

  @override
  State<GoogleDriveVideoPlayer> createState() => _GoogleDriveVideoPlayerState();
}

class _GoogleDriveVideoPlayerState extends State<GoogleDriveVideoPlayer> {
  VideoPlayerController? _videoController;
  ChewieController? _chewieController;
  String? directUrl;
  bool loading = true;
  bool error = false;

  String? extractFileId(String url) {
    try {
      if (url.contains("file/d/")) {
        return url.split("file/d/")[1].split("/")[0];
      }
      if (url.contains("id=")) {
        return url.split("id=")[1].split("&")[0];
      }
      return null;
    } catch (_) {
      return null;
    }
  }

  String? convertToDirectLink(String url) {
    final fileId = extractFileId(url);
    if (fileId == null) return null;
    return "https://drive.google.com/uc?export=download&id=$fileId";
  }

  Future<void> initPlayer() async {
    final link = convertToDirectLink(widget.url);
    if (link == null) {
      error = true;
      loading = false;
      setState(() {});
      return;
    }

    directUrl = link;

    _videoController = VideoPlayerController.networkUrl(Uri.parse(directUrl!));
    await _videoController!.initialize();

    _chewieController = ChewieController(
      videoPlayerController: _videoController!,
      autoPlay: true,
      looping: false,
      allowFullScreen: true,
    );

    loading = false;
    setState(() {});
  }

  @override
  void initState() {
    super.initState();
    initPlayer();
  }

  @override
  void dispose() {
    _videoController?.dispose();
    _chewieController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (loading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (error || directUrl == null) {
      return const Scaffold(
        body: Center(child: Text("Invalid Google Drive Link")),
      );
    }

    return Scaffold(
      body: SafeArea(
        child: Chewie(controller: _chewieController!),
      ),
    );
  }
}
