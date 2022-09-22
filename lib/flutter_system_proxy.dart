import 'dart:async';
import 'dart:convert';
import 'dart:developer';
import 'dart:io';
import 'package:flutter/services.dart';

// ignore: avoid_classes_with_only_static_members
class FlutterSystemProxy {
  static const MethodChannel _channel = MethodChannel('flutter_system_proxy');

  static Future<Map<String, String>?> _getSystemProxy(String url) async {
    final bool isHttps = Uri.parse(url).scheme == 'https';
    final dynamic proxySettings = await _channel.invokeMethod('getDeviceProxy');
    if (Platform.isAndroid) {
      if (isHttps) {
        if (!isNullOrEmpty(proxySettings['https.proxyHost']) && isPort(proxySettings['https.proxyPort'])) {
          return {
            'enabled': 'true',
            'host': proxySettings['https.proxyHost'],
            'port': proxySettings['https.proxyPort']
          };
        }
      } else {
        if (!isNullOrEmpty(proxySettings['http.proxyHost']) && isPort(proxySettings['http.proxyPort'])) {
          return {'enabled': 'true', 'host': proxySettings['http.proxyHost'], 'port': proxySettings['http.proxyPort']};
        }
      }
      return null;
    } else if (Platform.isIOS) {
      if (proxySettings['ProxyAutoConfigEnable'] == 1) {
        return {'pacEnabled': 'true', 'pacUrl': proxySettings['ProxyAutoConfigURLString']};
      } else {
        if (isHttps) {
          if (proxySettings['HTTPSEnable'] == 1) {
            return {
              'enabled': 'true',
              'host': proxySettings['HTTPSProxy'].toString(),
              'port': proxySettings['HTTPSPort'].toString()
            };
          }
        } else {
          if (proxySettings['HTTPEnable'] == 1) {
            return {
              'enabled': 'true',
              'host': proxySettings['HTTPProxy'].toString(),
              'port': proxySettings['HTTPPort'].toString()
            };
          }
        }
        return null;
      }
    }
    return null;
  }

  static Future<String> findProxyFromEnvironment(String url) async {
    final parsedProxy = await _getSystemProxy(url);
    log(parsedProxy.toString());
    final host = Uri.parse(url).host;
    if (parsedProxy != null && parsedProxy['enabled'] == 'true') {
      return 'PROXY ${parsedProxy['host'] as String}:${parsedProxy['port'] as String}';
    } else if (parsedProxy != null && parsedProxy['pacEnabled'] == 'true' && parsedProxy['pacUrl'] != null) {
      final String pacLocation = parsedProxy['pacUrl'] as String;
      final String jsContents = await contents(pacLocation);
      final String proxy = await _channel.invokeMethod('executePAC', {'url': url, 'host': host, 'js': jsContents});
      return proxy;
    } else {
      return HttpClient.findProxyFromEnvironment(Uri.parse(url));
    }
  }
}

bool isNullOrEmpty(String? str) {
  return str == null || str == '';
}

bool isPort(String? port) {
  if (port == null) {
    return false;
  }
  final number = num.tryParse(port);
  if (number != null && number > 0) {
    return true;
  } else {
    return false;
  }
}

Future<String> contents(String url) async {
  final HttpClient client = HttpClient();
  final completor = Completer<String>();
  client.findProxy = null;
  final request = await client.getUrl(Uri.parse(url));
  final response = await request.close();
  response.transform(utf8.decoder).listen(completor.complete);
  return completor.future;
}
