import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../data/models/simple_user.dart';
import '../../../services/WebSocketService.dart';
import 'contact_event.dart';
import 'contact_state.dart';

class ContactBloc extends Bloc<ContactEvent, ContactState> {
  List<SimpleUser> _contacts = [];

  ContactBloc({required WebSocketService socket}) : super(ContactInitial()) {
    on<SetInitialContacts>((event, emit) {
      // Nếu đã có _contacts (tức là đã từng load), thì merge trạng thái online
      if (_contacts.isNotEmpty) {
        for (var i = 0; i < event.contacts.length; i++) {
          final index = _contacts.indexWhere((c) => c.username == event.contacts[i].username);
          if (index != -1) {
            // Giữ status từ dữ liệu cũ
            event.contacts[i] = event.contacts[i].copyWith(status: _contacts[index].status);
          }
        }
      }

      _contacts = List.from(event.contacts);
      emit(ContactLoaded(_contacts));
    });

    on<UpdateStatuses>((event, emit) {
      for (var updated in event.updatedUsers) {
        final index = _contacts.indexWhere((u) => u.username == updated.username);
        if (index != -1) {
          _contacts[index] = _contacts[index].copyWith(status: updated.status);
        }
      }
      emit(ContactLoaded(List.from(_contacts)));
    });

    // Lắng nghe WebSocket
    socket.onPresence = (users) {
      final updated = users.map((u) => SimpleUser(
        id: '',
        username: u.username,
        displayName: u.username,
        avatarUrl: '',
        status: u.status,
        lastSeen: DateTime.now(),
      )).toList();

      add(UpdateStatuses(updated));
    };
  }
}
