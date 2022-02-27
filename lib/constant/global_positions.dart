part of image_cropping;

double leftTopDX = 0;
double leftTopDY = 0;

double leftBottomDX = 0;
double leftBottomDY = 0;

double rightTopDX = 0;
double rightTopDY = 0;

double rightBottomDX = 0;
double rightBottomDY = 0;

double startedDX = 0;
double startedDY = 0;

double imageWidth = 0;
double imageHeight = 0;
double deviceWidth = 0;
double deviceHeight = 0;

double defaultCropSize = 100;
double cropSizeWidth = 100;
double cropSizeHeight = 100;
double minCropSizeWidth = 20;
double minCropSizeHeight = 20;

double currentRatioWidth = 0;
double currentRatioHeight = 0;

/// Image Widget's real size with position based on Stack
Rect rectImageWidget = Rect.zero;
/// Image Widget and Stack's width gap
double gapImageWidth = 0;
/// Image Widget and Stack's height gap
double gapImageHeight = 0;

var currentRotationDegreeValue = 0;

double imageViewMaxHeight = 0;
double imageViewMaxWidth = 0;
double topViewHeight = 0;

Uint8List? finalImageBytes;
late Library.Image libraryImage;

ImageRatio? selectedImageRatio;
