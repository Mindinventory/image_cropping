import 'dart:html' as html;
import 'dart:typed_data';

import 'package:image/image.dart';

/// compressing cropping process for web is done here
class ImageProcess {
  /// web worker to do multithreaded computation.
  late final html.Worker worker;

  /// image bytes which will be of user's picked image.
  Uint8List imageBytes;

  ImageProcess(this.imageBytes) {
    worker = html.Worker('worker.js');
  }

  /// compressed image is shown for user's reference
  void compress(
      Function() onBytesLoaded, Function(Image) onLibraryImageLoaded) async {
    worker.postMessage([0, imageBytes]);
    final event = await worker.onMessage.first;
    final List<int> intList = event.data[0];
    imageBytes = Uint8List.fromList(intList);
    onBytesLoaded.call();
    final image = await Image.fromBytes(
        event.data[1], event.data[2], event.data[3],
        channels: Channels.rgb);
    onLibraryImageLoaded.call(image);
  }

  /// Image cropping will be done by crop method
  void crop(
      Image libraryImage,
      int imageCropX,
      int imageCropY,
      int imageCropWidth,
      int imageCropHeight,
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
    ]);
    final event = await worker.onMessage.first;
    onImageLoaded.call(
        Image.fromBytes(imageCropWidth, imageCropHeight, event.data[0],
            channels: Channels.rgb),
        event.data[1]);
  }
}
