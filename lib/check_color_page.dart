// import 'dart:io';
// import 'dart:typed_data';
//
// import 'package:flutter/foundation.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'package:path_provider/path_provider.dart';
// import 'package:testmlkit/dominant_colors.dart';
//
// class CheckColorPage extends StatefulWidget {
//   const CheckColorPage({super.key});
//
//   @override
//   State<CheckColorPage> createState() => _CheckColorPageState();
// }
//
// class _CheckColorPageState extends State<CheckColorPage> {
//   List<Color> colors = [];
//   var colorsCountToExtract = 10;
//   Uint8List? imageBytes;
//
//   @override
//   void initState() {
//     super.initState();
//     extractColors();
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('Dominant colors'),
//         centerTitle: true,
//         actions: [
//           IconButton(
//             onPressed: () {
//               extractColors();
//               setState(() {});
//             },
//             icon: const Icon(Icons.refresh),
//           ),
//         ],
//       ),
//       body: Column(
//         children: [
//           SizedBox(
//             height: 300,
//             child: imageBytes != null && imageBytes!.isNotEmpty
//                 ? Image.memory(
//                     imageBytes!,
//                     fit: BoxFit.fitWidth,
//                   )
//                 : const Center(
//                     child: CircularProgressIndicator(),
//                   ),
//           ),
//           Container(
//             color: Colors.white.withOpacity(0.3),
//             padding: const EdgeInsets.only(
//               top: 6,
//               bottom: 16,
//             ),
//             alignment: Alignment.center,
//             child: Column(
//               children: [
//                 Text('Dominant $colorsCountToExtract colors:'),
//                 _getDominantColors()
//               ],
//             ),
//           )
//         ],
//       ),
//     );
//   }
//
//   // Future<Uint8List> fetchImage(String photoUrl) async {
//   //   var httpClient = HttpClient();
//   //   var request = await httpClient.getUrl(Uri.parse(photoUrl));
//   //   var response = await request.close();
//   //   var bytes = await consolidateHttpClientResponseBytes(response);
//   //   return bytes;
//   // }
//
//   Future<Uint8List> imageToFile(String imageName) async {
//     var bytes = await rootBundle.load('assets/images/$imageName');
//     String tempPath = (await getApplicationDocumentsDirectory()).path;
//     File file = File('$tempPath/test_led.png');
//
//     await file.writeAsBytes(
//       bytes.buffer.asUint8List(
//         bytes.offsetInBytes,
//         bytes.lengthInBytes,
//       ),
//     );
//
//     return file.readAsBytesSync();
//   }
//
//   Future<void> extractColors() async {
//     // photo = photos[random.nextInt(photos.length)];
//     // imageBytes = await fetchImage(photo);
//
//     imageBytes = await imageToFile('led_sensor.jpeg');
//     // imageBytes = await imageToFile('led_sensor_module.jpeg');
//     // imageBytes = await imageToFile('4colors.png');
//     setState(() {});
//
//     try {
//       DominantColors extractor = DominantColors(
//         bytes: imageBytes!,
//         dominantColorsCount: colorsCountToExtract,
//       );
//
//       List<Color> dominantColors = extractor.extractDominantColors();
//       setState(() {});
//
//       colors = dominantColors;
//       print(colors);
//     } catch (e) {
//       colors.clear();
//     }
//     setState(() {});
//   }
//
//   Widget _getDominantColors() {
//     return SizedBox(
//       height: 60,
//       child: colors.isEmpty
//           ? Container(
//               alignment: Alignment.center,
//               height: 60,
//               child: const CircularProgressIndicator(),
//             )
//           : Container(
//               decoration: BoxDecoration(
//                 border: Border.all(),
//               ),
//               child: ListView.builder(
//                 shrinkWrap: true,
//                 scrollDirection: Axis.horizontal,
//                 itemCount: colors.length,
//                 itemBuilder: (BuildContext context, int index) => Container(
//                   color: colors[index],
//                   height: 30,
//                   width: 30,
//                 ),
//               ),
//             ),
//     );
//   }
// }
