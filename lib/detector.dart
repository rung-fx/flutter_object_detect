import 'package:image/image.dart' as imglib;
import 'package:poc_detect_object_tflite/cluster.dart';
import 'package:poc_detect_object_tflite/pixel.dart';

const int grayColor = 4291348680; // imglib.getColor(200, 200, 200, 255)

imglib.ColorRgb8 blackColor = imglib.ColorRgb8(0, 0, 0);
imglib.ColorRgb8 whiteColor = imglib.ColorRgb8(255, 255, 255);
imglib.ColorRgb8 redColor = imglib.ColorRgb8(255, 0, 0);

class Detector {
  int targetWidth = 320;

  List<Cluster> detectedList = [];

  resizeImage(imglib.Image image) {
    double ratio = image.height / image.width;

    imglib.Image resize = imglib.copyResize(
      image,
      width: targetWidth,
      height: (targetWidth * ratio).toInt(),
    );

    // print('original size: ${image.width}, ${image.height}');
    // print('resize size: ${resize.width}, ${resize.height}');
    // print('ratio: $ratio');

    return resize;
  }

  detectCluster(
      imglib.Image image, {
        double dtThreshold = 0.0,
        int minClusterSize = 80, // ขนาดของ cluster
        int maxClusterSize = 1000,
        double minRatio = 0.7, // ratio ของ cluster
        double maxRatio = 1.3,
        bool drawDetected = true,
      }) async {
    detectedList.clear();

    imglib.Image originalColor = image.clone();

    // var contrast = imglib.contrast(image, 100)!;
    // return contrast;

    var grayscale = imglib.grayscale(image);
    // return grayscale;

    var blur = imglib.gaussianBlur(grayscale, radius: 3);
    // return blur;

    var dt = dynamicThreshold(blur, threshold: dtThreshold);
    // return dt;

    for (int y = 0; y < dt.height; y++) {
      for (int x = 0; x < dt.width; x++) {
        imglib.Pixel currentPixel = dt.getPixel(x, y);
        imglib.ColorRgb8 currentColor = imglib.ColorRgb8(
          currentPixel.r.toInt(),
          currentPixel.g.toInt(),
          currentPixel.b.toInt(),
        );

        if (currentColor == whiteColor) {
          Cluster? cluster = floodFill(dt, x, y, redColor);
          print('cluster size: ${cluster?.pixelList.length}, ratio ${cluster?.ratio}');

          if (cluster != null &&
              cluster.pixelList.length > minClusterSize &&
              cluster.pixelList.length < maxClusterSize &&
              cluster.ratio > minRatio &&
              cluster.ratio < maxRatio) {
            detectedList.add(cluster);
          } else {
            // ถ้า Cluster เล็กหรือใหญ่กว่าที่กำหนด ถมดำทิ้งไป
            floodFill(dt, x, y, blackColor);
          }
        }
      }
    }

    for (Cluster cluster in detectedList) {
      String color = detectColor(originalColor, cluster: cluster);
      // print('x: ${cluster.x}, y: ${cluster.y}, r: ${cluster.r}, $color');

      if (drawDetected) {
        // Cluster
        imglib.drawCircle(
          image,
          x: cluster.x,
          y: cluster.y,
          radius: cluster.r + cluster.drawOffset,
          color: redColor,
        );

        // 4 จุดที่ใช้เช็คสี
        imglib.fillCircle(
          image,
          x: cluster.topLeft.x,
          y: cluster.topLeft.y,
          radius: 4,
          color: redColor,
        );

        imglib.fillCircle(
          image,
          x: cluster.topRight.x,
          y: cluster.topRight.y,
          radius: 4,
          color: redColor,
        );

        imglib.fillCircle(
          image,
          x: cluster.bottomLeft.x,
          y: cluster.bottomLeft.y,
          radius: 4,
          color: redColor,
        );

        imglib.fillCircle(
          image,
          x: cluster.bottomRight.x,
          y: cluster.bottomRight.y,
          radius: 4,
          color: redColor,
        );

        // สีที่เจอ
        imglib.drawString(
          image,
          color,
          font: imglib.arial14,
          x: cluster.x,
          y: cluster.y,
          color: whiteColor,
        );
      }
    }

    return image;
  }

  Cluster? floodFill(
      imglib.Image image,
      int startX,
      int startY,
      imglib.ColorRgb8 fillColor,
      ) {
    Cluster cluster = Cluster(pixelList: []);

    imglib.Pixel targetPixel = image.getPixel(startX, startY);
    imglib.ColorRgb8 targetColor = imglib.ColorRgb8(
      targetPixel.r.toInt(),
      targetPixel.g.toInt(),
      targetPixel.b.toInt(),
    );

    if (targetColor == fillColor) {
      return null;
    }

    int width = image.width;
    int height = image.height;

    // Directions for N, S, E, W
    List<int> dx = [-1, 1, 0, 0];
    List<int> dy = [0, 0, -1, 1];

    List<List<int>> stack = [
      [startX, startY]
    ];

    while (stack.isNotEmpty) {
      var current = stack.removeLast();
      int x = current[0];
      int y = current[1];

      if (x < 0 || x >= width || y < 0 || y >= height) {
        continue; // Skip if out of bounds
      }

      imglib.Pixel currentPixel = image.getPixel(x, y);
      imglib.ColorRgb8 currentColor = imglib.ColorRgb8(
        currentPixel.r.toInt(),
        currentPixel.g.toInt(),
        currentPixel.b.toInt(),
      );

      if (currentColor != targetColor) {
        continue; // Skip if not the target color
      }

      image.setPixel(x, y, fillColor);
      cluster.pixelList.add(Pixel(x: x, y: y));

      for (int i = 0; i < 4; i++) {
        stack.add([x + dx[i], y + dy[i]]);
      }
    }

    cluster.calculate();
    return cluster;
  }

  String detectColor(
      imglib.Image image, {
        required Cluster cluster,
      }) {
    List<String> colorList = [];

    var pixel = image.getPixel(cluster.topLeft.x, cluster.topLeft.y);
    colorList.add(checkPrimaryColor(
      pixel.r.toInt(),
      pixel.g.toInt(),
      pixel.b.toInt(),
    ));

    pixel = image.getPixel(cluster.topRight.x, cluster.topRight.y);
    colorList.add(checkPrimaryColor(
      pixel.r.toInt(),
      pixel.g.toInt(),
      pixel.b.toInt(),
    ));

    pixel = image.getPixel(cluster.bottomLeft.x, cluster.bottomLeft.y);
    colorList.add(checkPrimaryColor(
      pixel.r.toInt(),
      pixel.g.toInt(),
      pixel.b.toInt(),
    ));

    pixel = image.getPixel(cluster.bottomRight.x, cluster.bottomRight.y);
    colorList.add(checkPrimaryColor(
      pixel.r.toInt(),
      pixel.g.toInt(),
      pixel.b.toInt(),
    ));

    return mostDuplicateValue(colorList);
  }

  // Image utilities
  imglib.Image edgeDetectionHard(imglib.Image src) {
    const filter = [-1, -1, -1, -1, 8, -1, -1, -1, -1];
    return imglib.convolution(src, filter: filter);
  }

  imglib.Image dynamicThreshold(
      imglib.Image src, {
        double threshold = 0.0, // threshold range = -1, 1
      }) {
    double range = 2000000;
    double value = grayColor + (threshold * range);

    for (var x = 0; x < src.width; x++) {
      for (var y = 0; y < src.height; y++) {
        final pixel = src.getPixel(x, y);
        int pixelColor = getColorFromPixel(pixel);

        src.setPixel(
          x,
          y,
          pixelColor <= value ? blackColor : whiteColor,
        );
      }
    }

    return src;
  }

  String checkPrimaryColor(int r, g, b) {
    String result = 'unknown';

    // TODO: รอจูนค่าสี
    if (r > g + 20 && r > b + 20) {
      result = 'red';
    } else if (g > r + 10 && g > b + 10) {
      result = 'green';
    } else if (b > r + 50 && b > g + 50 && r < 50) {
      result = 'blue';
    } else if (r > 50 && g > 100 && b > 100) {
      result = 'white';
    } else if (r < 50 && g < 50 && b < 50) {
      result = 'black';
    }

    // print('r $r, g $g, b $b, $result');
    return result;
  }

  String mostDuplicateValue(List<String> strings) {
    if (strings.isEmpty) {
      return '';
    }

    final Map<String, int> frequencyMap = {};
    for (String str in strings) {
      if (frequencyMap.containsKey(str)) {
        frequencyMap[str] = frequencyMap[str]! + 1;
      } else {
        frequencyMap[str] = 1;
      }
    }

    String mostDuplicateString = strings[0];
    int highestCount = frequencyMap[mostDuplicateString]!;

    frequencyMap.forEach((key, value) {
      if (value > highestCount) {
        mostDuplicateString = key;
        highestCount = value;
      }
    });

    return mostDuplicateString;
  }

  int getColorFromPixel(imglib.Pixel pixel) {
    return imglib.rgbaToUint32(
      pixel.r.toInt(),
      pixel.g.toInt(),
      pixel.b.toInt(),
      pixel.a.toInt(),
    );
  }
}
