import 'package:plugin_platform_interface/plugin_platform_interface.dart';
import 'package:wireguard_dart/src/tunnel_config.dart';

import 'wireguard_dart_method_channel.dart';

abstract class WireguardDartPlatform extends PlatformInterface {
  /// Constructs a WireguardDartPlatform.
  WireguardDartPlatform() : super(token: _token);

  static final Object _token = Object();

  static WireguardDartPlatform _instance = MethodChannelWireguardDart();

  /// The default instance of [WireguardDartPlatform] to use.
  ///
  /// Defaults to [MethodChannelWireguardDart].
  static WireguardDartPlatform get instance => _instance;

  /// Platform-specific implementations should set this with their own
  /// platform-specific class that extends [WireguardDartPlatform] when
  /// they register themselves.
  static set instance(WireguardDartPlatform instance) {
    PlatformInterface.verifyToken(instance, _token);
    _instance = instance;
  }

  Future<Map<String, String>> generateKeyPair() {
    throw UnimplementedError('generateKeyPair() has not been implemented');
  }

  Future<void> setupTunnel({
    required String bundleId,
    required TunnelConfig tunnelConfig,
  }) {
    throw UnimplementedError('setupTunnel() has not been implemented');
  }

  Future<void> connect({
    required TunnelConfig tunnelConfig,
  }) {
    throw UnimplementedError('connect() has not been implemented');
  }

  Future<void> disconnect() {
    throw UnimplementedError('disconnect() has not been implemented');
  }

  Stream<dynamic> get events =>
      throw UnimplementedError('events has not been implemented,');

  Future<void> checkPermission() {
    throw UnimplementedError('disconnect() has not been implemented');
  }
}
