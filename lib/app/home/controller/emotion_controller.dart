
import 'dart:ffi';
import 'dart:typed_data';

import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:flutter_face_detection/app/home/controller/tflite_helper.dart';
import 'package:get/get.dart';
import 'package:image/image.dart' as img;
import 'package:tflite_flutter/tflite_flutter.dart';

class EmotionController extends GetxController {
  TFLiteHelper? tfLiteHelper;
  Interpreter? _interpreter;
  List<String> emotions = ['angry','disgust','fear','happy','neutral','sad','surprise'];
  Uint8List? imageTobeDisplayed;

  EmotionController() {
    tfLiteHelper = TFLiteHelper();
  }

  Future<void> load() async {
    await tfLiteHelper?.loadModel();
    _interpreter = tfLiteHelper?.interpreter;
  }
  
  Future<List<String>> detectEmotions(img.Image image, List<Rect> boxes, int width, int height) async {
    List<String> emotionsPerFace = [];

    for(Rect box in boxes){
      img.Image face = preprocessFace(image, box, width, height);
      

      Float32List tensorBuffer = imageToTensor(face);
      List<double> output = List<double>.from(runTFLiteModel(tensorBuffer));

      int maxIndex = output.indexWhere((value) => value == output.reduce((a, b) => a > b ? a : b));
      emotionsPerFace.add(emotions[maxIndex]);
    }

    return emotionsPerFace;
  }

  // List<Uint8List> getProcessedImages(img.Image image, List<Rect> boxes, int width, int height){
  //   List<Uint8List> processedImages = [];

  //   for(Rect box in boxes){
  //     img.Image face = preprocessFace(image, box, width, height);

  //     processedImages.add(faceBytes);
  //   }

  //   return processedImages;
  // }

  img.Image preprocessFace(img.Image image, Rect faceRect, int imageWidth, int imageHeight) {
    int x = faceRect.left.toInt();
    int y = faceRect.top.toInt();
    int width = faceRect.width.toInt();
    int height = faceRect.height.toInt();

    print('x: $x');
    print('y: $y');
    print('width: $width');
    print('height: $height');
    

    x = x.clamp(0, imageWidth - 1);
    y = y.clamp(0, imageHeight - 1);
    width = width.clamp(1, imageWidth - x);
    height = height.clamp(1, imageHeight - y);

    img.Image rotatedImage = img.copyRotate(image, angle: -90);
    img.Image croppedFace = img.copyCrop(rotatedImage, x: x, y: y, width: width, height: height);
    img.Image resizedFace = img.copyResize(croppedFace, width: 48, height: 48);

    return resizedFace;
  }

  Float32List imageToTensor(img.Image image) {
    Float32List tensorBuffer = Float32List(48 * 48);

    for (int y = 0; y < 48; y++) {
      for (int x = 0; x < 48; x++) {
        img.Pixel pixel = image.getPixel(x, y); 
        num grayValue = img.getLuminance(pixel);
        tensorBuffer[y * 48 + x] = grayValue / 255.0; // Normalize
      }
    }

    return tensorBuffer;
  }

  List<dynamic> runTFLiteModel(Float32List inputData) {
    var input = inputData.reshape([1, 48, 48, 1]); // Shape for TFLite
    var output = Float32List(7).reshape([1, 7]); // Adjust output size

    _interpreter?.run(input, output);
    return output[0];
  }


}