import 'package:wireguard_dart/src/tunnel_config.dart';

import 'wireguard_dart_platform_interface.dart';

export 'src/tunnel_config.dart';
export 'src/interface_config.dart';
export 'src/peer_config.dart';

class WireguardDart {
  const WireguardDart();

  Future<Map<String, String>> generateKeyPair() {
    return WireguardDartPlatform.instance.generateKeyPair();
  }

  Future<void> setupTunnel({
    required TunnelConfig tunnelConfig,
  }) {
    return WireguardDartPlatform.instance.setupTunnel(
      bundleId: tunnelConfig.peer.name,
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

  Future<dynamic> getCurrentConfig() {
    return WireguardDartPlatform.instance.getCurrentConfig();
  }

  Stream<dynamic> get states => WireguardDartPlatform.instance.events;
}
