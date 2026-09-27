import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import '../providers/sign_analyzer_provider.dart';

class SignCaptureScreen extends ConsumerStatefulWidget {
  final String targetCountry; // e.g. "Japan"

  const SignCaptureScreen({Key? key, required this.targetCountry})
      : super(key: key);

  @override
  ConsumerState<SignCaptureScreen> createState() => _SignCaptureScreenState();
}

class _SignCaptureScreenState extends ConsumerState<SignCaptureScreen> {
  CameraController? _controller;
  Future<void>? _initializeControllerFuture;

  List<CameraDescription> _cameras = [];
  int _selectedCameraIndex = 0;

  double _minZoom = 1.0;
  double _maxZoom = 1.0;
  double _currentZoom = 1.0;

  @override
  void initState() {
    super.initState();
    _initCameras();
  }

  Future<void> _initCameras() async {
    try {
      _cameras = await availableCameras();
      if (_cameras.isNotEmpty) {
        await _setupCamera(_cameras[_selectedCameraIndex]);
      }
    } catch (e) {
      debugPrint('❌ [SignCapture] Camera initialization error: $e');
    }
  }

  Future<void> _setupCamera(CameraDescription cameraDescription) async {
    if (_controller != null) {
      await _controller!.dispose();
    }

    // Use ResolutionPreset.max to match the native camera app's full uncropped sensor field of view
    _controller = CameraController(
      cameraDescription,
      ResolutionPreset.max,
      enableAudio: false,
    );

    _initializeControllerFuture = _controller!.initialize().then((_) async {
      if (!mounted) return;
      try {
        _minZoom = await _controller!.getMinZoomLevel();
        _maxZoom = await _controller!.getMaxZoomLevel();
        _currentZoom = _minZoom;
        await _controller!.setZoomLevel(_currentZoom);
      } catch (e) {
        debugPrint(
            '⚠️ [SignCapture] Zoom not supported on this device/browser: $e');
      }
      setState(() {});
    });

    if (mounted) setState(() {});
  }

  Future<void> _switchCamera() async {
    if (_cameras.length < 2) return;
    setState(() {
      _selectedCameraIndex = (_selectedCameraIndex + 1) % _cameras.length;
    });
    await _setupCamera(_cameras[_selectedCameraIndex]);
  }

  Future<void> _updateZoom(double zoom) async {
    if (_controller == null || !_controller!.value.isInitialized) return;
    setState(() {
      _currentZoom = zoom;
    });
    try {
      await _controller!.setZoomLevel(_currentZoom);
    } catch (e) {
      debugPrint('❌ [SignCapture] Error setting zoom: $e');
    }
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  // Handle Image from Gallery option
  Future<void> _pickImageFromGallery() async {
    try {
      final XFile? pickedFile = await ImagePicker().pickImage(
        source: ImageSource.gallery,
        imageQuality: 85,
      );

      if (pickedFile != null) {
        final bytes = await pickedFile.readAsBytes();

        debugPrint(
            '🎯 [SignCapture] Image successfully selected from Gallery: ${pickedFile.path}');
        debugPrint(
            '🚀 [SignCapture] Dispatched image payload to Google AI Studio (Gemini) for target country: ${widget.targetCountry}');

        if (!mounted) return;
        await ref.read(signAnalyzerStateProvider.notifier).captureAndAnalyze(
              imageBytes: bytes,
              targetCountry: widget.targetCountry,
            );
      }
    } catch (e) {
      debugPrint('❌ [SignCapture] Gallery pick error: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading image from gallery: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final analysisState = ref.watch(signAnalyzerStateProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text('Scan Sign (${widget.targetCountry})'),
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        actions: [
          if (_cameras.length > 1)
            IconButton(
              icon: const Icon(Icons.switch_camera),
              tooltip: 'Switch Camera',
              onPressed: analysisState.isLoading ? null : _switchCamera,
            ),
          IconButton(
            icon: const Icon(Icons.photo_library),
            tooltip: 'Choose image from gallery',
            onPressed: analysisState.isLoading ? null : _pickImageFromGallery,
          ),
        ],
      ),
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // 1. Camera Preview (Optimized aspect ratio to avoid artificial zoom/cropping)
          FutureBuilder<void>(
            future: _initializeControllerFuture,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.done &&
                  _controller != null &&
                  _controller!.value.isInitialized) {
                final size = MediaQuery.of(context).size;
                var camera = _controller!.value;

                // Calculate correct scale to fit screen proportionally without aggressive cropping
                // If aspect ratio needs matching:
                return Center(
                  child: CameraPreview(_controller!),
                );
              } else {
                return const Center(
                  child: CircularProgressIndicator(color: Colors.deepOrange),
                );
              }
            },
          ),

          // 2. Viewfinder Guide Box Overlay
          Center(
            child: Container(
              width: 300,
              height: 200,
              decoration: BoxDecoration(
                border: Border.all(
                    color: Colors.deepOrange.withValues(alpha: 0.8), width: 2),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Align(
                alignment: Alignment.topCenter,
                child: Container(
                  margin: const EdgeInsets.only(top: 8),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.black54,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Text(
                    'Align sign inside box',
                    style: TextStyle(color: Colors.white, fontSize: 12),
                  ),
                ),
              ),
            ),
          ),

          // 3. Zoom Slider Control (Right side vertical bar)
          if (_maxZoom > _minZoom)
            Positioned(
              right: 16,
              top: 40,
              bottom: 140,
              child: Container(
                width: 48,
                padding: const EdgeInsets.symmetric(vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.black54,
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: Colors.white24),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.zoom_in, color: Colors.white70, size: 20),
                    const SizedBox(height: 8),
                    Expanded(
                      child: RotatedBox(
                        quarterTurns: 3,
                        child: Slider(
                          value: _currentZoom,
                          min: _minZoom,
                          max: _maxZoom,
                          activeColor: Colors.deepOrange,
                          inactiveColor: Colors.white30,
                          onChanged: _updateZoom,
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '${_currentZoom.toStringAsFixed(1)}x',
                      style: const TextStyle(color: Colors.white, fontSize: 10),
                    ),
                  ],
                ),
              ),
            ),

          // 4. Loading State Indicator Overlay
          if (analysisState.isLoading)
            Container(
              color: Colors.black54,
              child: const Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CircularProgressIndicator(color: Colors.deepOrange),
                    SizedBox(height: 16),
                    Text(
                      'Analyzing cultural context via Gemini...',
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),
            ),

          // 5. Capture Button Overlay
          Positioned(
            bottom: 40,
            left: 0,
            right: 0,
            child: Center(
              child: FloatingActionButton.large(
                backgroundColor: Colors.deepOrange,
                foregroundColor: Colors.white,
                onPressed: analysisState.isLoading
                    ? null
                    : () async {
                        try {
                          await _initializeControllerFuture;
                          final image = await _controller!.takePicture();
                          final bytes = await image.readAsBytes();

                          debugPrint(
                              '📸 [SignCapture] Photo successfully captured from camera: ${image.path}');
                          debugPrint(
                              '🚀 [SignCapture] Dispatched image payload to Google AI Studio (Gemini) for target country: ${widget.targetCountry}');

                          await ref
                              .read(signAnalyzerStateProvider.notifier)
                              .captureAndAnalyze(
                                imageBytes: bytes,
                                targetCountry: widget.targetCountry,
                              );
                        } catch (e) {
                          debugPrint(
                              '❌ [SignCapture] Camera capture error: $e');
                          if (mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                  content: Text('Error capturing image: $e')),
                            );
                          }
                        }
                      },
                child: const Icon(Icons.camera_alt, size: 36),
              ),
            ),
          ),

          // 6. Result Bottom Sheet handler
          if (analysisState.hasValue && analysisState.value != null)
            DraggableScrollableSheet(
              initialChildSize: 0.45,
              minChildSize: 0.25,
              maxChildSize: 0.85,
              builder: (context, scrollController) {
                final data = analysisState.value!;
                return Container(
                  padding: const EdgeInsets.all(24),
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius:
                        BorderRadius.vertical(top: Radius.circular(24)),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black26,
                        blurRadius: 10,
                        spreadRadius: 2,
                      )
                    ],
                  ),
                  child: ListView(
                    controller: scrollController,
                    children: [
                      Center(
                        child: Container(
                          width: 40,
                          height: 4,
                          decoration: BoxDecoration(
                            color: Colors.grey[300],
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Detected Text: "${data.originalText}"',
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          color: Colors.grey,
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        data.translation,
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                      const Divider(height: 32),
                      const Row(
                        children: [
                          Icon(Icons.lightbulb_outline,
                              color: Colors.deepOrange, size: 20),
                          SizedBox(width: 8),
                          Text(
                            'Cultural Context & Mindset',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                              color: Colors.blueGrey,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Text(
                        data.culturalContext,
                        style: const TextStyle(
                          fontSize: 16,
                          height: 1.4,
                          color: Colors.black87,
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
        ],
      ),
    );
  }
}
