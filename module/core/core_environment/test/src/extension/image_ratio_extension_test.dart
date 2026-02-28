import 'dart:ui';
import 'package:core_environment/core_environment.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('ImageRatioExtension ratio calculates correctly', () async {
    // Generate a simple Image object via PictureRecorder
    final recorder = PictureRecorder();
    final canvas = Canvas(recorder);
    canvas.drawRect(const Rect.fromLTRB(0, 0, 100, 50), Paint()..color = const Color(0xFF000000));
    final picture = recorder.endRecording();
    // Width 100, Height 50 -> ratio = height/width = 50/100 = 0.5
    final image = await picture.toImage(100, 50);
    
    expect(image.ratio, equals(0.5));
  });
}
