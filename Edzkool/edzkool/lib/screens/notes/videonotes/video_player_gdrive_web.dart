import 'dart:html' show IFrameElement;
import 'dart:ui_web';
import 'package:flutter/material.dart';

class GDPreviewPlayer extends StatefulWidget {
  final String url;
  const GDPreviewPlayer({super.key, required this.url});

  @override
  State<GDPreviewPlayer> createState() => _GDPreviewPlayerState();
}

class _GDPreviewPlayerState extends State<GDPreviewPlayer> {
  final String viewId = "drive-preview-iframe";

  @override
  void initState() {
    super.initState();

    platformViewRegistry.registerViewFactory(
      viewId,
      (int id) {
        final IFrameElement frame = IFrameElement()
          ..src = widget.url
          ..style.border = "none"
          ..allowFullscreen = true;

        return frame;
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: HtmlElementView(
        viewType: viewId,
      ),
    );
  }
}
