
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
  RxList<String> emotions = <String>[].obs;
  RxList<Rect> faceBoxes = <Rect>[].obs;
  //Uint8List im = Uint8List(48*48*4);

  @override
  Future<void> onInit() async {
    super.onInit();
    cameraManager = CameraManager();
    emotionController = EmotionController();
    faceController = FaceController();

    cameraController = await cameraManager?.load();
    await emotionController.load();
    await faceController.load();
    update();
    startCameraStream();
  }

  Future<void> startCameraStream() async {
    print("Starting Camera Stream");
    if (cameraController == null) {
      print("Log: CameraController is null");
      return;
    }
    await cameraController!.startImageStream((cameraImage) async {
      if(_isDetecting) return;

      print('Face Detection Started');
      _isDetecting = true;

      try {
        final data = cameraManager?.inputImageFromCameraImage(cameraImage);
        if(data == null) {
          print('Log: inputImage is null. Something went wrong');
          _isDetecting = false;
          return;
        }

        InputImage inputImage = data;

        List<Rect> faces = await faceController.detectFaces(inputImage);
        print('Number of faces: ${faces.length}');
        if(faces.isNotEmpty) {
          print(faces[0]);
        }
        imglib.Image? image = null;
        faceCount.value = faces.length;
        if(Platform.isAndroid){
          image = cameraManager?.convertYUV420ToGrayscale(cameraImage);
        }
        else {
          image = cameraManager?.convertBGRA8888ToGreyscale(cameraImage);
        }
        if(image == null) {
          print('Log: image is null. in convertYUV420ToGrayscale');
          _isDetecting = false;
          return;
        }
        //Uint8List? debugImage = cameraManager?.convertToJPG(image);
        List<String> _emotions = await emotionController.detectEmotions(image, faces, cameraImage.width, cameraImage.height);
        if(_emotions.isNotEmpty) { 
          emotions.assignAll(_emotions);
          faceBoxes.assignAll(faces);
          // if(debugImage != null){
          //   im = debugImage;
          // }
          update();
        }
        else {
          emotions.clear();
          faceBoxes.clear();
        }

        // List<Uint8List> processedImages = emotionController.getProcessedImages(image, faces, cameraImage.width, cameraImage.height);
        // if(processedImages.isNotEmpty) {
        //   im = processedImages[0];
        //   print("Log: Image length: ${im.length}");
        // }
      }
      finally {
        _isDetecting = false;
      }
      //sleep(Duration(milliseconds: 1000));

    });
  }
  
  @override
  void onClose() {
    cameraController?.stopImageStream();
    cameraController?.dispose();
    super.onClose();
  }

}