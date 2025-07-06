abstract class CallState {}

class CallInitial extends CallState {}
class CallInProgress extends CallState {
  final String conversationId;
  final String partner;
  final bool isCaller;

  CallInProgress({required this.conversationId, required this.partner, required this.isCaller});
}
class CallFinished extends CallState {}
