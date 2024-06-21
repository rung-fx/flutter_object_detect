import 'dart:async';
import 'dart:io';
import 'dart:math';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image/image.dart' as img;

import 'package:tflite_v2/tflite_v2.dart';
import 'package:image_picker/image_picker.dart';

class TestTf extends StatefulWidget {
  const TestTf({super.key});

  @override
  State<TestTf> createState() => _TestTfState();
}

class _TestTfState extends State<TestTf> {
  File? _image;
  List? _recognitions;
  String _model = 'mobile';
  double? _imageHeight;
  double? _imageWidth;
  bool _busy = false;

  Future predictImagePicker() async {
    var image = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (image == null) {
      return;
    }

    _busy = true;
    setState(() {});

    predictImage(File(image.path));
  }

  Future predictImage(File image) async {
    switch (_model) {
      case 'yolo':
        await yolov2Tiny(image);
        break;
      case 'ssd':
        await ssdMobileNet(image);
        break;
      case 'deeplab':
        await segmentMobileNet(image);
        break;
      case 'posenet':
        await poseNet(image);
        break;
      default:
        await recognizeImage(image);
    }

    FileImage(image).resolve(const ImageConfiguration()).addListener(
      ImageStreamListener(
        (ImageInfo info, bool _) {
          _imageHeight = info.image.height.toDouble();
          _imageWidth = info.image.width.toDouble();
          setState(() {});
        },
      ),
    );

    _image = image;
    _busy = false;
    setState(() {});
  }

  @override
  void initState() {
    super.initState();

    _busy = true;

    loadModel().then(
      (val) {
        _busy = false;
        setState(() {});
      },
    );
  }

  Future loadModel() async {
    Tflite.close();
    try {
      String? res;
      switch (_model) {
        case 'yolo':
          res = await Tflite.loadModel(
            model: "assets/test_model/yolov2_tiny.tflite",
            labels: "assets/test_model/yolov2_tiny.txt",
          );
          break;
        case 'ssd':
          res = await Tflite.loadModel(
            model: "assets/test_model/ssd_mobilenet.tflite",
            labels: "assets/test_model/ssd_mobilenet.txt",
          );
          break;
        case 'deeplab':
          res = await Tflite.loadModel(
            model: "assets/test_model/deeplabv3_257_mv_gpu.tflite",
            labels: "assets/test_model/deeplabv3_257_mv_gpu.txt",
          );
          break;
        case 'posenet':
          res = await Tflite.loadModel(
            model:
                "assets/test_model/posenet_mv1_075_float_from_checkpoints.tflite",
          );
          break;
        default:
          res = await Tflite.loadModel(
            // model: "assets/test_model/mobilenet_v1_1.0_224.tflite",
            // labels: "assets/test_model/mobilenet_v1_1.0_224.txt",
            model: "assets/breathalyzer_model/model_unquant.tflite",
            labels: "assets/breathalyzer_model/labels.txt",
          );
      }
      print(res);
    } on PlatformException {
      print('Failed to load model.');
    }
  }

  Uint8List imageToByteListFloat32(
      img.Image image, int inputSize, double mean, double std) {
    var convertedBytes = Float32List(1 * inputSize * inputSize * 3);

    return convertedBytes.buffer.asUint8List();
  }

  Uint8List imageToByteListUint8(img.Image image, int inputSize) {
    var convertedBytes = Uint8List(1 * inputSize * inputSize * 3);

    return convertedBytes.buffer.asUint8List();
  }

  Future recognizeImage(File image) async {
    int startTime = DateTime.now().millisecondsSinceEpoch;
    var recognitions = await Tflite.runModelOnImage(
      path: image.path,
      numResults: 6,
      threshold: 0.3,
      imageMean: 127.5,
      imageStd: 127.5,
    );

    _recognitions = recognitions;
    setState(() {});

    int endTime = DateTime.now().millisecondsSinceEpoch;
    print("Inference took ${endTime - startTime}ms");
  }

  Future yolov2Tiny(File image) async {
    int startTime = DateTime.now().millisecondsSinceEpoch;
    var recognitions = await Tflite.detectObjectOnImage(
      path: image.path,
      model: "YOLO",
      threshold: 0.3,
      imageMean: 0.0,
      imageStd: 255.0,
      numResultsPerClass: 1,
    );

    _recognitions = recognitions;
    setState(() {});

    int endTime = DateTime.now().millisecondsSinceEpoch;
    print("Inference took ${endTime - startTime}ms");
  }

  Future ssdMobileNet(File image) async {
    int startTime = DateTime.now().millisecondsSinceEpoch;
    var recognitions = await Tflite.detectObjectOnImage(
      path: image.path,
      numResultsPerClass: 1,
    );

    _recognitions = recognitions;
    setState(() {});

    int endTime = DateTime.now().millisecondsSinceEpoch;
    print("Inference took ${endTime - startTime}ms");
  }

  Future segmentMobileNet(File image) async {
    int startTime = DateTime.now().millisecondsSinceEpoch;
    var recognitions = await Tflite.runSegmentationOnImage(
      path: image.path,
      imageMean: 127.5,
      imageStd: 127.5,
    );

    _recognitions = recognitions;
    setState(() {});

    int endTime = DateTime.now().millisecondsSinceEpoch;
    print("Inference took ${endTime - startTime}");
  }

  Future poseNet(File image) async {
    int startTime = DateTime.now().millisecondsSinceEpoch;
    var recognitions = await Tflite.runPoseNetOnImage(
      path: image.path,
      numResults: 2,
    );

    print(recognitions);

    _recognitions = recognitions;
    setState(() {});

    int endTime = DateTime.now().millisecondsSinceEpoch;
    print("Inference took ${endTime - startTime}ms");
  }

  onSelect(model) async {
    _busy = true;
    _model = model;
    _recognitions = null;
    setState(() {});
    await loadModel();

    if (_image != null) {
      predictImage(_image!);
    } else {
      _busy = false;
      setState(() {});
    }
  }

  List<Widget> renderBoxes(Size screen) {
    if (_recognitions == null) return [];
    if (_imageHeight == null || _imageWidth == null) return [];

    double factorX = screen.width;
    double factorY = _imageHeight! / _imageWidth! * screen.width;
    Color blue = const Color.fromRGBO(37, 213, 253, 1.0);
    return _recognitions!.map(
      (re) {
        return Positioned(
          left: re["rect"]["x"] * factorX,
          top: re["rect"]["y"] * factorY,
          width: re["rect"]["w"] * factorX,
          height: re["rect"]["h"] * factorY,
          child: Container(
            decoration: BoxDecoration(
              borderRadius: const BorderRadius.all(Radius.circular(8.0)),
              border: Border.all(
                color: blue,
                width: 2,
              ),
            ),
            child: Text(
              "${re["detectedClass"]} ${(re["confidenceInClass"] * 100).toStringAsFixed(0)}%",
              style: TextStyle(
                background: Paint()..color = blue,
                color: Colors.white,
                fontSize: 12.0,
              ),
            ),
          ),
        );
      },
    ).toList();
  }

  List<Widget> renderKeypoints(Size screen) {
    if (_recognitions == null) return [];
    if (_imageHeight == null || _imageWidth == null) return [];

    double factorX = screen.width;
    double factorY = _imageHeight! / _imageWidth! * screen.width;

    var lists = <Widget>[];
    for (var re in _recognitions!) {
      var color = Color((Random().nextDouble() * 0xFFFFFF).toInt() << 0)
          .withOpacity(1.0);
      var list = re["keypoints"].values.map<Widget>(
        (k) {
          return Positioned(
            left: k["x"] * factorX - 6,
            top: k["y"] * factorY - 6,
            width: 100,
            height: 12,
            child: Text(
              "● ${k["part"]}",
              style: TextStyle(
                color: color,
                fontSize: 12.0,
              ),
            ),
          );
        },
      ).toList();

      lists.addAll(list);
    }

    return lists;
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    List<Widget> stackChildren = [];

    if (_model == 'deeplab' && _recognitions != null) {
      stackChildren.add(
        Positioned(
          top: 0.0,
          left: 0.0,
          width: size.width,
          child: _image == null
              ? const Text('No image selected.')
              : Image.file(_image!),
        ),
      );
    } else {
      stackChildren.add(
        Positioned(
          top: 0.0,
          left: 0.0,
          width: size.width,
          child: _image == null
              ? const Text('No image selected.')
              : Image.file(_image!),
        ),
      );
    }

    if (_model == 'mobile') {
      stackChildren.add(
        Center(
          child: Column(
            children: _recognitions != null
                ? _recognitions!.map(
                    (res) {
                      return Text(
                        "${res["index"]} - ${res["label"]}: ${res["confidence"].toStringAsFixed(3)}",
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: 20.0,
                          background: Paint()..color = Colors.white,
                        ),
                      );
                    },
                  ).toList()
                : [],
          ),
        ),
      );
    } else if (_model == 'ssd' || _model == 'yolo') {
      stackChildren.addAll(renderBoxes(size));
    } else if (_model == 'posenet') {
      stackChildren.addAll(renderKeypoints(size));
    }

    if (_busy) {
      stackChildren.add(
        const Opacity(
          opacity: 0.3,
          child: ModalBarrier(
            dismissible: false,
            color: Colors.grey,
          ),
        ),
      );
      stackChildren.add(
        const Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('tflite example app'),
      ),
      body: Stack(
        children: stackChildren,
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: predictImagePicker,
        tooltip: 'Pick Image',
        child: const Icon(Icons.image),
      ),
    );
  }
}
