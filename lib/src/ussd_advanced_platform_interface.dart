import 'package:plugin_platform_interface/plugin_platform_interface.dart';

import 'ussd_advanced_method_channel.dart';
import 'ussd_dialer.dart';
import 'ussd_permissions.dart';
import 'ussd_session_channel.dart';

/// Platform contract implemented by Android, iOS, and tests.
abstract class UssdAdvancedPlatform extends PlatformInterface
    implements UssdDialer, UssdSessionChannel, UssdPermissions {
  /// Constructs a platform implementation verified by [_token].
  UssdAdvancedPlatform() : super(token: _token);

  static final Object _token = Object();

  static UssdAdvancedPlatform? _instance;

  /// The platform implementation used when no dependency override is set.
  static UssdAdvancedPlatform get instance =>
      _instance ??= MethodChannelUssdAdvanced();

  /// Replaces [instance] with another implementation of this contract.
  static set instance(UssdAdvancedPlatform instance) {
    PlatformInterface.verifyToken(instance, _token);
    _instance = instance;
  }

  @override
  Future<void> sendUssd({required String code, required int subscriptionId}) {
    throw UnimplementedError('sendUssd() has not been implemented.');
  }

  @override
  Future<String?> sendAdvancedUssd({
    required String code,
    required int subscriptionId,
  }) {
    throw UnimplementedError('sendAdvancedUssd() has not been implemented.');
  }

  @override
  Future<String?> start({required String code, required int subscriptionId}) {
    throw UnimplementedError('start() has not been implemented.');
  }

  @override
  Future<String?> send(String message) {
    throw UnimplementedError('send() has not been implemented.');
  }

  @override
  Future<void> cancel() {
    throw UnimplementedError('cancel() has not been implemented.');
  }

  @override
  Stream<String?> get onEnd {
    throw UnimplementedError('onEnd has not been implemented.');
  }

  @override
  Future<bool> hasPermissions() {
    throw UnimplementedError('hasPermissions() has not been implemented.');
  }

  @override
  Future<void> requestPermissions() {
    throw UnimplementedError('requestPermissions() has not been implemented.');
  }
}
