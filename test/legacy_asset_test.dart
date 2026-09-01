import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  test('legacy baby icon is absent and no Dart source references it', () {
    const legacyAssetName =
        'baby_'
        'icon.png';
    expect(File('assets/images/$legacyAssetName').existsSync(), isFalse);

    final dartFiles = Directory('lib')
        .listSync(recursive: true)
        .whereType<File>()
        .where((file) => file.path.endsWith('.dart'));
    final references = dartFiles
        .where((file) => file.readAsStringSync().contains(legacyAssetName))
        .map((file) => file.path)
        .toList();

    expect(references, isEmpty);
  });
}
