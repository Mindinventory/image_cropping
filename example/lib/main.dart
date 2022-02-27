import 'dart:typed_data';

import 'package:example/constants/colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:image_cropping/image_cropping.dart';
import 'package:image_picker/image_picker.dart';

import 'constants/strings.dart';

void main() {
  runApp(
    MaterialApp(
      debugShowCheckedModeBanner: false,
      builder: EasyLoading.init(),
      home: MyApp(),
    ),
  );
}

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> with WidgetsBindingObserver {
  /// set the images bytes
  Uint8List? imageBytes;

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance!.addObserver(this);
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: Container(
          color: AppColors.grey,
          child: Center(
            child: Center(
              child: InkWell(
                child: imageBytes == null
                    ? Icon(
                        Icons.add_photo_alternate_outlined,
                        color: AppColors.black,
                      )
                    : Image.memory(imageBytes!),
                onTap: () {
                  showImagePickerDialog();
                },
              ),
            ),
          ),
        ),
      ),
    );
  }

  /// Image Picker dialog with Open Camera, Open Gallery and cancel button.
  Future<void> showImagePickerDialog() async {
    Dialog dialog = Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
      //this right here
      child: Container(
        height: 200.0,
        width: 200.0,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Padding(
              padding: EdgeInsets.all(15.0),
              child: Text(
                Strings.kSelectImageSource,
                style: TextStyle(color: AppColors.red),
              ),
            ),
            Padding(
              padding: EdgeInsets.only(top: 50.0),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                AppDialogButton(
                  buttonTitle: Strings.kCamera,
                  onPressed: () {
                    back();
                    openImagePicker(ImageSource.camera);
                  },
                ),
                AppDialogButton(
                  buttonTitle: Strings.kGallery,
                  onPressed: () {
                    back();
                    openImagePicker(ImageSource.gallery);
                  },
                ),
                AppDialogButton(
                  buttonTitle: Strings.kCancel,
                  onPressed: () {
                    back();
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );

    /// To display a dialog
    showDialog(
      context: context,
      builder: (BuildContext context) => dialog,
      barrierDismissible: false,
    );
  }

  /// Open image picker
  void openImagePicker(source) async {
    showLoader();
    final pickedFile = await ImagePicker()
        .pickImage(source: source, maxWidth: 1920, maxHeight: 1920);
    imageBytes = await pickedFile?.readAsBytes();

    if (imageBytes != null) {
      ImageCropping.cropImage(
        context: context,
        imageBytes: imageBytes!,
        onImageDoneListener: (data) {
          setState(
            () {
              imageBytes = data;
            },
          );
        },
        onImageStartLoading: showLoader,
        onImageEndLoading: hideLoader,
        selectedImageRatio: ImageRatio.RATIO_1_1,
        visibleOtherAspectRatios: true,
        squareBorderWidth: 2,
        squareCircleColor: AppColors.red,
        defaultTextColor: AppColors.black,
        selectedTextColor: AppColors.orange,
        colorForWhiteSpace: AppColors.white,
      );
    }
  }

  /// To display loader with loading text
  void showLoader() {
    if (EasyLoading.isShow) {
      return;
    }
    EasyLoading.show(status: Strings.kLoading);
  }

  /// To hide loader
  void hideLoader() {
    EasyLoading.dismiss();
  }

  /// to pop from current
  void back() {
    Navigator.of(context).pop();
  }
}

/// class for dialog button
class AppDialogButton extends StatefulWidget {
  final String buttonTitle;
  final VoidCallback onPressed;

  const AppDialogButton(
      {Key? key, required this.buttonTitle, required this.onPressed})
      : super(key: key);

  @override
  State<AppDialogButton> createState() => AppDialogButtonState();
}

class AppDialogButtonState extends State<AppDialogButton> {
  Uint8List? imageBytes;

  @override
  Widget build(BuildContext context) {
    return TextButton(
      onPressed: widget.onPressed,
      child: Text(
        widget.buttonTitle,
        style: TextStyle(color: AppColors.purple, fontSize: 18.0),
      ),
    );
  }
}
