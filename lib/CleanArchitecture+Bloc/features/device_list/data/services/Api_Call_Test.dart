import 'package:dio/dio.dart';
import 'package:ntavideofeedapp/CleanArchitecture+Bloc/config/service_locator.dart';

import 'package:ntavideofeedapp/CleanArchitecture+Bloc/features/device_list/data/models/group_model.dart';
import 'package:ntavideofeedapp/main.dart';

class ApiService {
  final Dio dio = serviceLocator<Dio>();

  Future<List<CamerasModel>> fetchCameras() async {
    try {
      final response = await dio.get(
        'https://xvms.irishidev.com/api/group/',
        options: Options(
          headers: {
            'accept': 'application/json',
            'X-CSRFTOKEN':
                'eEwlWsq6mNBvZU5NGKVxwCPgpX6Rx0xD2YH6DdRZCF1f3efoVyPnem9atDYb5OhW',
          },
        ),
      );

      final data = response.data;
      logger.d("Response of camera is : $data");
      final payload = data['payload'] as List;
      List<CamerasModel> cameras = [];

      for (var group in payload) {
        final int groupId = group['id'];
        final cameraList = group['cameras'];
        if (cameraList != null) {
          for (var cam in cameraList) {
            cameras.add(CamerasModel.fromJson(cam, groupId));
          }
        }
      }

      return cameras;
    } catch (e) {
      logger.e('API Error: $e');
      return [];
    }
  }
}
