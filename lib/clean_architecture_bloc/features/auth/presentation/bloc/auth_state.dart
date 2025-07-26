part of 'auth_bloc.dart';

abstract class AuthState {}

class AuthInitial extends AuthState {}

class AuthLoading extends AuthState {}

class AuthAskEmailRequestState extends AuthState {}

class AuthShowVerification extends AuthState {
  final String userCode;
  final String verificationUrl;
  final String qrCodeUrl;

  AuthShowVerification(this.userCode, this.verificationUrl, this.qrCodeUrl);
}

class DeviceVerificationSendState extends AuthState {
}

class AuthSuccess extends AuthState {
  final String accessToken;

  AuthSuccess(this.accessToken);
}

class AuthFailure extends AuthState {
  final String emessage;

  AuthFailure(this.emessage);
}
