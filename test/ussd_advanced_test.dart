import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:ussd_advanced/ussd_advanced.dart';

void main() {
  late _FakePlatform platform;

  setUp(() {
    platform = _FakePlatform();
    UssdAdvanced.dialer = platform;
    UssdAdvanced.session = platform;
    UssdAdvanced.permissions = platform;
  });

  tearDown(UssdAdvanced.reset);

  test('sendUssd forwards the code and subscription', () async {
    await UssdAdvanced.sendUssd(code: '*100#', subscriptionId: 2);

    expect(platform.calls, [
      (method: 'sendUssd', code: '*100#', subscriptionId: 2),
    ]);
  });

  test('sendAdvancedUssd returns the dialer reply', () async {
    platform.advancedResponse = 'Your account is';

    final response = await UssdAdvanced.sendAdvancedUssd(code: '*100#');

    expect(response, 'Your account is');
  });

  test('sendAdvancedUssd times out when the dialer never replies', () async {
    UssdAdvanced.advancedTimeout = const Duration(milliseconds: 10);
    UssdAdvanced.dialer = _HangingDialer();

    await expectLater(
      UssdAdvanced.sendAdvancedUssd(code: '*100#'),
      throwsA(isA<TimeoutException>()),
    );
  });

  test('multisessionUssd dials the root code then sends each reply', () async {
    platform.messageResponseQueue.addAll(['option', 'done']);

    final response = await UssdAdvanced.multisessionUssd(code: '*123*1*4#');

    expect(platform.calls.single.code, '*123#');
    expect(platform.messages, ['1', '4']);
    expect(response, 'menu\n\noption\ndone');
  });

  test('multisessionUssd does not send replies for a single code', () async {
    final response = await UssdAdvanced.multisessionUssd(code: '*100#');

    expect(response, 'menu');
    expect(platform.messages, isEmpty);
  });

  test('a custom parser replaces the default code layout', () async {
    UssdAdvanced.parser = const _PassThroughParser();

    await UssdAdvanced.multisessionUssd(code: '*123*1#');

    expect(platform.calls.single.code, '*123*1#');
    expect(platform.messages, ['9']);
  });

  test('sendMultipleMessages prefixes every reply with a newline', () async {
    platform.messageResponseQueue.addAll(['a', null]);

    final response = await UssdAdvanced.sendMultipleMessages(['1', '2']);

    expect(response, '\na\nnull');
  });

  test('onEnd emits session text from the injected channel', () async {
    final events = <String?>[];
    final subscription = UssdAdvanced.onEnd().listen(events.add);

    platform.ends.add('closed');
    await Future<void>.delayed(Duration.zero);

    expect(events, ['closed']);
    await subscription.cancel();
  });

  test('permissions delegate to the injected gateway', () async {
    platform.permissionsGranted = true;

    expect(await UssdAdvanced.hasPermissions(), isTrue);
    await UssdAdvanced.requestPermissions();
    expect(platform.permissionRequests, 1);
  });

  test('rejects an empty code before calling the dialer', () {
    expect(() => UssdAdvanced.sendUssd(code: ''), throwsArgumentError);
    expect(platform.calls, isEmpty);
  });

  test('rejects a subscription below -1', () {
    expect(
      () => UssdAdvanced.sendAdvancedUssd(code: '*100#', subscriptionId: -2),
      throwsArgumentError,
    );
    expect(platform.calls, isEmpty);
  });

  test(
    'static calls use the current platform when no override is set',
    () async {
      UssdAdvanced.reset();
      final previous = UssdAdvancedPlatform.instance;
      final fallback = _FakePlatform();
      UssdAdvancedPlatform.instance = fallback;
      addTearDown(() => UssdAdvancedPlatform.instance = previous);

      await UssdAdvanced.sendUssd(code: '*100#');

      expect(fallback.calls.single.method, 'sendUssd');
    },
  );
}

final class _FakePlatform extends UssdAdvancedPlatform {
  final List<({String method, String code, int subscriptionId})> calls = [];
  final List<String> messages = [];
  final List<String?> messageResponseQueue = [];
  final StreamController<String?> ends = StreamController<String?>.broadcast();

  String? advancedResponse = 'balance';
  String? sessionResponse = 'menu';
  bool permissionsGranted = false;
  int permissionRequests = 0;

  @override
  Future<void> sendUssd({
    required String code,
    required int subscriptionId,
  }) async {
    calls.add((method: 'sendUssd', code: code, subscriptionId: subscriptionId));
  }

  @override
  Future<String?> sendAdvancedUssd({
    required String code,
    required int subscriptionId,
  }) async {
    calls.add((
      method: 'sendAdvancedUssd',
      code: code,
      subscriptionId: subscriptionId,
    ));
    return advancedResponse;
  }

  @override
  Future<String?> start({
    required String code,
    required int subscriptionId,
  }) async {
    calls.add((method: 'start', code: code, subscriptionId: subscriptionId));
    return sessionResponse;
  }

  @override
  Future<String?> send(String message) async {
    messages.add(message);
    if (messageResponseQueue.isEmpty) return 'ok';
    return messageResponseQueue.removeAt(0);
  }

  @override
  Future<void> cancel() async {}

  @override
  Stream<String?> get onEnd => ends.stream;

  @override
  Future<bool> hasPermissions() async => permissionsGranted;

  @override
  Future<void> requestPermissions() async {
    permissionRequests += 1;
  }
}

final class _HangingDialer implements UssdDialer {
  @override
  Future<String?> sendAdvancedUssd({
    required String code,
    required int subscriptionId,
  }) {
    return Completer<String?>().future;
  }

  @override
  Future<void> sendUssd({
    required String code,
    required int subscriptionId,
  }) async {}
}

final class _PassThroughParser implements UssdCodeParser {
  const _PassThroughParser();

  @override
  UssdCode parse(String raw) => UssdCode(code: raw, messages: const ['9']);
}
