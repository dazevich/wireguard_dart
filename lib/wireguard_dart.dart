import 'package:wireguard_dart/src/tunnel_config.dart';

import 'wireguard_dart_platform_interface.dart';

export 'src/tunnel_config.dart';
export 'src/interface_config.dart';
export 'src/peer_config.dart';

class WireguardDart {
  final String bundleId;
  final String description;

  WireguardDart({
    required this.bundleId,
    required this.description,
  });

  Future<Map<String, String>> generateKeyPair() {
    return WireguardDartPlatform.instance.generateKeyPair();
  }

  Future<void> setupTunnel({
    required TunnelConfig tunnelConfig,
  }) {
    return WireguardDartPlatform.instance.setupTunnel(
      bundleId: bundleId,
      tunnelConfig: tunnelConfig,
    );
  }

  Future<void> connect({
    required TunnelConfig tunnelConfig,
  }) {
    return WireguardDartPlatform.instance.connect(
      tunnelConfig: tunnelConfig,
    );
  }

  Future<void> disconnect() {
    return WireguardDartPlatform.instance.disconnect();
  }

  Future<void> checkPermisson() {
    return WireguardDartPlatform.instance.checkPermission();
  }

  Stream<dynamic> get states => WireguardDartPlatform.instance.events;
}
