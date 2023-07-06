/// Конфигурация интерфейса.
class InterfaceConfig {
  final String privateKey;
  final String address;
  final String dns;

  InterfaceConfig({
    required this.privateKey,
    required this.address,
    required this.dns,
  });

  @override
  String toString() {
    final buffer = StringBuffer();
    buffer
      ..writeln('[Interface]')
      ..writeln('PrivateKey = $privateKey')
      ..writeln('Address = $address')
      ..writeln('DNS = $dns');
    return buffer.toString();
  }

  Map<String, dynamic> toJson() => {
        'privateKey': privateKey,
        'address': address,
        'dns': dns,
      };
}
