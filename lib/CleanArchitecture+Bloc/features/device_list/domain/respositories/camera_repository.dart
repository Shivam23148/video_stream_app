import 'package:ntavideofeedapp/CleanArchitecture+Bloc/features/device_list/data/models/group_model.dart';
import 'package:ntavideofeedapp/CleanArchitecture+Bloc/features/device_list/domain/entities/camera_entity.dart';

abstract class CameraRepository {
  Future<List<CameraEntity>> fetchCameras();
}
