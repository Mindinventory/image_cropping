# image_cropping


<a href="https://pub.dev/packages/image_cropping"><img src="https://img.shields.io/pub/v/image_cropping.svg?label=image_cropping" alt="image_cropping version"></a>
<a href="https://github.com/Mindinventory/image_cropping"><img src="https://img.shields.io/github/stars/Mindinventory/image_cropping?style=social" alt="MIT License"></a>
<a href="https://developer.android.com" style="pointer-events: stroke;" target="_blank">
<img src="https://img.shields.io/badge/platform-android-blue">
</a>
<a href="https://developer.apple.com/ios/" style="pointer-events: stroke;" target="_blank">
<img src="https://img.shields.io/badge/platform-iOS-blue">
</a>
<a href="" style="pointer-events: stroke;" target="_blank">
<img src="https://img.shields.io/badge/platform-Linux-blue">
</a>
<a href="" style="pointer-events: stroke;" target="_blank">
<img src="https://img.shields.io/badge/platform-Mac-blue">
</a>
<a href="" style="pointer-events: stroke;" target="_blank">
<img src="https://img.shields.io/badge/platform-web-blue">
</a>
<a href="" style="pointer-events: stroke;" target="_blank">
<img src="https://img.shields.io/badge/platform-Windows-blue">
</a>
<a href="https://opensource.org/licenses/MIT"><img src="https://img.shields.io/badge/license-MIT-purple.svg" alt="MIT License"></a>

This plugin supports cropping and rotating images for multiplatform. It Allow inclusion of background, Rotation of image, changing ratio of selection as per requirements.


### Allow inclusion of background.
![Image Plugin](https://github.com/Mindinventory/image_cropping/blob/master/assets/image_plugin_1.gif)

### Rotation of image.
![Image Plugin](https://github.com/Mindinventory/image_cropping/blob/master/assets/image_plugin_2.gif)

### Change ratio of selection.
![Image Plugin](https://github.com/Mindinventory/image_cropping/blob/master/assets/image_plugin_3.gif)

## Installation
If you are targeting web, don't forget to add worker.js in your project's root directory.

You can also add worker.js.deps and worker.js.map but they are optional and only used for development.

These 3 files are generated when running the following command in the example folder:
``` bash
dart compile js -O1 -o web/worker.js lib/worker.dart
```
For more details on the command, check [this link](https://dart.dev/tools/dart2js).
It converts the dart code to JS, which will then be run in a web worker.

### Example
``` dart
final croppedBytes = await ImageCropping.cropImage(
    context: context,
    imageBytes: bytes,
    onImageStartLoading: () {
        showLoader();
    },
    onImageEndLoading: () {
        hideLoader();
    },
    onImageDoneListener: (data) {
        // You can also use a listener instead of awaiting the function
        setState(() {
          imageBytes = data;
        });
    },
    selectedImageRatio: ImageRatio.RATIO_1_1,
    visibleOtherAspectRatios: true,
    squareBorderWidth: 2,
    squareCircleColor: Colors.black,
    defaultTextColor: Colors.orange,
    selectedTextColor: Colors.black,
    colorForWhiteSpace: Colors.grey,
    encodingQuality: 80,
    outputImageFormat: OutputImageFormat.jpg, 
    workerPath: 'crop_worker.js',
);
```

### Required parameters

##### BuildContext:
Context is use to push new screen for image cropping.

##### _imageBytes:
Image bytes is use to draw image in device and if image not fits in device screen then we manage background color(if you have passed colorForWhiteSpace or else White background) in image cropping screen.

##### _onImageStartLoading:
This is a callback. you have to override and show dialog or etc when image cropping is in loading state.

##### _onImageEndLoading:
This is a callback. you have to override and hide dialog or etc when image cropping is ready to show result in cropping screen.

##### _onImageDoneListener:
This is a callback. you have to override and you will get Uint8List as result.

## Optional parameters

##### ImageRatio:
This property contains ImageRatio value. You can set the initialized aspect ratio when starting the cropper by passing a value of ImageRatio. default value is `ImageRatio.FREE`

##### visibleOtherAspectRatios:
This property contains boolean value. If this properties is true then it shows all other aspect ratios in cropping screen. default value is `true`.

##### squareBorderWidth:
This property contains double value. You can change square border width by passing this value.

##### squareCircleColor:
This property contains Color value. You can change square circle color by passing this value.

#####  defaultTextColor:
This property contains Color value. By passing this property you can set aspect ratios color which are unselected.

##### selectedTextColor:
This property contains Color value. By passing this property you can set aspect ratios color which is selected.

##### colorForWhiteSpace:
This property contains Color value. By passing this property you can set background color, if screen contains blank space.

##### encodingQuality
Set the encodingQuality of the cropped image. Defaults to 100 (max).
High quality involves bigger image file size.

#### outputImageFormat
Output format of cropped image, can be PNG or JPG, default is JPG.

##### workerPath
You may want to change the worker.js name, especially if you use other web workers and you already have a worker.js file.
Defaults to 'worker.js'.

## Note:
For flutter web, copy worker.js from example folder to the project, else it will not work.
The result returns in Uint8List. so it can be lost later, you are responsible for storing it somewhere permanent (if needed).

## Guideline for contributors
Contribution towards our repository is always welcome, we request contributors to create a pull request to the develop branch only.

## Guideline to report an issue/feature request
It would be great for us if the reporter can share the below things to understand the root cause of the issue.
- Library version
- Code snippet
- Logs if applicable
- Device specification like (Manufacturer, OS version, etc)
- Screenshot/video with steps to reproduce the issue

## Library used
- [Image](https://pub.dev/packages/image "Image")

# LICENSE!
Image Cropper is [MIT-licensed](https://github.com/Mindinventory/image_cropping/blob/master/LICENSE "MIT-licensed").

# Let us know!
We’d be really happy if you send us links to your projects where you use our component. Just send an email to sales@mindinventory.com And do let us know if you have any questions or suggestion regarding our work.
