import 'dart:html' show IFrameElement;
import 'dart:ui_web';
import 'package:flutter/material.dart';

// 'https://www.youtube.com/embed/h6L1DzsuME0',
// https://drive.google.com/file/d/1SNJ20_93_lJOjcMaryyvD6Fv68lrNqys/edit

/// Converts YouTube watch URL to embed URL with origin
String _convertToEmbedUrl(String url, String origin) {
  String? videoId;
  
  // Handle youtu.be short URLs
  if (url.contains('youtu.be/')) {
    videoId = url.split('youtu.be/').last.split('?').first;
  }
  
  // Handle standard youtube.com/watch?v= URLs
  else if (url.contains('youtube.com/watch')) {
    final uri = Uri.parse(url);
    videoId = uri.queryParameters['v'];
  }
  
  // Already an embed URL - extract video ID
  else if (url.contains('youtube.com/embed/')) {
    final parts = url.split('embed/');
    if (parts.length > 1) {
      videoId = parts[1].split('?').first;
    }
  }
  
  if (videoId != null && videoId.isNotEmpty) {
    // Add origin parameter for security
    return 'https://www.youtube.com/embed/$videoId?origin=$origin&rel=0';
  }
  
  return url;
}

class VideoPlayer extends StatefulWidget {
  final String url;
  const VideoPlayer({super.key, required this.url});

  @override
  State<VideoPlayer> createState() => _GDPreviewPlayerState();
}

class _GDPreviewPlayerState extends State<VideoPlayer> {
  late final String viewId;
  late final String embedUrl;

  @override
  void initState() {
    super.initState();
    
    // Create unique view ID per instance
    viewId = "youtube-iframe-${widget.url.hashCode}-${DateTime.now().millisecondsSinceEpoch}";
    
    // Get current origin from window location
    final origin = Uri.base.origin;
    embedUrl = _convertToEmbedUrl(widget.url, origin);
    
    print('DEBUG VideoPlayer: Original URL: ${widget.url}');
    print('DEBUG VideoPlayer: Origin: $origin');
    print('DEBUG VideoPlayer: Embed URL: $embedUrl');
    print('DEBUG VideoPlayer: View ID: $viewId');

    platformViewRegistry.registerViewFactory(
      viewId,
      (int id) {
        final IFrameElement frame = IFrameElement()
          ..src = embedUrl
          ..style.border = "none"
          ..style.width = "100%"
          ..style.height = "100%"
          ..allowFullscreen = true;

        return frame;
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        child: HtmlElementView(
          viewType: viewId,
        ),
      ),
    );
  }
}
