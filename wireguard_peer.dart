
class WireGuardPeer {
  final String publicKey;
  final String endpoint;
  final String allowedIps;
  final int persistentKeepalive;

  const WireGuardPeer({
    required this.publicKey,
    required this.endpoint,
    this.allowedIps = '0.0.0.0/0',
    this.persistentKeepalive = 25,
  });

  Map<String, dynamic> toJson() => {
    'publicKey': publicKey,
    'endpoint': endpoint,
    'allowedIps': allowedIps,
    'persistentKeepalive': persistentKeepalive,
  };
}
