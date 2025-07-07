// In order to *not* need this ignore, consider extracting the "web" version
// of your plugin as a separate package, instead of inlining it in the same
// package as the core of your plugin.
// ignore: avoid_web_libraries_in_flutter

import 'package:flutter_web_plugins/flutter_web_plugins.dart';
import 'package:wireguard_dart/wireguard_dart.dart';

import 'wireguard_dart_platform_interface.dart';

/// A web implementation of the WireguardDartPlatform of the WireguardDart plugin.
class WireguardDartWeb extends WireguardDartPlatform {
  final _mockStream = const Stream.empty();

  /// Constructs a WireguardDartWeb
  WireguardDartWeb();

  static void registerWith(Registrar registrar) {
    WireguardDartPlatform.instance = WireguardDartWeb();
  }

  @override
  Future<void> setupTunnel({required String bundleId, required TunnelConfig tunnelConfig}) async {
    return;
  }

  @override
  Future<Map<String, String>> generateKeyPair() async {
    return {};
  }

  @override
  Future<void> connect({required TunnelConfig tunnelConfig}) async {
    return;
  }

  @override
  Future<void> disconnect() async {
    return;
  }

  @override
  Future<void> checkPermission() async {
    return;
  }

  Stream<dynamic> get states => _mockStream.asBroadcastStream();
}
