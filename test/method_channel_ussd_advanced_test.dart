import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ussd_advanced/ussd_advanced.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late MethodChannelUssdAdvanced platform;
  late List<MethodCall> calls;

  setUp(() {
    platform = MethodChannelUssdAdvanced();
    calls = <MethodCall>[];
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(platform.methodChannel, (
          MethodCall call,
        ) async {
          calls.add(call);
          return switch (call.method) {
            'sendAdvancedUssd' => 'Your account is',
            'multisessionUssd' => 'menu',
            'hasPermissions' => true,
            'sendUssd' => true,
            'multisessionUssdCancel' => null,
            _ => null,
          };
        });
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockDecodedMessageHandler<String>(platform.messageChannel, (
          String? message,
        ) async {
          return 'reply:$message';
        });
  });

  tearDown(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(platform.methodChannel, null);
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockDecodedMessageHandler<String>(platform.messageChannel, null);
  });

  test('sendAdvancedUssd returns the channel text', () async {
    final response = await platform.sendAdvancedUssd(
      code: '*100#',
      subscriptionId: 1,
    );

    expect(response, 'Your account is');
    expect(calls.single.method, 'sendAdvancedUssd');
    expect(calls.single.arguments, {'subscriptionId': 1, 'code': '*100#'});
  });

  test('sendUssd accepts a non-string platform result', () async {
    await platform.sendUssd(code: '*100#', subscriptionId: -1);

    expect(calls.single.arguments, {'subscriptionId': -1, 'code': '*100#'});
  });

  test('start and send use the session channels', () async {
    expect(await platform.start(code: '*123#', subscriptionId: 1), 'menu');
    expect(await platform.send('1'), 'reply:1');
    await platform.cancel();
    expect(calls.last.method, 'multisessionUssdCancel');
  });

  test('hasPermissions is false when the platform call fails', () async {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(platform.methodChannel, null);

    expect(await platform.hasPermissions(), isFalse);
  });

  test('onEnd emits text pushed by the platform', () async {
    final events = <String?>[];
    final subscription = platform.onEnd.listen(events.add);
    final data = const StringCodec().encodeMessage('session closed');

    await TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .handlePlatformMessage(
          MethodChannelUssdAdvanced.messageChannelName,
          data,
          (ByteData? reply) {},
        );
    await Future<void>.delayed(Duration.zero);

    expect(events, ['session closed']);
    await subscription.cancel();
  });
}
