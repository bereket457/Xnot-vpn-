import 'package:flutter/services.dart';

class VpnService {
  static const _channel = MethodChannel('xnot.vpn/service');

  Future<bool> prepare() async =>
      await _channel.invokeMethod<bool>('prepare') ?? false;

  Future<bool> start(Map<String, dynamic> config) async =>
      await _channel.invokeMethod<bool>('start', config) ?? false;

  Future<void> stop() => _channel.invokeMethod('stop');

  Future<Map<String, dynamic>> stats() async =>
      Map<String, dynamic>.from(await _channel.invokeMethod('stats') ?? {});
}
