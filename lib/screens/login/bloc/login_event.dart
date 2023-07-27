import 'package:equatable/equatable.dart';

abstract class LoginEvent extends Equatable {
  const LoginEvent();
  @override
  List<Object> get props => [];
}

class LoadLastUser extends LoginEvent {}

class LoginWithPassword extends LoginEvent {
  final String username;
  final String password;

  const LoginWithPassword({required this.username, required this.password});

  @override
  List<Object> get props => [username, password];

  @override
  String toString() => 'LoginWithPassword: '
      'username: $username, password: *****';
}

class Dispose extends LoginEvent {}
