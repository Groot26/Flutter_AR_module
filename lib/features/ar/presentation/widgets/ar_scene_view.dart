import 'package:ar_flutter_plugin/ar_flutter_plugin.dart';
import 'package:ar_flutter_plugin/datatypes/config_planedetection.dart';
import 'package:ar_flutter_plugin/managers/ar_anchor_manager.dart';
import 'package:ar_flutter_plugin/managers/ar_location_manager.dart';
import 'package:ar_flutter_plugin/managers/ar_object_manager.dart';
import 'package:ar_flutter_plugin/managers/ar_session_manager.dart';
import 'package:flutter/material.dart';

typedef ArManagersCreatedCallback =
    Future<void> Function({
      required Object sessionManager,
      required Object objectManager,
      required Object anchorManager,
    });

class ArSceneView extends StatefulWidget {
  const ArSceneView({
    super.key,
    required this.sceneRevision,
    required this.onManagersCreated,
    required this.onScaleGesture,
  });

  final int sceneRevision;
  final ArManagersCreatedCallback onManagersCreated;
  final ValueChanged<double> onScaleGesture;

  @override
  State<ArSceneView> createState() => _ArSceneViewState();
}

class _ArSceneViewState extends State<ArSceneView> {
  double _lastScale = 1.0;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        ARView(
          key: ValueKey<int>(widget.sceneRevision),
          planeDetectionConfig: PlaneDetectionConfig.horizontal,
          onARViewCreated: _onArViewCreated,
        ),
        Positioned.fill(
          child: GestureDetector(
            behavior: HitTestBehavior.translucent,
            onScaleStart: (_) {
              _lastScale = 1.0;
            },
            onScaleUpdate: (details) {
              if (details.pointerCount < 2) {
                return;
              }
              final delta = details.scale / _lastScale;
              _lastScale = details.scale;
              widget.onScaleGesture(delta);
            },
          ),
        ),
      ],
    );
  }

  Future<void> _onArViewCreated(
    ARSessionManager sessionManager,
    ARObjectManager objectManager,
    ARAnchorManager anchorManager,
    ARLocationManager locationManager,
  ) {
    return widget.onManagersCreated(
      sessionManager: sessionManager,
      objectManager: objectManager,
      anchorManager: anchorManager,
    );
  }
}
