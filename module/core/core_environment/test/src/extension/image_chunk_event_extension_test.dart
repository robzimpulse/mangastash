import 'package:core_environment/core_environment.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('ProgressImageChunkEventExtension', () {
    test('progress calculates correctly', () {
      const event = ImageChunkEvent(
        cumulativeBytesLoaded: 50,
        expectedTotalBytes: 100,
      );
      
      expect(event.progress, equals(0.5));
    });

    test('progress returns null if expectedTotalBytes is null', () {
      const event = ImageChunkEvent(
        cumulativeBytesLoaded: 50,
        expectedTotalBytes: null,
      );
      
      expect(event.progress, isNull);
    });

    test('progress returns 0 if expectedTotalBytes is 0', () {
      const event = ImageChunkEvent(
        cumulativeBytesLoaded: 50,
        expectedTotalBytes: 0,
      );
      
      expect(event.progress, equals(0.0));
    });
    
    test('progress handles cumulative larger than total', () {
      const event = ImageChunkEvent(
        cumulativeBytesLoaded: 150,
        expectedTotalBytes: 100,
      );
      
      // The implementation allows > 1.0 based on simple division
      expect(event.progress, equals(1.5));
    });
  });
}
