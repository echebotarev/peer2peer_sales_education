import 'package:equatable/equatable.dart';

abstract class LoginState extends Equatable {
  const LoginState();

  @override
  List<Object?> get props => [];
}

class LoginInitial extends LoginState {}

class LoginLastUserLoaded extends LoginState {
  final String lastUser;
  const LoginLastUserLoaded({required this.lastUser});

  @override
  List<Object> get props => [lastUser];

  @override
  String toString() => 'LoginLastUserLoaded: user: $lastUser';
}

class LoginInProgress extends LoginState {}

class LoginSuccess extends LoginState {}

class LoginFailure extends LoginState {
  final String errorCode;
  final String? errorDescription;

  const LoginFailure({required this.errorCode, required this.errorDescription});

  @override
  List<Object?> get props => [errorCode, errorDescription];

  @override
  String toString() =>
      'LoginStateFailure: errorCode: $errorCode, errorDescription: $errorDescription';
}
