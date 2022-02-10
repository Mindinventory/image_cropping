part of image_cropping;

/// [CroppingImageView] class shows a image.
/// Also, it shows a cropping2 buttons and borders.
class CroppingImageView extends StatefulWidget {
  /// This property contains Color value.
  /// By passing this property you can set background color, if screen contains blank space.
  final Color? colorForWhiteSpace;

  final double? squareCircleSize;

  /// This property contains double value.
  /// You can change square border width by passing this value.
  final double? squareBorderWidth;

  /// This property contains Color value.
  /// You can change square circle color by passing this value.
  final Color? squareCircleColor;

  final state;

  const CroppingImageView({
    this.colorForWhiteSpace,
    this.squareCircleSize,
    this.squareBorderWidth,
    this.squareCircleColor,
    this.state,
    Key? key,
  }) : super(key: key);

  @override
  _CroppingImageViewState createState() => _CroppingImageViewState();
}

class _CroppingImageViewState extends State<CroppingImageView> {
  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Center(
        child: Stack(
          key: stackGlobalKey,
          children: [
            /// Showing image in screen
            loadImage(),

            /// Showing border of crop view.
            showImageCropButtonsBorder(widget.state),

            /// Displaying a dot button in left top.
            showImageCropLeftTopButton(widget.state),

            /// Displaying a dot button in left bottom.
            showImageCropLeftBottomButton(widget.state),

            /// Displaying a dot button in right top.
            showImageCropRightTopButton(widget.state),

            /// Displaying a dot button in right bottom.
            showImageCropRightBottomButton(widget.state),
          ],
        ),
      ),
    );
  }

  /// Showing image in screen
  Widget loadImage() {
    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        imageViewMaxHeight = constraints.maxHeight;
        return Container(
          color: widget.colorForWhiteSpace,
          child: Center(
            child: Image.memory(
              finalImageBytes!,
              key: imageGlobalKey,
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
      left: leftTopDX + (widget.squareCircleSize! / 3),
      top: leftTopDY + (widget.squareCircleSize! / 3),
      child: GestureDetector(
        onPanUpdate: (details) {
          _buttonDrag(state, details, DragDirection.ALL);
        },
        onPanDown: (details) {
          startedDX = details.globalPosition.dx - leftTopDX;
          startedDY = details.globalPosition.dy - leftTopDY;
        },
        child: Container(
          width: cropSizeWidth,
          height: cropSizeHeight,
          decoration: BoxDecoration(
            border: Border.all(
              color: Colors.white,
              width: widget.squareBorderWidth!,
            ),
          ),
        ),
      ),
    );
  }

  /// Show left top dot button at particular position.
  Widget showImageCropLeftTopButton(state) {
    return Positioned(
      left: leftTopDX,
      top: leftTopDY,
      child: GestureDetector(
        child: CircleAvatar(
          key: leftTopGlobalKey,
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
      left: leftBottomDX,
      top: leftBottomDY,
      child: GestureDetector(
        child: CircleAvatar(
          key: leftBottomGlobalKey,
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
      left: rightTopDX,
      top: rightTopDY,
      child: GestureDetector(
        child: CircleAvatar(
          key: rightTopGlobalKey,
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
      left: rightBottomDX,
      top: rightBottomDY,
      child: GestureDetector(
        child: CircleAvatar(
          key: rightBottomGlobalKey,
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
        details.globalPosition.dx - (widget.squareCircleSize! / 4);
    var globalPositionDY = details.globalPosition.dy - topViewHeight;

    if (globalPositionDY < 1) {
      return;
    }

    var _previousLeftTopDX = leftTopDX;
    var _previousLeftTopDY = leftTopDY;
    var _previousCropWidth = cropSizeWidth;
    var _previousCropHeight = cropSizeHeight;

    leftTopDX = globalPositionDX;
    leftTopDY = globalPositionDY;

    // this logic is for Free ratio
    if (selectedImageRatio == ImageRatio.FREE) {
      // set crop size width
      if (_previousLeftTopDX > leftTopDX) {
        // moving to left side
        cropSizeWidth += _previousLeftTopDX - leftTopDX;
      } else {
        // moving to right side
        cropSizeWidth -= leftTopDX - _previousLeftTopDX;
      }

      // set crop size height
      if (_previousLeftTopDY > leftTopDY) {
        // moving to top side
        cropSizeHeight += _previousLeftTopDY - leftTopDY;
      } else {
        // moving to bottom side
        cropSizeHeight -= leftTopDY - _previousLeftTopDY;
      }

      if (cropSizeWidth < minCropSizeWidth) {
        cropSizeWidth = _previousCropWidth;
        leftTopDX = _previousLeftTopDX;
      } else if (leftTopDX != leftBottomDX) {
        // set left bottom when moving left top.
        SetImageRatio.setLeftBottomCropButtonPosition(
            leftBottomDx: leftTopDX, leftBottomDy: leftBottomDY);
      }

      if (cropSizeHeight < minCropSizeHeight) {
        cropSizeHeight = _previousCropHeight;
        leftTopDY = _previousLeftTopDY;
      } else if (leftTopDY != rightTopDY) {
        // set right top when moving left top.
        SetImageRatio.setRightTopCropButtonPosition(
            rightTopDx: rightTopDX, rightTopDy: leftTopDY);
      }
    } else {
      // this will executes whenever any ratio is selected.
      // set crop size width
      if (_previousLeftTopDX > leftTopDX) {
        // moving to left side
        cropSizeWidth += (_previousLeftTopDX - leftTopDX) * currentRatioWidth;
        cropSizeHeight += (_previousLeftTopDX - leftTopDX) * currentRatioHeight;
      } else {
        // moving to right side
        cropSizeWidth -= (leftTopDX - _previousLeftTopDX) * currentRatioWidth;
        cropSizeHeight -= (leftTopDX - _previousLeftTopDX) * currentRatioHeight;
      }

      if (cropSizeWidth < minCropSizeWidth ||
              cropSizeHeight < minCropSizeHeight ||
              leftTopDX + cropSizeWidth + widget.squareCircleSize! >
                  stackGlobalKey.globalPaintBounds!
                      .width // this condition checks the right top crop button is outside the screen.
          ) {
        cropSizeWidth = _previousCropWidth;
        cropSizeHeight = _previousCropHeight;
        leftTopDX = _previousLeftTopDX;
        leftTopDY = _previousLeftTopDY;
        return;
      }
      SetImageRatio.setLeftBottomCropButtonPosition(
          leftBottomDx: leftTopDX, leftBottomDy: leftTopDY + cropSizeHeight);
      SetImageRatio.setRightTopCropButtonPosition(
          rightTopDx: leftTopDX + cropSizeWidth, rightTopDy: leftTopDY);
      SetImageRatio.setRightBottomCropButtonPosition(
          rightBottomDx: leftTopDX + cropSizeWidth,
          rightBottomDy: leftTopDY + cropSizeHeight);
    }
  }

  /// Manage left bottom button on drag.
  void _manageLeftBottomButtonDrag(
      state, DragUpdateDetails details, DragDirection dragDirection) {
    var globalPositionDX =
        details.globalPosition.dx - (widget.squareCircleSize! / 4);
    var globalPositionDY = details.globalPosition.dy - topViewHeight;

    if ((globalPositionDY + widget.squareCircleSize!) >
        stackGlobalKey.globalPaintBounds!.height) {
      return;
    }

    var _previousLeftBottomDX = leftBottomDX;
    var _previousLeftBottomDY = leftBottomDY;
    var _previousCropWidth = cropSizeWidth;
    var _previousCropHeight = cropSizeHeight;

    leftBottomDX = globalPositionDX;
    leftBottomDY = globalPositionDY;

    // this logic is for Free ratio
    if (selectedImageRatio == ImageRatio.FREE) {
      // set crop size width
      if (_previousLeftBottomDX > leftBottomDX) {
        // moving to left side
        cropSizeWidth += _previousLeftBottomDX - leftBottomDX;
      } else {
        // moving to right side
        cropSizeWidth -= leftBottomDX - _previousLeftBottomDX;
      }

      // set crop size height
      if (_previousLeftBottomDY > leftBottomDY) {
        // moving to top side
        cropSizeHeight -= _previousLeftBottomDY - leftBottomDY;
      } else {
        // moving to bottom side
        cropSizeHeight += leftBottomDY - _previousLeftBottomDY;
      }

      if (cropSizeWidth < minCropSizeWidth) {
        cropSizeWidth = _previousCropWidth;
        leftBottomDX = _previousLeftBottomDX;
      } else if (leftBottomDX != leftTopDX) {
        // set left top when moving left bottom.
        SetImageRatio.setLeftTopCropButtonPosition(
            leftTopDx: leftBottomDX, leftTopDy: leftTopDY);
      }

      if (cropSizeHeight < minCropSizeHeight) {
        cropSizeHeight = _previousCropHeight;
        leftBottomDY = _previousLeftBottomDY;
      } else if (rightBottomDY != leftBottomDY) {
        // set right bottom when moving left bottom.
        SetImageRatio.setRightBottomCropButtonPosition(
            rightBottomDx: rightBottomDX, rightBottomDy: leftBottomDY);
      }
    } else {
      // this will executes whenever any ratio is selected.
      // set crop size width
      if (_previousLeftBottomDX > leftBottomDX) {
        // moving to left side
        cropSizeWidth +=
            (_previousLeftBottomDX - leftBottomDX) * currentRatioWidth;
        cropSizeHeight +=
            (_previousLeftBottomDX - leftBottomDX) * currentRatioHeight;
      } else {
        // moving to right side
        cropSizeWidth -=
            (leftBottomDX - _previousLeftBottomDX) * currentRatioWidth;
        cropSizeHeight -=
            (leftBottomDX - _previousLeftBottomDX) * currentRatioHeight;
      }
      if (cropSizeWidth < minCropSizeWidth ||
              cropSizeHeight < minCropSizeHeight ||
              leftTopDX + cropSizeWidth + widget.squareCircleSize! >
                  stackGlobalKey.globalPaintBounds!
                      .width // this condition checks the right top crop button is outside the screen.
          ) {
        cropSizeWidth = _previousCropWidth;
        cropSizeHeight = _previousCropHeight;
        leftBottomDX = _previousLeftBottomDX;
        leftBottomDY = _previousLeftBottomDY;
        return;
      }
      SetImageRatio.setLeftTopCropButtonPosition(
          leftTopDx: leftBottomDX, leftTopDy: leftBottomDY - cropSizeHeight);
      SetImageRatio.setRightTopCropButtonPosition(
          rightTopDx: leftBottomDX + cropSizeWidth, rightTopDy: leftTopDY);
      SetImageRatio.setRightBottomCropButtonPosition(
          rightBottomDx: leftBottomDX + cropSizeWidth,
          rightBottomDy: leftBottomDY);
    }
  }

  /// Manage right top button on drag.
  void _manageRightTopButtonDrag(
      state, DragUpdateDetails details, DragDirection dragDirection) {
    var globalPositionDX =
        details.globalPosition.dx - (widget.squareCircleSize! / 4);
    var globalPositionDY = details.globalPosition.dy - topViewHeight;

    if (globalPositionDY < 1) {
      return;
    }

    var _previousRightTopDX = rightTopDX;
    var _previousRightTopDY = rightTopDY;
    var _previousCropWidth = cropSizeWidth;
    var _previousCropHeight = cropSizeHeight;

    rightTopDX = globalPositionDX;
    rightTopDY = globalPositionDY;

    // this logic is Free ratio
    if (selectedImageRatio == ImageRatio.FREE) {
      // set crop size width
      if (_previousRightTopDX > rightTopDX) {
        // moving to left side
        cropSizeWidth -= _previousRightTopDX - rightTopDX;
      } else {
        // moving to right side
        cropSizeWidth += rightTopDX - _previousRightTopDX;
      }

      // set crop size height
      if (_previousRightTopDY > rightTopDY) {
        // moving to top side
        cropSizeHeight += _previousRightTopDY - rightTopDY;
      } else {
        // moving to bottom side
        cropSizeHeight -= rightTopDY - _previousRightTopDY;
      }

      if (cropSizeWidth < minCropSizeWidth) {
        cropSizeWidth = _previousCropWidth;
        rightTopDX = _previousRightTopDX;
      } else if (rightTopDX != rightBottomDX) {
        // set right bottom when moving right top.
        SetImageRatio.setRightBottomCropButtonPosition(
            rightBottomDx: rightTopDX, rightBottomDy: rightBottomDY);
      }

      if (cropSizeHeight < minCropSizeHeight) {
        cropSizeHeight = _previousCropHeight;
        rightTopDY = _previousRightTopDY;
      } else if (rightTopDY != leftTopDY) {
        // set right bottom when moving right top.
        SetImageRatio.setLeftTopCropButtonPosition(
            leftTopDx: leftTopDX, leftTopDy: rightTopDY);
      }
    } else {
      // this will executes whenever any ratio is selected.
      // set crop size width
      if (_previousRightTopDX > rightTopDX) {
        // moving to left side
        cropSizeWidth -= (_previousRightTopDX - rightTopDX) * currentRatioWidth;
        cropSizeHeight -=
            (_previousRightTopDX - rightTopDX) * currentRatioHeight;
      } else {
        // moving to right side
        cropSizeWidth += (rightTopDX - _previousRightTopDX) * currentRatioWidth;
        cropSizeHeight +=
            (rightTopDX - _previousRightTopDX) * currentRatioHeight;
      }

      // check crop size less than declared min crop size. then set to previous size.
      if (cropSizeWidth < minCropSizeWidth ||
              cropSizeHeight < minCropSizeHeight ||
              (rightTopDX - cropSizeWidth) <
                  1 // this condition checks the left top crop button is outside the screen.
          ) {
        cropSizeWidth = _previousCropWidth;
        cropSizeHeight = _previousCropHeight;
        rightTopDX = _previousRightTopDX;
        rightTopDY = _previousRightTopDY;
        return;
      }

      SetImageRatio.setLeftTopCropButtonPosition(
          leftTopDx: rightTopDX - cropSizeWidth, leftTopDy: rightTopDY);
      SetImageRatio.setLeftBottomCropButtonPosition(
          leftBottomDx: leftTopDX, leftBottomDy: leftTopDY + cropSizeHeight);
      SetImageRatio.setRightBottomCropButtonPosition(
          rightBottomDx: rightTopDX,
          rightBottomDy: rightTopDY + cropSizeHeight);
    }
  }

  /// Manage right bottom button on drag.
  void _manageRightBottomButtonDrag(
      state, DragUpdateDetails details, DragDirection dragDirection) {
    var globalPositionDX =
        details.globalPosition.dx - (widget.squareCircleSize! / 4);
    var globalPositionDY = details.globalPosition.dy - topViewHeight;

    if ((globalPositionDY + widget.squareCircleSize!) >
        stackGlobalKey.globalPaintBounds!.height) {
      return;
    }

    var _previousRightBottomDX = rightBottomDX;
    var _previousRightBottomDY = rightBottomDY;
    var _previousCropWidth = cropSizeWidth;
    var _previousCropHeight = cropSizeHeight;

    rightBottomDX = globalPositionDX;
    rightBottomDY = globalPositionDY;

    // this logic is Free ratio
    if (selectedImageRatio == ImageRatio.FREE) {
      // set crop size width
      if (_previousRightBottomDX > rightBottomDX) {
        // moving to left side
        cropSizeWidth -= _previousRightBottomDX - rightBottomDX;
      } else {
        // moving to right side
        cropSizeWidth += rightBottomDX - _previousRightBottomDX;
      }

      // set crop size height
      if (_previousRightBottomDY > rightBottomDY) {
        // moving to top side
        cropSizeHeight -= _previousRightBottomDY - rightBottomDY;
      } else {
        // moving to bottom side
        cropSizeHeight += rightBottomDY - _previousRightBottomDY;
      }

      if (cropSizeWidth < minCropSizeWidth) {
        cropSizeWidth = _previousCropWidth;
        rightBottomDX = _previousRightBottomDX;
      } else if (rightBottomDX != rightTopDX) {
        // set right top when moving right bottom.
        SetImageRatio.setRightTopCropButtonPosition(
            rightTopDx: rightBottomDX, rightTopDy: rightTopDY);
      }

      if (cropSizeHeight < minCropSizeHeight) {
        cropSizeHeight = _previousCropHeight;
        rightBottomDY = _previousRightBottomDY;
      } else if (rightBottomDY != leftBottomDY) {
        // set left bottom when moving right bottom.
        SetImageRatio.setLeftBottomCropButtonPosition(
            leftBottomDx: leftBottomDX, leftBottomDy: rightBottomDY);
      }
    } else {
      // this will executes whenever any ratio is selected.
      // set crop size width
      if (_previousRightBottomDX > rightBottomDX) {
        // moving to left side
        cropSizeWidth -=
            (_previousRightBottomDX - rightBottomDX) * currentRatioWidth;
        cropSizeHeight -=
            (_previousRightBottomDX - rightBottomDX) * currentRatioHeight;
      } else {
        // moving to right side
        cropSizeWidth +=
            (rightBottomDX - _previousRightBottomDX) * currentRatioWidth;
        cropSizeHeight +=
            (rightBottomDX - _previousRightBottomDX) * currentRatioHeight;
      }

      // check crop size less than declared min crop size. then set to previous size.
      if (cropSizeWidth < minCropSizeWidth ||
              cropSizeHeight < minCropSizeHeight ||
              (rightTopDX - cropSizeWidth) <
                  1 // this condition checks the left top crop button is outside the screen.
          ) {
        print("size: previous default");
        cropSizeWidth = _previousCropWidth;
        cropSizeHeight = _previousCropHeight;
        rightBottomDX = _previousRightBottomDX;
        rightBottomDY = _previousRightBottomDY;
        return;
      }

      SetImageRatio.setRightTopCropButtonPosition(
          rightTopDx: rightBottomDX,
          rightTopDy: rightBottomDY - cropSizeHeight);
      SetImageRatio.setLeftTopCropButtonPosition(
          leftTopDx: rightTopDX - cropSizeWidth, leftTopDy: rightTopDY);
      SetImageRatio.setLeftBottomCropButtonPosition(
          leftBottomDx: leftTopDX, leftBottomDy: leftTopDY + cropSizeHeight);
    }
  }

  /// Manage square on drag.
  void _manageSquareDrag(
      state, DragUpdateDetails details, DragDirection dragDirection) {
    var globalPositionDX = details.globalPosition.dx - startedDX;
    var globalPositionDY = details.globalPosition.dy - startedDY;

    if (globalPositionDX < -9 ||
        (globalPositionDX + cropSizeWidth + (widget.squareCircleSize! / 5)) >
            MediaQuery.of(context).size.width) {
      globalPositionDX = leftTopDX;
    }

    if (globalPositionDY < -9 ||
        (globalPositionDY + cropSizeHeight + (widget.squareCircleSize! / 5)) >
            imageViewMaxHeight) {
      globalPositionDY = leftTopDY;
    }
    SetImageRatio.setLeftTopCropButtonPosition(
        leftTopDx: globalPositionDX, leftTopDy: globalPositionDY);
    SetImageRatio.setLeftBottomCropButtonPosition(
        leftBottomDx: leftTopDX, leftBottomDy: leftTopDY + cropSizeHeight);
    SetImageRatio.setRightTopCropButtonPosition(
        rightTopDx: leftTopDX + cropSizeWidth, rightTopDy: leftTopDY);
    SetImageRatio.setRightBottomCropButtonPosition(
        rightBottomDx: rightTopDX, rightBottomDy: rightTopDY + cropSizeHeight);
  }
}
