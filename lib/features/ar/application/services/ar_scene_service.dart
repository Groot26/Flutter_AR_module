import 'package:vector_math/vector_math_64.dart';

import '../../domain/entities/prepared_ar_model.dart';

typedef ArSceneErrorCallback = void Function(String message);
typedef ArPlaneTappedCallback = Future<void> Function(Matrix4 worldTransform);

class ArViewHandles {
  const ArViewHandles({
    required this.sessionManager,
    required this.objectManager,
    required this.anchorManager,
  });

  final Object sessionManager;
  final Object objectManager;
  final Object anchorManager;
}

abstract class ArSceneService {
  bool get isBound;

  Future<void> bind(ArViewHandles handles);

  Future<void> initialize({
    required ArSceneErrorCallback onError,
    required ArPlaneTappedCallback onPlaneTapped,
  });

  Future<bool> placeModelOnPlane({
    required PreparedArModel model,
    required Matrix4 planeWorldTransform,
  });

  Future<bool> scaleCurrentModel(double scaleFactorDelta);

  Future<bool> rotateCurrentModel(double radiansDelta);

  Future<bool> moveCurrentModel(Vector3 delta);

  Future<bool> setCurrentModelAnimationPlaying(bool playing);

  Future<bool> stopCurrentModelAnimation();

  Future<bool> resetCurrentModelTransform();

  Future<void> clearPlacedModel();

  Future<void> pause();

  Future<void> resume();

  Future<void> dispose();
}
