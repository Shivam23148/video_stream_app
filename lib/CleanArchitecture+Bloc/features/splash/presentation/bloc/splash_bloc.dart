import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ntavideofeedapp/CleanArchitecture+Bloc/core/service/auth_service.dart';
import 'package:ntavideofeedapp/main.dart';

part 'splash_event.dart';
part 'splash_state.dart';

class SplashBloc extends Bloc<SplashEvent, SplashState> {
  final DeviceFlowAuthService authService;
  SplashBloc(this.authService) : super(SplashInitial()) {
    on<CheckAuthStatusSplash>((event, emit) async {
      emit(SplashLoading());
      final token = await authService.getValidAccessToken();
      if (token != null) {
        logger.d("Inside token of splash bloc: ${token}");
        await authService.getRole();
        emit(SplashAuthenticated());
      } else {
        emit(SplashUnauthenticated());
      }
    });
  }
}
