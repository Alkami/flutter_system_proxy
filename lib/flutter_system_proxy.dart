import 'dart:async';
import 'dart:io';

import 'package:flutter/services.dart';

class FlutterSystemProxy {
  static const MethodChannel _channel = MethodChannel('flutter_system_proxy');

  /// returns host and port from environment
  Future<dynamic> getEnvironmentProxy(String url) async {
    return _channel.invokeMethod('getDeviceProxy', <String, dynamic>{'url': url});
  }

  /// returns Proxy String
  Future<String> findProxyFromEnvironment(String url) async {
    final dynamic proxySettings = await getEnvironmentProxy(url);
    if (!isNullOrEmpty(proxySettings['host']) && isPort(proxySettings['port'])) {
      return 'PROXY ${proxySettings['host']}:${proxySettings['port']}';
    } else {
      return HttpClient.findProxyFromEnvironment(Uri.parse(url));
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
}
