import 'package:wireguard_dart/src/interface_config.dart';
import 'package:wireguard_dart/src/peer_config.dart';

class TunnelConfig {
  final InterfaceConfig interface;
  final PeerConfig peer;

  TunnelConfig({
    required this.interface,
    required this.peer,
  });

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
