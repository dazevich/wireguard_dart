import 'dart:convert';

import 'package:wireguard_dart/src/interface_config.dart';
import 'package:wireguard_dart/src/peer_config.dart';

class TunnelConfig {
  final InterfaceConfig interface;
  final PeerConfig peer;

  TunnelConfig({
    required this.interface,
    required this.peer,
  });

  String get id => base64Encode(utf8.encode('${peer.name}${peer.endpoint}'));

  @override
  String toString() {
    final buffer = StringBuffer();
    buffer.writeln(interface.toString());
    buffer.write(peer.toString());
    return buffer.toString();
  }

  Map<String, dynamic> toJson() => {
        'interface': interface.toJson(),
        'peer': peer.toJson(),
      };
}
