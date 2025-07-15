import 'package:ntavideofeedapp/CleanArchitecture+Bloc/features/device_list/domain/entities/camera_entity.dart';
import 'package:ntavideofeedapp/CleanArchitecture+Bloc/features/device_list/domain/respositories/camera_repository.dart';
import 'package:ntavideofeedapp/CleanArchitecture+Bloc/features/device_list/domain/respositories/camera_respository_impl.dart';

class FetchCameraUsecase {
  final CameraRepository repository = CameraRespositoryImpl();
  FetchCameraUsecase();
  Future<List<CameraEntity>> call() {
    return repository.fetchCameras();
  }
}
