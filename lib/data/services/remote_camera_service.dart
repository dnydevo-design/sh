import 'package:camera/camera.dart';

class RemoteCameraService {
  CameraController? _controller;

  CameraController? get controller => _controller;

  Future<CameraController?> startPreview() async {
    final cameras = await availableCameras();
    if (cameras.isEmpty) {
      return null;
    }
    final camera = cameras.firstWhere(
      (candidate) => candidate.lensDirection == CameraLensDirection.back,
      orElse: () => cameras.first,
    );
    final controller = CameraController(
      camera,
      ResolutionPreset.medium,
      enableAudio: false,
    );
    await controller.initialize();
    _controller = controller;
    return controller;
  }

  Future<void> stop() async {
    await _controller?.dispose();
    _controller = null;
  }
}

