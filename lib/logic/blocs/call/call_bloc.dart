import 'package:flutter_bloc/flutter_bloc.dart';

import 'call_event.dart';
import 'call_state.dart';

class CallBloc extends Bloc<CallEvent, CallState> {
  CallBloc() : super(CallInitial()) {
    on<CallStarted>((event, emit) {
      emit(CallInProgress(
        conversationId: event.conversationId,
        partner: event.to,
        isCaller: event.isCaller,
      ));
    });

    on<CallEnded>((event, emit) {
      emit(CallFinished());
      emit(CallInitial());
    });
  }
}