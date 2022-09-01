part of image_cropping;

/// [ShowCropImageRatios] class shows ratios
class ShowCropImageRatios extends StatefulWidget {
  /// This property contains boolean value.
  /// If this properties is true then it shows all other aspect ratios in cropping2 screen.
  /// default value is `true`.
  final bool? visibleOtherAspectRatios;

  /// This property contains Color value.
  /// By passing this property you can set aspect ratios color which is selected.
  final Color? selectedTextColor;

  /// This property contains Color value.
  /// By passing this property you can set aspect ratios color which are unselected.
  final Color? defaultTextColor;
  final CropAspectRatio? selectedImageRatio;
  final state;
  List<CropAspectRatio>? customAspectRatios;

  ShowCropImageRatios({
    this.visibleOtherAspectRatios,
    this.selectedImageRatio,
    this.selectedTextColor,
    this.defaultTextColor,
    this.customAspectRatios,
    this.state,
    Key? key,
  }) : super(key: key);

  @override
  _ShowCropImageRatiosState createState() => _ShowCropImageRatiosState();
}

class _ShowCropImageRatiosState extends State<ShowCropImageRatios> {
  @override
  void initState() {
    /// Set Image ratio for cropping2 the image.
    SetImageRatio.setImageRatio(
        null, widget.selectedImageRatio ?? CropAspectRatio.free());

    /// Set default button position (left, right, top, bottom) in center of the screen.
    SetImageRatio.setDefaultButtonPosition();

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Visibility(
      visible: widget.visibleOtherAspectRatios!,
      child: Padding(
        padding: const EdgeInsets.all(10.0),
        child: Row(
          mainAxisAlignment:
              (kIsWeb) ? MainAxisAlignment.end : MainAxisAlignment.spaceAround,
          children: [
            /// This is for free cropping ratio.
            InkWell(
              onTap: () {
                changeImageRatio(widget.state, ImageRatio.FREE);
              },
              child: Text(
                Strings.ratioFree,
                style: TextStyle(
                  color: (selectedImageRatio.equals(ImageRatio.FREE))
                      ? widget.selectedTextColor
                      : widget.defaultTextColor,
                ),
              ),
            ),
            for (final CropAspectRatio ratio
                in widget.customAspectRatios ?? []) ...[
              SizedBox(
                width: (kIsWeb) ? 20 : 0,
              ),
              InkWell(
                onTap: () {
                  changeImageRatio(widget.state, null, aspectRatio: ratio);
                },
                child: Text(
                  '${ratio.ratioX}:${ratio.ratioY}',
                  style: TextStyle(
                    color: (selectedImageRatio == ratio)
                        ? widget.selectedTextColor
                        : widget.defaultTextColor,
                  ),
                ),
              ),
            ],
            SizedBox(
              width: (kIsWeb) ? 20 : 0,
            ),

            /// This is for 1:1 cropping ratio.
            InkWell(
              onTap: () {
                changeImageRatio(widget.state, ImageRatio.RATIO_1_1);
              },
              child: Text(
                Strings.ratio_1_1,
                style: TextStyle(
                  color:
                      (selectedImageRatio.equals(ImageRatio.RATIO_1_1) == true)
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
                changeImageRatio(widget.state, ImageRatio.RATIO_1_2);
              },
              child: Text(
                Strings.ratio_1_2,
                style: TextStyle(
                  color: ((selectedImageRatio.equals(ImageRatio.RATIO_1_2) ==
                          true))
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
                changeImageRatio(widget.state, ImageRatio.RATIO_3_2);
              },
              child: Text(
                Strings.ratio_3_2,
                style: TextStyle(
                  color: ((selectedImageRatio.equals(ImageRatio.RATIO_3_2) ==
                          true))
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
                changeImageRatio(widget.state, ImageRatio.RATIO_4_3);
              },
              child: Text(
                Strings.ratio_4_3,
                style: TextStyle(
                  color:
                      (selectedImageRatio.equals(ImageRatio.RATIO_4_3) == true)
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
                changeImageRatio(widget.state, ImageRatio.RATIO_16_9);
              },
              child: Text(
                Strings.ratio_16_9,
                style: TextStyle(
                  color:
                      (selectedImageRatio.equals(ImageRatio.RATIO_16_9) == true)
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

  /// Set crop ratio and again render the screen.
  void changeImageRatio(state, ImageRatio? imageRatio,
      {CropAspectRatio? aspectRatio}) {
    SetImageRatio.setImageRatio(imageRatio, aspectRatio);
    state(() {});
  }
}
