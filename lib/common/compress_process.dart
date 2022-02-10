import 'dart:typed_data';

import 'package:image/image.dart' as Library;

class ImageProcess {
  // compressing cropping process is done here
  Uint8List imageBytes;

  ImageProcess(this.imageBytes);

  void compress(Function() onBytesLoaded, Function(Library.Image) onLibraryImageLoaded) async {
    final libraryImage = getCompressedImage(imageBytes);
    onBytesLoaded.call();
    onLibraryImageLoaded.call(libraryImage);
  }

  void crop(Library.Image libraryImage, int imageCropX, int imageCropY, int imageCropWidth, int imageCropHeight,
      Function(Library.Image, Uint8List) onImageLoaded) async {
    libraryImage = Library.copyCrop(
      libraryImage,
      imageCropX,
      imageCropY,
      imageCropWidth,
      imageCropHeight,
    );

    final _libraryUInt8List = Uint8List.fromList(
      Library.encodeJpg(
        libraryImage,
        quality: 100,
      ),
    );
    onImageLoaded.call(libraryImage, _libraryUInt8List);
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
