import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image/image.dart' as img;
import 'package:flutter/material.dart';
import 'dart:typed_data';

import 'package:package_info_plus/package_info_plus.dart';

class HelperFunctions {

  static  HelperFunctions shared = HelperFunctions();

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

  //Check version info
  Future<void> checkVersion(BuildContext context) async {
    PackageInfo packageInfo = await PackageInfo.fromPlatform();

    String appName = packageInfo.appName;
    String packageName = packageInfo.packageName;
    String currentVersion = packageInfo.version;
    String buildNumber = packageInfo.buildNumber;

    print("App Name: $appName");
    print("Package Name: $packageName");
    print("CurrentV ersion: $currentVersion");
    print("Build Number: $buildNumber");

    // Sunucuya manuel kaydedilen güncel versiyon numarası
    String? latestVersion = await  getLastVersionNumber();

    if (currentVersion != latestVersion) {
      // Eğer mevcut versiyon güncel değilse, kullanıcıya güncellemesi gerektiğini bildir
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text("Update Your App"),
          content: const Text("A new update is available. Please update your application."),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('OK'),
            ),
          ],
        ),
      );
    }
  }

  Future<String?> getLastVersionNumber() async {
    String? lastVersionNumber;
    try {
      final QuerySnapshot appSettingsSnapshot =
      await FirebaseFirestore.instance.collection('appSettings').get();
      if (appSettingsSnapshot.docs.isNotEmpty) {
        // Eğer belge varsa, ilk belgeyi kullanabilirsiniz
        final doc = appSettingsSnapshot.docs.first;
        lastVersionNumber = doc["lastVersionNumber"];
        print("*************************************");
        print("Latest version number registered in Firestore: $lastVersionNumber");
      } else {
        print("*************************************");
        print("Document does not exist in Firestore.");
      }
    } catch (e) {
      print("*************************************");
      print("Error fetching last version number: $e");
    }
    return lastVersionNumber;
  }



}
