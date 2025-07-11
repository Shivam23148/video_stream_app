import 'dart:convert';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:dio/io.dart';
import 'package:http/http.dart' as http;

/* Dio createDio() {
  final dio = Dio();

  (dio.httpClientAdapter as DefaultHttpClientAdapter).onHttpClientCreate =
      (HttpClient client) {
        client.badCertificateCallback =
            (X509Certificate cert, String host, int port) => true;
        return client;
      };

  return dio;
}

Future<void> fetchGroupData() async {
  /* final url = Uri.parse("https://xvms.irishidev.com/api/group/");
  final headers = {
    'accept': 'application/json',
    'X-CSRFTOKEN':
        'FSZhIdFXSdVPsR72rEYP7GHLdla7739yWqt0AyrZmHmjJn3zDGe0Ek8DdhJ1XCHz',
  };

  try {
    print("Api is getting called");
    final response = await http.get(url, headers: headers);
    print("Response code is ${response.statusCode}");
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      print("Response of the url(API) is :${data}");
    } else {
      print("Error is : ${response.statusCode}");
      print("Body : ${response.body}");
    }
  } catch (e) {
    print("API Error is : ${e}");
  } */
  final dio = createDio();
  try {
    final response = await dio.get(
      'https://103.159.169.170:8443/api/group/',
      options: Options(
        headers: {
          'accept': 'application/json',
          'X-CSRFTOKEN':
              'R1UL0KybFJwPfJTmr9yIGtg3gePR7l5kWneOMqh3Mb7RpfyTzf2FgAt30Y8eSTeu',
        },
      ),
    );

    print('✅ Response: ${response.data}');
  } catch (e) {
    print('❌ Dio Error: $e');
  }
} */

import 'package:ntavideofeedapp/model/CameraGroup/group_model.dart';

class ApiService {
  final Dio dio = Dio();

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
      print("Response of camera is : ${data}");
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
      print('API Error: $e');
      return [];
    }
  }
}
