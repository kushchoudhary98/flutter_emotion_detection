import 'package:camera/camera.dart';
import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_face_detection/app/home/controller/camera_controller.dart';
import 'package:flutter_face_detection/app/home/controller/home_controller.dart';
import 'package:get/get.dart';
import 'package:get/get_state_manager/get_state_manager.dart';

class HomeView extends GetView<HomeController> {
  HomeView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      body: GetBuilder<HomeController>(
        init: controller,
        builder: (HomeController controller) {
          if(controller.cameraController == null) {
            return Center(child: Text('Loading Camera...'));
          }
          return Column(
            children: [
              Obx(() => Stack(
                children: [
                    CameraPreview(controller.cameraController!),
                    ...controller.faceBoxes.value.mapIndexed((index, box)  {
                      final perviewWidth = controller.cameraController!.value.previewSize!.height;
                      final perviewHeight = controller.cameraController!.value.previewSize!.width;
                      return Positioned(
                        left: box.left * MediaQuery.of(context).size.width / perviewWidth,
                        top: box.top * 1.3,
                        width: box.width * MediaQuery.of(context).size.width / perviewWidth,
                        height: box.height * (MediaQuery.of(context).size.height / perviewHeight) * 0.8,
                        child: Container(
                          decoration: BoxDecoration(
                            border: Border.all(
                              color: Colors.red,
                              width: 2,
                            ),
                          ),
                          child: Text(
                            controller.emotions[index],
                            style: TextStyle(
                              backgroundColor: Colors.red,
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                            ),
                        ),
                      );
                    }),
                  ],
                )
              ),
              Center(child: Obx(() => Text('Number of faces: ${controller.faceCount.value}'))),
              //Image.memory(controller.im, scale: 2,)
            ]
          );
        },
      ),
    );
  }
}