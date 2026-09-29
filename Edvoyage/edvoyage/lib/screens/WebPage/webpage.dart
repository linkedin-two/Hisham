import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

class GoogleScreenWidget extends StatefulWidget {
  final String url;
  final bool showAppBar;
  final String title;

  const GoogleScreenWidget({
    super.key,
    required this.url,
    this.showAppBar = true,
    this.title = 'Website Screen',
  });

  @override
  _GoogleScreenWidgetState createState() => _GoogleScreenWidgetState();
}

class _GoogleScreenWidgetState extends State<GoogleScreenWidget> {
  late final WebViewController _controller;

  @override
  void initState() {
    super.initState();
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..loadRequest(Uri.parse(widget.url)); // Automatically loads URL
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: widget.showAppBar ? AppBar(title: Text(widget.title)) : null,
      body: WebViewWidget(controller: _controller),
    );
  }
}
