// ignore_for_file: prefer_const_constructors

import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

class MoviePlayer extends StatefulWidget {
  final String streamingLink;
  const MoviePlayer({required this.streamingLink});

  @override
  _MoviePlayerState createState() => _MoviePlayerState(streamingLink);
}

class _MoviePlayerState extends State<MoviePlayer> {
  late WebViewController webviewController;
  final String link;
  _MoviePlayerState(this.link);

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: WebView(
          javascriptMode: JavascriptMode.unrestricted,
          initialUrl: "https://webtor.io/#/magnet-to-torrent",
          onWebViewCreated: (controller) {
            webviewController = controller;
          },
          onPageStarted: (url) {},
        ),
      ),
    );
  }
}
