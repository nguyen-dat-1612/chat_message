import 'package:equatable/equatable.dart';

abstract class ProfileState extends Equatable {
  const ProfileState();
}

class ProfileInitial extends ProfileState {

  ProfileInitial();

  @override
  List<Object> get props => [];
}

class ProfileLoading extends ProfileState {

  ProfileLoading();

  @override
  List<Object> get props => [];
}

class LogoutSuccess extends ProfileState {

  LogoutSuccess();

  @override
  List<Object?> get props => [];
}

class Error extends ProfileState {
  final String error;

  Error({required this.error});

  @override
  List<Object?> get props => [error];
}