import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';

class WebViewScreen extends StatefulWidget {
  final String url;

  const WebViewScreen({super.key, required this.url});

  @override
  State<WebViewScreen> createState() => _WebViewScreenState();
}

class _WebViewScreenState extends State<WebViewScreen> {
  @override
  void initState() {
    super.initState();
  }

  InAppWebViewController? controller;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("WebView")),
      body: InAppWebView(
        initialUrlRequest: URLRequest(
            url: WebUri("https://www.youtube.com/embed/7_wkWQ9rB5I")),
        onWebViewCreated: (c) => controller = c,
      ),
    );
  }
}
