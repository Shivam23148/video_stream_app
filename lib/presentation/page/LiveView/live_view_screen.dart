import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_vlc_player/flutter_vlc_player.dart';
import 'package:ntavideofeedapp/CleanArchitecture+Bloc/core/router/route_names.dart';
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
      appBar: AppBar(backgroundColor: Colors.white, title: Text("Live View")),
      backgroundColor: Colors.white,
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
                print("Url is ${url}");
                return GestureDetector(
                  onLongPress: (url == null || url.isEmpty)
                      ? null
                      : () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  /*     LiveStreamFullScreen(url: url), */
                                  LiveVideoTesting(url: url),
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
    controller.addListener(() {
      if (controller.value.hasError) {
        print('Video Error: ${controller.value.errorDescription}');
      }
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
        : Center(child: CircularProgressIndicator(color: Colors.blue));
  }
}

class LiveStreamFullScreen extends StatefulWidget {
  final String url;

  const LiveStreamFullScreen({super.key, required this.url});
  @override
  State<LiveStreamFullScreen> createState() => _LiveStreamFullScreenState();
}

class _LiveStreamFullScreenState extends State<LiveStreamFullScreen> {
  late VlcPlayerController vlcPlayerController;
  bool isMuted = false;

  @override
  void initState() {
    super.initState();
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
    vlcPlayerController = VlcPlayerController.network(
      widget.url,
      hwAcc: HwAcc.full,
      autoPlay: true,
      options: VlcPlayerOptions(),
    );
  }

  @override
  void dispose() {
    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    vlcPlayerController.stop();
    vlcPlayerController.dispose();

    super.dispose();
  }

  void toggleMute() {
    if (isMuted) {
      vlcPlayerController.setVolume(100);
    } else {
      vlcPlayerController.setVolume(0);
    }
    setState(() {
      isMuted = !isMuted;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        VlcPlayer(
          controller: vlcPlayerController,
          aspectRatio: 16 / 9,
          placeholder: const Center(child: CircularProgressIndicator()),
        ),
        Positioned(
          top: 20,
          right: 20,
          child: IconButton(
            icon: Icon(
              isMuted ? Icons.volume_off : Icons.volume_up,
              color: Colors.white,
              size: 30,
            ),
            onPressed: toggleMute,
          ),
        ),
        Positioned(
          top: 20,
          left: 20,
          child: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white, size: 30),
            onPressed: () => Navigator.pop(context),
          ),
        ),
      ],
    );
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

class LiveVideoTesting extends StatefulWidget {
  final String url;

  const LiveVideoTesting({super.key, required this.url});
  State<LiveVideoTesting> createState() => _LiveVideoTestingState();
}

class _LiveVideoTestingState extends State<LiveVideoTesting> {
  late VlcPlayerController vlcPlayerController;
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    vlcPlayerController = VlcPlayerController.network(
      widget.url,
      hwAcc: HwAcc.full,
      autoPlay: true,
      options: VlcPlayerOptions(),
    );
  }

  @override
  void dispose() {
    // TODO: implement dispose
    vlcPlayerController.stop();
    vlcPlayerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return VlcPlayer(
      controller: vlcPlayerController,
      aspectRatio: 16 / 9,
      placeholder: Center(child: CircularProgressIndicator(color: Colors.blue)),
    );
  }
}
