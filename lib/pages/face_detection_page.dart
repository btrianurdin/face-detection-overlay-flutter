import 'package:face_detection_overlay/main.dart';
import 'package:face_detection_overlay/utils/face_detection_overlay.dart';
import 'package:flutter/material.dart';
import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';

class FaceDetectionPage extends StatefulWidget {
  const FaceDetectionPage({super.key});

  @override
  State<FaceDetectionPage> createState() => _FaceDetectionPageState();
}

class _FaceDetectionPageState extends State<FaceDetectionPage> {
  bool _faceFound = false;

  Widget _overlay() {
    return Stack(
      children: [
        Align(
          alignment: Alignment.topCenter,
          child: Container(
            width: double.infinity,
            height: MediaQuery.of(context).size.height * 0.30,
            color: Colors.black.withOpacity(0.6),
          ),
        ),
        Align(
          alignment: Alignment.bottomCenter,
          child: Container(
            width: double.infinity,
            height: MediaQuery.of(context).size.height * 0.30,
            color: Colors.black.withOpacity(0.6),
          ),
        ),
        Align(
          alignment: Alignment.centerLeft,
          child: Container(
            width: MediaQuery.of(context).size.width * 0.10,
            height: MediaQuery.of(context).size.height * 0.4001,
            color: Colors.black.withOpacity(0.6),
          ),
        ),
        Align(
          alignment: Alignment.centerRight,
          child: Container(
            width: MediaQuery.of(context).size.width * 0.10,
            height: MediaQuery.of(context).size.height * 0.4001,
            color: Colors.black.withOpacity(0.6),
          ),
        ),
        Align(
          alignment: Alignment.center,
          child: Container(
            width: MediaQuery.of(context).size.width * 0.82,
            height: MediaQuery.of(context).size.height * 0.41,
            decoration: BoxDecoration(
              border: Border.all(
                color: _faceFound ? Colors.green.shade700 : Colors.red.shade700,
                width: 5.0,
              ),
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
        Align(
          alignment: Alignment.topCenter,
          child: SafeArea(
            child: Container(
              width: MediaQuery.of(context).size.width * 0.80,
              margin: const EdgeInsets.only(top: 20),
              padding: const EdgeInsets.symmetric(vertical: 15),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                color: _faceFound ? Colors.green.shade700 : Colors.red.shade700,
              ),
              child: Text(
                _faceFound ? 'Deteksi Wajah Berhasil' : 'Deteksi Wajah Gagal',
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.white),
              ),
            ),
          ),
        )
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return FaceDetectionOverlay(
      cameras: cameras,
      faceDetectorOptions: FaceDetectorOptions(
        enableClassification: false,
        enableContours: false,
      ),
      overlay: _overlay(),
      resultCallback: _resultCallback,
    );
  }

  void _resultCallback(List result) {
    if (result.isNotEmpty) {
      for (final Face face in result) {
        final width = MediaQuery.of(context).size.width;
        final height = MediaQuery.of(context).size.height;

        final xPositionStart = width * 0.15;
        final xPositionEnd = width - (width * 0.15);
        final yPositionStart = height * 0.30;
        final yPositionEnd = height - (height * 0.30);

        if ((face.boundingBox.left > xPositionStart &&
                face.boundingBox.left < xPositionEnd) &&
            (face.boundingBox.top > yPositionStart &&
                face.boundingBox.top < yPositionEnd)) {
          setState(() {
            _faceFound = true;
          });
        } else {
          setState(() {
            _faceFound = false;
          });
        }
      }
    } else {
      setState(() {
        _faceFound = false;
      });
    }
  }
}
