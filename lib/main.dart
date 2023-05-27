import 'package:camera/camera.dart';
import 'package:flutter/material.dart';

void main() async {
  /// Ensures that the plugin services are initialized.
  WidgetsFlutterBinding.ensureInitialized();

  /// Obtain a list of the available cameras on the device.
  final cameras = await availableCameras();

  /// Get a specific camera from the list of available cameras.
  final firstCamera = cameras.first;

  runApp(
    MaterialApp(
      title: 'Flutter Application',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      debugShowCheckedModeBanner: false,
      home: TakePictureScreen(
        camera: firstCamera,
      ),
    ),
  );
}

class TakePictureScreen extends StatefulWidget {
  const TakePictureScreen({Key? key, required this.camera}) : super(key: key);

  final CameraDescription camera;

  @override
  State<TakePictureScreen> createState() => _TakePictureScreenState();
}

class _TakePictureScreenState extends State<TakePictureScreen> {
  late CameraController _controller;
  late Future<void> _initializeControllerFuture;

  @override
  void initState() {
    super.initState();
    /// To display the current output of the Camera,
    /// a CameraController is created
    _controller = CameraController(
      /// Gets a specific camera from the list of available cameras.
      widget.camera,
      /// Defines the resolution to be used.
      ResolutionPreset.medium,
    );

    /// Initialize the controller. This returns a Future
    _initializeControllerFuture = _controller.initialize();
  }

  @override
  void dispose() {
    /// Disposes the controller when the widget is disposed.
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return const Placeholder();
  }
}
