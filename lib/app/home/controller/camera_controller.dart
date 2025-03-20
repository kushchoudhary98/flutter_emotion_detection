import 'dart:io';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get_state_manager/get_state_manager.dart';
import 'package:google_mlkit_commons/google_mlkit_commons.dart';
import 'package:image/image.dart' as imglib;

class CameraManager extends GetxController {
  CameraController? cameraController;
  List<CameraDescription>? _cameras;
  final _orientations = {
    DeviceOrientation.portraitUp: 0,
    DeviceOrientation.landscapeLeft: 90,
    DeviceOrientation.portraitDown: 180,
    DeviceOrientation.landscapeRight: 270,
  };

  
  Future<CameraController?> load() async {
    _cameras = await availableCameras();
    cameraController = CameraController(
      _cameras![1],
      ResolutionPreset.low,
      enableAudio: false,
      imageFormatGroup: Platform.isAndroid? ImageFormatGroup.nv21 : ImageFormatGroup.bgra8888,
    );
    await cameraController!.initialize();

    return cameraController;
  }

  InputImage? inputImageFromCameraImage(CameraImage image) {
    // get image rotation
    // it is used in android to convert the InputImage from Dart to Java
    // `rotation` is not used in iOS to convert the InputImage from Dart to Obj-C
    // in both platforms `rotation` and `camera.lensDirection` can be used to compensate `x` and `y` coordinates on a canvas
    final camera = _cameras![1];
    final sensorOrientation = camera.sensorOrientation;
    InputImageRotation? rotation;
    if (Platform.isIOS) {
      rotation = InputImageRotationValue.fromRawValue(sensorOrientation);
    } else if (Platform.isAndroid) {
      var rotationCompensation =
          _orientations[DeviceOrientation.portraitUp];

      if (rotationCompensation == null) return null;
      if (camera.lensDirection == CameraLensDirection.front) {
        // front-facing
        rotationCompensation = (sensorOrientation + rotationCompensation) % 360;
      } else {
        // back-facing
        rotationCompensation =
            (sensorOrientation - rotationCompensation + 360) % 360;
      }
      rotation = InputImageRotationValue.fromRawValue(rotationCompensation);
    }
   
    if (rotation == null) return null;

    if(Platform.isAndroid){
      Uint8List nv21Data = convertYUV420ToNV21(image);

      return 
        InputImage.fromBytes(
        bytes: nv21Data,
        metadata: InputImageMetadata(
          size: Size(image.width.toDouble(), image.height.toDouble()),
          rotation: rotation,
          format: Platform.isAndroid? InputImageFormat.nv21 : InputImageFormat.bgra8888,
          bytesPerRow: image.width,
        ),
      );
    }
    else {
      //for iOS
      final format = InputImageFormatValue.fromRawValue(image.format.raw);
      if (format == null ||
              (Platform.isAndroid && format != InputImageFormat.nv21) ||
              (Platform.isIOS && format != InputImageFormat.bgra8888)) {
        return null;
      }

      // since format is constraint to nv21 or bgra8888, both only have one plane
      if (image.planes.length != 1) return null;
      final plane = image.planes.first;

      // compose InputImage using bytes
      return InputImage.fromBytes(
        bytes: plane.bytes,
        metadata: InputImageMetadata(
          size: Size(image.width.toDouble(), image.height.toDouble()),
          rotation: rotation, // used only in Android
          format: format, // used only in iOS
          bytesPerRow: plane.bytesPerRow, // used only in iOS
        ),
      );
    }
  }

  Uint8List convertYUV420ToNV21(CameraImage image) {
    final width = image.width;
    final height = image.height;

    // Planes from CameraImage
    final yPlane = image.planes[0];
    final uPlane = image.planes[1];
    final vPlane = image.planes[2];

    // Buffers from Y, U, and V planes
    final yBuffer = yPlane.bytes;
    final uBuffer = uPlane.bytes;
    final vBuffer = vPlane.bytes;

    // Total number of pixels in NV21 format
    final numPixels = width * height + (width * height ~/ 2);
    final nv21 = Uint8List(numPixels);

    // Y (Luma) plane metadata
    int idY = 0;
    int idUV = width * height; // Start UV after Y plane
    final uvWidth = width ~/ 2;
    final uvHeight = height ~/ 2;

    // Strides and pixel strides for Y and UV planes
    final yRowStride = yPlane.bytesPerRow;
    final yPixelStride = yPlane.bytesPerPixel ?? 1;
    final uvRowStride = uPlane.bytesPerRow;
    final uvPixelStride = uPlane.bytesPerPixel ?? 2;

    // Copy Y (Luma) channel
    for (int y = 0; y < height; ++y) {
      final yOffset = y * yRowStride;
      for (int x = 0; x < width; ++x) {
        nv21[idY++] = yBuffer[yOffset + x * yPixelStride];
      }
    }

    // Copy UV (Chroma) channels in NV21 format (YYYYVU interleaved)
    for (int y = 0; y < uvHeight; ++y) {
      final uvOffset = y * uvRowStride;
      for (int x = 0; x < uvWidth; ++x) {
        final bufferIndex = uvOffset + (x * uvPixelStride);
        nv21[idUV++] = vBuffer[bufferIndex]; // V channel
        nv21[idUV++] = uBuffer[bufferIndex]; // U channel
      }
    }

    return nv21;
  }

  Uint8List? convertCameraImageToUint8List(CameraImage image) {
    final WriteBuffer allBytes = WriteBuffer();
    for (var plane in image.planes) {
      allBytes.putUint8List(plane.bytes);
    }
    return allBytes.done().buffer.asUint8List();
  }

  Uint8List convertYUV420ToRGB(CameraImage image) {
    final int width = image.width;
    final int height = image.height;
    final int yRowStride = image.planes[0].bytesPerRow;
    final int uvRowStride = image.planes[1].bytesPerRow;
    final int uvPixelStride = image.planes[1].bytesPerPixel ?? 1;

    Uint8List rgbBytes = Uint8List(width * height * 3);
    int index = 0;

    for (int y = 0; y < height; y++) {
      for (int x = 0; x < width; x++) {
        int yIndex = y * yRowStride + x;
        int uvIndex = (y ~/ 2) * uvRowStride + (x ~/ 2) * uvPixelStride;

        int Y = image.planes[0].bytes[yIndex] & 0xFF;
        int U = image.planes[1].bytes[uvIndex] & 0xFF;
        int V = image.planes[2].bytes[uvIndex] & 0xFF;

        int R = (Y + 1.402 * (V - 128)).toInt().clamp(0, 255);
        int G = (Y - 0.344136 * (U - 128) - 0.714136 * (V - 128)).toInt().clamp(0, 255);
        int B = (Y + 1.772 * (U - 128)).toInt().clamp(0, 255);

        rgbBytes[index++] = R;
        rgbBytes[index++] = G;
        rgbBytes[index++] = B;
      }
    }

    return Uint8List.fromList(rgbBytes);
  }

  imglib.Image convertYUV420ToGrayscale(CameraImage image) {
    // Ensure the image format is YUV420
    if (image.format.group != ImageFormatGroup.yuv420) {
      throw UnsupportedError('Unsupported image format: ${image.format.group}');
    }

    // Extract the Y plane (luminance)
    final yPlane = image.planes[0];
    final width = image.width;
    final height = image.height;

    // Create an Image buffer with the same width and height
    final imglib.Image grayscaleImage = imglib.Image(width: width, height: height);

    // Iterate over each pixel to set the luminance value
    for (int y = 0; y < height; y++) {
      for (int x = 0; x < width; x++) {
        final index = y * width + x;
        final luminance = yPlane.bytes[index];
        grayscaleImage.setPixel(x, y, imglib.ColorInt32.rgb(luminance, luminance, luminance));
      }
    }

    // Encode the grayscale image to PNG format
    return grayscaleImage;
  }

  Uint8List convertGrayscaleToRGBA(int width, int height, Uint8List grayscaleBytes) {
    Uint8List rgbaBytes = Uint8List(width * height * 4);
    for (int i = 0; i < grayscaleBytes.length; i++) {
      int pixel = grayscaleBytes[i];
      rgbaBytes[i * 4] = pixel; // R
      rgbaBytes[i * 4 + 1] = pixel; // G
      rgbaBytes[i * 4 + 2] = pixel; // B
      rgbaBytes[i * 4 + 3] = 255; // Alpha
    }
    return rgbaBytes;
  }


  @override void dispose() {
    cameraController?.dispose();
    super.dispose();
  }
}