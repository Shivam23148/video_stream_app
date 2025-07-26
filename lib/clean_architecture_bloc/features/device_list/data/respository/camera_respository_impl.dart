import 'package:ntavideofeedapp/clean_architecture_bloc/config/service_locator.dart';
import 'package:ntavideofeedapp/clean_architecture_bloc/features/device_list/data/data_sources/Api_Call_Test.dart';
import 'package:ntavideofeedapp/clean_architecture_bloc/features/device_list/domain/entities/camera_entity.dart';
import 'package:ntavideofeedapp/clean_architecture_bloc/features/device_list/domain/respositories/camera_repository.dart';

class CameraRespositoryImpl implements CameraRepository {
  final ApiService apiService;

  CameraRespositoryImpl( this.apiService);

  @override
  Future<List<CameraEntity>> fetchCameras() async {
    final cameraModels = await apiService.fetchCameras();
    return cameraModels
        .map(
          (item) => CameraEntity(
            item.groupId,
            item.cameraId,
            item.cameraName,
            item.location,
            item.area,
            item.city,
          ),
        )
        .toList();
  }
}
