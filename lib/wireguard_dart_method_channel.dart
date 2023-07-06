import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

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
    required String endpoint,
    required String desc,
  }) async {
    await methodChannel.invokeMethod<void>('setupTunnel', {
      'bundleId': bundleId,
      'endpoint': endpoint,
      'desc': desc,
    });
  }

  @override
  Future<void> connect({
    required String cfg,
    required String endpoint,
    required String desc,
  }) async {
    await methodChannel.invokeMethod<void>('connect', {
      'cfg': cfg,
      'endpoint': endpoint,
      'desc': desc,
    });
  }

  @override
  Future<void> disconnect({
    required String endpoint,
    required String desc,
  }) async {
    await methodChannel.invokeMethod<void>('disconnect', {
      'endpoint': endpoint,
      'desc': desc,
    });
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
