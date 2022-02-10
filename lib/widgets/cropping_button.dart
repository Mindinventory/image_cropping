part of image_cropping;

/// /// [CroppingButton] class shows rotation, done and cancel buttons.
class CroppingButton extends StatefulWidget {
  final state;
  final double? headerMenuSize;
  final BuildContext context;

  /// This property contains Color value.
  /// By passing this property you can set background color, if screen contains blank space.
  final Color? colorForWhiteSpace;

  final ImageProcess imageProcess;
  final double? squareCircleSize;

  /// This is a callback. you have to override and show dialog or etc when image cropping2 is in loading state.
  final Function()? imageLoadingStarted;

  /// This is a callback. you have to override and hide dialog or etc when image cropping2 is ready to show result in cropping2 screen.
  final Function()? imageLoadingFinished;

  /// This is a callback. you have to override and you will get Uint8List as result.
  final Function(dynamic) onImageDoneListener;

  /// Image bytes is use to draw image in device and
  /// if image not fits in device screen then we manage background color
  /// (if you have passed colorForWhiteSpace or else White background) in image cropping2 screen.
  final Uint8List imageBytes;

  const CroppingButton({
    required this.onImageDoneListener,
    required this.imageBytes,
    required this.context,
    required this.imageProcess,
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
        AppButton(
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
        AppButton(
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
        AppButton(
          icon: Icons.close,
          background: Colors.transparent,
          iconColor: Colors.grey.shade800,
          onPress: () async {
            Navigator.pop(widget.context);
          },
          size: widget.headerMenuSize ?? 30.0,
        ),

        /// this [appIconButton] icon for cropping is done.
        AppButton(
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

  /// crop is done, now process for cropping2 the image.
  void _onPressDone() {
    widget.imageLoadingStarted?.call();
    // image view width / height
    final imageViewWidth = imageGlobalKey.globalPaintBounds!.width;
    final imageViewHeight = imageGlobalKey.globalPaintBounds!.height;

    final stackWidth = stackGlobalKey.globalPaintBounds!.width;
    final stackHeight = stackGlobalKey.globalPaintBounds!.height;

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
    final timeStamp=DateTime.now().millisecondsSinceEpoch;
    widget.imageProcess.crop(
      libraryImage,
      imageCropX.toInt(),
      imageCropY.toInt(),
      imageCropWidth.toInt(),
      imageCropHeight.toInt(),
      (image, bytes) {
        print('TAKEN ${DateTime.now().millisecondsSinceEpoch-timeStamp}');
        libraryImage=image;
        widget.imageLoadingFinished?.call();
        widget.onImageDoneListener(bytes);
        Navigator.pop(widget.context);

      },
    );
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
    finalImageBytes = Uint8List.fromList(Library.encodeJpg(libraryImage, quality: 100));
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

  /// [setWhiteColorInImage] we set the background in Library image.
  Library.Image setWhiteColorInImage(Library.Image image, int colorForWhiteSpace, double imageWidth, double imageHeight,
      double renderedImageWidth, double renderedImageHeight, double stackWidth, double stackHeight) {
    bool isWhiteVisibleInScreenWidth = stackWidth > renderedImageWidth;
    bool isWhiteVisibleInScreenHeight = stackHeight > renderedImageHeight;

    double finalImageWidth =
        (isWhiteVisibleInScreenWidth) ? (stackWidth * imageWidth) / renderedImageWidth : imageWidth;
    double finalImageHeight =
        (isWhiteVisibleInScreenHeight) ? (stackHeight * imageHeight) / renderedImageHeight : imageHeight;

    int centreImageWidthPoint =
        ((finalImageWidth / 2) - (((finalImageWidth * renderedImageWidth) / stackWidth) / 2)).toInt();

    int centreImageHeightPoint =
        ((finalImageHeight / 2) - (((finalImageHeight * renderedImageHeight) / stackHeight) / 2)).toInt();

    var whiteImage = Library.Image(finalImageWidth.toInt(), finalImageHeight.toInt());
    whiteImage = whiteImage.fill(colorForWhiteSpace);

    var mergedImage = Library.drawImage(whiteImage, image, dstX: centreImageWidthPoint, dstY: centreImageHeightPoint);
    return mergedImage;
  }
}
