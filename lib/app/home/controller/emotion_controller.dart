
import 'dart:typed_data';

import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:image/image.dart' as img;

class EmotionController extends GetxController {
  
  Future<List<String>?> detectEmotions(Uint8List imageBytes, List<Rect> faces, int width, int height) async {
    List<String> emotions = [];

    for(Rect face in faces){
      Uint8List? faceBytes = preprocessFace(imageBytes, face, width, height);
      if(faceBytes == null) {
        print('Log: CANNOT DECODE IMAGE in emotion_controller.dart');
        return null;
      }


    }
  }

  Uint8List? preprocessFace(Uint8List imageBytes, Rect faceRect, int imageWidth, int imageHeight) {
    img.Image? image = img.decodeImage(imageBytes);
    if (image == null) return null;

    int x = faceRect.left.toInt();
    int y = faceRect.top.toInt();
    int width = faceRect.width.toInt();
    int height = faceRect.height.toInt();

    x = x.clamp(0, imageWidth - 1);
    y = y.clamp(0, imageHeight - 1);
    width = width.clamp(1, imageWidth - x);
    height = height.clamp(1, imageHeight - y);

    img.Image croppedFace = img.copyCrop(image, x: x, y: y, width: width, height: height);
    img.Image resizedFace = img.copyResize(croppedFace, width: 48, height: 48);
    img.Image grayscaleFace = img.grayscale(resizedFace);

    return Uint8List.fromList(img.encodeJpg(grayscaleFace));
  }

  Float32List imageToTensor(Uint8List imageBytes) {
    img.Image? image = img.decodeImage(imageBytes);
    if (image == null) return Float32List(48 * 48);

    Float32List tensorBuffer = Float32List(48 * 48);

    for (int y = 0; y < 48; y++) {
      for (int x = 0; x < 48; x++) {
        int pixel = image.getPixel(x, y);
        int grayValue = img.getLuminance(pixel);
        tensorBuffer[y * 48 + x] = grayValue / 255.0; // Normalize
      }
    }

    return tensorBuffer;
  }



}