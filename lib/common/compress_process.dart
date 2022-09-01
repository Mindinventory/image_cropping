import 'dart:typed_data';

import 'package:image/image.dart' as Library;

import '../image_cropping.dart';

/// compressing cropping process is done here
class ImageProcess {
  /// image bytes which will be of user's picked image.
  Uint8List imageBytes;

  /// JPEG encoding quality
  final int encodingQuality;

  /// Output format of image
  final OutputImageFormat outputImageFormat;

  ImageProcess(
    this.imageBytes, {
    required this.encodingQuality,
    required this.outputImageFormat,
    String? workerPath, // Used on web only
  });

  /// compressed image is shown for user's reference
  void compress(Function() onBytesLoaded,
      Function(Library.Image) onLibraryImageLoaded) async {
    final libraryImage = getCompressedImage(imageBytes);
    onBytesLoaded.call();
    onLibraryImageLoaded.call(libraryImage);
  }

  /// Image cropping will be done by crop method
  void crop(
      int imageCropX,
      int imageCropY,
      int imageCropWidth,
      int imageCropHeight,
      Function(Library.Image, Uint8List) onImageLoaded) async {
    libraryImage = Library.copyCrop(
      libraryImage,
      imageCropX,
      imageCropY,
      imageCropWidth,
      imageCropHeight,
    );

    onImageLoaded.call(
        libraryImage, Uint8List.fromList(_compressImage(libraryImage)));
  }

  List<int> _compressImage(Library.Image libraryImage) {
    switch (outputImageFormat) {
      case OutputImageFormat.jpg:
        return Library.encodeJpg(
          libraryImage,
          quality: encodingQuality,
        );
      case OutputImageFormat.png:
        return Library.encodePng(libraryImage);
    }
  }

  static Library.Image getCompressedImage(Uint8List _imageData) {
    Library.Image image = Library.decodeImage(_imageData)!;
    if (image.width > 1920) {
      image = Library.copyResize(image, width: 1920);
    } else if (image.height > 1920) {
      image = Library.copyResize(image, height: 1920);
    }
    return image;
  }
}
