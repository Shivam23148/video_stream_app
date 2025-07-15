import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ntavideofeedapp/CleanArchitecture+Bloc/config/service_locator.dart';
import 'package:ntavideofeedapp/CleanArchitecture+Bloc/features/device_list/presentation/bloc/device_list_bloc.dart';
import 'package:ntavideofeedapp/main.dart';

class DeviceListScreen extends StatefulWidget {
  const DeviceListScreen({super.key});

  @override
  State<DeviceListScreen> createState() => _DeviceListScreenState();
}

class _DeviceListScreenState extends State<DeviceListScreen> {
  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) =>
          serviceLocator<DeviceListBloc>()..add(FetchCameraEvent()),
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: Colors.white,
          title: Text("Select Camera"),
        ),
        body: BlocBuilder<DeviceListBloc, DeviceListState>(
          builder: (context, state) {
            if (state is DeviceListLoading) {
              return const Center(child: CircularProgressIndicator());
            } else if (state is DeviceListLoaded) {
              final cameras = state.cameras;
              return ListView.builder(
                itemCount: cameras.length,
                itemBuilder: (context, index) {
                  final cam = cameras[index];
                  return ListTile(
                    leading: Text((index + 1).toString()),
                    title: Text(cam.area),
                    subtitle: Text(cam.location),
                    trailing: Text("Camera Name: ${cam.cameraName}"),
                    onTap: () {
                      logger.d("Tapped on camera: ${cam.location}");
                      Navigator.pop(
                        context,
                        "https://xvms.irishidev.com/api/go2rtc/${cam.groupId}/api/stream.m3u8?src=${cam.cameraName}&mp4",
                      );
                    },
                  );
                },
              );
            } else if (state is DevicelistError) {
              return Center(child: Text(state.message));
            } else {
              return const Center(child: Text("Please wait..."));
            }
          },
        ),
      ),
    );
  }
}
