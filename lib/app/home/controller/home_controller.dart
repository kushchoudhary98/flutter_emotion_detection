
import 'dart:developer';
import 'dart:io';
import 'dart:math';
import 'dart:ui';

import 'package:camera/camera.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_face_detection/app/home/controller/camera_controller.dart';
import 'package:flutter_face_detection/app/home/controller/emotion_controller.dart';
import 'package:flutter_face_detection/app/home/controller/face_controller.dart';
import 'package:get/get.dart';
import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';
import 'package:image/image.dart' as imglib;

class HomeController extends GetxController{
  CameraManager? cameraManager;
  late FaceController faceController;
  late EmotionController emotionController;
  CameraController? cameraController;
  bool _isDetecting = false;
  RxInt faceCount = 0.obs;
  RxString emotion = ''.obs;
  RxList<Rect> faceBoxes = <Rect>[].obs;
  Uint8List im = Uint8List(48*48*4);

  HomeController() {
    cameraManager = CameraManager();
    emotionController = EmotionController();
    faceController = FaceController();
  }

  Future<void> loadCamera() async {
    cameraController = await cameraManager?.load();
    update();
  }

  Future<void> loadModel() async {
    await emotionController.load();
  }

  void startCameraStream() {
    print("Starting Camera Stream");
    if (cameraController == null) {
      print("Log: CameraController is null");
      return;
    }
    cameraController!.startImageStream((cameraImage) async {
      if(_isDetecting) { return; }

      print('Face Detection Started');
      _isDetecting = true;

      final data = cameraManager?.inputImageFromCameraImage(cameraImage);
      if(data == null) {
        print('Log: inputImage is null. Something went wrong');
        _isDetecting = false;
        return;
      }

      InputImage inputImage = data[1] as InputImage;

      List<Rect> faces = await faceController.detectFaces(inputImage);
      faceBoxes.value = faces;
      print('Number of faces: ${faces.length}');
      if(faces.length > 0) {
        print(faces[0]);
      }
      faceCount.value = faces.length;
      imglib.Image? image = cameraManager?.convertYUV420ToGrayscale(cameraImage);
      if(image == null) {
        print('Log: image is null. in convertYUV420ToGrayscale');
        _isDetecting = false;
        return;
      }
      // List<String>? emotions = await emotionController.detectEmotions(image, faces, cameraImage.width, cameraImage.height);
      // if(emotions == null) {
      //   print('Log: emotions is null. in detectEmotions');
      //   _isDetecting = false;
      //   return;
      // }
      // if(emotions.isNotEmpty) emotion.value = emotions[0];

      List<Uint8List> processedImages = emotionController.getProcessedImages(image, faces, cameraImage.width, cameraImage.height);
      if(processedImages.isNotEmpty) {
        im = processedImages[0];
        print("Log: Image length: ${im.length}");
      }
      _isDetecting = false;
      update();
      sleep(Duration(milliseconds: 1000));

    });
  }
  
  @override
  void dispose() {
    cameraController?.stopImageStream();
    cameraController?.dispose();
    super.dispose();
  }
}