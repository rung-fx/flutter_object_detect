import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:freewill_fx_widgets/fx.dart';
import 'package:get/get.dart';
import 'package:palette_generator/palette_generator.dart';
import 'package:image/image.dart' as img;
import 'package:path_provider/path_provider.dart';

class ImageColorPicker extends StatefulWidget {
  const ImageColorPicker({super.key});

  @override
  State<ImageColorPicker> createState() => _ImageColorPickerState();
}

class _ImageColorPickerState extends State<ImageColorPicker> {
  RxBool isLoading = false.obs;

  PaletteGenerator? _paletteGenerator;
  File? imageFile;

  final String _imagePath = 'assets/images/alcohol_sensor.jpg';

  // final String _imagePath = 'assets/images/led_with_tape_android.jpeg';

  // final String _imagePath = 'assets/images/led_with_tape_iphone.jpeg';

  // final String _imagePath = 'assets/images/led_android.jpeg';

  // final String _imagePath = 'assets/images/led_iphone.jpeg';

  // final String _imagePath = 'assets/images/real_led_crop.jpg';

  // final String _imagePath = 'assets/images/led_sensor.jpeg';

  // final String _imagePath = 'assets/images/led_sensor_module.jpeg';

  // final String _imagePath = 'assets/images/4colors.png';

  @override
  void initState() {
    super.initState();
    _prepareData();
  }

  _prepareData() async {
    isLoading.value = true;
    await _generatorPalette();
    isLoading.value = false;
  }

  _generatorPalette() async {
    imageFile = await _contrastImageFile();

    if (imageFile == null) {
      return;
    }

    _paletteGenerator = await PaletteGenerator.fromImageProvider(
      FileImage(imageFile!),
      maximumColorCount: 4,
    );

    setState(() {});
  }

  Future<File?> _contrastImageFile() async {
    Directory documentDir = await getApplicationDocumentsDirectory();
    String imageFolder = '${documentDir.path}/image';

    final byteData = await rootBundle.load(_imagePath);
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

    final contrastImage = img.adjustColor(
      image,
      // contrast: 2,
      saturation: 2,
      gamma: 5,
      amount: 100,
      // brightness: 1,
      // exposure: 1,
      // hue: 10,
      // maskChannel: img.Channel.alpha,
    );


    final imageBytes = img.encodePng(contrastImage);
    File result = File('$imageFolder/result.png');

    return await result.writeAsBytes(imageBytes);
  }

  @override
  Widget build(BuildContext context) {
    return !isLoading.value
        ? Scaffold(
            appBar: AppBar(
              title: const Text('Color Picker'),
              centerTitle: true,
              actions: [
                IconButton(
                  onPressed: () async {
                    isLoading.value = true;
                    await _prepareData();
                    isLoading.value = false;

                    setState(() {});
                  },
                  icon: const Icon(Icons.refresh),
                ),
              ],
            ),
            body: Column(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                imageFile != null
                    ? SizedBox(
                        height: 300,
                        width: 200,
                        child: Image.file(
                          imageFile!,
                          fit: BoxFit.fitHeight,
                        ),
                      )
                    : const SizedBox(),
                if (_paletteGenerator != null)
                  Container(
                    width: double.maxFinite,
                    alignment: Alignment.center,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    child: Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: _paletteGenerator!.colors.map((color) {
                        print(color);

                        return Container(
                          width: 50,
                          height: 50,
                          decoration: BoxDecoration(
                            color: color,
                            borderRadius: BorderRadius.circular(8),
                          ),
                        );
                      }).toList(),
                    ),
                  ),
              ],
            ),
          )
        : const FXLoading();
  }
}
