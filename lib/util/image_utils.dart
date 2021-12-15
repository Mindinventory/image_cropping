import 'package:image/image.dart' as Library;

Library.Image setWhiteColorInImage(
    Library.Image image,
    int colorForWhiteSpace,
    double imageWidth,
    double imageHeight,
    double renderedImageWidth,
    double renderedImageHeight,
    double stackWidth,
    double stackHeight) {
  bool isWhiteVisibleInScreenWidth = stackWidth > renderedImageWidth;
  bool isWhiteVisibleInScreenHeight = stackHeight > renderedImageHeight;

  double finalImageWidth = (stackWidth > imageWidth)
      ? stackWidth
      : (isWhiteVisibleInScreenWidth)
          ? (stackWidth * imageWidth) / renderedImageWidth
          : imageWidth;
  double finalImageHeight = (stackHeight > imageHeight)
      ? stackHeight
      : (isWhiteVisibleInScreenHeight)
          ? (stackHeight * imageHeight) / renderedImageHeight
          : imageHeight;

  int centreImageWidthPoint = ((finalImageWidth / 2) -
          (((finalImageWidth * renderedImageWidth) / stackWidth) / 2))
      .toInt();

  int centreImageHeightPoint = ((finalImageHeight / 2) -
          (((finalImageHeight * renderedImageHeight) / stackHeight) / 2))
      .toInt();

  var whiteImage =
      Library.Image(finalImageWidth.toInt(), finalImageHeight.toInt());
  whiteImage = whiteImage.fill(colorForWhiteSpace);

  var mergedImage = Library.drawImage(whiteImage, image,
      dstX: centreImageWidthPoint, dstY: centreImageHeightPoint);
  return mergedImage;
}
