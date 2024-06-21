import 'dart:math';

import 'package:poc_detect_object_tflite/pixel.dart';


class Cluster {
  int x;
  int y;
  int r;

  int drawOffset;
  late Pixel topLeft;
  late Pixel topRight;
  late Pixel bottomLeft;
  late Pixel bottomRight;

  List<Pixel> pixelList;
  double ratio;

  Cluster({
    this.x = 0,
    this.y = 0,
    this.r = 0,
    required this.pixelList,
    this.ratio = 0,
    this.drawOffset = 5,
  });

  isSameCluster(
      Cluster cluster, {
        int threshold = 20,
      }) {
    if ((cluster.x > x - threshold && cluster.x < x + threshold) &&
        (cluster.y > y - threshold && cluster.y < y + threshold)) {
      return true;
    }

    return false;
  }

  calculate() {
    if (pixelList.isEmpty) {
      return;
    }

    int minX = pixelList.first.x;
    int maxX = pixelList.first.x;

    int minY = pixelList.first.y;
    int maxY = pixelList.first.y;

    for (Pixel pixel in pixelList) {
      if (pixel.x < minX) {
        minX = pixel.x;
      }

      if (pixel.x > maxX) {
        maxX = pixel.x;
      }

      if (pixel.y < minY) {
        minY = pixel.y;
      }

      if (pixel.y > maxY) {
        maxY = pixel.y;
      }
    }

    x = (minX + maxX) ~/ 2;
    y = (minY + maxY) ~/ 2;

    int dx = maxX - minX;
    int dy = maxY - minY;

    ratio = dx / dy;
    r = max(maxX - minX, maxY - minY) ~/ 2;

    // 4 จุดที่จะใช้เช็คสี
    int offset = r + drawOffset;

    topLeft = Pixel(
      x: x + (offset * cos(45 * pi / 180)).round(),
      y: y + (offset * sin(45 * pi / 180)).round(),
    );

    topRight = Pixel(
      x: x + (offset * cos(135 * pi / 180)).round(),
      y: y + (offset * sin(135 * pi / 180)).round(),
    );

    bottomLeft = Pixel(
      x: x + (offset * cos(225 * pi / 180)).round(),
      y: y + (offset * sin(225 * pi / 180)).round(),
    );

    bottomRight = Pixel(
      x: x + (offset * cos(315 * pi / 180)).round(),
      y: y + (offset * sin(315 * pi / 180)).round(),
    );
  }
}
