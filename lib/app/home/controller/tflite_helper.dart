import 'package:tflite_flutter/tflite_flutter.dart';

class TFLiteHelper {
  static final TFLiteHelper _instance = TFLiteHelper._internal();
  factory TFLiteHelper() => _instance;
  TFLiteHelper._internal();

  Interpreter? interpreter;

  Future<void> loadModel() async {
    if (interpreter != null) return;
    interpreter = await Interpreter.fromAsset('assets/model/emotionDetection.tflite');
    print('Model loaded successfully.');
  }

  void closeModel() {
    interpreter?.close();
    interpreter = null;
  }
}
