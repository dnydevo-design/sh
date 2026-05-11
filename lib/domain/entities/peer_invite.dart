import 'dart:convert';

enum PeerTransport {
  socket,
  nearby,
  hotspot,
}

class PeerInvite {
  const PeerInvite({
    required this.sessionId,
    required this.host,
    required this.port,
    required this.transport,
    required this.displayName,
  });

  final String sessionId;
  final String host;
  final int port;
  final PeerTransport transport;
  final String displayName;

  Map<String, Object?> toJson() {
    return {
      'sessionId': sessionId,
      'host': host,
      'port': port,
      'transport': transport.name,
      'displayName': displayName,
    };
  }

  String toQrPayload() {
    final payload = base64Url.encode(utf8.encode(jsonEncode(toJson())));
    return 'fastshare://join/$payload';
  }

  static PeerInvite fromQrPayload(String payload) {
    final marker = payload.trim();
    final encoded = marker.startsWith('fastshare://join/')
        ? marker.substring('fastshare://join/'.length)
        : marker;
    final json = jsonDecode(utf8.decode(base64Url.decode(encoded)));
    final map = json as Map<String, Object?>;
    final transportName = map['transport'] as String? ?? PeerTransport.socket.name;
    return PeerInvite(
      sessionId: map['sessionId'] as String,
      host: map['host'] as String,
      port: (map['port'] as num).toInt(),
      transport: PeerTransport.values.firstWhere(
        (transport) => transport.name == transportName,
        orElse: () => PeerTransport.socket,
      ),
      displayName: map['displayName'] as String? ?? 'Fast Share',
    );
  }
}

