import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ntavideofeedapp/CleanArchitecture+Bloc/core/service/auth_service.dart';

part 'auth_event.dart';
part 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final DeviceFlowAuthService authService;
  AuthBloc(this.authService) : super(AuthInitial()) {
    on<LoginStartedEvent>((event, emit) {
      emit(AuthAskEmailRequestState());
    });
    on<EmailRequestEvent>((event, emit) async {
      emit(AuthLoading());
      try {
        final deviceData = await authService.requestDeviceCode();
        print("Device Data inside the auth bloc : ${deviceData}");
        await authService.sendVerificationUrl(
          deviceCode: deviceData['user_code'],
          verificationUrl: deviceData['verification_uri'],
          email: event.userEmail,
        );
        emit(DeviceVerificationSendState());
        final tokenData = await authService.pollForToken(
          deviceData['device_code'],
          deviceData['interval'] ?? 5,
        );
        emit(AuthSuccess(tokenData['access_token']));
      } catch (e) {
        print("Auth bloc email request error: ${e}");
        emit(AuthFailure(e.toString()));
      }
    });
  }
}
