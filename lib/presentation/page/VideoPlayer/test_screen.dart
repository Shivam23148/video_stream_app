import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:video_player/video_player.dart';

class TestScreen extends StatefulWidget {
  TestScreen({super.key, required this.url});
  final String url;
  @override
  State<TestScreen> createState() => _TestScreenState();
}

class _TestScreenState extends State<TestScreen> {
  VideoPlayerController? controller;
  bool isLandscape = false;
  void toggleOrientation() {
    setState(() {
      isLandscape = !isLandscape;
    });
    SystemChrome.setPreferredOrientations([
      isLandscape
          ? DeviceOrientation.landscapeLeft
          : DeviceOrientation.portraitUp, 
    ]);
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    controller = VideoPlayerController.networkUrl(Uri.parse(widget.url));
    controller?.initialize();
    controller?.play();
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    controller?.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FittedBox(
      fit: BoxFit.contain,
      child: SizedBox(
        width: MediaQuery.sizeOf(context).width,
        height: MediaQuery.sizeOf(context).height * 0.4,
        child: VideoPlayer(controller!),
      ),
    );
  }
}

extension on VideoPlayerController? {
  get controller => null;
}
