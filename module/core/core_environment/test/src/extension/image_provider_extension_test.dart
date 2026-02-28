import 'dart:ui';
import 'package:core_environment/core_environment.dart';
import 'package:flutter/widgets.dart' hide Image;
import 'package:flutter_test/flutter_test.dart';

// Creates a 1x1 transparent Image for testing
Future<Image> createTestImage() async {
  final recorder = PictureRecorder();
  final canvas = Canvas(recorder);
  canvas.drawRect(const Rect.fromLTRB(0, 0, 1, 1), Paint()..color = const Color(0x00000000));
  final picture = recorder.endRecording();
  return picture.toImage(1, 1);
}

class TestImageProvider extends ImageProvider<TestImageProvider> {
  final Future<Image> imageFuture;

  TestImageProvider(this.imageFuture);

  @override
  Future<TestImageProvider> obtainKey(ImageConfiguration configuration) {
    return Future.value(this);
  }

  @override
  ImageStreamCompleter loadImage(TestImageProvider key, ImageDecoderCallback decode) {
    return OneFrameImageStreamCompleter(
      imageFuture.then((image) => ImageInfo(image: image, scale: 1.0)),
    );
  }
}

void main() {
  testWidgets('ImageProviderExtension returns ImageInfo', (tester) async {
    final image = await createTestImage();
    final provider = TestImageProvider(Future.value(image));
    
    final info = await provider.imageInfo;
    
    expect(info, isNotNull);
    expect(info.image, isNotNull);
    expect(info.image.width, equals(1));
    expect(info.image.height, equals(1));
    expect(info.scale, equals(1.0));
  });
}
