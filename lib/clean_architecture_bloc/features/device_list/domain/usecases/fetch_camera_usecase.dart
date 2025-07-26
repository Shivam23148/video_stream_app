import 'package:ntavideofeedapp/clean_architecture_bloc/features/device_list/domain/entities/camera_entity.dart';
import 'package:ntavideofeedapp/clean_architecture_bloc/features/device_list/domain/respositories/camera_repository.dart';
import 'package:ntavideofeedapp/clean_architecture_bloc/features/device_list/data/respository/camera_respository_impl.dart';

class FetchCameraUsecase {
  final CameraRepository repository;
  FetchCameraUsecase(this.repository);
  Future<List<CameraEntity>> call() {
    return repository.fetchCameras();
  }
}
