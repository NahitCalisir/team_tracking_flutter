import 'dart:io';
import 'package:image/image.dart' as img;
import 'package:flutter/material.dart';
import 'dart:typed_data';

class HelperFunctions {

  static Widget wrapWithAnimatedBuilder({
    required Animation<Offset> animation,
    required Widget child,
  }) {
    return AnimatedBuilder(
      animation: animation,
      builder: (_, __) => FractionalTranslation(
        translation: animation.value,
        child: child,
      ),
    );
  }

  static Future<File> resizeImage(File imageFile, double width, double height) async {
    // Dosyayı oku ve image paketini kullanarak image nesnesine dönüştür
    List<int> imageBytes = await imageFile.readAsBytes();
    img.Image image = img.decodeImage(Uint8List.fromList(imageBytes))!;

    // Belirli genişlik ve yüksekliğe boyutlandır
    img.Image resizedImage = img.copyResize(image, width: width.toInt(), height: height.toInt());

    // Boyutlandırılmış resmi bir File nesnesine dönüştür
    File resultFile = File(imageFile.path)
      ..writeAsBytesSync(Uint8List.fromList(img.encodePng(resizedImage)));

    return resultFile;
  }
}
