import 'dart:async';

import 'package:flutter/foundation.dart';

import 'ussd_advanced_platform_interface.dart';
import 'ussd_code_parser.dart';
import 'ussd_dialer.dart';
import 'ussd_permissions.dart';
import 'ussd_session_channel.dart';
import 'ussd_session_coordinator.dart';

/// Runs USSD codes from a Flutter application.
///
/// [sendUssd] dials a code and does not return the network reply.
/// [sendAdvancedUssd] waits for one reply. On Android 8 and later the reply
/// comes from `TelephonyManager`; older Android versions and iOS fall back
/// to opening the dialer.
/// [multisessionUssd] drives a menu. `*123*1*4#` dials `*123#`, then sends
/// `1` and `4`. Further replies go through [sendMessage], and [cancelSession]
/// closes the dialog.
///
/// The static methods are the composition root. Replace [dialer], [session],
/// [permissions], or [parser] to extend a single step without changing the
/// others. When an override is null, the call uses [UssdAdvancedPlatform.instance].
abstract final class UssdAdvanced {
  /// Dialer used by [sendUssd] and [sendAdvancedUssd].
  static UssdDialer? dialer;

  /// Session channel used by multi-session calls.
  static UssdSessionChannel? session;

  /// Permission gateway used by [hasPermissions] and [requestPermissions].
  static UssdPermissions? permissions;

  /// Splits a multi-session code into a root code and menu replies.
  static UssdCodeParser parser = const UssdCodeParser();

  /// How long [sendAdvancedUssd] waits for a reply.
  static Duration advancedTimeout = const Duration(seconds: 30);

  /// Dials [code] on [subscriptionId] without waiting for a reply.
  ///
  /// [subscriptionId] `-1` selects the system default SIM. Android 6 and
  /// later honor it; older versions use the default SIM.
  static Future<void> sendUssd({required String code, int subscriptionId = 1}) {
    _requireRequest(code: code, subscriptionId: subscriptionId);
    return _dialer.sendUssd(code: code, subscriptionId: subscriptionId);
  }

  /// Dials [code] and returns the single-session reply.
  ///
  /// Throws [TimeoutException] when the reply takes longer than [advancedTimeout].
  static Future<String?> sendAdvancedUssd({
    required String code,
    int subscriptionId = 1,
  }) {
    _requireRequest(code: code, subscriptionId: subscriptionId);
    return _dialer
        .sendAdvancedUssd(code: code, subscriptionId: subscriptionId)
        .timeout(advancedTimeout);
  }

  /// Opens a multi-session menu and sends the replies embedded in [code].
  static Future<String?> multisessionUssd({
    required String code,
    int subscriptionId = 1,
  }) {
    _requireRequest(code: code, subscriptionId: subscriptionId);
    return _coordinator.run(code: code, subscriptionId: subscriptionId);
  }

  /// Closes the current multi-session dialog.
  static Future<void> cancelSession() => _session.cancel();

  /// Sends one menu reply and returns the next dialog text.
  static Future<String?> sendMessage(String message) => _session.send(message);

  /// Sends [messages] in order.
  ///
  /// The returned text starts with a newline, then each reply separated by
  /// a newline. A missing reply is written as the text `null`.
  static Future<String?> sendMultipleMessages(List<String> messages) {
    return _coordinator.sendAll(messages);
  }

  /// Emits the text pushed by the platform when a session ends on its own.
  ///
  /// Repeated calls share the same stream.
  static Stream<String?> onEnd() => _session.onEnd;

  /// Whether phone and accessibility access are granted.
  static Future<bool> hasPermissions() => _permissions.hasPermissions();

  /// Requests phone permissions and opens accessibility settings if needed.
  static Future<void> requestPermissions() => _permissions.requestPermissions();

  /// Clears dependency overrides. Does not replace the platform instance.
  @visibleForTesting
  static void reset() {
    dialer = null;
    session = null;
    permissions = null;
    parser = const UssdCodeParser();
    advancedTimeout = const Duration(seconds: 30);
  }

  static UssdDialer get _dialer => dialer ?? UssdAdvancedPlatform.instance;

  static UssdSessionChannel get _session =>
      session ?? UssdAdvancedPlatform.instance;

  static UssdPermissions get _permissions =>
      permissions ?? UssdAdvancedPlatform.instance;

  static UssdSessionCoordinator get _coordinator =>
      UssdSessionCoordinator(channel: _session, parser: parser);

  static void _requireRequest({
    required String code,
    required int subscriptionId,
  }) {
    if (code.isEmpty) {
      throw ArgumentError.value(code, 'code', 'Must not be empty.');
    }
    if (subscriptionId < -1) {
      throw ArgumentError.value(
        subscriptionId,
        'subscriptionId',
        'Must be greater than or equal to -1.',
      );
    }
  }
}
