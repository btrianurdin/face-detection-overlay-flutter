import 'package:face_detection_overlay/pages/face_detection_page.dart';
import 'package:flutter/material.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        alignment: Alignment.center,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('Click button bellow to open camera'),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const FaceDetectionPage(),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                padding:
                    const EdgeInsets.symmetric(vertical: 20, horizontal: 30),
              ),
              icon: const Icon(Icons.camera_alt_outlined),
              label: const Text('Open Camera'),
            )
          ],
        ),
      ),
    );
    // return Scaffold(
    //   body: FaceDetectionOverlay(
    //     cameras: cameras,
    //     faceDetectorOptions: FaceDetectorOptions(
    //       enableContours: false,
    //       enableClassification: false,
    //     ),
    //   ),
    // );
  }
}
