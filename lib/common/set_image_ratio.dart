part of image_cropping;

class SetImageRatio {
  static void setImageRatio(
      ImageRatio? imageRatio, CropAspectRatio? aspectRatio, {double? width, double? height}) {
    if (imageRatio != null) {
      switch (imageRatio) {
        case ImageRatio.RATIO_1_2:
          currentRatioWidth = 1;
          currentRatioHeight = 2;
          break;
        case ImageRatio.RATIO_3_2:
          currentRatioWidth = 3;
          currentRatioHeight = 2;
          break;
        case ImageRatio.RATIO_4_3:
          currentRatioWidth = 4;
          currentRatioHeight = 3;
          break;
        case ImageRatio.RATIO_16_9:
          currentRatioWidth = 16;
          currentRatioHeight = 9;
          break;
        default:
          currentRatioWidth = 1;
          currentRatioHeight = 1;
      }
    } else {
      if (aspectRatio!.ratioX == 0 && aspectRatio.ratioY == 0) {
        currentRatioWidth = 1;
        currentRatioHeight = 1;
      } else {
        currentRatioWidth = aspectRatio.ratioX.toDouble();
        currentRatioHeight = aspectRatio.ratioY.toDouble();
      }
    }
    cropSizeWidth = width ?? defaultCropSize;
    cropSizeHeight = height ?? (defaultCropSize * currentRatioHeight) / currentRatioWidth;
    if (imageRatio != null)
      selectedImageRatio = CropAspectRatio.fromRation(imageRatio);
    else {
      selectedImageRatio = aspectRatio ?? CropAspectRatio.free();
    }
    setDefaultButtonPosition();
  }

  /// set position of all dot buttons.
  static void setDefaultButtonPosition() {
    setLeftTopCropButtonPosition();
    setLeftBottomCropButtonPosition();
    setRightTopCropButtonPosition();
    setRightBottomCropButtonPosition();
  }

  /// set left top crop button on screen.
  static void setLeftTopCropButtonPosition({leftTopDx = -1, leftTopDy = -1}) {
    leftTopDX =
        (leftTopDx == -1) ? (deviceWidth / 2) - (cropSizeWidth / 2) : leftTopDx;
    leftTopDY =
        (leftTopDy == -1) ? (deviceHeight / 2) - cropSizeHeight : leftTopDy;
  }

  /// set left bottom crop button on screen.
  static void setLeftBottomCropButtonPosition(
      {leftBottomDx = -1, leftBottomDy = -1}) {
    leftBottomDX = (leftBottomDx == -1) ? leftTopDX : leftBottomDx;
    leftBottomDY =
        (leftBottomDy == -1) ? leftTopDY + cropSizeHeight : leftBottomDy;
  }

  /// set right top crop button on screen.
  static void setRightTopCropButtonPosition(
      {rightTopDx = -1, rightTopDy = -1}) {
    rightTopDX = (rightTopDx == -1) ? leftTopDX + cropSizeWidth : rightTopDx;
    rightTopDY = (rightTopDy == -1) ? leftTopDY : rightTopDy;
  }

  /// set right bottom crop button on screen.
  static void setRightBottomCropButtonPosition(
      {rightBottomDx = -1, rightBottomDy = -1}) {
    rightBottomDX =
        (rightBottomDx == -1) ? leftTopDX + cropSizeWidth : rightBottomDx;
    rightBottomDY =
        (rightBottomDy == -1) ? rightTopDY + cropSizeHeight : rightBottomDy;
  }

  static void setTheWholeImageSize(double squareCircleSize, bool isInitialCrop) {
    cropSizeWidth = (imageGlobalKey.currentContext?.size?.width ?? 0);
    cropSizeHeight = (imageGlobalKey.currentContext?.size?.height ?? 0);
    SetImageRatio.setImageRatio(null, selectedImageRatio,
        width: cropSizeWidth,
        height: cropSizeHeight);
    RenderBox? box = imageGlobalKey.currentContext?.findRenderObject() as RenderBox?;
    Offset? position = box?.localToGlobal(Offset.zero) ?? Offset.zero;

    SetImageRatio.setLeftTopCropButtonPosition(
        leftTopDx: position.dx - (squareCircleSize / 3) - leftViewWidth,
        leftTopDy: position.dy - (squareCircleSize / 3) - topViewHeight);
    SetImageRatio.setLeftBottomCropButtonPosition(
        leftBottomDx: position.dx - (squareCircleSize / 3) - leftViewWidth,
        leftBottomDy: leftTopDY + (imageGlobalKey.currentContext?.size?.height ?? 0));
    SetImageRatio.setRightTopCropButtonPosition(
        rightTopDx:
        position.dx + (imageGlobalKey.currentContext?.size?.width ?? 0) - (squareCircleSize / 3) - leftViewWidth,
        rightTopDy: position.dy - (squareCircleSize / 3) - topViewHeight);
    SetImageRatio.setRightBottomCropButtonPosition(
        rightBottomDx:
        position.dx + (imageGlobalKey.currentContext?.size?.width ?? 0) - (squareCircleSize / 3) - leftViewWidth,
        rightBottomDy: leftTopDY + (imageGlobalKey.currentContext?.size?.height ?? 0));
    isImageLoaded = true;
  }
}
