import 'dart:io';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';

Future<void> main() async {
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
        // Pass the appropriate camera  to the TakePictureScreen widget.
        camera: firstCamera,
      ),
    ),
  );
}

/// A screen that allows users to take a picture using a given camera.
class TakePictureScreen extends StatefulWidget {
  const TakePictureScreen({
    super.key,
    required this.camera,
  });

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
    // To display the current output of the Camera,
    // a CameraController is created
    _controller = CameraController(
      // Gets a specific camera from the list of available cameras.
      widget.camera,
      // Defines the resolution to be used.
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
    return Scaffold(
      appBar: AppBar(
        title: const Text('Take a picture'),
      ),
      // The controller has to finish initializing before displaying the
      // camera preview. This is why a FutureBuilder is used to display a
      // loading spinner until the controller has finished initializing.
      body: FutureBuilder<void>(
        future: _initializeControllerFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            // If the Future is complete, display the preview
            return CameraPreview(_controller);
          } else {
            // Otherwise, display a loading indicator
            return const Center(child: CircularProgressIndicator());
          }
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          /// Take the picture in a try / catch block
          /// to catch any error that may occur
          try {
            /// Ensure that the camera is initialized
            await _initializeControllerFuture;

            /// Attempt to take a picture and get the file 'image'
            /// where it was saved.
            final image = await _controller.takePicture();

            if (!mounted) return;

            /// Display the location at which the image was stored using snackbar
            final snackBar = SnackBar(content: Text('Image stored at: ${image.path}'));
            ScaffoldMessenger.of(context).showSnackBar(snackBar);

            /// If the picture was taken, display it in a new screen.
            await Navigator.of(context).push(MaterialPageRoute(
                builder: (context) => DisplayPictureScreen(
                      /// Pass the automatically generated path to
                      /// the DisplayPictureScreen widget
                      imagePath: image.path,
                    )));
          } catch (e) {
            /// If an error occurs, doc it in the console
            print(e);
          }
        },
        child: const Icon(Icons.camera_alt),
      ),
    );
  }
}

class DisplayPictureScreen extends StatelessWidget {
  const DisplayPictureScreen({super.key, required this.imagePath});

  final String imagePath;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Picture Display'),),
      /// The image is stored as a file on the device.
      /// The 'Image.file' constructor with the given path is
      /// used in order to display the image.
      body: Image.file(File(imagePath)),
    );
  }
}
