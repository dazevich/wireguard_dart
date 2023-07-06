import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:wireguard_dart/wireguard_dart.dart';

import 'wireguard_dart_platform_interface.dart';

/// An implementation of [WireguardDartPlatform] that uses method channels.
class MethodChannelWireguardDart extends WireguardDartPlatform {
  /// The method channel used to interact with the native platform.
  @visibleForTesting
  final methodChannel = const MethodChannel('wireguard_dart');

  /// Event channel need to listen WireGuard states.
  @visibleForTesting
  final eventChannel = const EventChannel('wireguard_dart_events');

  @override
  Future<Map<String, String>> generateKeyPair() async {
    return Map<String, String>.from(
        await methodChannel.invokeMethod('generateKeyPair'));
  }

  @override
  Future<void> setupTunnel({
    required String bundleId,
    required TunnelConfig tunnelConfig,
  }) async {
    await methodChannel.invokeMethod<void>('setupTunnel', {
      'bundleId': bundleId,
      'cfg': tunnelConfig.toJson(),
    });
  }

  @override
  Future<void> connect({
    required TunnelConfig tunnelConfig,
  }) async {
    await methodChannel.invokeMethod<void>('connect', {
      'cfg': tunnelConfig.toString(),
    });
  }

  @override
  Future<void> disconnect() async {
    await methodChannel.invokeMethod<void>('disconnect');
  }

  @override
  Future<void> checkPermission() async {
    await methodChannel.invokeMethod<void>('checkPermission');
  }

  @override
  // TODO: implement events
  Stream get events =>
      eventChannel.receiveBroadcastStream().map((event) => event);
}
