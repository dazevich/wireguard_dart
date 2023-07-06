/// Конфигурация пира.
class PeerConfig {
  final String publicKey;
  final String allowedIps;
  final String endpoint;

  PeerConfig({
    required this.publicKey,
    required this.allowedIps,
    required this.endpoint,
  });

  @override
  String toString() {
    final buffer = StringBuffer();
    buffer
      ..writeln('[Peer]')
      ..writeln('PublicKey = $publicKey')
      ..writeln('AllowedIPs = $allowedIps')
      ..writeln('Endpoint = $endpoint');
    return buffer.toString();
  }

  Map<String, dynamic> toJson() => {
        'publicKey': publicKey,
        'allowedIps': allowedIps,
        'endpoint': endpoint,
      };
}
