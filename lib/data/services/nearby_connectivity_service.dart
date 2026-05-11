import 'dart:typed_data';

import 'package:nearby_connections/nearby_connections.dart';

import '../../core/constants/app_constants.dart';
import '../../domain/entities/peer_endpoint.dart';

class NearbyConnectivityService {
  NearbyConnectivityService({Nearby? nearby}) : _nearby = nearby ?? Nearby();

  final Nearby _nearby;

  Future<bool> startAdvertising({
    required String userName,
    required void Function(String endpointId, ConnectionInfo info)
        onConnectionInitiated,
    required void Function(String endpointId, Status status) onConnectionResult,
    required void Function(String endpointId) onDisconnected,
  }) {
    return _nearby.startAdvertising(
      userName,
      Strategy.P2P_CLUSTER,
      onConnectionInitiated: onConnectionInitiated,
      onConnectionResult: onConnectionResult,
      onDisconnected: onDisconnected,
      serviceId: AppConstants.nearbyServiceId,
    );
  }

  Future<bool> startDiscovery({
    required String userName,
    required void Function(PeerEndpoint endpoint) onEndpointFound,
    required void Function(String endpointId) onEndpointLost,
  }) {
    return _nearby.startDiscovery(
      userName,
      Strategy.P2P_CLUSTER,
      onEndpointFound: (id, name, serviceId) {
        onEndpointFound(
          PeerEndpoint(id: id, name: name, serviceId: serviceId),
        );
      },
      onEndpointLost: onEndpointLost,
      serviceId: AppConstants.nearbyServiceId,
    );
  }

  Future<void> stop() async {
    await Future.sync(_nearby.stopAdvertising);
    await Future.sync(_nearby.stopDiscovery);
  }

  Future<void> acceptConnection({
    required String endpointId,
    required void Function(String endpointId, Payload payload) onPayloadReceived,
    required void Function(String endpointId, PayloadTransferUpdate update)
        onPayloadTransferUpdate,
  }) {
    return _nearby.acceptConnection(
      endpointId,
      onPayLoadRecieved: onPayloadReceived,
      onPayloadTransferUpdate: onPayloadTransferUpdate,
    );
  }

  Future<void> sendBytes({
    required String endpointId,
    required List<int> bytes,
  }) {
    return _nearby.sendBytesPayload(endpointId, Uint8List.fromList(bytes));
  }
}
