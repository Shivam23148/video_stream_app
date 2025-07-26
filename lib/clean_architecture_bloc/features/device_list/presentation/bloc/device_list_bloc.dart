import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ntavideofeedapp/clean_architecture_bloc/features/device_list/domain/entities/camera_entity.dart';
import 'package:ntavideofeedapp/clean_architecture_bloc/features/device_list/domain/usecases/fetch_camera_usecase.dart';
import 'package:ntavideofeedapp/main.dart';

part 'device_list_event.dart';
part 'device_list_state.dart';

class DeviceListBloc extends Bloc<DeviceListEvent, DeviceListState> {
  final FetchCameraUsecase fetchCameraUsecase ;
  DeviceListBloc(this.fetchCameraUsecase) : super(DeviceListInitial()) {
    on<FetchCameraEvent>((event, emit) async {
      emit(DeviceListLoading());
      try {
        final cameras = await fetchCameraUsecase();
        emit(DeviceListLoaded(cameras));
      } catch (e) {
        logger.e("Failed to fetch cameras : $e");
        emit(DevicelistError('Failed to fetch cameras: ${e.toString()}'));
      }
    });
  }
}
