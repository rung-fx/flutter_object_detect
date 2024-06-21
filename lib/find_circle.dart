import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image/image.dart' as imglib;
import 'package:poc_detect_object_tflite/detector.dart';

class FindCircle extends StatefulWidget {
  const FindCircle({super.key});

  @override
  State<FindCircle> createState() => _FindCircleState();
}

class _FindCircleState extends State<FindCircle> {
  Uint8List? _result;
  String _testImage = 'assets/images/real_led.jpg';

  final Detector _detector = Detector();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('find circle'),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Wrap(
              spacing: 8.0,
              runSpacing: -8.0,
              children: [
                InputChip(
                  label: const Text('actual1'),
                  onPressed: () {
                    _testImage = 'assets/images/alcohol_sensor.jpg';
                    _changeImage();
                  },
                ),
                // InputChip(
                //   label: const Text('actual2'),
                //   onPressed: () {
                //     _testImage = 'assets/images/led_android.jpeg';
                //     _changeImage();
                //   },
                // ),
                InputChip(
                  label: const Text('actual3'),
                  onPressed: () {
                    _testImage = 'assets/images/real_led_crop.jpg';
                    _changeImage();
                  },
                ),
              ],
            ),
            _images(),
          ],
        ),
      ),
    );
  }

  _images() {
    return Row(
      children: [
        Expanded(
          child: Image.asset(_testImage),
        ),
        Expanded(
          child: _resultImage(),
        ),
      ],
    );
  }

  _resultImage() {
    if (_result == null) {
      return const SizedBox();
    }

    return SizedBox(
      width: 200.0,
      child: Image.memory(_result!),
    );
  }

  _changeImage() async {
    ByteData byteData = await rootBundle.load(_testImage);
    Uint8List bytes = byteData.buffer.asUint8List();

    imglib.Image originalImage = imglib.decodeImage(bytes)!;

    _detect(originalImage);
  }

  _detect(imglib.Image image) async {
    imglib.Image resize = _detector.resizeImage(image);

    imglib.Image resultImage = await _detector.detectCluster(
      resize.clone(),
      minClusterSize: 20, // TODO: รอจูนค่า
      maxClusterSize: 1300,
      drawDetected: true,
    );

    // Optional: เอาผลจากการ detect ไปแสดง
    final resultBytes = imglib.encodePng(resultImage);
    _result = Uint8List.fromList(resultBytes);

    setState(() {});
  }
}
