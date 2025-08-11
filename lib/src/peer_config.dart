/// Конфигурация пира.
class PeerConfig {
  final String name;
  final String publicKey;
  final String allowedIps;
  final String endpoint;

  PeerConfig({
    required this.name,
    required this.publicKey,
    required this.allowedIps,
    required this.endpoint,
  });

  @override
  String toString() {
    final buffer = StringBuffer();
    buffer
      ..writeln('[Peer]')
      ..writeln('Name = $name')
      ..writeln('PublicKey = $publicKey')
      ..writeln('AllowedIPs = $allowedIps')
      ..writeln('Endpoint = $endpoint');
    return buffer.toString();
  }

  Map<String, dynamic> toJson() => {
        'name': name,
        'publicKey': publicKey,
        'allowedIps': allowedIps,
        'endpoint': endpoint,
      };
}
