import 'dart:io';
import 'package:image/image.dart' as img;

void main() async {
  // Read the white paw image
  final pawImage = img.decodeImage(
    await File('assets/paw_white.png').readAsBytes(),
  );

  if (pawImage == null) {
    print('Error: Could not read paw_white.png');
    exit(1);
  }

  // Create a new image with black background
  final iconImage = img.Image(
    width: pawImage.width,
    height: pawImage.height,
  );

  // Fill with black background
  img.fill(iconImage, color: img.ColorRgb8(0, 0, 0));

  // Composite the white paw on top
  img.compositeImage(iconImage, pawImage);

  // Save the result
  final outputFile = File('assets/app_icon.png');
  await outputFile.writeAsBytes(img.encodePng(iconImage));

  print('Created app_icon.png with black background');
}

