import 'package:flutter_test/flutter_test.dart';
import 'package:wireguard_dart/src/interface_config.dart';
import 'package:wireguard_dart/src/peer_config.dart';
import 'package:wireguard_dart/src/tunnel_config.dart';

const expectedConfig = """
[Interface]
PrivateKey = privateKey
Address = address
DNS = 8.8.8.8

[Peer]
PublicKey = pubKey
AllowedIPs = 0.0.0.0/0
Endpoint = endpoint
""";

void main() {
  test('test build configuration', () {
    final interface = InterfaceConfig(
      privateKey: "privateKey",
      address: "address",
      dns: "8.8.8.8",
    );
    final peer = PeerConfig(
      publicKey: "pubKey",
      allowedIps: "0.0.0.0/0",
      endpoint: "endpoint",
    );
    final tunnelConfig = TunnelConfig(interface: interface, peer: peer);

    final tunnelConfigString = tunnelConfig.toString();

    expect(tunnelConfigString, expectedConfig);
  });
}
