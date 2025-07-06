import 'package:equatable/equatable.dart';
import '../../../data/models/conversation.dart';
import '../../../data/models/simple_user.dart';
import '../../../data/models/user_status.dart';

abstract class ConversationState extends Equatable {
  const ConversationState();
}

class ConversationInitial extends ConversationState {
  @override
  List<Object?> get props => [];
}

class ConversationLoading extends ConversationState {
  @override
  List<Object?> get props => [];
}

class ConversationSuccess extends ConversationState {
  final List<Conversation> conversations;

  const ConversationSuccess(this.conversations);

  @override
  List<Object?> get props => [conversations];
}

class ConversationFailure extends ConversationState {
  final String err;

  const ConversationFailure(this.err);

  @override
  List<Object?> get props => [err];
}