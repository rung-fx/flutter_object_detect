import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:poc_detect_object_tflite/test_controller.dart';
import 'package:tflite_v2/tflite_v2.dart';

class TrainedModelTestPage extends StatefulWidget {
  const TrainedModelTestPage({super.key});

  @override
  State<TrainedModelTestPage> createState() => _TrainedModelTestPageState();
}

class _TrainedModelTestPageState extends State<TrainedModelTestPage> {
  final TestController _testController = Get.put(TestController());

  XFile? imageFile;
  List predictedResult = [];

  @override
  void initState() {
    super.initState();
    _prepareData();
  }

  _prepareData() async {
    await _testController.loadModel();
  }

  @override
  void dispose() {
    super.dispose();
    Tflite.close();
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder<TestController>(
      builder: (context) {
        return Scaffold(
          appBar: AppBar(
            title: const Text('Trained Model'),
            centerTitle: true,
          ),
          body: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: Column(
              children: [
                _addImage(),
                const SizedBox(height: 10),
                _testController.isLoading.value
                    ? const Center(child: CircularProgressIndicator())
                    : _testController.predictedResult.isNotEmpty
                        ? ListView.builder(
                            shrinkWrap: true,
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            itemCount: _testController.predictedResult.length,
                            itemBuilder: (context, index) {
                              return Container(
                                margin:
                                    const EdgeInsets.symmetric(vertical: 4.0),
                                color: Colors.grey.shade300,
                                child: Text(
                                    '${_testController.predictedResult[index]['label']} ${_testController.predictedResult[index]['confidence']}'),
                              );
                            },
                          )
                        : const Text('-'),
                const SizedBox(height: 10),
                // _testController.bytesList.isNotEmpty
                _testController.showBytes != null
                    ? Image.memory(
                        _testController.showBytes!,
                        height: 300,
                      )
                    : const SizedBox(),
              ],
            ),
          ),
        );
      },
    );
  }

  _addImage() {
    return Column(
      children: [
        _testController.imageCrop.isNotEmpty
            ? ListView.builder(
                shrinkWrap: true,
                itemCount: _testController.imageCrop.length,
                itemBuilder: (context, index) {
                  File? item = _testController.imageCrop[index];

                  return Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Image.memory(
                        item!.readAsBytesSync(),
                          height: 150,
                          fit: BoxFit.fitHeight,
                      ),
                    ],
                  );
                },
              )
            : const SizedBox(),
        const SizedBox(height: 20),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _button(
              Icons.image_outlined,
              'Gallery',
            ),
          ],
        ),
      ],
    );
  }

  _button(icon, title) {
    return InkWell(
      onTap: () {
        _testController.getImageAndDetectObjects();
        setState(() {});
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
}
