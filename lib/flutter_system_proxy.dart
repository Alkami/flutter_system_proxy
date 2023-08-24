import 'dart:async';
import 'dart:io';
import 'package:flutter/services.dart';

// ignore: avoid_classes_with_only_static_members
class FlutterSystemProxy {
  static const MethodChannel _channel = MethodChannel('flutter_system_proxy');

  /// returns host and port from environment
  static Future<dynamic> getEnvironmentProxy(String url) async {
    return _channel.invokeMethod('getDeviceProxy', <String, dynamic>{'url': url});
  }

  /// returns Proxy String
  static Future<String> findProxyFromEnvironment(String url) async {
    // ignore: prefer_final_locals
    dynamic proxySettings = await getEnvironmentProxy(url);
    if (!isNullOrEmpty(proxySettings['host']) && isPort(proxySettings['port'])) {
      return "PROXY ${proxySettings['host']}:${proxySettings['port']}";
    } else {
      return HttpClient.findProxyFromEnvironment(Uri.parse(url));
    }
  }
}

bool isNullOrEmpty(String? str) {
  return str == null || str == '';
}

bool isPort(dynamic port) {
  if (port == null) {
    return false;
  }
  final number = num.tryParse(port.toString());
  if (number != null && number > 0 && number <= 65536) {
    return true;
  } else {
    return false;
  }
}
