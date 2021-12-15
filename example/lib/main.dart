import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:image_cropping/constant/enums.dart';
import 'package:image_cropping/image_cropping.dart';
import 'package:image_picker/image_picker.dart';

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
  Uint8List? imageBytes;

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    print('Current state of App :::: $state ');
  }

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
          color: Colors.grey,
          child: Center(
            child: Center(
              child: InkWell(
                child: imageBytes == null
                    ? Icon(
                        Icons.add_photo_alternate_outlined,
                        color: Colors.black,
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
                'Select Image Source',
                style: TextStyle(color: Colors.red),
              ),
            ),
            Padding(
              padding: EdgeInsets.only(top: 50.0),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                    openImagePicker(ImageSource.camera);
                  },
                  child: Text(
                    'Camera',
                    style: TextStyle(color: Colors.purple, fontSize: 18.0),
                  ),
                ),
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                    openImagePicker(ImageSource.gallery);
                  },
                  child: Text(
                    'Gallery',
                    style: TextStyle(color: Colors.purple, fontSize: 18.0),
                  ),
                ),
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: Text(
                    'Cancel',
                    style: TextStyle(color: Colors.purple, fontSize: 18.0),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
    showDialog(
      context: context,
      builder: (BuildContext context) => dialog,
      barrierDismissible: false,
    );
  }

  void openImagePicker(source) async {
    showLoader();
    var pickedFile = await ImagePicker()
        .getImage(source: source, maxWidth: 1920, maxHeight: 1920);

    imageBytes = await pickedFile?.readAsBytes();
    hideLoader();

    ImageCropping.cropImage(
      context,
      imageBytes!,
      () {
        showLoader();
      },
      () {
        hideLoader();
      },
      (data) {
        setState(
          () {
            imageBytes = data;
          },
        );
      },
      selectedImageRatio: ImageRatio.RATIO_1_1,
      visibleOtherAspectRatios: true,
      squareBorderWidth: 2,
      squareCircleColor: Colors.black,
      defaultTextColor: Colors.orange,
      selectedTextColor: Colors.black,
      colorForWhiteSpace: Colors.white,
    );
  }

  void showLoader() {
    if (EasyLoading.isShow) {
      return;
    }
    EasyLoading.show(status: 'Loading...');
  }

  void hideLoader() {
    EasyLoading.dismiss();
  }
}
