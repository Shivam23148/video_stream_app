import 'dart:async';

import 'package:chewie/chewie.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:ntavideofeedapp/routes/route_names.dart';
import 'package:video_player/video_player.dart';

class LiveViewScreen extends StatefulWidget {
  const LiveViewScreen({super.key});

  @override
  State<LiveViewScreen> createState() => _LiveViewScreenState();
}

class _LiveViewScreenState extends State<LiveViewScreen> {
  List<String> gridNumberList = ['1X1', '2X2', '3X3', '4X4'];
  String dropdownValue = '2X2';
  Map<int, String> selectedStream = {};
  @override
  Widget build(BuildContext context) {
    int crossAxisCount = int.tryParse(dropdownValue.split('X').first) ?? 2;
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: Text("Multi View"),
        centerTitle: true,
        automaticallyImplyLeading: false,
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            child: GridView.builder(
              itemCount: crossAxisCount * crossAxisCount,
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: crossAxisCount,
              ),
              itemBuilder: (context, index) {
                final url = selectedStream[index];
                return GestureDetector(
                  onLongPress: (url == null || url.isEmpty)
                      ? null
                      : () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  LiveStreamFullScreen(url: url!),
                            ),
                          );
                        },
                  onTap: () async {
                    final result = await Navigator.pushNamed<String>(
                      context,
                      Routes.deviceListRoute,
                    );
                    if (result != null) {
                      setState(() {
                        selectedStream[index] = result;
                      });
                    }
                  },
                  child: Container(
                    color: Colors.black,
                    child: url != null
                        ? LiveVideoTile(url: url)
                        : Center(
                            child: CircleAvatar(
                              backgroundColor: Colors.grey,
                              child: Icon(Icons.add),
                            ),
                          ),
                  ),
                );
              },
            ),
          ),
          ElevatedButton.icon(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => FullScreenGridViewScreen(
                    selectedStreams: selectedStream,
                    gridSize: dropdownValue,
                  ),
                ),
              );
            },
            icon: Icon(Icons.fullscreen),
            label: Text("Fullscreen View"),
          ),
          DropdownButton(
            dropdownColor: Colors.white,
            value: dropdownValue,
            items: gridNumberList.map<DropdownMenuItem<String>>((String value) {
              return DropdownMenuItem<String>(value: value, child: Text(value));
            }).toList(),
            onChanged: (String? value) {
              setState(() {
                dropdownValue = value!;
              });
            },
          ),
        ],
      ),
    );
  }
}

class LiveVideoTile extends StatefulWidget {
  final String url;

  const LiveVideoTile({super.key, required this.url});
  @override
  State<LiveVideoTile> createState() => _LiveVideoTileState();
}

class _LiveVideoTileState extends State<LiveVideoTile> {
  late VideoPlayerController controller;
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    controller = VideoPlayerController.networkUrl(Uri.parse(widget.url))
      ..initialize().then((_) {
        setState(() {
          controller.play();
        });
      });
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    controller.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return controller.value.isInitialized
        ? AspectRatio(
            aspectRatio: controller.value.aspectRatio,
            child: VideoPlayer(controller),
          )
        : Center(child: CircularProgressIndicator());
  }
}

class LiveStreamFullScreen extends StatefulWidget {
  final String url;

  const LiveStreamFullScreen({super.key, required this.url});
  @override
  State<LiveStreamFullScreen> createState() => _LiveStreamFullScreenState();
}

class _LiveStreamFullScreenState extends State<LiveStreamFullScreen> {
  late VideoPlayerController videoPlayerController;
  late ChewieController chewieController;
  late DateTime startStreamTime;

  int currentSeekValue = 0;
  bool userIsDragging = false;
  Timer? sliderTimer;

  @override
  void initState() {
    super.initState();
    SystemChrome.setPreferredOrientations([DeviceOrientation.landscapeLeft]);

    startStreamTime = DateTime.now();

    videoPlayerController = VideoPlayerController.networkUrl(
      Uri.parse(widget.url),
    );
    videoPlayerController.initialize().then((_) {
      // Setup ChewieController
      chewieController = ChewieController(
        videoPlayerController: videoPlayerController,
        autoPlay: true,
        looping: false,
        allowMuting: false,
        allowPlaybackSpeedChanging: false,
        showControls: true, // we'll build our own controls
      );

      setState(() {
        startStreamTime = DateTime.now();
      });

      sliderTimer = Timer.periodic(Duration(seconds: 1), (_) {
        final livePos = DateTime.now()
            .difference(startStreamTime)
            .inMilliseconds;

        if (!userIsDragging && currentSeekValue < livePos) {
          setState(() {
            currentSeekValue = livePos;
            print(
              "Timer updated currentSeekValue to livePos: $currentSeekValue",
            );
          });
        }
      });
    });
  }

  @override
  void dispose() {
    sliderTimer?.cancel();
    chewieController.dispose();
    videoPlayerController.dispose();
    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
    super.dispose();
  }

  String formatDuration(Duration d) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    return "${twoDigits(d.inMinutes)}:${twoDigits(d.inSeconds % 60)}";
  }

  @override
  Widget build(BuildContext context) {
    return videoPlayerController.value.isInitialized
        ? Stack(
            children: [
              AspectRatio(
                aspectRatio: videoPlayerController.value.aspectRatio,
                child: Chewie(controller: chewieController),
              ),
              Positioned(
                bottom: 30,
                left: 20,
                right: 20,
                child: Builder(
                  builder: (context) {
                    final livePosition = DateTime.now().difference(
                      startStreamTime,
                    );
                    final livePosMs = livePosition.inMilliseconds;

                    final seekMin = (livePosMs - 30000).clamp(0, livePosMs);
                    final seekMax = livePosMs;

                    final sliderValue = currentSeekValue
                        .clamp(seekMin, seekMax)
                        .toDouble();

                    return Material(
                      color: Colors.black54,
                      borderRadius: BorderRadius.circular(8),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Slider(
                            min: seekMin.toDouble(),
                            max: seekMax.toDouble(),
                            value: sliderValue,
                            onChangeStart: (value) {
                              userIsDragging = true;
                              print("User started dragging at $value");
                            },
                            onChanged: (newValue) {
                              setState(() {
                                currentSeekValue = newValue.toInt();
                              });
                              videoPlayerController
                                  .seekTo(
                                    Duration(milliseconds: currentSeekValue),
                                  )
                                  .then((_) => videoPlayerController.play());
                              print("User dragging at $newValue");
                            },
                            onChangeEnd: (value) {
                              userIsDragging = false;
                              final livePos = DateTime.now()
                                  .difference(startStreamTime)
                                  .inMilliseconds;

                              if ((livePos - value) < 2000) {
                                setState(() {
                                  currentSeekValue = livePos;
                                });
                              }
                              print("User stopped dragging at $value");
                            },
                            activeColor: Colors.red,
                            inactiveColor: Colors.white24,
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12.0,
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  formatDuration(
                                    Duration(milliseconds: currentSeekValue),
                                  ),
                                  style: TextStyle(color: Colors.white),
                                ),
                                TextButton(
                                  onPressed: () {
                                    final livePos = DateTime.now().difference(
                                      startStreamTime,
                                    );
                                    setState(() {
                                      currentSeekValue = livePos.inMilliseconds;
                                    });
                                    videoPlayerController.seekTo(livePos).then((
                                      _,
                                    ) {
                                      videoPlayerController.play();
                                    });
                                  },
                                  child: Text(
                                    "LIVE",
                                    style: TextStyle(
                                      color: (sliderValue >= seekMax - 2000)
                                          ? Colors.red
                                          : Colors.white,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ],
          )
        : Center(child: CircularProgressIndicator());
  }
}

class FullScreenGridViewScreen extends StatefulWidget {
  final Map<int, String> selectedStreams;
  final String gridSize;

  const FullScreenGridViewScreen({
    super.key,
    required this.selectedStreams,
    required this.gridSize,
  });

  @override
  State<FullScreenGridViewScreen> createState() =>
      _FullScreenGridViewScreenState();
}

class _FullScreenGridViewScreenState extends State<FullScreenGridViewScreen> {
  List<String> gridNumberList = ['1X1', '2X2', '3X3', '4X4'];
  late String dropdownValue;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    dropdownValue = widget.gridSize;

    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
  }

  @override
  void dispose() {
    // TODO: implement dispose
    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    int crossAxisCount = int.tryParse(dropdownValue.split('X').first) ?? 2;
    int totalItems = crossAxisCount * crossAxisCount;
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    final tileWidth = screenWidth / crossAxisCount;
    final tileHeight = screenHeight / crossAxisCount;
    print("Total items : ${totalItems}");
    // TODO: implement build
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          SizedBox.expand(
            child: GridView.count(
              physics: NeverScrollableScrollPhysics(),
              crossAxisCount: crossAxisCount,
              childAspectRatio: tileWidth / tileHeight,
              children: List.generate(totalItems, (index) {
                final url = widget.selectedStreams[index];
                return GestureDetector(
                  onTap: () async {
                    final result = await Navigator.pushNamed<String>(
                      context,
                      Routes.deviceListRoute,
                    );
                    if (result != null) {
                      setState(() {
                        widget.selectedStreams[index] = result;
                      });
                    }
                  },
                  child: Container(
                    margin: const EdgeInsets.all(1),
                    color: Colors.black,
                    child: url != null
                        ? LiveVideoTile(url: url)
                        : Center(
                            child: CircleAvatar(
                              backgroundColor: Colors.grey,
                              child: Icon(Icons.add, color: Colors.white),
                            ),
                          ),
                  ),
                );
              }),
            ),
          ),
          DropdownButton<String>(
            dropdownColor: Colors.black,
            value: dropdownValue,
            style: TextStyle(color: Colors.white),
            iconEnabledColor: Colors.white,
            items: gridNumberList.map((String value) {
              return DropdownMenuItem<String>(value: value, child: Text(value));
            }).toList(),
            onChanged: (value) {
              setState(() {
                dropdownValue = value!;
              });
            },
          ),
        ],
      ),
    );
  }
}
