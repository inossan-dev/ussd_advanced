/// Talks to an already opened multi-step USSD menu.
abstract interface class UssdSessionChannel {
  /// Opens a multi-session dialog for [code] on [subscriptionId].
  Future<String?> start({required String code, required int subscriptionId});

  /// Sends the next menu reply and returns the dialog text.
  Future<String?> send(String message);

  /// Closes the current dialog.
  Future<void> cancel();

  /// Text the platform pushes when the session ends on its own.
  Stream<String?> get onEnd;
}
