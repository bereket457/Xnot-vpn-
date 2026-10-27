import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../main.dart';
import '../providers/vpn_provider.dart';

class LogsScreen extends StatelessWidget {
  const LogsScreen({super.key});
  @override
  Widget build(BuildContext context) {
    final logs = context.watch<VpnProvider>().logs;
    return Scaffold(
      appBar: AppBar(title: const Text('Connection Logs')),
      body: logs.isEmpty
        ? const Center(child: Text('No logs yet', style: TextStyle(color: XnotColors.muted)))
        : ListView.builder(
            padding: const EdgeInsets.all(14),
            itemCount: logs.length,
            itemBuilder: (_, i) => Container(
              margin: const EdgeInsets.only(bottom: 7),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(color: XnotColors.card, borderRadius: BorderRadius.circular(12)),
              child: Text(logs[i], style: const TextStyle(fontFamily: 'monospace', fontSize: 12)),
            ),
          ),
    );
  }
}
