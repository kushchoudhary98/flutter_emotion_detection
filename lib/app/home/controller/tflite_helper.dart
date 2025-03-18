
import 'dart:typed_data';

import 'package:tflite_flutter/tflite_flutter.dart';

class TFLiteHelper {
  Interpreter? interpreter;

  Future<void> loadModel() async {
    interpreter = await Interpreter.fromAsset('assets/model/emotionDetection.tflite');
    print('Model loaded successfully.');
  }

  void closeModel() {
    interpreter?.close();
  }
}
