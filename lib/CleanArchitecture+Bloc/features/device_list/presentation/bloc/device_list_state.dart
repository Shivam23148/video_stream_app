part of 'device_list_bloc.dart';

abstract class DeviceListState {}

class DeviceListInitial extends DeviceListState {}

class DeviceListLoading extends DeviceListState {}

class DeviceListLoaded extends DeviceListState {
  final List<CameraEntity> cameras;

  DeviceListLoaded(this.cameras);
}

class DevicelistError extends DeviceListState {
  final String message;

  DevicelistError(this.message);
}
