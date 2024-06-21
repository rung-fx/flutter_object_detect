import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_mlkit_image_labeling/google_mlkit_image_labeling.dart';
import 'package:google_mlkit_object_detection/google_mlkit_object_detection.dart';
import 'package:image_picker/image_picker.dart';

class ImageLabelingPage extends StatefulWidget {
  const ImageLabelingPage({super.key});

  @override
  State<ImageLabelingPage> createState() => _ImageLabelingPageState();
}

class _ImageLabelingPageState extends State<ImageLabelingPage> {
  bool imageLabelChecking = false;
  XFile? imageFile;
  String imageLabel = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
      appBar: AppBar(
        title: const Text(
          'Image Labeling',
        ),
        centerTitle: true,
      ),
      body: SizedBox(
        width: Get.width,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _addImage(),
            const SizedBox(height: 20),
            _labeling(),
          ],
        ),
      ),
    );
  }

  _addImage() {
    return Column(
      children: [
        imageFile != null
            ? Image.file(
                File(imageFile!.path),
                height: 300,
                width: 300,
                fit: BoxFit.fitHeight,
              )
            : Container(
                height: 300,
                width: 300,
                color: Colors.grey.shade300,
              ),
        const SizedBox(height: 20),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _button(
              Icons.camera_alt_outlined,
              'Camera',
              ImageSource.camera,
            ),
            const SizedBox(width: 10),
            _button(
              Icons.image_outlined,
              'Gallery',
              ImageSource.gallery,
            ),
          ],
        ),
      ],
    );
  }

  _button(icon, title, source) {
    return InkWell(
      onTap: () {
        getImage(source);
      },
      child: Container(
        height: 50,
        width: 120,
        decoration: BoxDecoration(
          color: Colors.grey.shade400,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon),
            const SizedBox(width: 10),
            Text(title),
          ],
        ),
      ),
    );
  }

  void getImage(ImageSource source) async {
    try {
      final pickedImage = await ImagePicker().pickImage(source: source);
      if (pickedImage != null) {
        imageLabelChecking = true;
        imageFile = pickedImage;
        setState(() {});
        getImageLabels(pickedImage);
      }
    } catch (e) {
      imageLabelChecking = false;
      imageFile = null;
      imageLabel = "Error occurred while getting image Label";
      setState(() {});
    }
  }

  _labeling() {
    return Text(imageLabel);
  }

  void getImageLabels(XFile image) async {
    final inputImage = InputImage.fromFilePath(image.path);
    ImageLabeler imageLabeler =
        ImageLabeler(options: ImageLabelerOptions());
    List<ImageLabel> labels = await imageLabeler.processImage(inputImage);
    StringBuffer sb = StringBuffer();

    for (ImageLabel imgLabel in labels) {
      String lblText = imgLabel.label;
      double confidence = imgLabel.confidence;
      sb.write(lblText);
      sb.write(" : ");
      sb.write((confidence * 100).toStringAsFixed(2));
      sb.write("%\n");
    }

    imageLabeler.close();
    imageLabel = sb.toString();
    imageLabelChecking = false;

    setState(() {});
  }
}
