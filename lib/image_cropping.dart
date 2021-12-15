import 'dart:typed_data';

import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image/image.dart' as Library;

import 'common/app_button.dart';
import 'constant/enums.dart';
import 'util/image_utils.dart';
import 'util/widget_bound.dart';

class ImageCropping {
  static void cropImage(
      BuildContext _context,
      Uint8List _imageBytes,
      Function() _onImageStartLoading,
      Function() _onImageEndLoading,
      Function(dynamic) _onImageDoneListener,
      {ImageRatio selectedImageRatio = ImageRatio.FREE,
      bool visibleOtherAspectRatios = true,
      double squareBorderWidth = 2,
      Color squareCircleColor = Colors.orange,
      double squareCircleSize = 30,
      Color defaultTextColor = Colors.black,
      Color selectedTextColor = Colors.orange,
      Color colorForWhiteSpace = Colors.white,
      Key? key}) {
    /// Here, we are pushing a image cropping screen.
    Navigator.of(_context).push(
      MaterialPageRoute(
        builder: (_context) => ImageCroppingScreen(
          _context,
          _imageBytes,
          _onImageStartLoading,
          _onImageEndLoading,
          _onImageDoneListener,
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

  /// [_imageBytes] is use to draw image in device and if image not fits in device screen then we manage background color(if you have passed colorForWhiteSpace or else White background) in image cropping screen.
  late Uint8List _imageBytes;

  /// This property contains ImageRatio value. You can set the initialized a  spect ratio when starting the cropper by passing a value of ImageRatio. default value is `ImageRatio.FREE`
  ImageRatio selectedImageRatio = ImageRatio.FREE;

  /// This property contains boolean value. If this properties is true then it shows all other aspect ratios in cropping screen. default value is `true`.
  bool visibleOtherAspectRatios = true;

  /// This is a callback. you have to override and show dialog or etc when image cropping is in loading state.
  void Function() _onImageStartLoading;

  /// This is a callback. you have to override and hide dialog or etc when image cropping is ready to show result in cropping screen.
  void Function() _onImageEndLoading;

  /// This is a callback. you have to override and you will get Uint8List as result.
  void Function(dynamic) _onImageDoneListener;

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
      this._imageBytes,
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
      : super(key: key);

  @override
  _ImageCroppingScreenState createState() => _ImageCroppingScreenState();
}

class _ImageCroppingScreenState extends State<ImageCroppingScreen> {
  double _leftTopDX = 0;
  double _leftTopDY = 0;

  double _leftBottomDX = 0;
  double _leftBottomDY = 0;

  double _rightTopDX = 0;
  double _rightTopDY = 0;

  double _rightBottomDX = 0;
  double _rightBottomDY = 0;

  double _startedDX = 0;
  double _startedDY = 0;

  double _imageWidth = 0;
  double _imageHeight = 0;
  double _deviceWidth = 0;
  double _deviceHeight = 0;

  double _defaultCropSize = 100;
  double _cropSizeWidth = 100;
  double _cropSizeHeight = 100;
  double _minCropSizeWidth = 20;
  double _minCropSizeHeight = 20;

  double _currentRatioWidth = 0;
  double _currentRatioHeight = 0;

  var _currentRotationValue = 0;
  var _currentRotationDegreeValue = 0;

  var _stackGlobalKey = GlobalKey();
  GlobalKey _imageGlobalKey = GlobalKey();
  GlobalKey _leftTopGlobalKey = GlobalKey();
  GlobalKey _leftBottomGlobalKey = GlobalKey();
  GlobalKey _rightTopGlobalKey = GlobalKey();
  GlobalKey _rightBottomGlobalKey = GlobalKey();
  GlobalKey _cropMenuGlobalKey = GlobalKey();

  late Library.Image _libraryImage;
  Uint8List? _finalImageBytes;

  double _imageViewMaxHeight = 0;
  double _topViewHeight = 0;

  @override
  void initState() {
    /// Show Image Loading.
    _imageLoadingStarted();

    /// Set device orientation
    _setDeviceOrientation();

    /// Generate Image from image bytes.
    _generateLibraryImage();

    /// Set device height & width from image.
    _setDeviceHeightWidth();

    /// Set Image ratio for cropping the image.
    _setImageRatio(widget.selectedImageRatio);

    /// Set default button position (left, right, top, bottom) in center of the screen.
    _setDefaultButtonPosition();

    /// Image loading finished.
    _imageLoadingFinished();

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    /// Wait till image creates from image bytes.
    if (_finalImageBytes != null) {
      return StatefulBuilder(
        builder: (context, state) {
          _setTopHeight();
          return SafeArea(
            child: Material(
              child: Container(
                width: _deviceWidth,
                child: Column(
                  children: [
                    _showCroppingButtons(state),
                    _showCropImageView(state),
                    _showCropImageRatios(state),
                  ],
                ),
              ),
            ),
          );
        },
      );
    } else {
      return Container();
    }
  }

  /// callback for image loading started.
  void _setDeviceOrientation() {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
    ]);
  }

  /// callback for image loading started.
  void _imageLoadingStarted() {
    widget._onImageStartLoading();
  }

  /// callback for image loading finished.
  void _imageLoadingFinished() {
    widget._onImageEndLoading();
  }

  /// Generate image from image bytes.
  void _generateLibraryImage() async {
    // _libraryImage = await compressImage(widget._imageBytes);
    _libraryImage = await getCompressedImage(widget._imageBytes);
    _finalImageBytes = widget._imageBytes;
    _setImageHeightWidth();
    setState(() {});
  }

  /// Resize image and return the result.
  static Library.Image getCompressedImage(Uint8List _imageData) {
    Library.Image image = Library.decodeImage(_imageData)!;
    if (image.width > 1920) {
      image = Library.copyResize(image, width: 1920);
    } else if (image.height > 1920) {
      image = Library.copyResize(image, height: 1920);
    }
    return image;
  }

  /// set device width & height
  void _setDeviceHeightWidth() {
    _deviceWidth = MediaQuery.of(widget._context).size.width;
    _deviceHeight = MediaQuery.of(widget._context).size.height;
  }

  /// set image width & height.
  void _setImageHeightWidth() {
    _imageWidth = _libraryImage.width.toDouble();
    _imageHeight = _libraryImage.height.toDouble();
  }

  /// set position of all dot buttons.
  void _setDefaultButtonPosition() {
    _setLeftTopCropButtonPosition();
    _setLeftBottomCropButtonPosition();
    _setRightTopCropButtonPosition();
    _setRightBottomCropButtonPosition();
  }

  /// set topview height(means screen top point to stack starting point height.)
  void _setTopHeight() {
    if (_topViewHeight == 0) {
      WidgetsBinding.instance?.addPostFrameCallback((timeStamp) async {
        _topViewHeight = _stackGlobalKey.globalPaintBounds?.top ?? 0;
      });
    }
  }

  /// set left top crop button on screen.
  void _setLeftTopCropButtonPosition({leftTopDx = -1, leftTopDy = -1}) {
    _leftTopDX = (leftTopDx == -1)
        ? (_deviceWidth / 2) - (_cropSizeWidth / 2)
        : leftTopDx;
    _leftTopDY =
        (leftTopDy == -1) ? (_deviceHeight / 2) - _cropSizeHeight : leftTopDy;
  }

  /// set left bottom crop button on screen.
  void _setLeftBottomCropButtonPosition(
      {leftBottomDx = -1, leftBottomDy = -1}) {
    _leftBottomDX = (leftBottomDx == -1) ? _leftTopDX : leftBottomDx;
    _leftBottomDY =
        (leftBottomDy == -1) ? _leftTopDY + _cropSizeHeight : leftBottomDy;
  }

  /// set right top crop button on screen.
  void _setRightTopCropButtonPosition({rightTopDx = -1, rightTopDy = -1}) {
    _rightTopDX = (rightTopDx == -1) ? _leftTopDX + _cropSizeWidth : rightTopDx;
    _rightTopDY = (rightTopDy == -1) ? _leftTopDY : rightTopDy;
  }

  /// set right bottom crop button on screen.
  void _setRightBottomCropButtonPosition(
      {rightBottomDx = -1, rightBottomDy = -1}) {
    _rightBottomDX =
        (rightBottomDx == -1) ? _leftTopDX + _cropSizeWidth : rightBottomDx;
    _rightBottomDY =
        (rightBottomDy == -1) ? _rightTopDY + _cropSizeHeight : rightBottomDy;
  }

  /// Showing stack in screen.
  Widget _showCropImageView(state) {
    return Expanded(
      child: getStackWidget(state),
    );
  }

  /// showing image & buttons in screen.
  Widget getStackWidget(state) {
    return Stack(
      key: _stackGlobalKey,
      children: [
        /// Showing image in screen
        loadImage(),

        /// Showing border of crop view.
        showImageCropButtonsBorder(state),

        /// Displaying a dot button in left top.
        showImageCropLeftTopButton(state),

        /// Displaying a dot button in left bottom.
        showImageCropLeftBottomButton(state),

        /// Displaying a dot button in right top.
        showImageCropRightTopButton(state),

        /// Displaying a dot button in right bottom.
        showImageCropRightBottomButton(state),
      ],
    );
  }

  /// Showing image in screen
  Widget loadImage() {
    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        _imageViewMaxHeight = constraints.maxHeight;
        return Container(
          color: widget._colorForWhiteSpace,
          child: Center(
            child: Image.memory(
              _finalImageBytes!,
              key: _imageGlobalKey,
              fit: BoxFit.cover,
            ),
          ),
        );
      },
    );
  }

  /// Showing border of crop view.
  Widget showImageCropButtonsBorder(state) {
    return Positioned(
      left: _leftTopDX + (widget.squareCircleSize / 4),
      top: _leftTopDY + (widget.squareCircleSize / 4),
      child: GestureDetector(
        onPanUpdate: (details) {
          _buttonDrag(state, details, DragDirection.ALL);
        },
        onPanDown: (details) {
          _startedDX = details.globalPosition.dx - _leftTopDX;
          _startedDY = details.globalPosition.dy - _leftTopDY;
        },
        child: Container(
          width: _cropSizeWidth,
          height: _cropSizeHeight,
          decoration: BoxDecoration(
            border: Border.all(
              color: Colors.white,
              width: widget.squareBorderWidth,
            ),
          ),
        ),
      ),
    );
  }

  /// Showing buttons of crop view.
  Widget _showCroppingButtons(state) {
    return Row(
      key: _cropMenuGlobalKey,
      mainAxisAlignment:
          (kIsWeb) ? MainAxisAlignment.end : MainAxisAlignment.spaceAround,
      children: [
        /// this [appIconButton] icon for rotate the image on left side.
        appIconButton(
          icon: Icons.rotate_left,
          background: Colors.transparent,
          iconColor: Colors.grey.shade800,
          onPress: () async {
            _imageGlobalKey = GlobalKey();
            changeImageRotation(ImageRotation.LEFT, state);
          },
          size: widget.headerMenuSize,
        ),

        /// this [appIconButton] icon for rotate the image on right side.
        appIconButton(
          icon: Icons.rotate_right,
          background: Colors.transparent,
          iconColor: Colors.grey.shade800,
          onPress: () async {
            _imageGlobalKey = GlobalKey();
            changeImageRotation(ImageRotation.RIGHT, state);
          },
          size: widget.headerMenuSize,
        ),

        /// this [appIconButton] icon for close the cropping screen.
        appIconButton(
          icon: Icons.close,
          background: Colors.transparent,
          iconColor: Colors.grey.shade800,
          onPress: () async {
            Navigator.pop(widget._context);
          },
          size: widget.headerMenuSize,
        ),

        /// this [appIconButton] icon for cropping is done.
        appIconButton(
          icon: Icons.done,
          background: Colors.transparent,
          iconColor: Colors.green,
          onPress: () async {
            /// crop is done, and start process for cropping the image from screen.
            _onPressDone(widget._context, _libraryImage, _leftTopDX, _leftTopDY,
                _cropSizeWidth, _cropSizeHeight, state);
          },
          size: widget.headerMenuSize,
        ),
      ],
    );
  }

  /// Show all crop ratios.
  Widget _showCropImageRatios(state) {
    /// If widget.visibleOtherAspectRatios is true then ratio list will be visible or else it will hide.
    return Visibility(
      visible: widget.visibleOtherAspectRatios,
      child: Padding(
        padding: const EdgeInsets.all(10.0),
        child: Row(
          mainAxisAlignment:
              (kIsWeb) ? MainAxisAlignment.end : MainAxisAlignment.spaceAround,
          children: [
            /// This is for free cropping ratio.
            InkWell(
              onTap: () {
                changeImageRatio(state, ImageRatio.FREE);
              },
              child: Text(
                "Free",
                style: TextStyle(
                  color: (widget.selectedImageRatio == ImageRatio.FREE)
                      ? widget.selectedTextColor
                      : widget.defaultTextColor,
                ),
              ),
            ),

            SizedBox(
              width: (kIsWeb) ? 20 : 0,
            ),

            /// This is for 1:1 cropping ratio.
            InkWell(
              onTap: () {
                changeImageRatio(state, ImageRatio.RATIO_1_1);
              },
              child: Text(
                "1:1",
                style: TextStyle(
                  color: (widget.selectedImageRatio == ImageRatio.RATIO_1_1)
                      ? widget.selectedTextColor
                      : widget.defaultTextColor,
                ),
              ),
            ),

            SizedBox(
              width: (kIsWeb) ? 20 : 0,
            ),

            /// This is for 1:2 cropping ratio.
            InkWell(
              onTap: () {
                changeImageRatio(state, ImageRatio.RATIO_1_2);
              },
              child: Text(
                "1:2",
                style: TextStyle(
                  color: (widget.selectedImageRatio == ImageRatio.RATIO_1_2)
                      ? widget.selectedTextColor
                      : widget.defaultTextColor,
                ),
              ),
            ),

            SizedBox(
              width: (kIsWeb) ? 20 : 0,
            ),

            /// This is for 3:2 cropping ratio.
            InkWell(
              onTap: () {
                changeImageRatio(state, ImageRatio.RATIO_3_2);
              },
              child: Text(
                "3:2",
                style: TextStyle(
                  color: (widget.selectedImageRatio == ImageRatio.RATIO_3_2)
                      ? widget.selectedTextColor
                      : widget.defaultTextColor,
                ),
              ),
            ),

            SizedBox(
              width: (kIsWeb) ? 20 : 0,
            ),

            /// This is for 4:3 cropping ratio.
            InkWell(
              onTap: () {
                changeImageRatio(state, ImageRatio.RATIO_4_3);
              },
              child: Text(
                "4:3",
                style: TextStyle(
                  color: (widget.selectedImageRatio == ImageRatio.RATIO_4_3)
                      ? widget.selectedTextColor
                      : widget.defaultTextColor,
                ),
              ),
            ),

            SizedBox(
              width: (kIsWeb) ? 20 : 0,
            ),

            /// This is for 16:9 cropping ratio.
            InkWell(
              onTap: () {
                changeImageRatio(state, ImageRatio.RATIO_16_9);
              },
              child: Text(
                "16:9",
                style: TextStyle(
                  color: (widget.selectedImageRatio == ImageRatio.RATIO_16_9)
                      ? widget.selectedTextColor
                      : widget.defaultTextColor,
                ),
              ),
            ),

            SizedBox(
              width: (kIsWeb) ? 50 : 0,
              height: (kIsWeb) ? 50 : 0,
            ),
          ],
        ),
      ),
    );
  }

  /// Change crop ratio width & height and also change the crop size based on selected image ratio.
  void _setImageRatio(ImageRatio imageRatio) {
    switch (imageRatio) {
      case ImageRatio.RATIO_1_2:
        _currentRatioWidth = 1;
        _currentRatioHeight = 2;
        break;
      case ImageRatio.RATIO_3_2:
        _currentRatioWidth = 3;
        _currentRatioHeight = 2;
        break;
      case ImageRatio.RATIO_4_3:
        _currentRatioWidth = 4;
        _currentRatioHeight = 3;
        break;
      case ImageRatio.RATIO_16_9:
        _currentRatioWidth = 16;
        _currentRatioHeight = 9;
        break;
      default:
        _currentRatioWidth = 1;
        _currentRatioHeight = 1;
    }
    _cropSizeWidth = _defaultCropSize;
    _cropSizeHeight =
        (_defaultCropSize * _currentRatioHeight) / _currentRatioWidth;
    widget.selectedImageRatio = imageRatio;
    _setDefaultButtonPosition();
  }

  /// Set crop ratio and again render the screen.
  void changeImageRatio(state, ImageRatio imageRatio) {
    _setImageRatio(imageRatio);
    state(() {});
  }

  /// Change the image rotation.
  Future<void> changeImageRotation(ImageRotation imageRotation, state) async {
    _imageLoadingStarted();
    if (imageRotation == ImageRotation.LEFT) {
      _currentRotationValue -= 1;
      checkRotationValue();
      if (_currentRotationValue != 0) {
        _currentRotationDegreeValue -= 90;
      } else {
        _currentRotationDegreeValue = 270;
      }
    } else {
      _currentRotationValue += 1;
      checkRotationValue();
      if (_currentRotationValue != 0) {
        _currentRotationDegreeValue += 90;
      } else {
        _currentRotationDegreeValue = 90;
      }
    }
    _libraryImage =
        Library.copyRotate(_libraryImage, _currentRotationDegreeValue);
    widget._imageBytes =
        Uint8List.fromList(Library.encodeJpg(_libraryImage, quality: 100));
    _finalImageBytes = widget._imageBytes;
    _setImageHeightWidth();
    _imageLoadingFinished();
    state(() {});
  }

  /// Check rotation value if it is greater or lesser than 3 then set it to 0.
  void checkRotationValue() {
    if (_currentRotationValue > 3 || _currentRotationValue < -3) {
      _currentRotationValue = 0;
    }
  }

  /// Show left top dot button at particular position.
  Widget showImageCropLeftTopButton(state) {
    return Positioned(
      left: _leftTopDX,
      top: _leftTopDY,
      child: GestureDetector(
        child: CircleAvatar(
          key: _leftTopGlobalKey,
          radius: 10,
          child: Container(),
          backgroundColor: widget.squareCircleColor,
        ),
        onPanUpdate: (details) {
          _buttonDrag(state, details, DragDirection.LEFT_TOP);
        },
      ),
    );
  }

  /// Show left bottom dot button at particular position.
  Widget showImageCropLeftBottomButton(state) {
    return Positioned(
      left: _leftBottomDX,
      top: _leftBottomDY,
      child: GestureDetector(
        child: CircleAvatar(
          key: _leftBottomGlobalKey,
          radius: 10,
          child: Container(),
          backgroundColor: widget.squareCircleColor,
        ),
        onPanUpdate: (details) {
          _buttonDrag(state, details, DragDirection.LEFT_BOTTOM);
        },
      ),
    );
  }

  /// Show right top dot button at particular position.
  Widget showImageCropRightTopButton(state) {
    return Positioned(
      left: _rightTopDX,
      top: _rightTopDY,
      child: GestureDetector(
        child: CircleAvatar(
          key: _rightTopGlobalKey,
          radius: 10,
          child: Container(),
          backgroundColor: widget.squareCircleColor,
        ),
        onPanUpdate: (details) {
          _buttonDrag(state, details, DragDirection.RIGHT_TOP);
        },
      ),
    );
  }

  /// Show right bottom dot button at particular position.
  Widget showImageCropRightBottomButton(state) {
    return Positioned(
      left: _rightBottomDX,
      top: _rightBottomDY,
      child: GestureDetector(
        child: CircleAvatar(
          key: _rightBottomGlobalKey,
          radius: 10,
          child: Container(),
          backgroundColor: widget.squareCircleColor,
        ),
        onPanUpdate: (details) {
          _buttonDrag(state, details, DragDirection.RIGHT_BOTTOM);
        },
      ),
    );
  }

  /// Update button or square position on drag and update the UI.
  void _buttonDrag(
      state, DragUpdateDetails details, DragDirection dragDirection) {
    if (dragDirection == DragDirection.LEFT_TOP) {
      _manageLeftTopButtonDrag(state, details, dragDirection);
    } else if (dragDirection == DragDirection.LEFT_BOTTOM) {
      _manageLeftBottomButtonDrag(state, details, dragDirection);
    } else if (dragDirection == DragDirection.RIGHT_TOP) {
      _manageRightTopButtonDrag(state, details, dragDirection);
    } else if (dragDirection == DragDirection.RIGHT_BOTTOM) {
      _manageRightBottomButtonDrag(state, details, dragDirection);
    } else if (dragDirection == DragDirection.ALL) {
      _manageSquareDrag(state, details, dragDirection);
    }
    state(() {});
  }

  /// Manage left top button on drag.
  void _manageLeftTopButtonDrag(
      state, DragUpdateDetails details, DragDirection dragDirection) {
    var globalPositionDX =
        details.globalPosition.dx - (widget.squareCircleSize / 4);
    var globalPositionDY = details.globalPosition.dy - _topViewHeight;

    if (globalPositionDY < 1) {
      return;
    }

    var _previousLeftTopDX = _leftTopDX;
    var _previousLeftTopDY = _leftTopDY;
    var _previousCropWidth = _cropSizeWidth;
    var _previousCropHeight = _cropSizeHeight;

    _leftTopDX = globalPositionDX;
    _leftTopDY = globalPositionDY;

    // this logic is for Free ratio
    if (widget.selectedImageRatio == ImageRatio.FREE) {
      // set crop size width
      if (_previousLeftTopDX > _leftTopDX) {
        // moving to left side
        _cropSizeWidth += _previousLeftTopDX - _leftTopDX;
      } else {
        // moving to right side
        _cropSizeWidth -= _leftTopDX - _previousLeftTopDX;
      }

      // set crop size height
      if (_previousLeftTopDY > _leftTopDY) {
        // moving to top side
        _cropSizeHeight += _previousLeftTopDY - _leftTopDY;
      } else {
        // moving to bottom side
        _cropSizeHeight -= _leftTopDY - _previousLeftTopDY;
      }

      if (_cropSizeWidth < _minCropSizeWidth) {
        _cropSizeWidth = _previousCropWidth;
        _leftTopDX = _previousLeftTopDX;
      } else if (_leftTopDX != _leftBottomDX) {
        // set left bottom when moving left top.
        _setLeftBottomCropButtonPosition(
            leftBottomDx: _leftTopDX, leftBottomDy: _leftBottomDY);
      }

      if (_cropSizeHeight < _minCropSizeHeight) {
        _cropSizeHeight = _previousCropHeight;
        _leftTopDY = _previousLeftTopDY;
      } else if (_leftTopDY != _rightTopDY) {
        // set right top when moving left top.
        _setRightTopCropButtonPosition(
            rightTopDx: _rightTopDX, rightTopDy: _leftTopDY);
      }
    } else {
      // this will executes whenever any ratio is selected.
      // set crop size width
      if (_previousLeftTopDX > _leftTopDX) {
        // moving to left side
        _cropSizeWidth +=
            (_previousLeftTopDX - _leftTopDX) * _currentRatioWidth;
        _cropSizeHeight +=
            (_previousLeftTopDX - _leftTopDX) * _currentRatioHeight;
      } else {
        // moving to right side
        _cropSizeWidth -=
            (_leftTopDX - _previousLeftTopDX) * _currentRatioWidth;
        _cropSizeHeight -=
            (_leftTopDX - _previousLeftTopDX) * _currentRatioHeight;
      }

      if (_cropSizeWidth < _minCropSizeWidth ||
              _cropSizeHeight < _minCropSizeHeight ||
              _leftTopDX + _cropSizeWidth + widget.squareCircleSize >
                  _stackGlobalKey.globalPaintBounds!
                      .width // this condition checks the right top crop button is outside the screen.
          ) {
        _cropSizeWidth = _previousCropWidth;
        _cropSizeHeight = _previousCropHeight;
        _leftTopDX = _previousLeftTopDX;
        _leftTopDY = _previousLeftTopDY;
        return;
      }
      _setLeftBottomCropButtonPosition(
          leftBottomDx: _leftTopDX, leftBottomDy: _leftTopDY + _cropSizeHeight);
      _setRightTopCropButtonPosition(
          rightTopDx: _leftTopDX + _cropSizeWidth, rightTopDy: _leftTopDY);
      _setRightBottomCropButtonPosition(
          rightBottomDx: _leftTopDX + _cropSizeWidth,
          rightBottomDy: _leftTopDY + _cropSizeHeight);
    }
  }

  /// Manage left bottom button on drag.
  void _manageLeftBottomButtonDrag(
      state, DragUpdateDetails details, DragDirection dragDirection) {
    var globalPositionDX =
        details.globalPosition.dx - (widget.squareCircleSize / 4);
    var globalPositionDY = details.globalPosition.dy - _topViewHeight;

    if ((globalPositionDY + widget.squareCircleSize) >
        _stackGlobalKey.globalPaintBounds!.height) {
      return;
    }

    var _previousLeftBottomDX = _leftBottomDX;
    var _previousLeftBottomDY = _leftBottomDY;
    var _previousCropWidth = _cropSizeWidth;
    var _previousCropHeight = _cropSizeHeight;

    _leftBottomDX = globalPositionDX;
    _leftBottomDY = globalPositionDY;

    // this logic is for Free ratio
    if (widget.selectedImageRatio == ImageRatio.FREE) {
      // set crop size width
      if (_previousLeftBottomDX > _leftBottomDX) {
        // moving to left side
        _cropSizeWidth += _previousLeftBottomDX - _leftBottomDX;
      } else {
        // moving to right side
        _cropSizeWidth -= _leftBottomDX - _previousLeftBottomDX;
      }

      // set crop size height
      if (_previousLeftBottomDY > _leftBottomDY) {
        // moving to top side
        _cropSizeHeight -= _previousLeftBottomDY - _leftBottomDY;
      } else {
        // moving to bottom side
        _cropSizeHeight += _leftBottomDY - _previousLeftBottomDY;
      }

      if (_cropSizeWidth < _minCropSizeWidth) {
        _cropSizeWidth = _previousCropWidth;
        _leftBottomDX = _previousLeftBottomDX;
      } else if (_leftBottomDX != _leftTopDX) {
        // set left top when moving left bottom.
        _setLeftTopCropButtonPosition(
            leftTopDx: _leftBottomDX, leftTopDy: _leftTopDY);
      }

      if (_cropSizeHeight < _minCropSizeHeight) {
        _cropSizeHeight = _previousCropHeight;
        _leftBottomDY = _previousLeftBottomDY;
      } else if (_rightBottomDY != _leftBottomDY) {
        // set right bottom when moving left bottom.
        _setRightBottomCropButtonPosition(
            rightBottomDx: _rightBottomDX, rightBottomDy: _leftBottomDY);
      }
    } else {
      // this will executes whenever any ratio is selected.
      // set crop size width
      if (_previousLeftBottomDX > _leftBottomDX) {
        // moving to left side
        _cropSizeWidth +=
            (_previousLeftBottomDX - _leftBottomDX) * _currentRatioWidth;
        _cropSizeHeight +=
            (_previousLeftBottomDX - _leftBottomDX) * _currentRatioHeight;
      } else {
        // moving to right side
        _cropSizeWidth -=
            (_leftBottomDX - _previousLeftBottomDX) * _currentRatioWidth;
        _cropSizeHeight -=
            (_leftBottomDX - _previousLeftBottomDX) * _currentRatioHeight;
      }
      if (_cropSizeWidth < _minCropSizeWidth ||
              _cropSizeHeight < _minCropSizeHeight ||
              _leftTopDX + _cropSizeWidth + widget.squareCircleSize >
                  _stackGlobalKey.globalPaintBounds!
                      .width // this condition checks the right top crop button is outside the screen.
          ) {
        _cropSizeWidth = _previousCropWidth;
        _cropSizeHeight = _previousCropHeight;
        _leftBottomDX = _previousLeftBottomDX;
        _leftBottomDY = _previousLeftBottomDY;
        return;
      }
      _setLeftTopCropButtonPosition(
          leftTopDx: _leftBottomDX, leftTopDy: _leftBottomDY - _cropSizeHeight);
      _setRightTopCropButtonPosition(
          rightTopDx: _leftBottomDX + _cropSizeWidth, rightTopDy: _leftTopDY);
      _setRightBottomCropButtonPosition(
          rightBottomDx: _leftBottomDX + _cropSizeWidth,
          rightBottomDy: _leftBottomDY);
    }
  }

  /// Manage right top button on drag.
  void _manageRightTopButtonDrag(
      state, DragUpdateDetails details, DragDirection dragDirection) {
    var globalPositionDX =
        details.globalPosition.dx - (widget.squareCircleSize / 4);
    var globalPositionDY = details.globalPosition.dy - _topViewHeight;

    if (globalPositionDY < 1) {
      return;
    }

    var _previousRightTopDX = _rightTopDX;
    var _previousRightTopDY = _rightTopDY;
    var _previousCropWidth = _cropSizeWidth;
    var _previousCropHeight = _cropSizeHeight;

    _rightTopDX = globalPositionDX;
    _rightTopDY = globalPositionDY;

    // this logic is Free ratio
    if (widget.selectedImageRatio == ImageRatio.FREE) {
      // set crop size width
      if (_previousRightTopDX > _rightTopDX) {
        // moving to left side
        _cropSizeWidth -= _previousRightTopDX - _rightTopDX;
      } else {
        // moving to right side
        _cropSizeWidth += _rightTopDX - _previousRightTopDX;
      }

      // set crop size height
      if (_previousRightTopDY > _rightTopDY) {
        // moving to top side
        _cropSizeHeight += _previousRightTopDY - _rightTopDY;
      } else {
        // moving to bottom side
        _cropSizeHeight -= _rightTopDY - _previousRightTopDY;
      }

      if (_cropSizeWidth < _minCropSizeWidth) {
        _cropSizeWidth = _previousCropWidth;
        _rightTopDX = _previousRightTopDX;
      } else if (_rightTopDX != _rightBottomDX) {
        // set right bottom when moving right top.
        _setRightBottomCropButtonPosition(
            rightBottomDx: _rightTopDX, rightBottomDy: _rightBottomDY);
      }

      if (_cropSizeHeight < _minCropSizeHeight) {
        _cropSizeHeight = _previousCropHeight;
        _rightTopDY = _previousRightTopDY;
      } else if (_rightTopDY != _leftTopDY) {
        // set right bottom when moving right top.
        _setLeftTopCropButtonPosition(
            leftTopDx: _leftTopDX, leftTopDy: _rightTopDY);
      }
    } else {
      // this will executes whenever any ratio is selected.
      // set crop size width
      if (_previousRightTopDX > _rightTopDX) {
        // moving to left side
        _cropSizeWidth -=
            (_previousRightTopDX - _rightTopDX) * _currentRatioWidth;
        _cropSizeHeight -=
            (_previousRightTopDX - _rightTopDX) * _currentRatioHeight;
      } else {
        // moving to right side
        _cropSizeWidth +=
            (_rightTopDX - _previousRightTopDX) * _currentRatioWidth;
        _cropSizeHeight +=
            (_rightTopDX - _previousRightTopDX) * _currentRatioHeight;
      }

      // check crop size less than declared min crop size. then set to previous size.
      if (_cropSizeWidth < _minCropSizeWidth ||
              _cropSizeHeight < _minCropSizeHeight ||
              (_rightTopDX - _cropSizeWidth) <
                  1 // this condition checks the left top crop button is outside the screen.
          ) {
        _cropSizeWidth = _previousCropWidth;
        _cropSizeHeight = _previousCropHeight;
        _rightTopDX = _previousRightTopDX;
        _rightTopDY = _previousRightTopDY;
        return;
      }

      _setLeftTopCropButtonPosition(
          leftTopDx: _rightTopDX - _cropSizeWidth, leftTopDy: _rightTopDY);
      _setLeftBottomCropButtonPosition(
          leftBottomDx: _leftTopDX, leftBottomDy: _leftTopDY + _cropSizeHeight);
      _setRightBottomCropButtonPosition(
          rightBottomDx: _rightTopDX,
          rightBottomDy: _rightTopDY + _cropSizeHeight);
    }
  }

  /// Manage right bottom button on drag.
  void _manageRightBottomButtonDrag(
      state, DragUpdateDetails details, DragDirection dragDirection) {
    var globalPositionDX =
        details.globalPosition.dx - (widget.squareCircleSize / 4);
    var globalPositionDY = details.globalPosition.dy - _topViewHeight;

    if ((globalPositionDY + widget.squareCircleSize) >
        _stackGlobalKey.globalPaintBounds!.height) {
      return;
    }

    var _previousRightBottomDX = _rightBottomDX;
    var _previousRightBottomDY = _rightBottomDY;
    var _previousCropWidth = _cropSizeWidth;
    var _previousCropHeight = _cropSizeHeight;

    _rightBottomDX = globalPositionDX;
    _rightBottomDY = globalPositionDY;

    // this logic is Free ratio
    if (widget.selectedImageRatio == ImageRatio.FREE) {
      // set crop size width
      if (_previousRightBottomDX > _rightBottomDX) {
        // moving to left side
        _cropSizeWidth -= _previousRightBottomDX - _rightBottomDX;
      } else {
        // moving to right side
        _cropSizeWidth += _rightBottomDX - _previousRightBottomDX;
      }

      // set crop size height
      if (_previousRightBottomDY > _rightBottomDY) {
        // moving to top side
        _cropSizeHeight -= _previousRightBottomDY - _rightBottomDY;
      } else {
        // moving to bottom side
        _cropSizeHeight += _rightBottomDY - _previousRightBottomDY;
      }

      if (_cropSizeWidth < _minCropSizeWidth) {
        _cropSizeWidth = _previousCropWidth;
        _rightBottomDX = _previousRightBottomDX;
      } else if (_rightBottomDX != _rightTopDX) {
        // set right top when moving right bottom.
        _setRightTopCropButtonPosition(
            rightTopDx: _rightBottomDX, rightTopDy: _rightTopDY);
      }

      if (_cropSizeHeight < _minCropSizeHeight) {
        _cropSizeHeight = _previousCropHeight;
        _rightBottomDY = _previousRightBottomDY;
      } else if (_rightBottomDY != _leftBottomDY) {
        // set left bottom when moving right bottom.
        _setLeftBottomCropButtonPosition(
            leftBottomDx: _leftBottomDX, leftBottomDy: _rightBottomDY);
      }
    } else {
      // this will executes whenever any ratio is selected.
      // set crop size width
      if (_previousRightBottomDX > _rightBottomDX) {
        // moving to left side
        _cropSizeWidth -=
            (_previousRightBottomDX - _rightBottomDX) * _currentRatioWidth;
        _cropSizeHeight -=
            (_previousRightBottomDX - _rightBottomDX) * _currentRatioHeight;
      } else {
        // moving to right side
        _cropSizeWidth +=
            (_rightBottomDX - _previousRightBottomDX) * _currentRatioWidth;
        _cropSizeHeight +=
            (_rightBottomDX - _previousRightBottomDX) * _currentRatioHeight;
      }

      // check crop size less than declared min crop size. then set to previous size.
      if (_cropSizeWidth < _minCropSizeWidth ||
              _cropSizeHeight < _minCropSizeHeight ||
              (_rightTopDX - _cropSizeWidth) <
                  1 // this condition checks the left top crop button is outside the screen.
          ) {
        print("size: previous default");
        _cropSizeWidth = _previousCropWidth;
        _cropSizeHeight = _previousCropHeight;
        _rightBottomDX = _previousRightBottomDX;
        _rightBottomDY = _previousRightBottomDY;
        return;
      }

      _setRightTopCropButtonPosition(
          rightTopDx: _rightBottomDX,
          rightTopDy: _rightBottomDY - _cropSizeHeight);
      _setLeftTopCropButtonPosition(
          leftTopDx: _rightTopDX - _cropSizeWidth, leftTopDy: _rightTopDY);
      _setLeftBottomCropButtonPosition(
          leftBottomDx: _leftTopDX, leftBottomDy: _leftTopDY + _cropSizeHeight);
    }
  }

  /// Manage square on drag.
  void _manageSquareDrag(
      state, DragUpdateDetails details, DragDirection dragDirection) {
    var globalPositionDX = details.globalPosition.dx - _startedDX;
    var globalPositionDY = details.globalPosition.dy - _startedDY;

    if (globalPositionDX < -9 ||
        (globalPositionDX + _cropSizeWidth + (widget.squareCircleSize / 5)) >
            _deviceWidth) {
      globalPositionDX = _leftTopDX;
    }

    if (globalPositionDY < -9 ||
        (globalPositionDY + _cropSizeHeight + (widget.squareCircleSize / 5)) >
            _imageViewMaxHeight) {
      globalPositionDY = _leftTopDY;
    }
    _setLeftTopCropButtonPosition(
        leftTopDx: globalPositionDX, leftTopDy: globalPositionDY);
    _setLeftBottomCropButtonPosition(
        leftBottomDx: _leftTopDX, leftBottomDy: _leftTopDY + _cropSizeHeight);
    _setRightTopCropButtonPosition(
        rightTopDx: _leftTopDX + _cropSizeWidth, rightTopDy: _leftTopDY);
    _setRightBottomCropButtonPosition(
        rightBottomDx: _rightTopDX,
        rightBottomDy: _rightTopDY + _cropSizeHeight);
  }

  // crop is done, now process for cropping the image.
  void _onPressDone(BuildContext context, Library.Image sourceImage, double x,
      double y, double width, double height, state) {
    _imageLoadingStarted();
    // image view width / height
    var imageViewWidth = _imageGlobalKey.globalPaintBounds!.width;
    var imageViewHeight = _imageGlobalKey.globalPaintBounds!.height;

    var stackWidth = _stackGlobalKey.globalPaintBounds!.width;
    var stackHeight = _stackGlobalKey.globalPaintBounds!.height;

    // _libraryImage = Library.bakeOrientation(_libraryImage);

    _libraryImage = setWhiteColorInImage(
      _libraryImage,
      widget._colorForWhiteSpace.value,
      _imageWidth,
      _imageHeight,
      imageViewWidth,
      imageViewHeight,
      stackWidth,
      stackHeight,
    );

    _imageWidth = _libraryImage.width.toDouble();
    _imageHeight = _libraryImage.height.toDouble();

    var leftX = _leftTopDX + (widget.squareCircleSize / 4);
    var leftY = _leftTopDY + (widget.squareCircleSize / 4);

    var imageCropX = (_imageWidth * leftX) / stackWidth;
    var imageCropY = (_imageHeight * leftY) / stackHeight;
    var imageCropWidth = (_imageWidth * _cropSizeWidth) / stackWidth;
    var imageCropHeight = (_imageHeight * _cropSizeHeight) / stackHeight;

    _libraryImage = Library.copyCrop(
      _libraryImage,
      imageCropX.toInt(),
      imageCropY.toInt(),
      imageCropWidth.toInt(),
      imageCropHeight.toInt(),
    );

    var _libraryUInt8List = Uint8List.fromList(
      Library.encodeJpg(
        _libraryImage,
        quality: 100,
      ),
    );

    _imageLoadingFinished();
    widget._onImageDoneListener(_libraryUInt8List);
    Navigator.pop(widget._context);
  }
}
