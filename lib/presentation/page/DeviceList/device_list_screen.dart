import 'package:flutter/material.dart';
import 'package:ntavideofeedapp/model/CameraGroup/group_model.dart';
import 'package:ntavideofeedapp/presentation/page/Example/Api_Call_Test.dart';

class DeviceListScreen extends StatefulWidget {
  const DeviceListScreen({super.key});

  @override
  State<DeviceListScreen> createState() => _DeviceListScreenState();
}

class _DeviceListScreenState extends State<DeviceListScreen> {
  List<CamerasModel> cameras = [];
  final ApiService apiService = ApiService();
  bool isLoading = true;
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    print("Device list init");
    loadCameras();
  }

  void loadCameras() async {
    final result = await apiService.fetchCameras();
    print("Api result is : ${result.first.location}");
    setState(() {
      cameras = result;
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: Text("Select Camera"),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
              itemCount: cameras.length,
              itemBuilder: (context, index) {
                final cam = cameras[index];
                return ListTile(
                  leading: Text((index + 1).toString()),
                  title: Text(cam.location),
                  subtitle: Text(cam.area),
                  trailing: Text("Camera Name: ${cam.cameraName}"),
                  onTap: () {
                    print("Camera name");
                    /* Navigator.pop(
                      context,
                      "https://103.159.169.170:8443/go2rtc/8/api/stream.m3u8?src=agrawaldistilleriesbottlingroom&mp4=flac",
                    ); */
                    // HTTPS
                    Navigator.pop(
                      context,
                      "https://xvms.irishidev.com/api/go2rtc/${cam.groupId}/api/stream.m3u8?src=${cam.cameraName}&mp4",
                    );
                  },
                );
              },
            ),
    );
  }
}
