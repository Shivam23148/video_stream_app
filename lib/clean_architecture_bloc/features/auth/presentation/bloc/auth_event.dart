part of 'auth_bloc.dart';

abstract class AuthEvent {}

class LoginStartedEvent extends AuthEvent {}

class EmailRequestEvent extends AuthEvent {
  final String userEmail;

  EmailRequestEvent(this.userEmail);
}

class StartLoginRequested extends AuthEvent {}
