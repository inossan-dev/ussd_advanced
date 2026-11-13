/// Root USSD code and the menu replies that follow it.
///
/// `*123*1*4#` becomes the root code `*123#` and the replies `1`, `4`.
final class UssdCode {
  const UssdCode({required this.code, this.messages = const <String>[]});

  /// Code sent to open the session, including its closing `#`.
  final String code;

  /// Replies sent, in order, after the root session is open.
  final List<String> messages;

  bool get hasFollowUp => messages.isNotEmpty;
}
