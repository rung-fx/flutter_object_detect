import 'dart:io';

import 'package:flutter/material.dart';

import 'package:get/get.dart';
import 'package:poc_detect_object_tflite/default_button.dart';
import 'package:poc_detect_object_tflite/object_painter.dart';
import 'package:poc_detect_object_tflite/test_controller.dart';

class HomeView extends GetView<TestController> {
  const HomeView({super.key});

  @override
  Widget build(BuildContext context) {
    Get.put(TestController());
    return GetBuilder<TestController>(
      builder: (context) {
        return Scaffold(
          appBar: AppBar(
            title: const Text("Object Detector"),
          ),
          body: Padding(
            padding: const EdgeInsets.all(8.0),
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: Column(
                children: [
                  // original image
                  controller.isLoading.value
                      ? const Center(child: CircularProgressIndicator())
                      : Center(
                          child: Container(
                            width: Get.width,
                            height: 200,
                            padding: const EdgeInsets.all(5),
                            decoration: BoxDecoration(
                              border: Border.all(color: Colors.grey),
                            ),
                            child: (controller
                                    .selectedImagePath.value.isNotEmpty)
                                ? FittedBox(
                                    child: SizedBox(
                                      width:
                                          controller.iimage?.width.toDouble(),
                                      height:
                                          controller.iimage?.height.toDouble(),
                                      child: Image.file(
                                        File(
                                            controller.selectedImagePath.value),
                                      ),
                                    ),
                                  )
                                : const Center(
                                    child: Text('No image selected')),
                          ),
                        ),
                  DefaultButton(
                    press: () {
                      controller.getImageAndDetectObjects();
                    },
                    text: "Pick Image",
                  ),
                  // original image with object painter
                  Container(
                    width: Get.width,
                    height: 200,
                    padding: const EdgeInsets.all(5),
                    decoration:
                        BoxDecoration(border: Border.all(color: Colors.grey)),
                    child: (controller.iimageFile != null)
                        ? FittedBox(
                            child: SizedBox(
                              width: controller.iimage?.width.toDouble(),
                              height: controller.iimage?.height.toDouble(),
                              child: controller.iimage != null &&
                                      controller.objectss != null
                                  ? CustomPaint(
                                      painter: ObjectPainter(controller.iimage!,
                                          controller.objectss!))
                                  : const SizedBox(),
                            ),
                          )
                        : const Center(
                            child: Text('No object detected in image')),
                  ),
                  const SizedBox(height: 5),
                  Container(
                    width: Get.width,
                    padding: const EdgeInsets.all(5),
                    decoration:
                        BoxDecoration(border: Border.all(color: Colors.grey)),
                    child: (controller.imageCrop.isNotEmpty)
                        ? ListView.builder(
                            physics: const NeverScrollableScrollPhysics(),
                            shrinkWrap: true,
                            itemCount: controller.imageCrop.length,
                            itemBuilder: (context, index) {
                              File? item = controller.imageCrop[index];

                              return Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Image.file(
                                    item!,
                                    height: 200,
                                    fit: BoxFit.fitHeight,
                                  ),
                                  Container(
                                    width: double.maxFinite,
                                    alignment: Alignment.center,
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 12),
                                    child: controller.paletteGenerator != null
                                        ? Wrap(
                                            spacing: 8,
                                            runSpacing: 8,
                                            children: controller
                                                .paletteGenerator!.colors
                                                .map((color) {
                                              return Container(
                                                width: 30,
                                                height: 30,
                                                decoration: BoxDecoration(
                                                  color: color,
                                                  borderRadius:
                                                      BorderRadius.circular(8),
                                                ),
                                              );
                                            }).toList(),
                                          )
                                        : const SizedBox(),
                                  ),
                                  controller.predictedResult.isNotEmpty
                                      ? Text(
                                          '${controller.predictedResult[0]['label']} ${controller.predictedResult[0]['confidence']}')
                                      : const SizedBox(),
                                ],
                              );
                            },
                          )
                        : const Center(child: Text('No crop image')),
                  ),
                  const SizedBox(height: 5),
                  // Container(
                  //   width: Get.width,
                  //   padding: const EdgeInsets.all(5),
                  //   decoration:
                  //       BoxDecoration(border: Border.all(color: Colors.grey)),
                  //   child: controller.showBytes != null
                  //       ? Image.memory(
                  //           controller.showBytes!,
                  //     height: 400,
                  //         )
                  //       : const SizedBox(),
                  // ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
