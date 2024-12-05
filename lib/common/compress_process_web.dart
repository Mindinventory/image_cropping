import 'dart:html' as html;
import 'dart:typed_data';

import 'package:image/image.dart';
import 'package:image_cropping/image_cropping.dart';

/// compressing cropping process for web is done here
class ImageProcess {
  /// web worker to do multithreaded computation.
  late final html.Worker worker;

  /// JPEG encoding quality, not used yet
  final int encodingQuality;

  /// Output format of image
  final OutputImageFormat outputImageFormat;

  /// image bytes which will be of user's picked image.
  Uint8List imageBytes;

  ImageProcess(this.imageBytes, {required this.encodingQuality, String? workerPath, required this.outputImageFormat}) {
    worker = html.Worker(workerPath ?? 'worker.js');
  }

  /// compressed image is shown for user's reference
  void compress(Function() onBytesLoaded, Function(Image) onLibraryImageLoaded) async {
    worker.postMessage([0, imageBytes]);
    final event = await worker.onMessage.first;
    final List<int> intList = event.data[0];
    imageBytes = Uint8List.fromList(intList);
    onBytesLoaded.call();
    Uint8List byteData = Uint8List.fromList(imageBytes);
    int width = byteData.buffer.asByteData().getInt32(0, Endian.big);
    int height = byteData.buffer.asByteData().getInt32(4, Endian.big);

    final image = await Image.fromBytes(width: width, height: height, bytes: imageBytes.buffer);
    onLibraryImageLoaded.call(image);
  }

  /// Image cropping will be done by crop method
  void crop(int imageCropX, int imageCropY, int imageCropWidth, int imageCropHeight,
      Function(Image, Uint8List) onImageLoaded) async {
    worker.postMessage([
      1,
      libraryImage.getBytes(),
      libraryImage.width.toInt(),
      libraryImage.height.toInt(),
      imageCropX,
      imageCropY,
      imageCropWidth,
      imageCropHeight,
      encodingQuality,
      outputImageFormat.index
    ]);
    final event = await worker.onMessage.first;
    onImageLoaded.call(
        Image.fromBytes(width: imageCropWidth, height: imageCropHeight, bytes: event.data[0], order: ChannelOrder.rgb),
        event.data[1]);
  }
}
