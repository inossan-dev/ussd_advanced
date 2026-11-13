import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import 'ussd_advanced_platform_interface.dart';

/// [UssdAdvancedPlatform] that talks to Android and iOS through platform channels.
final class MethodChannelUssdAdvanced extends UssdAdvancedPlatform {
  /// Channel name shared with the native plugins.
  static const methodChannelName = 'method.com.phan_tech/ussd_advanced';

  /// Channel that carries multi-session menu text.
  static const messageChannelName = 'message.com.phan_tech/ussd_advanced';

  /// Method channel used by [sendUssd], permissions, and session control.
  @visibleForTesting
  final MethodChannel methodChannel = const MethodChannel(methodChannelName);

  /// Message channel used to send a menu reply and receive the dialog text.
  @visibleForTesting
  final BasicMessageChannel<String> messageChannel =
      const BasicMessageChannel<String>(messageChannelName, StringCodec());

  final StreamController<String?> _ends = StreamController<String?>.broadcast();
  Stream<String?>? _onEnd;

  @override
  Future<void> sendUssd({
    required String code,
    required int subscriptionId,
  }) async {
    await methodChannel.invokeMethod<Object?>(
      'sendUssd',
      _arguments(code: code, subscriptionId: subscriptionId),
    );
  }

  @override
  Future<String?> sendAdvancedUssd({
    required String code,
    required int subscriptionId,
  }) {
    return _invokeString(
      'sendAdvancedUssd',
      code: code,
      subscriptionId: subscriptionId,
    );
  }

  @override
  Future<String?> start({required String code, required int subscriptionId}) {
    return _invokeString(
      'multisessionUssd',
      code: code,
      subscriptionId: subscriptionId,
    );
  }

  @override
  Future<String?> send(String message) => messageChannel.send(message);

  @override
  Future<void> cancel() {
    return methodChannel.invokeMethod<void>('multisessionUssdCancel');
  }

  @override
  Stream<String?> get onEnd {
    final existing = _onEnd;
    if (existing != null) return existing;

    messageChannel.setMessageHandler((String? message) async {
      if (!_ends.isClosed) _ends.add(message);
      return message ?? '';
    });
    final created = _ends.stream;
    _onEnd = created;
    return created;
  }

  @override
  Future<bool> hasPermissions() async {
    try {
      final granted = await methodChannel.invokeMethod<bool>('hasPermissions');
      return granted ?? false;
    } on Object {
      return false;
    }
  }

  @override
  Future<void> requestPermissions() {
    return methodChannel.invokeMethod<void>('requestPermissions');
  }

  Future<String?> _invokeString(
    String method, {
    required String code,
    required int subscriptionId,
  }) async {
    final response = await methodChannel.invokeMethod<Object?>(
      method,
      _arguments(code: code, subscriptionId: subscriptionId),
    );
    return switch (response) {
      null => null,
      final String value => value,
      _ => response.toString(),
    };
  }

  Map<String, Object> _arguments({
    required String code,
    required int subscriptionId,
  }) {
    return <String, Object>{'subscriptionId': subscriptionId, 'code': code};
  }
}
