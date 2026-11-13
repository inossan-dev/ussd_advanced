import 'ussd_code.dart';

/// Turns a raw USSD string into a root code and optional menu replies.
///
/// Provide another implementation to [UssdAdvanced.parser] when a carrier
/// uses a different layout than `*service*reply*reply#`.
abstract interface class UssdCodeParser {
  const factory UssdCodeParser() = StandardUssdCodeParser;

  UssdCode parse(String raw);
}

/// Parser for the `*service*reply*reply#` form used by this plugin.
final class StandardUssdCodeParser implements UssdCodeParser {
  const StandardUssdCodeParser();

  @override
  UssdCode parse(String raw) {
    if (raw.length < 2) {
      throw FormatException(
        'USSD code must include a prefix and a closing character.',
        raw,
      );
    }

    final body = raw.substring(1, raw.length - 1);
    final items = body.split('*');
    final root = '${raw[0]}${items.first}#';
    if (items.length == 1) {
      return UssdCode(code: root);
    }
    return UssdCode(
      code: root,
      messages: List<String>.unmodifiable(items.sublist(1)),
    );
  }
}
