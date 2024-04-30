import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const MethodChannel channel = MethodChannel('flutter_system_proxy');

  TestWidgetsFlutterBinding.ensureInitialized();
  final defaultMessenger = TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger;

  setUp(() {
    defaultMessenger.setMockMethodCallHandler(channel,
        (MethodCall methodCall) async {
      return '42';
    });
  });

  tearDown(() {
    defaultMessenger.setMockMethodCallHandler(channel, null);
  });

  test('getSystemProxy', () async {});
}
