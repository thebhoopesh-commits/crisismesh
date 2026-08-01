import 'dart:async';
import 'dart:math' as math;

import 'package:camera/camera.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// 📷 Camera Service — Camera Capture & Hardware Stream.
///
/// Wraps the platform camera plugin. The UI calls [[start]] once and
/// feeds frames to the triage pipeline via [[captureFrame]].
class CameraService {
  CameraController? _controller;
  List<CameraDescription> _cameras = <CameraDescription>[];

  Future<void> initialize() async {
    _cameras = await availableCameras();
    if (_cameras.isEmpty) return;
    _controller = CameraController(
      _cameras.first,
      ResolutionPreset.high,
      enableAudio: false,
    );
    await _controller!.initialize();
  }

  Future<void> start() async {
    await _controller?.startImageStream((_) {});
  }

  Future<void> stop() async {
    await _controller?.stopImageStream();
  }

  Future<XFile> captureFrame() async {
    if (_controller == null) {
      throw StateError('Camera not initialized');
    }
    return _controller!.takePicture();
  }

  void dispose() {
    _controller?.dispose();
    _controller = null;
  }
}

final Provider<CameraService> cameraServiceProvider =
    Provider<CameraService>((_) => CameraService());

/// Generates a deterministic mock camera capture path for the UI demo.
String mockCapturePath() {
  final int n = math.Random().nextInt(1 << 31);
  return '/tmp/crisismesh_capture_$n.jpg';
}