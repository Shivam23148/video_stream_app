import 'package:ntavideofeedapp/CleanArchitecture+Bloc/config/service_locator.dart';
import 'package:ntavideofeedapp/CleanArchitecture+Bloc/features/device_list/data/models/group_model.dart';
import 'package:ntavideofeedapp/CleanArchitecture+Bloc/features/device_list/data/services/Api_Call_Test.dart';
import 'package:ntavideofeedapp/CleanArchitecture+Bloc/features/device_list/domain/entities/camera_entity.dart';
import 'package:ntavideofeedapp/CleanArchitecture+Bloc/features/device_list/domain/respositories/camera_repository.dart';

class CameraRespositoryImpl extends CameraRepository {
  final ApiService apiService = serviceLocator<ApiService>();

  @override
  Future<List<CameraEntity>> fetchCameras() async {
    final cameraModels = await apiService.fetchCameras();
    return cameraModels
        .map(
          (item) => CameraEntity(item.cameraId, item.cameraName, item.groupId),
        )
        .toList();
  }
}
