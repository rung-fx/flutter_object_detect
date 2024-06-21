import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:poc_detect_object_tflite/find_circle.dart';
import 'package:poc_detect_object_tflite/home_view.dart';
import 'package:poc_detect_object_tflite/image_color_picker.dart';
import 'package:poc_detect_object_tflite/test_tf.dart';
import 'package:poc_detect_object_tflite/trained_model_test_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SizedBox(
          width: Get.width,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _button(
                'crop and custom model',
                () {
                  Get.to(() => const HomeView());
                },
              ),
              _button(
                'test tf model',
                () {
                  Get.to(() => const TestTf());
                },
              ),
              _button(
                'trained model',
                () {
                  Get.to(() => const TrainedModelTestPage());
                },
              ),
              _button(
                'pick color',
                () {
                  Get.to(() => const ImageColorPicker());
                },
              ),
              _button(
                'find circle',
                    () {
                  Get.to(() => const FindCircle());
                },
              ),
              // _button(
              //   'dominant color',
              //   () {
              //     Get.to(() => const CheckColorPage());
              //   },
              // ),
            ],
          ),
        ),
      ),
    );
  }

  _button(String title, Function() onTap) {
    return InkWell(
      onTap: onTap,
      child: Container(
        height: 50.0,
        width: 180.0,
        margin: const EdgeInsets.all(8.0),
        decoration: BoxDecoration(
          color: Colors.grey.shade300,
          borderRadius: BorderRadius.circular(10.0),
        ),
        child: Center(
          child: Text(title),
        ),
      ),
    );
  }
}
