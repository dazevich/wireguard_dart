import 'wireguard_dart_platform_interface.dart';

class WireguardDart {
  Future<Map<String, String>> generateKeyPair() {
    return WireguardDartPlatform.instance.generateKeyPair();
  }

  Future<void> setupTunnel({required String bundleId}) {
    return WireguardDartPlatform.instance.setupTunnel(bundleId: bundleId);
  }

  Future<void> connect({required String cfg}) {
    return WireguardDartPlatform.instance.connect(cfg: cfg);
  }

  Future<void> disconnect() {
    return WireguardDartPlatform.instance.disconnect();
  }

  Stream<dynamic> get states => WireguardDartPlatform.instance.events;
}
