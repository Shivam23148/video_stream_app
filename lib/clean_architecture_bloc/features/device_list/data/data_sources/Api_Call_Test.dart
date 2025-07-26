import 'package:ntavideofeedapp/clean_architecture_bloc/core/constants/app_constants.dart';
import 'package:ntavideofeedapp/clean_architecture_bloc/core/constants/url_constants.dart';
import 'package:ntavideofeedapp/clean_architecture_bloc/core/network/dio_client.dart';
import 'package:ntavideofeedapp/clean_architecture_bloc/features/device_list/data/models/group_model.dart';
import 'package:ntavideofeedapp/main.dart';

class ApiService {
  final DioClient dioClient;

  ApiService(this.dioClient);

  Future<List<CamerasModel>> fetchCameras() async {
    try {
      /* final response = await dio.get(
        'https://xvms.irishidev.com/api/group/',
        options: Options(
          headers: {
            'accept': 'application/json',
            'X-CSRFTOKEN':
                'eEwlWsq6mNBvZU5NGKVxwCPgpX6Rx0xD2YH6DdRZCF1f3efoVyPnem9atDYb5OhW',
          },
        ),
      ); */
      logger.i('Api call started');
      final response = await dioClient.get(
        '${AppConstants.baseUrl}${UrlConstants.groupUrl}',
        headers: {
          'accept': 'application/json',
          'X-CSRFTOKEN':
              'eEwlWsq6mNBvZU5NGKVxwCPgpX6Rx0xD2YH6DdRZCF1f3efoVyPnem9atDYb5OhW',
        },
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
