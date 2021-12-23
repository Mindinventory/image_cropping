part of image_cropping;

class CroppingButton extends StatefulWidget {
  final state;
  final double? headerMenuSize;
  final BuildContext context;
  final Color? colorForWhiteSpace;
  final double? squareCircleSize;
  final Function()? imageLoadingStarted;
  final Function()? imageLoadingFinished;
  final Function(dynamic) onImageDoneListener;
  late Uint8List imageBytes;

  CroppingButton({
    required this.onImageDoneListener,
    required this.imageBytes,
    required this.context,
    this.state,
    this.headerMenuSize,
    this.colorForWhiteSpace,
    this.squareCircleSize,
    this.imageLoadingStarted,
    this.imageLoadingFinished,
    Key? key,
  }) : super(key: key);

  @override
  State<CroppingButton> createState() => _CroppingButtonState();
}

/// Showing buttons of crop view.
class _CroppingButtonState extends State<CroppingButton> {
  @override
  Widget build(BuildContext context) {
    return Row(
      key: cropMenuGlobalKey,
      mainAxisAlignment: (kIsWeb) ? MainAxisAlignment.end : MainAxisAlignment.spaceAround,
      children: [
        /// this [appIconButton] icon for rotate the image on left side.
        appIconButton(
          icon: Icons.rotate_left,
          background: Colors.transparent,
          iconColor: Colors.grey.shade800,
          onPress: () async {
            imageGlobalKey = GlobalKey();
            changeImageRotation(ImageRotation.LEFT, widget.state);
          },
          size: widget.headerMenuSize ?? 30.0,
        ),

        /// this [appIconButton] icon for rotate the image on right side.
        appIconButton(
          icon: Icons.rotate_right,
          background: Colors.transparent,
          iconColor: Colors.grey.shade800,
          onPress: () async {
            imageGlobalKey = GlobalKey();
            changeImageRotation(ImageRotation.RIGHT, widget.state);
          },
          size: widget.headerMenuSize ?? 30.0,
        ),

        /// this [appIconButton] icon for close the cropping screen.
        appIconButton(
          icon: Icons.close,
          background: Colors.transparent,
          iconColor: Colors.grey.shade800,
          onPress: () async {
            Navigator.pop(widget.context);
          },
          size: widget.headerMenuSize ?? 30.0,
        ),

        /// this [appIconButton] icon for cropping is done.
        appIconButton(
          icon: Icons.done,
          background: Colors.transparent,
          iconColor: Colors.green,
          onPress: () async {
            /// crop is done, and start process for cropping the image from screen.
            _onPressDone();
          },
          size: widget.headerMenuSize ?? 30.0,
        ),
      ],
    );
  }

  /// crop is done, now process for cropping the image.
  void _onPressDone() {
    widget.imageLoadingStarted?.call();
    // image view width / height
    var imageViewWidth = imageGlobalKey.globalPaintBounds!.width;
    var imageViewHeight = imageGlobalKey.globalPaintBounds!.height;

    var stackWidth = stackGlobalKey.globalPaintBounds!.width;
    var stackHeight = stackGlobalKey.globalPaintBounds!.height;

    // _libraryImage = Library.bakeOrientation(_libraryImage);
    libraryImage = setWhiteColorInImage(
      libraryImage,
      widget.colorForWhiteSpace!.value,
      imageWidth,
      imageHeight,
      imageViewWidth,
      imageViewHeight,
      stackWidth,
      stackHeight,
    );

    imageWidth = libraryImage.width.toDouble();
    imageHeight = libraryImage.height.toDouble();

    var leftX = leftTopDX + (widget.squareCircleSize! / 3);
    var leftY = leftTopDY + (widget.squareCircleSize! / 3);

    var imageCropX = (imageWidth * leftX) / stackWidth;
    var imageCropY = (imageHeight * leftY) / stackHeight;
    var imageCropWidth = (imageWidth * cropSizeWidth) / stackWidth;
    var imageCropHeight = (imageHeight * cropSizeHeight) / stackHeight;

    libraryImage = Library.copyCrop(
      libraryImage,
      imageCropX.toInt(),
      imageCropY.toInt(),
      imageCropWidth.toInt(),
      imageCropHeight.toInt(),
    );

    var _libraryUInt8List = Uint8List.fromList(
      Library.encodeJpg(
        libraryImage,
        quality: 100,
      ),
    );

    widget.imageLoadingFinished?.call();
    widget.onImageDoneListener(_libraryUInt8List);
    Navigator.pop(widget.context);
  }

  /// Change the image rotation.
  Future<void> changeImageRotation(ImageRotation imageRotation, state) async {
    widget.imageLoadingStarted?.call();
    if (imageRotation == ImageRotation.LEFT) {
      currentRotationDegreeValue -= 90;
    } else {
      currentRotationDegreeValue += 90;
    }
    libraryImage = Library.copyRotate(libraryImage, currentRotationDegreeValue);
    widget.imageBytes = Uint8List.fromList(Library.encodeJpg(libraryImage, quality: 100));
    finalImageBytes = widget.imageBytes;
    _setImageHeightWidth();
    widget.imageLoadingFinished?.call();
    currentRotationDegreeValue = 0;
    state(() {});
  }

  /// set image width & height.
  void _setImageHeightWidth() {
    imageWidth = libraryImage.width.toDouble();
    imageHeight = libraryImage.height.toDouble();
  }
}
