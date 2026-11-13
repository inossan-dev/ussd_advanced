/// Places a USSD request and, on a single-session call, returns the reply.
abstract interface class UssdDialer {
  /// Dials [code] on [subscriptionId] without waiting for the network reply.
  ///
  /// `-1` selects the system default subscription.
  Future<void> sendUssd({required String code, required int subscriptionId});

  /// Dials [code] and waits for the single-session reply.
  Future<String?> sendAdvancedUssd({
    required String code,
    required int subscriptionId,
  });
}
