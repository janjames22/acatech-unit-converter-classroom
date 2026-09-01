import 'dart:convert';
import 'dart:io';
import 'dart:math' as math;
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('PWA branding inventory has the required dimensions', () async {
    final expectedSizes = <String, ui.Size>{
      'web/favicon.png': const ui.Size(32, 32),
      'web/icons/Icon-192.png': const ui.Size(192, 192),
      'web/icons/Icon-512.png': const ui.Size(512, 512),
      'web/icons/Icon-maskable-192.png': const ui.Size(192, 192),
      'web/icons/Icon-maskable-512.png': const ui.Size(512, 512),
      'assets/branding/app_icon_master.png': const ui.Size(1024, 1024),
      'assets/branding/app_icon_maskable_master.png': const ui.Size(1024, 1024),
      'assets/branding/acatech_logo_full.png': const ui.Size(1200, 689),
    };

    for (final entry in expectedSizes.entries) {
      final image = await _decodePng(entry.key);
      expect(
        ui.Size(image.width.toDouble(), image.height.toDouble()),
        entry.value,
        reason: entry.key,
      );
      image.dispose();
    }
  });

  test('Android launcher density assets use the mask-safe artwork', () async {
    final expectedSizes = <String, int>{
      'android/app/src/main/res/mipmap-mdpi/ic_launcher.png': 48,
      'android/app/src/main/res/mipmap-hdpi/ic_launcher.png': 72,
      'android/app/src/main/res/mipmap-xhdpi/ic_launcher.png': 96,
      'android/app/src/main/res/mipmap-xxhdpi/ic_launcher.png': 144,
      'android/app/src/main/res/mipmap-xxxhdpi/ic_launcher.png': 192,
    };

    for (final entry in expectedSizes.entries) {
      final image = await _decodePng(entry.key);
      expect(image.width, entry.value, reason: entry.key);
      expect(image.height, entry.value, reason: entry.key);
      image.dispose();
    }
  });

  test('regular and maskable PWA artwork are distinct', () async {
    expect(
      await File('web/icons/Icon-192.png').readAsBytes(),
      isNot(await File('web/icons/Icon-maskable-192.png').readAsBytes()),
    );
    expect(
      await File('web/icons/Icon-512.png').readAsBytes(),
      isNot(await File('web/icons/Icon-maskable-512.png').readAsBytes()),
    );
  });

  test(
    'maskable artwork remains inside the central safe-zone circle',
    () async {
      for (final path in <String>[
        'web/icons/Icon-maskable-192.png',
        'web/icons/Icon-maskable-512.png',
      ]) {
        final image = await _decodePng(path);
        final data = await image.toByteData(format: ui.ImageByteFormat.rawRgba);
        expect(data, isNotNull, reason: path);

        final pixels = data!.buffer.asUint8List();
        final centerX = (image.width - 1) / 2;
        final centerY = (image.height - 1) / 2;
        final safeRadius = image.width * 0.4;
        var maximumDistance = 0.0;

        for (var y = 0; y < image.height; y++) {
          for (var x = 0; x < image.width; x++) {
            final offset = (y * image.width + x) * 4;
            if (!_isVisibleLogoPixel(pixels, offset)) {
              continue;
            }
            maximumDistance = math.max(
              maximumDistance,
              math.sqrt(math.pow(x - centerX, 2) + math.pow(y - centerY, 2)),
            );
          }
        }

        expect(
          maximumDistance,
          lessThanOrEqualTo(safeRadius),
          reason: '$path exceeds its maskable safe zone',
        );
        image.dispose();
      }
    },
  );

  test(
    'manifest declares ACATECH identity and separate icon purposes',
    () async {
      final manifest =
          jsonDecode(await File('web/manifest.json').readAsString())
              as Map<String, Object?>;

      expect(manifest['name'], 'ACATECH Aviation Tools');
      expect(manifest['short_name'], 'ACATECH Tools');
      expect(manifest['theme_color'], '#176B5B');
      expect(manifest['background_color'], '#FFFFFF');
      expect(manifest['display'], 'standalone');

      final icons = (manifest['icons']! as List<Object?>)
          .cast<Map<String, Object?>>();
      expect(
        icons
            .where((icon) => icon['purpose'] == 'any')
            .map((icon) => icon['src']),
        containsAll(<String>['icons/Icon-192.png', 'icons/Icon-512.png']),
      );
      expect(
        icons
            .where((icon) => icon['purpose'] == 'maskable')
            .map((icon) => icon['src']),
        containsAll(<String>[
          'icons/Icon-maskable-192.png',
          'icons/Icon-maskable-512.png',
        ]),
      );
    },
  );

  test(
    'web loading surface uses and dismisses the ACATECH full logo',
    () async {
      final index = await File('web/index.html').readAsString();
      final worker = await File('web/sw.js').readAsString();

      expect(index, contains('branding/acatech-logo-full.png'));
      expect(index, contains('flutter-first-frame'));
      expect(
        index,
        contains("document.getElementById('app-loading')?.remove()"),
      );
      expect(worker, contains("'./branding/acatech-logo-full.png'"));
      expect(
        worker,
        contains("'./assets/assets/branding/acatech_logo_full.png'"),
      );
    },
  );
}

Future<ui.Image> _decodePng(String path) async {
  final bytes = await File(path).readAsBytes();
  final codec = await ui.instantiateImageCodec(Uint8List.fromList(bytes));
  final frame = await codec.getNextFrame();
  codec.dispose();
  return frame.image;
}

bool _isVisibleLogoPixel(Uint8List pixels, int offset) {
  const nearWhite = 245;
  return pixels[offset] < nearWhite ||
      pixels[offset + 1] < nearWhite ||
      pixels[offset + 2] < nearWhite;
}
