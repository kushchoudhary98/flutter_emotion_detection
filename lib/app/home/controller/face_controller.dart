import 'dart:ui';

import 'package:get/get.dart';
import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';

class FaceController extends GetxController {
  FaceDetector? faceDetector;

  Future<void> load() async {
    faceDetector = FaceDetector(options: FaceDetectorOptions());
  }

  Future<List<Rect>> detectFaces(InputImage inputImage) async {
    
    List<Rect> masks = [];
    if(faceDetector == null){
      print('FaceDetector is null.');
      return masks;
    }
    final List<Face> faces = await faceDetector!.processImage(inputImage);

    for (Face face in faces) {
      masks.add(face.boundingBox);
    }

    return masks;
  }

  @override
  void onClose() {
    faceDetector?.close();
    super.onClose();
  }
}
