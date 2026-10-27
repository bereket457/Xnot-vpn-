enum TunnelProtocol { wireguard }
enum DnsMode { automatic, cloudflare, google, custom }

class VpnConfig {
  String name;
  String host;
  int port;
  TunnelProtocol protocol;
  DnsMode dns;
  String customDns;
  String wireguardPrivateKey;
  String wireguardAddress;
  String wireguardPeerPublicKey;
  String wireguardEndpoint;
  String wireguardAllowedIps;
  int wireguardKeepalive;

  VpnConfig({
    this.name = 'My WireGuard Server',
    this.host = '',
    this.port = 51820,
    this.protocol = TunnelProtocol.wireguard,
    this.dns = DnsMode.cloudflare,
    this.customDns = '',
    this.wireguardPrivateKey = '',
    this.wireguardAddress = '10.0.0.2/32',
    this.wireguardPeerPublicKey = '',
    this.wireguardEndpoint = '',
    this.wireguardAllowedIps = '0.0.0.0/0, ::/0',
    this.wireguardKeepalive = 25,
  });

  bool get isValid {
    final endpoint = wireguardEndpoint.trim().isNotEmpty
        ? wireguardEndpoint.trim()
        : '${host.trim()}:$port';
    return protocol == TunnelProtocol.wireguard &&
        wireguardPrivateKey.trim().isNotEmpty &&
        wireguardAddress.trim().isNotEmpty &&
        wireguardPeerPublicKey.trim().isNotEmpty &&
        endpoint.isNotEmpty &&
        port >= 1 &&
        port <= 65535;
  }

  Map<String, dynamic> toJson() => {
    'name': name,
    'host': host,
    'port': port,
    'protocol': protocol.name,
    'dns': dns.name,
    'customDns': customDns,
    'wireguardPrivateKey': wireguardPrivateKey,
    'wireguardAddress': wireguardAddress,
    'wireguardPeerPublicKey': wireguardPeerPublicKey,
    'wireguardEndpoint': wireguardEndpoint,
    'wireguardAllowedIps': wireguardAllowedIps,
    'wireguardKeepalive': wireguardKeepalive,
  };

  factory VpnConfig.fromJson(Map<String, dynamic> j) => VpnConfig(
    name: '${j['name'] ?? 'My WireGuard Server'}',
    host: '${j['host'] ?? ''}',
    port: int.tryParse('${j['port'] ?? 51820}') ?? 51820,
    protocol: TunnelProtocol.wireguard,
    dns: DnsMode.values.firstWhere(
      (x) => x.name == j['dns'],
      orElse: () => DnsMode.cloudflare,
    ),
    customDns: '${j['customDns'] ?? ''}',
    wireguardPrivateKey: '${j['wireguardPrivateKey'] ?? ''}',
    wireguardAddress: '${j['wireguardAddress'] ?? '10.0.0.2/32'}',
    wireguardPeerPublicKey: '${j['wireguardPeerPublicKey'] ?? ''}',
    wireguardEndpoint: '${j['wireguardEndpoint'] ?? ''}',
    wireguardAllowedIps: '${j['wireguardAllowedIps'] ?? '0.0.0.0/0, ::/0'}',
    wireguardKeepalive:
        int.tryParse('${j['wireguardKeepalive'] ?? 25}') ?? 25,
  );
}
