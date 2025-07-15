import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';
import 'package:ntavideofeedapp/CleanArchitecture+Bloc/features/device_list/domain/entities/camera_entity.dart';
import 'package:ntavideofeedapp/CleanArchitecture+Bloc/features/device_list/domain/usecases/fetch_camera_usecase.dart';

part 'device_list_event.dart';
part 'device_list_state.dart';

class DeviceListBloc extends Bloc<DeviceListEvent, DeviceListState> {
  final FetchCameraUsecase fetchCameraUsecase = FetchCameraUsecase();
  DeviceListBloc() : super(DeviceListInitial()) {
    on<FetchCameraEvent>((event, emit) async {
      emit(DeviceListLoading());
      try {
        final cameras = await fetchCameraUsecase();
        emit(DeviceListLoaded(cameras));
      } catch (e) {
        emit(DevicelistError('Failed to fetch cameras: ${e.toString()}'));
      }
    });
  }
}
