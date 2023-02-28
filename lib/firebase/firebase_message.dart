import 'firebase_message_type.dart';

class FirebaseMessage {
  final String? title;
  final String? body;
  final FirebaseMessageType? type;
  final Map<String, dynamic> data;

  const FirebaseMessage({
    this.title,
    this.body,
    this.type,
    this.data = const {},
  });
}
