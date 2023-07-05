import 'wireguard_dart_platform_interface.dart';

class WireguardDart {
  Future<Map<String, String>> generateKeyPair() {
    return WireguardDartPlatform.instance.generateKeyPair();
  }

  Future<void> setupTunnel({
    required String bundleId,
    required String endpoint,
    required String desc,
  }) {
    return WireguardDartPlatform.instance.setupTunnel(
      bundleId: bundleId,
      endpoint: endpoint,
      desc: desc,
    );
  }

  Future<void> connect({
    required String cfg,
    required String endpoint,
    required String desc,
  }) {
    return WireguardDartPlatform.instance.connect(
      cfg: cfg,
      endpoint: endpoint,
      desc: desc,
    );
  }

  Future<void> disconnect({
    required String endpoint,
    required String desc,
  }) {
    return WireguardDartPlatform.instance.disconnect(
      endpoint: endpoint,
      desc: desc,
    );
  }

  Stream<dynamic> get states => WireguardDartPlatform.instance.events;
}
