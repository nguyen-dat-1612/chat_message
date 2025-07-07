
import 'package:equatable/equatable.dart';

abstract class ProfileEvent extends Equatable {
  const ProfileEvent();
}

class LogoutProfileEvent extends ProfileEvent {
  @override
  List<Object?> get props => [];
}

class FetchProfileEvent extends ProfileEvent {
  @override
  List<Object?> get props =>[];

}

class UpdateProfileEvent extends ProfileEvent {
  @override
  List<Object?> get props => [];
}

class DeleteProfileEvent extends ProfileEvent {
  @override
  List<Object?> get props => [];
}