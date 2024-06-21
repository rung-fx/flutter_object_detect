// import 'dart:io';
// import 'dart:math';
// import 'dart:typed_data';
// import 'package:flutter/foundation.dart';
// import 'package:flutter/material.dart';
// import 'package:image/image.dart' as imageLib;
//
// class DominantColors {
//   final Uint8List bytes;
//   int dominantColorsCount = 2;
//
//   DominantColors({
//     required this.bytes,
//     required this.dominantColorsCount,
//   });
//
//   double distance(Color a, Color b) {
//     return sqrt(pow(a.red - b.red, 2) +
//         pow(a.green - b.green, 2) +
//         pow(a.blue - b.blue, 2));
//   }
//
//   List<Color> initializeCentroids(List<Color> colors) {
//     final random = Random();
//     List<Color> centroids = [];
//     centroids.add(colors[random.nextInt(10)]);
//
//     for (int i = 1; i < dominantColorsCount; i++) {
//       List<double> distances = colors
//           .map((color) => centroids
//               .map((centroid) => distance(color, centroid))
//               .reduce(min))
//           .toList();
//
//       double sum = distances.reduce((a, b) => a + b);
//       double r = random.nextDouble() * sum;
//
//       double accumulatedDistance = 0.0;
//       for (int j = 0; j < colors.length; j++) {
//         accumulatedDistance += distances[j];
//         if (accumulatedDistance >= r) {
//           centroids.add(colors[j]);
//           break;
//         }
//       }
//     }
//
//     return centroids;
//   }
//
//   List<Color> extractDominantColors() {
//     List<Color> colors = _getPixelsColorsFromHalfImage();
//     List<Color> centroids = initializeCentroids(colors);
//     List<Color> oldCentroids = [];
//
//     while (_isConverging(centroids, oldCentroids)) {
//       oldCentroids = List.from(centroids);
//       List<List<Color>> clusters =
//           List.generate(dominantColorsCount, (index) => []);
//
//       for (var color in colors) {
//         int closestIndex = _findClosestCentroid(color, centroids);
//         clusters[closestIndex].add(color);
//       }
//
//       for (int i = 0; i < dominantColorsCount; i++) {
//         centroids[i] = _averageColor(clusters[i]);
//       }
//     }
//
//     return centroids;
//   }
//
//   List<Color> _getPixelsColorsFromHalfImage() {
//     List<Color> colors = [];
//
//     imageLib.Image? image = imageLib.decodeImage(bytes.buffer.asUint8List());
//
//     if (image != null) {
//       int sampling = 5;
//
//       var width = image.width;
//       var height = image.height;
//       if (width > 1300) {
//         sampling = 10;
//       }
//       var heightTakenForColors = height / 2;
//       var widthTakenForColors = width / 2;
//
//       for (int y = 0; y < heightTakenForColors; y += sampling) {
//         for (int x = 0; x < widthTakenForColors; x += sampling) {
//           var pixel = image.getPixel(x, y);
//
//           int r = pixel.r.toInt();
//           int g = pixel.g.toInt();
//           int b = pixel.b.toInt();
//           int a = pixel.a.toInt();
//
//           colors.add(Color.fromARGB(a, r, g, b));
//         }
//       }
//     }
//
//     return colors;
//   }
//
//   bool _isConverging(List<Color> centroids, List<Color> oldCentroids) {
//     if (oldCentroids.isEmpty) return true;
//     for (int i = 0; i < centroids.length; i++) {
//       if (centroids[i] != oldCentroids[i]) return true;
//     }
//     return false;
//   }
//
//   int _findClosestCentroid(Color color, List<Color> centroids) {
//     int minIndex = 0;
//     double minDistance = distance(color, centroids[0]);
//     for (int i = 1; i < centroids.length; i++) {
//       double dist = distance(color, centroids[i]);
//       if (dist < minDistance) {
//         minDistance = dist;
//         minIndex = i;
//       }
//     }
//     return minIndex;
//   }
//
//   Color _averageColor(List<Color> colors) {
//     int r = 0, g = 0, b = 0;
//     for (var color in colors) {
//       r += color.red;
//       g += color.green;
//       b += color.blue;
//     }
//     int length = colors.length;
//     r = r ~/ length;
//     g = g ~/ length;
//     b = b ~/ length;
//     return Color.fromRGBO(r, g, b, 1);
//   }
//
//   Future<Uint8List> fetchImage(String photoUrl) async {
//     var httpClient = HttpClient();
//     var request = await httpClient.getUrl(Uri.parse(photoUrl));
//     var response = await request.close();
//     var bytes = await consolidateHttpClientResponseBytes(response);
//     return bytes;
//   }
// }
