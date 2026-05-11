import 'dart:io';

class NetworkAddressService {
  const NetworkAddressService();

  Future<String> preferredIPv4Address() async {
    final interfaces = await NetworkInterface.list(
      includeLoopback: false,
      type: InternetAddressType.IPv4,
    );

    for (final interface in interfaces) {
      for (final address in interface.addresses) {
        final value = address.address;
        if (!value.startsWith('169.254') && value != '0.0.0.0') {
          return value;
        }
      }
    }
    return InternetAddress.loopbackIPv4.address;
  }
}

