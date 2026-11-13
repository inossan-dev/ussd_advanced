import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:ussd_advanced/ussd_advanced.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final TextEditingController _controller = TextEditingController();
  String? _response;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _setResponse(String? value) {
    if (!mounted) return;
    setState(() => _response = value);
  }

  Future<void> _run(Future<String?> Function() request) async {
    try {
      _setResponse(await request());
    } on PlatformException catch (error) {
      _setResponse(error.message ?? error.code);
    } on Object catch (error) {
      _setResponse('$error');
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(title: const Text('Ussd Plugin example')),
        body: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            TextField(
              controller: _controller,
              keyboardType: TextInputType.phone,
              decoration: const InputDecoration(labelText: 'Ussd code'),
            ),
            if (_response != null)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Text(_response!),
              ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => _run(() async {
                await UssdAdvanced.sendUssd(
                  code: _controller.text,
                  subscriptionId: 1,
                );
                return 'Request sent';
              }),
              child: const Text('Normal request'),
            ),
            ElevatedButton(
              onPressed: () => _run(() async {
                return UssdAdvanced.sendAdvancedUssd(
                  code: _controller.text,
                  subscriptionId: 1,
                );
              }),
              child: const Text('Single session request'),
            ),
            ElevatedButton(
              onPressed: () => _run(() async {
                await UssdAdvanced.multisessionUssd(
                  code: _controller.text,
                  subscriptionId: 1,
                );
                final followUp = await UssdAdvanced.sendMessage('0');
                await UssdAdvanced.cancelSession();
                return followUp;
              }),
              child: const Text('Multi session request'),
            ),
          ],
        ),
      ),
    );
  }
}
