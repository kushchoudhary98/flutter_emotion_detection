
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

class HomeController extends GetxController{
  CameraManager? cameraManager;
  late FaceController faceController;
  late EmotionController emotionController;
  CameraController? cameraController;
  bool _isDetecting = false;
  RxInt faceCount = 0.obs;
  RxList<Rect> faceBoxes = <Rect>[].obs;

  HomeController() {
    cameraManager = CameraManager();
  }

  Future<void> loadCamera() async {
    cameraController = await cameraManager?.load();
    update();
  }

  void startCameraStream() {
    print("Starting Camera Stream");
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

      Uint8List imageBytes = data[0] as Uint8List;
      InputImage inputImage = data[1] as InputImage;

      List<Rect> faces = await faceController.detectFaces(inputImage);
      faceBoxes.value = faces;
      print('Number of faces: ${faces.length}');
      if(faces.length > 0) {
        print(faces[0]);
      }
      faceCount.value = faces.length;

      List<String>? emotions = await emotionController.detectEmotions(imageBytes, faces, cameraImage.width, cameraImage.height);

      _isDetecting = false;
      sleep(Duration(milliseconds: 500));
      update();
    });
  }
  
}