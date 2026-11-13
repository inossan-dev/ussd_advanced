import 'package:flutter_test/flutter_test.dart';
import 'package:ussd_advanced/ussd_advanced.dart';

void main() {
  const parser = UssdCodeParser();

  test('splits a menu code into a root code and replies', () {
    final parsed = parser.parse('*123*1*4*3#');

    expect(parsed.code, '*123#');
    expect(parsed.messages, ['1', '4', '3']);
    expect(parsed.hasFollowUp, isTrue);
  });

  test('keeps a single-session code unchanged', () {
    final parsed = parser.parse('*100#');

    expect(parsed.code, '*100#');
    expect(parsed.messages, isEmpty);
    expect(parsed.hasFollowUp, isFalse);
  });

  test('preserves the prefix character', () {
    expect(parser.parse('#100#').code, '#100#');
  });

  test('rejects a code that is too short', () {
    expect(() => parser.parse('*'), throwsFormatException);
  });
}
