part of image_cropping;

class ShowCropImageRatios extends StatefulWidget {
  final bool? visibleOtherAspectRatios;
  final Color? selectedTextColor;
  final Color? defaultTextColor;
  final BuildContext? context;
  final ImageRatio? selectedImageRatio;
  final state;

  ShowCropImageRatios({
    this.visibleOtherAspectRatios,
    this.selectedImageRatio,
    this.selectedTextColor,
    this.defaultTextColor,
    this.context,
    this.state,
    Key? key,
  }) : super(key: key);

  @override
  _ShowCropImageRatiosState createState() => _ShowCropImageRatiosState();
}

class _ShowCropImageRatiosState extends State<ShowCropImageRatios> {
  @override
  void initState() {
    /// Set Image ratio for cropping the image.
    SetImageRatio.setImageRatio(widget.selectedImageRatio!);

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
                  color: (selectedImageRatio == ImageRatio.FREE)
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
                changeImageRatio(widget.state, ImageRatio.RATIO_1_1);
              },
              child: Text(
                Strings.ratio_1_1,
                style: TextStyle(
                  color: (selectedImageRatio == ImageRatio.RATIO_1_1)
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
                  color: (selectedImageRatio == ImageRatio.RATIO_1_2)
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
                  color: (selectedImageRatio == ImageRatio.RATIO_3_2)
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
                  color: (selectedImageRatio == ImageRatio.RATIO_4_3)
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
                  color: (selectedImageRatio == ImageRatio.RATIO_16_9)
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
  void changeImageRatio(state, ImageRatio imageRatio) {
    SetImageRatio.setImageRatio(imageRatio);
    state(() {});
  }
}
