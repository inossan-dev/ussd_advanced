import 'ussd_code_parser.dart';
import 'ussd_session_channel.dart';

/// Runs a multi-session code: open the root menu, then send each reply.
final class UssdSessionCoordinator {
  const UssdSessionCoordinator({required this.channel, required this.parser});

  final UssdSessionChannel channel;
  final UssdCodeParser parser;

  Future<String?> run({
    required String code,
    required int subscriptionId,
  }) async {
    final parsed = parser.parse(code);
    final initial = await channel.start(
      code: parsed.code,
      subscriptionId: subscriptionId,
    );
    if (!parsed.hasFollowUp) return initial ?? '';

    // Each reply is already prefixed with a newline, which keeps the
    // historical text produced by sendMultipleMessages.
    final followUp = await sendAll(parsed.messages);
    return '${initial ?? ''}\n$followUp';
  }

  Future<String> sendAll(List<String> messages) async {
    final buffer = StringBuffer();
    for (final message in messages) {
      final reply = await channel.send(message);
      buffer
        ..write('\n')
        ..write(reply);
    }
    return buffer.toString();
  }
}
