import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart'; // <-- For gallery import
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
  final ImageProvider = ImagePicker(); // Instance for gallery picking

  @override
  void initState() {
    super.initState();
    _initCamera();
  }

  Future<void> _initCamera() async {
    final cameras = await availableCameras();
    if (cameras.isNotEmpty) {
      _controller = CameraController(
        cameras[0],
        ResolutionPreset.high,
        enableAudio: false,
      );
      _initializeControllerFuture = _controller!.initialize();
      if (mounted) setState(() {});
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

        // Terminal Console Log requested
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
          // Gallery Selection Action Button
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
          // 1. Camera Preview
          FutureBuilder<void>(
            future: _initializeControllerFuture,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.done) {
                return SizedBox.expand(
                  child: FittedBox(
                    fit: BoxFit.cover,
                    child: SizedBox(
                      width: _controller!.value.previewSize?.height ?? 100,
                      height: _controller!.value.previewSize?.width ?? 100,
                      child: CameraPreview(_controller!),
                    ),
                  ),
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
                    color: Colors.deepOrange.withOpacity(0.8), width: 2),
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

          // 3. Loading State Indicator Overlay
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

          // 4. Capture Button Overlay
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

                          // Terminal Console Logs requested
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

          // 5. Result Bottom Sheet handler
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
