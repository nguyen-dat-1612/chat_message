abstract class CallEvent {}

class CallStarted extends CallEvent {
  final String from;
  final String to;
  final String conversationId;
  final bool isCaller;

  CallStarted({
    required this.from,
    required this.to,
    required this.conversationId,
    required this.isCaller,
  });
}

class CallEnded extends CallEvent {}