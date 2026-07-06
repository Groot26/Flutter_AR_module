import 'package:vector_math/vector_math_64.dart';

enum ArRenderableType { fileSystemGlb, fileSystemGltf }

class PreparedArModel {
  const PreparedArModel({
    required this.nodeUri,
    required this.renderableType,
    required this.initialPositionOffset,
    required this.initialRotation,
    required this.initialScale,
  });

  final String nodeUri;
  final ArRenderableType renderableType;
  final Vector3 initialPositionOffset;
  final Vector4 initialRotation;
  final double initialScale;
}
