import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:poc_detect_object_tflite/scan_coltroller.dart';

class CameraViewPage extends StatelessWidget {
  const CameraViewPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GetBuilder<ScanController>(
        init: ScanController(),
        builder: (controller) {
          return SizedBox();
          // return CameraPreview();
        },
      ),
    );
  }
}
