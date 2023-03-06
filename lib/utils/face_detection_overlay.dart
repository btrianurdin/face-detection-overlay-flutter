import 'package:camera/camera.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';

class FaceDetectionOverlay extends StatefulWidget {
  const FaceDetectionOverlay(
      {super.key,
      required this.cameras,
      this.cameraDirection = CameraLensDirection.front,
      this.overlay,
      required this.faceDetectorOptions,
      required this.resultCallback});

  final CameraLensDirection cameraDirection;
  final Widget? overlay;
  final List<CameraDescription> cameras;
  final FaceDetectorOptions faceDetectorOptions;
  final Function(List result) resultCallback;

  @override
  State<FaceDetectionOverlay> createState() => _FaceDetectionOverlayState();
}

class _FaceDetectionOverlayState extends State<FaceDetectionOverlay> {
  CameraController? _camController;
  FaceDetector? _faceDetector;
  int _cameraIndex = -1;
  bool _canProcess = true;
  bool _isBusy = false;

  @override
  void initState() {
    super.initState();
    if (widget.cameras.any((element) =>
        element.lensDirection == widget.cameraDirection &&
        element.sensorOrientation == 90)) {
      _cameraIndex = widget.cameras.indexOf(
        widget.cameras.firstWhere((cam) =>
            cam.lensDirection == widget.cameraDirection &&
            cam.sensorOrientation == 90),
      );
    } else {
      for (var i = 0; i < widget.cameras.length; i++) {
        if (widget.cameras[i].lensDirection == widget.cameraDirection) {
          _cameraIndex = i;
          break;
        }
      }
    }
    _faceDetector = FaceDetector(options: widget.faceDetectorOptions);
    _startRecording();
  }

  Future _startRecording() async {
    final camera = widget.cameras[_cameraIndex];

    _camController =
        CameraController(camera, ResolutionPreset.high, enableAudio: false);
    _camController?.initialize().then((_) {
      if (!mounted) return;

      _camController?.startImageStream(_imageProcess);
      setState(() {});
    });
  }

  Future _imageProcess(CameraImage image) async {
    final WriteBuffer allBytes = WriteBuffer();
    for (final Plane plane in image.planes) {
      allBytes.putUint8List(plane.bytes);
    }
    final bytes = allBytes.done().buffer.asUint8List();

    final Size imageSize =
        Size(image.width.toDouble(), image.height.toDouble());

    final camera = widget.cameras[_cameraIndex];
    final imageRotation =
        InputImageRotationValue.fromRawValue(camera.sensorOrientation);

    if (imageRotation == null) return;

    final inputImageFormat =
        InputImageFormatValue.fromRawValue(image.format.raw);
    if (inputImageFormat == null) return;

    final planeData = image.planes.map(
      (Plane plane) {
        return InputImagePlaneMetadata(
          bytesPerRow: plane.bytesPerRow,
          height: plane.height,
          width: plane.width,
        );
      },
    ).toList();

    final inputImageData = InputImageData(
      size: imageSize,
      imageRotation: imageRotation,
      inputImageFormat: inputImageFormat,
      planeData: planeData,
    );

    final inputImage =
        InputImage.fromBytes(bytes: bytes, inputImageData: inputImageData);

    _detectionProcess(inputImage);
  }

  Future _detectionProcess(InputImage inputImage) async {
    if (!_canProcess) return;
    if (_isBusy) return;
    _isBusy = true;

    final faces = await _faceDetector!.processImage(inputImage);

    if (inputImage.inputImageData?.size != null &&
        inputImage.inputImageData?.imageRotation != null) {
      widget.resultCallback(faces);
    }
    _isBusy = false;
    if (mounted) {
      setState(() {});
    }
  }

  Widget _viewRender() {
    if (_camController?.value.isInitialized == false) {
      return Container();
    }

    final size = MediaQuery.of(context).size;
    var scale = size.aspectRatio * _camController!.value.aspectRatio;

    if (scale < 1) scale = 1 / scale;

    return Container(
      color: Colors.black,
      child: Stack(
        fit: StackFit.expand,
        children: [
          Transform.scale(
            scale: scale,
            child: Center(
              child: CameraPreview(_camController!),
            ),
          ),
          widget.overlay != null ? widget.overlay! : const Text(''),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(body: _viewRender());
  }

  Future _stopRecording() async {
    await _camController?.stopImageStream();
    await _camController?.dispose();
    _camController = null;
  }

  @override
  void dispose() {
    _stopRecording();
    _canProcess = false;
    _faceDetector!.close();
    super.dispose();
  }
}
