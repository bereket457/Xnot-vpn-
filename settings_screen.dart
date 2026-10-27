import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../main.dart';
import '../models/vpn_config.dart';
import '../providers/vpn_provider.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  late TextEditingController name, host, port, dns, wgPrivate, wgAddress,
      wgPeer, wgEndpoint, wgAllowed, wgKeepalive;
  late DnsMode dnsMode;

  @override
  void initState() {
    super.initState();
    final c = context.read<VpnProvider>().active;
    name = TextEditingController(text: c.name);
    host = TextEditingController(text: c.host);
    port = TextEditingController(text: '${c.port}');
    dns = TextEditingController(text: c.customDns);
    wgPrivate = TextEditingController(text: c.wireguardPrivateKey);
    wgAddress = TextEditingController(text: c.wireguardAddress);
    wgPeer = TextEditingController(text: c.wireguardPeerPublicKey);
    wgEndpoint = TextEditingController(text: c.wireguardEndpoint);
    wgAllowed = TextEditingController(text: c.wireguardAllowedIps);
    wgKeepalive = TextEditingController(text: '${c.wireguardKeepalive}');
    dnsMode = c.dns;
  }

  @override
  void dispose() {
    for (final c in [
      name, host, port, dns, wgPrivate, wgAddress, wgPeer, wgEndpoint,
      wgAllowed, wgKeepalive
    ]) {
      c.dispose();
    }
    super.dispose();
  }

  Future<void> _save() async {
    final v = context.read<VpnProvider>();
    v.active
      ..name = name.text.trim().isEmpty ? 'My WireGuard Server' : name.text.trim()
      ..host = host.text.trim()
      ..port = int.tryParse(port.text) ?? 51820
      ..dns = dnsMode
      ..customDns = dns.text.trim()
      ..wireguardPrivateKey = wgPrivate.text.trim()
      ..wireguardAddress = wgAddress.text.trim()
      ..wireguardPeerPublicKey = wgPeer.text.trim()
      ..wireguardEndpoint = wgEndpoint.text.trim()
      ..wireguardAllowedIps = wgAllowed.text.trim()
      ..wireguardKeepalive = int.tryParse(wgKeepalive.text) ?? 25;

    await v.save();

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Configuration saved ✓')),
    );
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(title: const Text('WireGuard Configuration')),
        body: ListView(
          padding: const EdgeInsets.all(18),
          children: [
            _title('SERVER'),
            _field('Profile name', name),
            _field('Server / Domain', host, hint: 'vpn.example.com'),
            _field('Port', port, number: true, hint: '51820'),

            _title('WIREGUARD'),
            _field('Client private key', wgPrivate,
                obscure: true, hint: 'Base64 WireGuard private key'),
            _field('Client interface address', wgAddress,
                hint: '10.0.0.2/32'),
            _field('Server peer public key', wgPeer,
                hint: 'Base64 peer public key'),
            _field('Peer endpoint', wgEndpoint,
                hint: 'vpn.example.com:51820'),
            _field('Allowed IPs', wgAllowed,
                hint: '0.0.0.0/0, ::/0'),
            _field('Persistent keepalive', wgKeepalive,
                number: true, hint: '25'),

            _title('DNS'),
            DropdownButtonFormField<DnsMode>(
              value: dnsMode,
              decoration: const InputDecoration(labelText: 'DNS mode'),
              items: DnsMode.values
                  .map((d) => DropdownMenuItem(
                        value: d,
                        child: Text(d.name),
                      ))
                  .toList(),
              onChanged: (x) =>
                  setState(() => dnsMode = x ?? DnsMode.cloudflare),
            ),
            if (dnsMode == DnsMode.custom) ...[
              const SizedBox(height: 12),
              _field('Custom DNS', dns, hint: '1.1.1.1'),
            ],

            const SizedBox(height: 18),
            const Text(
              'Use only a WireGuard server and credentials you own or are authorized to use.',
              style: TextStyle(color: XnotColors.muted),
            ),
            const SizedBox(height: 20),

            FilledButton.icon(
              onPressed: _save,
              icon: const Icon(Icons.save_rounded),
              label: const Text('SAVE CONFIGURATION'),
            ),
            const SizedBox(height: 12),
            OutlinedButton.icon(
              onPressed: () {
                final j = jsonEncode(
                  context.read<VpnProvider>().active.toJson(),
                );
                showDialog(
                  context: context,
                  builder: (_) => AlertDialog(
                    title: const Text('Export JSON'),
                    content: SelectableText(j),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text('Close'),
                      ),
                    ],
                  ),
                );
              },
              icon: const Icon(Icons.ios_share_rounded),
              label: const Text('EXPORT CONFIG'),
            ),
          ],
        ),
      );

  Widget _title(String x) => Padding(
        padding: const EdgeInsets.only(top: 10, bottom: 10),
        child: Text(
          x,
          style: const TextStyle(
            color: XnotColors.cyan,
            fontWeight: FontWeight.w900,
            letterSpacing: 1.4,
          ),
        ),
      );

  Widget _field(
    String label,
    TextEditingController c, {
    bool obscure = false,
    bool number = false,
    String? hint,
  }) =>
      Padding(
        padding: const EdgeInsets.only(bottom: 12),
        child: TextField(
          controller: c,
          obscureText: obscure,
          keyboardType:
              number ? TextInputType.number : TextInputType.text,
          decoration: InputDecoration(labelText: label, hintText: hint),
        ),
      );
}
