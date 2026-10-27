import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../main.dart';
import '../providers/vpn_provider.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final vpn = context.watch<VpnProvider>();
    return Scaffold(
      appBar: AppBar(
        title: const Row(children: [
          Icon(Icons.shield_rounded, color: XnotColors.cyan),
          SizedBox(width: 10),
          Text('XNOT VPN', style: TextStyle(fontWeight: FontWeight.w900, letterSpacing: 1.5))
        ]),
        actions: [
          IconButton(onPressed: () => Navigator.pushNamed(context, '/logs'), icon: const Icon(Icons.terminal_rounded)),
          IconButton(onPressed: () => Navigator.pushNamed(context, '/settings'), icon: const Icon(Icons.tune_rounded)),
        ],
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 10, 20, 30),
          children: [
            _statusCard(vpn),
            const SizedBox(height: 18),
            _connect(vpn),
            const SizedBox(height: 22),
            _serverCard(context, vpn),
            const SizedBox(height: 14),
            _stats(vpn),
            const SizedBox(height: 14),
            _quickFeatures(),
            const SizedBox(height: 20),
            Center(child: Text('Xnot VPN • Modern 2026', style: TextStyle(color: XnotColors.muted))),
          ],
        ),
      ),
    );
  }

  Widget _statusCard(VpnProvider v) {
    final online = v.connected;
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: LinearGradient(colors: [XnotColors.card, online ? const Color(0xFF0B2A24) : XnotColors.card2]),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: online ? XnotColors.green.withOpacity(.35) : Colors.white10),
      ),
      child: Row(children: [
        Container(
          width: 52, height: 52,
          decoration: BoxDecoration(shape: BoxShape.circle, color: (online ? XnotColors.green : XnotColors.muted).withOpacity(.12)),
          child: Icon(online ? Icons.lock_rounded : Icons.lock_open_rounded, color: online ? XnotColors.green : XnotColors.muted),
        ),
        const SizedBox(width: 14),
        Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(online ? 'PROTECTED' : 'NOT CONNECTED', style: TextStyle(color: online ? XnotColors.green : XnotColors.muted, fontWeight: FontWeight.w800)),
          const SizedBox(height: 4),
          Text(online ? 'Your VPN service is running' : 'Tap connect to start', style: const TextStyle(color: XnotColors.text)),
        ]),
      ]),
    );
  }

  Widget _connect(VpnProvider v) {
    final online = v.connected;
    return Center(
      child: GestureDetector(
        onTap: v.toggle,
        child: Container(
          width: 205, height: 205,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: SweepGradient(colors: [XnotColors.cyan, XnotColors.purple, XnotColors.cyan]),
            boxShadow: [BoxShadow(color: (online ? XnotColors.green : XnotColors.cyan).withOpacity(.18), blurRadius: 45, spreadRadius: 10)],
          ),
          padding: const EdgeInsets.all(6),
          child: Container(
            decoration: const BoxDecoration(shape: BoxShape.circle, color: XnotColors.bg),
            child: Center(
              child: Column(mainAxisSize: MainAxisSize.min, children: [
                Icon(online ? Icons.power_settings_new_rounded : Icons.power_settings_new_rounded,
                  size: 58, color: online ? XnotColors.green : XnotColors.cyan),
                const SizedBox(height: 8),
                Text(v.state == VpnState.connecting ? 'CONNECTING' : online ? 'DISCONNECT' : 'CONNECT',
                  style: const TextStyle(fontWeight: FontWeight.w900, letterSpacing: 1.2)),
              ]),
            ),
          ),
        ),
      ),
    );
  }

  Widget _serverCard(BuildContext context, VpnProvider v) => Card(
    color: XnotColors.card,
    child: ListTile(
      leading: const CircleAvatar(backgroundColor: Color(0xFF172231), child: Icon(Icons.public_rounded, color: XnotColors.cyan)),
      title: Text(v.active.name, style: const TextStyle(fontWeight: FontWeight.w800)),
      subtitle: Text(v.active.host.isEmpty ? 'No server configured' : '${v.active.host}:${v.active.port}'),
      trailing: const Icon(Icons.chevron_right_rounded),
      onTap: () => Navigator.pushNamed(context, '/settings'),
    ),
  );

  Widget _stats(VpnProvider v) => Row(children: [
    _stat('DOWNLOAD', '${v.download.toStringAsFixed(2)} MB/s', Icons.download_rounded),
    const SizedBox(width: 10),
    _stat('UPLOAD', '${v.upload.toStringAsFixed(2)} MB/s', Icons.upload_rounded),
    const SizedBox(width: 10),
    _stat('TIME', '${v.seconds}s', Icons.timer_outlined),
  ]);

  Widget _stat(String t, String value, IconData icon) => Expanded(
    child: Container(
      padding: const EdgeInsets.all(13),
      decoration: BoxDecoration(color: XnotColors.card, borderRadius: BorderRadius.circular(18)),
      child: Column(children: [
        Icon(icon, size: 20, color: XnotColors.cyan),
        const SizedBox(height: 7),
        Text(value, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w800)),
        const SizedBox(height: 3),
        Text(t, style: const TextStyle(fontSize: 8, color: XnotColors.muted)),
      ]),
    ),
  );

  Widget _quickFeatures() => Row(children: [
    _feature(Icons.speed_rounded, 'Fast'),
    const SizedBox(width: 10),
    _feature(Icons.security_rounded, 'Private'),
    const SizedBox(width: 10),
    _feature(Icons.battery_saver_rounded, 'Efficient'),
  ]);

  Widget _feature(IconData icon, String text) => Expanded(
    child: Container(
      padding: const EdgeInsets.symmetric(vertical: 15),
      decoration: BoxDecoration(color: XnotColors.card, borderRadius: BorderRadius.circular(16)),
      child: Column(children: [Icon(icon, color: XnotColors.purple), const SizedBox(height: 6), Text(text, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700))]),
    ),
  );
}
