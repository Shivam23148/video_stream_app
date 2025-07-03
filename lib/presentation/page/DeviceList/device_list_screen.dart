import 'package:flutter/material.dart';

class DeviceListScreen extends StatefulWidget {
  const DeviceListScreen({super.key});

  @override
  State<DeviceListScreen> createState() => _DeviceListScreenState();
}

class _DeviceListScreenState extends State<DeviceListScreen> {
  final List<String> imageUrls = List.generate(
    10,
    (index) =>
        'https://cdn.pixabay.com/photo/2018/08/04/11/30/draw-3583548_1280.png',
  );
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Select Camera")),
      body: ListView.builder(
        itemCount: imageUrls.length,
        itemBuilder: (context, index) {
          final imageUrl = imageUrls[index];
          return ListTile(
            leading: Image.network(imageUrl),
            title: Text("Camera ${index + 1}"),
            onTap: () => Navigator.pop(context, "https://live.143b.ch/cam/flux/ts:abr.m3u8"), 
          );
        },
      ),
    );
  }
}
