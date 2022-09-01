library image_cropping;

import 'dart:math';
import 'dart:typed_data';

import 'package:equatable/equatable.dart';
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
  static Future<dynamic> cropImage(
      {required BuildContext context,
      required Uint8List imageBytes,
      required Function(dynamic) onImageDoneListener,
      VoidCallback? onImageStartLoading,
      VoidCallback? onImageEndLoading,
      CropAspectRatio? selectedImageRatio,
      bool visibleOtherAspectRatios = true,
      double squareBorderWidth = 2,
      List<CropAspectRatio>? customAspectRatios,
      Color squareCircleColor = Colors.orange,
      double squareCircleSize = 30,
      Color defaultTextColor = Colors.black,
      Color selectedTextColor = Colors.orange,
      Color colorForWhiteSpace = Colors.white,
      int encodingQuality = 100,
      String? workerPath,
      bool isConstrain = true,
      bool makeDarkerOutside = true,
      EdgeInsets? imageEdgeInsets = const EdgeInsets.all(10),
      bool rootNavigator = false,
      Key? key}) {
    /// Here, we are pushing a image cropping2 screen.
    return Navigator.of(context,rootNavigator: rootNavigator).push(
      MaterialPageRoute(
        builder: (_context) => ImageCroppingScreen(
            _context,
            imageBytes,
            onImageStartLoading,
            onImageEndLoading,
            onImageDoneListener,
            colorForWhiteSpace,
            customAspectRatios: customAspectRatios,
            selectedImageRatio: selectedImageRatio,
            visibleOtherAspectRatios: visibleOtherAspectRatios,
            squareCircleColor: squareCircleColor,
            squareBorderWidth: squareBorderWidth,
            squareCircleSize: squareCircleSize,
            defaultTextColor: defaultTextColor,
            selectedTextColor: selectedTextColor,
            encodingQuality: encodingQuality,
            workerPath: workerPath,
          isConstrain: isConstrain,
          makeDarkerOutside: makeDarkerOutside,
          imageEdgeInsets: imageEdgeInsets,),
      ),
    );
  }
}

class ImageCroppingScreen extends StatefulWidget {
  /// context is use to get height & width of screen and pop this screen.
  final BuildContext _context;

  /// This property contains ImageRatio value. You can set the initialized a  spect ratio when starting the cropper by passing a value of ImageRatio. default value is `ImageRatio.FREE`
  final CropAspectRatio? selectedImageRatio;

  /// This property will be used tom perform image compression before showing up
  late final ImageProcess process;

  /// This property contains boolean value. If this properties is true then it shows all other aspect ratios in cropping2 screen. default value is `true`.
  final bool visibleOtherAspectRatios;

  /// This is a callback. you have to override and show dialog or etc when image cropping2 is in loading state.
  final VoidCallback? _onImageStartLoading;

  /// This is a callback. you have to override and hide dialog or etc when image cropping2 is ready to show result in cropping2 screen.
  final VoidCallback? _onImageEndLoading;

  /// This is a callback. you have to override and you will get Uint8List as result.
  final Function(dynamic) _onImageDoneListener;

  /// This property contains double value. You can change square border width by passing this value.
  final double squareBorderWidth;

  /// This property contains Color value. You can change square circle color by passing this value.
  final Color squareCircleColor;

  /// This property contains Color value. By passing this property you can set aspect ratios color which are unselected.
  final Color defaultTextColor;

  /// This property contains Color value. By passing this property you can set aspect ratios color which is selected.
  final Color selectedTextColor;

  /// This property contains Color value. By passing this property you can set background color, if screen contains blank space.
  final Color _colorForWhiteSpace;

  /// This property contains Square circle(dot) size
  final double squareCircleSize;

  /// This property contains Header menu icon size
  final double headerMenuSize = 30;

  /// JPEG encoding quality of the cropped image (between 0 and 100, with 100 being the best quality)
  int encodingQuality;

  /// Path to your worker js file. You may want to rename it if you use several
  /// workers. Will use 'worker.js' if nothing specified.
  String? workerPath;

  /// This property is inner insets of image
  final EdgeInsets? imageEdgeInsets;

  /// This property makes SquareCircle can't go outside of image
  final bool isConstrain;

  /// This property makes square's outside darker
  final bool makeDarkerOutside;

  final List<CropAspectRatio>? customAspectRatios;


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
      required this.customAspectRatios,
      required this.squareCircleColor,
      required this.defaultTextColor,
      required this.selectedTextColor,
      required this.squareCircleSize,
      this.encodingQuality = 100,
      this.workerPath,
      required this.isConstrain,
      required this.makeDarkerOutside,
      required this.imageEdgeInsets,
      Key? key})
      : super(key: key) {
    process = ImageProcess(
      _imageBytes,
      encodingQuality: encodingQuality,
      workerPath: workerPath,
    );
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
                          makeDarkerOutside: widget.makeDarkerOutside,
                          isConstrain: widget.isConstrain,
                          imageEdgeInsets: widget.imageEdgeInsets,
                        ),
                        ShowCropImageRatios(
                          state: state,
                          defaultTextColor: widget.defaultTextColor,
                          selectedImageRatio: widget.selectedImageRatio,
                          selectedTextColor: widget.selectedTextColor,
                          visibleOtherAspectRatios:
                              widget.visibleOtherAspectRatios,
                          customAspectRatios: widget.customAspectRatios,
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
      return const Center(child: CircularProgressIndicator());
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

      SetImageRatio.setImageRatio(
          null, widget.selectedImageRatio ?? CropAspectRatio.free());
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
      WidgetsBinding.instance.addPostFrameCallback((timeStamp) async {
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

class CropAspectRatio extends Equatable {
  final int ratioX;
  final int ratioY;

  const CropAspectRatio({
    required this.ratioX,
    required this.ratioY,
  });
  factory CropAspectRatio.free() {
    return CropAspectRatio(ratioX: 0, ratioY: 0);
  }
  factory CropAspectRatio.fromRation(ImageRatio ratio) {
    late int ratioX, ratioY;
    switch (ratio) {
      case ImageRatio.RATIO_1_1:
        ratioX = 1;
        ratioY = 1;
        break;
      case ImageRatio.RATIO_1_2:
        ratioX = 1;
        ratioY = 2;
        break;
      case ImageRatio.RATIO_3_2:
        ratioX = 3;
        ratioY = 2;
        break;
      case ImageRatio.RATIO_4_3:
        ratioX = 4;
        ratioY = 3;
        break;
      case ImageRatio.RATIO_16_9:
        ratioX = 16;
        ratioY = 9;
        break;
      case ImageRatio.FREE:
        ratioX = 0;
        ratioY = 0;
        break;
    }
    return CropAspectRatio(
      ratioX: ratioX,
      ratioY: ratioY,
    );
  }
  bool equals(ImageRatio imageRatio) {
    switch (imageRatio) {
      case ImageRatio.RATIO_1_1:
        return ratioX == 1 && ratioY == 1;
      case ImageRatio.RATIO_1_2:
        return ratioX == 1 && ratioY == 2;
      case ImageRatio.RATIO_3_2:
        return ratioX == 3 && ratioY == 2;
      case ImageRatio.RATIO_4_3:
        return ratioX == 4 && ratioY == 3;
      case ImageRatio.RATIO_16_9:
        return ratioX == 16 && ratioY == 9;
      case ImageRatio.FREE:
        return ratioX == 0 && ratioY == 0;
    }
  }

  @override
  List<Object?> get props => [ratioX, ratioY];
}
