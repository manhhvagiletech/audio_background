enum FirebaseMessageType {
  test,
}

extension FirebaseMessageTypeExt on FirebaseMessageType {
  static FirebaseMessageType? fromString(String? v) {
    switch (v?.toString()) {
      case "TEST":
        return FirebaseMessageType.test;

      default:
        return null;
    }
  }
}
