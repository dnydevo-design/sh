import 'package:fast_share/core/utils/file_formatters.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('formatBytes keeps transfer sizes readable', () {
    expect(formatBytes(0), '0 B');
    expect(formatBytes(1024), '1 KB');
    expect(formatBytes(1024 * 1024), '1 MB');
  });
}

