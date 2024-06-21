// import 'dart:io';
//
// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'package:get/get.dart';
// import 'package:google_mlkit_object_detection/google_mlkit_object_detection.dart';
// import 'dart:ui' as ui;
// import 'package:image_picker/image_picker.dart';
// import 'package:image/image.dart' as img;
// import 'package:path_provider/path_provider.dart';
//
// class HomeController extends GetxController {
//   var selectedImagePath = ''.obs;
//   RxBool isLoading = false.obs;
//   XFile? iimageFile;
//   List<DetectedObject>? objectss;
//   ui.Image? iimage;
//
//   Uint8List? imageBytes;
//   File? imageCrop;
//
//   Future<void> getImageAndDetectObjects() async {
//     final imageFile =
//         (await ImagePicker().pickImage(source: ImageSource.gallery));
//     isLoading.value = true;
//     selectedImagePath.value = imageFile!.path;
//     final image = InputImage.fromFilePath(imageFile.path);
//     var objectDetector = ObjectDetector(
//       options: ObjectDetectorOptions(
//         mode: DetectionMode.single,
//         classifyObjects: true,
//         multipleObjects: true,
//       ),
//     );
//
//     List<DetectedObject> objects = await objectDetector.processImage(image);
//     List<Map<String, int>> objectMaps = [];
//     for (DetectedObject object in objects) {
//       int x = object.boundingBox.left.toInt();
//       int y = object.boundingBox.top.toInt();
//       int w = object.boundingBox.width.toInt();
//       int h = object.boundingBox.height.toInt();
//       Map<String, int> thisMap = {'x': x, 'y': y, 'w': w, 'h': h};
//       objectMaps.add(thisMap);
//     }
//
//     imageBytes = File(imageFile.path).readAsBytesSync();
//
//     imageCrop = await _cropImageFile(
//       byteData: imageBytes!,
//       x: objectMaps[0]['x'] ?? 0,
//       y: objectMaps[0]['y'] ?? 0,
//       width: objectMaps[0]['w'] ?? 0,
//       height: objectMaps[0]['h'] ?? 0,
//     );
//
//     iimageFile = imageFile;
//     objectss = objects;
//     _loadImage(imageFile);
//
//     update();
//     isLoading.value = false;
//   }
//
//   Future<String> _imageFolder() async {
//     Directory documentDir = await getApplicationDocumentsDirectory();
//     String imageFolder = '${documentDir.path}/image';
//
//     Directory dir = Directory(imageFolder);
//     if (!dir.existsSync()) {
//       dir.createSync();
//     }
//
//     return imageFolder;
//   }
//
//   Future<File?> _cropImageFile({
//     required Uint8List byteData,
//     required int x,
//     required int y,
//     required int width,
//     required int height,
//   }) async {
//     String imageFolder = await _imageFolder();
//
//     final tempFile = File('$imageFolder/temp.png');
//
//     await tempFile.writeAsBytes(
//       byteData.buffer.asUint8List(
//         byteData.offsetInBytes,
//         byteData.lengthInBytes,
//       ),
//     );
//
//     final image = await img.decodeImageFile(tempFile.path);
//     if (image == null) {
//       return null;
//     }
//
//     final croppedImage = img.copyCrop(
//       image,
//       x: x,
//       y: y,
//       width: width,
//       height: height,
//     );
//
//     final croppedImageBytes = img.encodePng(croppedImage);
//     File result = File('$imageFolder/result.png');
//
//     return await result.writeAsBytes(croppedImageBytes);
//   }
//
//   _loadImage(XFile file) async {
//     final data = await file.readAsBytes();
//     await decodeImageFromList(data).then((value) => iimage = value);
//
//     update();
//   }
// }
