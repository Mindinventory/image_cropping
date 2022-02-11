library image_cropping;

import 'dart:typed_data';

import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:image/image.dart' as Library;

import 'common/compress_process.dart'
    if (dart.library.html) 'common/compress_process_web.dart';
import 'constant/strings.dart';

part 'common/set_image_ratio.dart';

part 'constant/enums.dart';

part 'constant/global_positions.dart';

part 'constant/keys.dart';

part 'util/widget_bound.dart';

part 'widgets/app_button.dart';

part 'widgets/crop_image_ratios.dart';

part 'widgets/crop_image_view.dart';

part 'widgets/cropping_button.dart';

class ImageCropping {
  static void cropImage(
      {required BuildContext context,
      required Uint8List imageBytes,
      required Function(dynamic) onImageDoneListener,
      VoidCallback? onImageStartLoading,
      VoidCallback? onImageEndLoading,
      ImageRatio selectedImageRatio = ImageRatio.FREE,
      bool visibleOtherAspectRatios = true,
      double squareBorderWidth = 2,
      Color squareCircleColor = Colors.orange,
      double squareCircleSize = 30,
      Color defaultTextColor = Colors.black,
      Color selectedTextColor = Colors.orange,
      Color colorForWhiteSpace = Colors.white,
      Key? key}) {
    /// Here, we are pushing a image cropping2 screen.
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_context) => ImageCroppingScreen(
          _context,
          imageBytes,
          onImageStartLoading,
          onImageEndLoading,
          onImageDoneListener,
          colorForWhiteSpace,
          selectedImageRatio: selectedImageRatio,
          visibleOtherAspectRatios: visibleOtherAspectRatios,
          squareCircleColor: squareCircleColor,
          squareBorderWidth: squareBorderWidth,
          squareCircleSize: squareCircleSize,
          defaultTextColor: defaultTextColor,
          selectedTextColor: selectedTextColor,
        ),
      ),
    );
  }
}

class ImageCroppingScreen extends StatefulWidget {
  /// context is use to get height & width of screen and pop this screen.
  BuildContext _context;

  /// This property contains ImageRatio value. You can set the initialized a  spect ratio when starting the cropper by passing a value of ImageRatio. default value is `ImageRatio.FREE`
  ImageRatio selectedImageRatio = ImageRatio.FREE;

  /// This property will be used tom perform image compression before showing up
  late final ImageProcess process;

  /// This property contains boolean value. If this properties is true then it shows all other aspect ratios in cropping2 screen. default value is `true`.
  bool visibleOtherAspectRatios = true;

  /// This is a callback. you have to override and show dialog or etc when image cropping2 is in loading state.
  VoidCallback? _onImageStartLoading;

  /// This is a callback. you have to override and hide dialog or etc when image cropping2 is ready to show result in cropping2 screen.
  VoidCallback? _onImageEndLoading;

  /// This is a callback. you have to override and you will get Uint8List as result.
  Function(dynamic) _onImageDoneListener;

  /// This property contains double value. You can change square border width by passing this value.
  double squareBorderWidth;

  /// This property contains Color value. You can change square circle color by passing this value.
  Color squareCircleColor;

  /// This property contains Color value. By passing this property you can set aspect ratios color which are unselected.
  Color defaultTextColor;

  /// This property contains Color value. By passing this property you can set aspect ratios color which is selected.
  Color selectedTextColor;

  /// This property contains Color value. By passing this property you can set background color, if screen contains blank space.
  Color _colorForWhiteSpace;

  /// This property contains Square circle(dot) size
  double squareCircleSize = 30;

  /// This property contains Header menu icon size
  double headerMenuSize = 30;

  ImageCroppingScreen(
      this._context,
      Uint8List _imageBytes,
      this._onImageStartLoading,
      this._onImageEndLoading,
      this._onImageDoneListener,
      this._colorForWhiteSpace,
      {required this.selectedImageRatio,
      required this.visibleOtherAspectRatios,
      required this.squareBorderWidth,
      required this.squareCircleColor,
      required this.defaultTextColor,
      required this.selectedTextColor,
      required this.squareCircleSize,
      Key? key})
      : super(key: key) {
    process = ImageProcess(_imageBytes);
  }

  @override
  _ImageCroppingScreenState createState() => _ImageCroppingScreenState();
}

class _ImageCroppingScreenState extends State<ImageCroppingScreen> {
  @override
  void initState() {
    /// Generate Image from image bytes.

    super.initState();
    _generateLibraryImage();
  }

  @override
  Widget build(BuildContext context) {
    /// Wait till image creates from image bytes.
    if (finalImageBytes != null) {
      return LayoutBuilder(
        builder: (context, constraint) {
          _setOrientation();
          return StatefulBuilder(
            builder: (context, state) {
              _setTopHeight();
              return SafeArea(
                child: Material(
                  child: Container(
                    width: deviceWidth,
                    child: Column(
                      children: [
                        CroppingButton(
                          imageBytes: widget.process.imageBytes,
                          context: context,
                          imageProcess: widget.process,
                          onImageDoneListener: widget._onImageDoneListener,
                          colorForWhiteSpace: widget._colorForWhiteSpace,
                          headerMenuSize: widget.headerMenuSize,
                          imageLoadingStarted: widget._onImageStartLoading,
                          imageLoadingFinished: widget._onImageEndLoading,
                          squareCircleSize: widget.squareCircleSize,
                          state: state,
                        ),
                        CroppingImageView(
                          state: state,
                          squareCircleSize: widget.squareCircleSize,
                          colorForWhiteSpace: widget._colorForWhiteSpace,
                          squareBorderWidth: widget.squareBorderWidth,
                          squareCircleColor: widget.squareCircleColor,
                        ),
                        ShowCropImageRatios(
                          state: state,
                          defaultTextColor: widget.defaultTextColor,
                          selectedImageRatio: widget.selectedImageRatio,
                          selectedTextColor: widget.selectedTextColor,
                          visibleOtherAspectRatios:
                              widget.visibleOtherAspectRatios,
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          );
        },
      );
    } else {
      return Container();
    }
  }

  /// Generate image from image bytes.
  void _generateLibraryImage() async {
    /// Set device height & width from image.

    /// Set Image ratio for cropping2 the image.

    /// Set default button position (left, right, top, bottom) in center of the screen.

    widget.process.compress(() {
      widget._onImageEndLoading?.call();
      finalImageBytes = widget.process.imageBytes;
      _setDeviceHeightWidth();

      SetImageRatio.setImageRatio(widget.selectedImageRatio);
      SetImageRatio.setDefaultButtonPosition();
      setState(() {});
    }, (image) {
      libraryImage = image;
      _setImageHeightWidth();
      setState(() {});
    });
  }

  /// set device width & height
  void _setDeviceHeightWidth() {
    deviceWidth = MediaQuery.of(widget._context).size.width;
    deviceHeight = MediaQuery.of(widget._context).size.height;
  }

  /// set image width & height.
  void _setImageHeightWidth() {
    imageWidth = libraryImage.width.toDouble();
    imageHeight = libraryImage.height.toDouble();
  }

  /// set topview height(means screen top point to stack starting point height.)
  void _setTopHeight() {
    if (topViewHeight == 0) {
      WidgetsBinding.instance?.addPostFrameCallback((timeStamp) async {
        topViewHeight = stackGlobalKey.globalPaintBounds?.top ?? 0;
      });
    }
  }

  /// set orientation for landscape and portrait mode.
  void _setOrientation() {
    Orientation currentOrientation = MediaQuery.of(context).orientation;
    if (currentOrientation == Orientation.landscape) {
      _setDeviceHeightWidth();
      SetImageRatio.setDefaultButtonPosition();
    } else if (currentOrientation == Orientation.portrait) {
      _setDeviceHeightWidth();
      SetImageRatio.setDefaultButtonPosition();
    }
  }
}
