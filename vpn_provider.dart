import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/vpn_config.dart';
import '../services/vpn_service.dart';

enum VpnState { disconnected, connecting, connected, reconnecting }

class VpnProvider extends ChangeNotifier {
  final VpnService service = VpnService();
  VpnState state = VpnState.disconnected;
  VpnConfig active = VpnConfig();
  final List<String> logs = [];
  Timer? _timer;
  int seconds = 0;
  double download = 0;
  double upload = 0;
  String? lastError;
  int _lastRx = 0;
  int _lastTx = 0;
  DateTime? _lastSample;

  bool get connected => state == VpnState.connected;
  bool get busy =>
      state == VpnState.connecting || state == VpnState.reconnecting;

  VpnProvider() {
    _load();
  }

  Future<void> _load() async {
    final p = await SharedPreferences.getInstance();
    final raw = p.getString('config');
    if (raw != null) {
      try {
        active = VpnConfig.fromJson(jsonDecode(raw));
      } catch (_) {
        addLog('Saved configuration could not be read');
      }
    }
    notifyListeners();
  }

  Future<void> save() async {
    final p = await SharedPreferences.getInstance();
    await p.setString('config', jsonEncode(active.toJson()));
    addLog('Configuration saved');
    notifyListeners();
  }

  void addLog(String message) {
    final stamp = DateTime.now().toIso8601String().substring(11, 19);
    logs.insert(0, '$stamp  $message');
    if (logs.length > 100) logs.removeLast();
    notifyListeners();
  }

  Future<void> toggle() async {
    if (connected || busy) {
      await disconnect();
      return;
    }

    lastError = null;
    if (!active.isValid) {
      lastError =
          'Enter the WireGuard private key, client address, peer public key and endpoint.';
      addLog(lastError!);
      return;
    }

    state = VpnState.connecting;
    seconds = 0;
    _lastRx = 0;
    _lastTx = 0;
    _lastSample = null;
    notifyListeners();

    addLog('Preparing Android VPN permission...');

    try {
      final prepared = await service.prepare();
      if (!prepared) {
        addLog(
          'VPN permission is required. Approve it, then tap Connect again.',
        );
        state = VpnState.disconnected;
        notifyListeners();
        return;
      }

      addLog('Starting WireGuard userspace tunnel...');
      final ok = await service.start(active.toJson());

      if (!ok) {
        throw Exception('WireGuard tunnel could not start');
      }

      state = VpnState.connected;
      addLog('WireGuard tunnel started ✓');
      _startStatsTimer();
    } catch (e) {
      lastError = e.toString().replaceFirst('Exception: ', '');
      addLog('Connection error: $lastError');
      state = VpnState.disconnected;
    }

    notifyListeners();
  }

  Future<void> _refreshStats() async {
    if (!connected) return;

    try {
      final s = await service.stats();
      final rx = (s['rx'] as num?)?.toInt() ?? 0;
      final tx = (s['tx'] as num?)?.toInt() ?? 0;
      final now = DateTime.now();

      if (_lastSample != null) {
        final dt = now.difference(_lastSample!).inMilliseconds / 1000.0;
        if (dt > 0) {
          download = ((rx - _lastRx).clamp(0, 1 << 60)).toDouble() / 1024 / 1024 / dt;
          upload = ((tx - _lastTx).clamp(0, 1 << 60)).toDouble() / 1024 / 1024 / dt;
        }
      }

      _lastRx = rx;
      _lastTx = tx;
      _lastSample = now;
    } catch (_) {}
  }

  void _startStatsTimer() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) async {
      if (!connected) return;
      seconds++;
      await _refreshStats();
      notifyListeners();
    });
  }

  Future<void> disconnect() async {
    _timer?.cancel();

    try {
      await service.stop();
    } finally {
      state = VpnState.disconnected;
      download = 0;
      upload = 0;
      seconds = 0;
      _lastSample = null;
      addLog('VPN disconnected');
      notifyListeners();
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }
}
