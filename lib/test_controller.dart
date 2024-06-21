import 'dart:developer';
import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'package:google_mlkit_object_detection/google_mlkit_object_detection.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:image/image.dart' as img;
import 'package:palette_generator/palette_generator.dart';
import 'package:poc_detect_object_tflite/detector.dart';
import 'package:tflite_v2/tflite_v2.dart';

class TestController extends GetxController {
  var selectedImagePath = ''.obs;
  RxBool isLoading = false.obs;
  XFile? iimageFile;
  List<DetectedObject>? objectss;
  ui.Image? iimage;

  Uint8List? imageBytes;
  List<File?> imageCrop = [];

  PaletteGenerator? paletteGenerator;

  List predictedResult = [];
  Uint8List? showBytes;
  List<Uint8List> bytesList = [];

  Future<void> getImageAndDetectObjects() async {
    imageCrop.clear();

    final imageFile =
        (await ImagePicker().pickImage(source: ImageSource.gallery));
    isLoading.value = true;
    selectedImagePath.value = imageFile!.path;
    final image = InputImage.fromFilePath(imageFile.path);
    var objectDetector = ObjectDetector(
      options: ObjectDetectorOptions(
        mode: DetectionMode.single,
        classifyObjects: true,
        multipleObjects: true,
      ),
    );

    List<DetectedObject> objects = await objectDetector.processImage(image);
    List<Map<String, int>> objectMaps = [];
    for (DetectedObject object in objects) {
      int x = object.boundingBox.left.toInt();
      int y = object.boundingBox.top.toInt();
      int w = object.boundingBox.width.toInt();
      int h = object.boundingBox.height.toInt();
      Map<String, int> thisMap = {'x': x, 'y': y, 'w': w, 'h': h};
      objectMaps.add(thisMap);
    }

    imageBytes = File(imageFile.path).readAsBytesSync();

    for (var object in objectMaps) {
      int index = objectMaps.indexOf(object);
      log(index.toString());

      var cropData = await _cropImageFile(
        byteData: imageBytes!,
        x: object['x'] ?? 0,
        y: object['y'] ?? 0,
        width: object['w'] ?? 0,
        height: object['h'] ?? 0,
        index: index,
      );

      if (cropData != null) {
        await predictImage(cropData);
        imageCrop.add(cropData);
        print('crop length: ${imageCrop.length}');

        // detectColor(cropData.readAsBytesSync());

        if (predictedResult.isNotEmpty) {
          for (var data in predictedResult) {
            if (data['label'] == '9 breathalyzer') {
              detectColor(cropData.readAsBytesSync());
            }
          }
        }
      }

      // imageCrop.add(cropData);
    }

    iimageFile = imageFile;
    objectss = objects;
    _loadImage(imageFile);

    update();
    isLoading.value = false;
  }

  // Future<PaletteGenerator?> generatorPalette(File? imageFile) async {
  //   if (imageFile == null) {
  //     return null;
  //   }
  //
  //   paletteGenerator = await PaletteGenerator.fromImageProvider(
  //     FileImage(imageFile),
  //     maximumColorCount: 4,
  //   );
  //
  //   return paletteGenerator;
  // }

  Future<String> _imageFolder() async {
    Directory documentDir = await getApplicationDocumentsDirectory();

    String imageFolder = '${documentDir.path}/image';
    log(imageFolder.toString());

    Directory dir = Directory(imageFolder);

    if (!dir.existsSync()) {
      dir.createSync();
    }

    return imageFolder;
  }

  Future<File?> _cropImageFile({
    required Uint8List byteData,
    required int x,
    required int y,
    required int width,
    required int height,
    required int index,
  }) async {
    String imageFolder = await _imageFolder();
    final tempFile = File('$imageFolder/temp.png');

    await tempFile.writeAsBytes(
      byteData.buffer.asUint8List(
        byteData.offsetInBytes,
        byteData.lengthInBytes,
      ),
    );

    final image = await img.decodeImageFile(tempFile.path);
    if (image == null) {
      return null;
    }

    final croppedImage = img.copyCrop(
      image,
      x: x,
      y: y,
      width: width,
      height: height,
    );

    // final adjustImage = img.adjustColor(
    //   croppedImage,
    //   saturation: 2,
    //   gamma: 5,
    //   amount: 100,
    // );

    final croppedImageBytes = img.encodePng(croppedImage);
    final resultFile = File('$imageFolder/result$index.png');
    tempFile.deleteSync();

    //TODO:
    // await generatorPalette(resultFile);
    // await predictImage(resultFile);
    //
    // if (predictedResult.isNotEmpty) {
    //   for (var data in predictedResult) {
    //     if (data['label'] != '0 breathalyzer') {
    //
    //     }
    //   }
    // }

    return await resultFile.writeAsBytes(croppedImageBytes, flush: true);
  }

  _loadImage(XFile file) async {
    final data = await file.readAsBytes();
    await decodeImageFromList(data).then((value) => iimage = value);

    update();
  }

  loadModel() async {
    await Tflite.loadModel(
      model: "assets/breathalyzer_model/model_unquant.tflite",
      labels: "assets/breathalyzer_model/labels.txt",
    );
  }

  predictImage(File image) async {
    List? output = await Tflite.runModelOnImage(
      path: image.path,
      threshold: 0.3,
      imageMean: 127.5,
      imageStd: 127.5,
    );

    log(output.toString());
    predictedResult = output!;
  }

  detectColor(Uint8List imageBytes) async {
    img.Image originalImage = img.decodeImage(imageBytes)!;

    detect(originalImage);
  }

  detect(img.Image image) async {
    final Detector detector = Detector();
    img.Image resize = detector.resizeImage(image);

    img.Image resultImage = await detector.detectCluster(
      resize.clone(),
      minClusterSize: 20,
      maxClusterSize: 1800,
      drawDetected: true,
    );

    final resultBytes = img.encodePng(resultImage);
    showBytes = Uint8List.fromList(resultBytes);
  }
}
