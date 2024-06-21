class Pixel {
  int x;
  int y;

  Pixel({
    required this.x,
    required this.y,
  });

  isSamePixel(
      Pixel pixel, {
        int threshold = 0,
      }) {
    if ((pixel.x > x - threshold && pixel.x < x + threshold) &&
        (pixel.y > y - threshold && pixel.y < y + threshold)) {
      return true;
    }

    return false;
  }
}
