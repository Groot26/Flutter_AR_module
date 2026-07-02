import 'package:ar_flutter_plugin/datatypes/hittest_result_types.dart';
import 'package:ar_flutter_plugin/datatypes/node_types.dart';
import 'package:ar_flutter_plugin/managers/ar_anchor_manager.dart';
import 'package:ar_flutter_plugin/managers/ar_object_manager.dart';
import 'package:ar_flutter_plugin/managers/ar_session_manager.dart';
import 'package:ar_flutter_plugin/models/ar_anchor.dart';
import 'package:ar_flutter_plugin/models/ar_hittest_result.dart';
import 'package:ar_flutter_plugin/models/ar_node.dart';
import 'package:vector_math/vector_math_64.dart';

import '../../application/services/ar_scene_service.dart';
import '../../domain/entities/prepared_ar_model.dart';

class ArFlutterSceneService implements ArSceneService {
  ARSessionManager? _sessionManager;
  ARObjectManager? _objectManager;
  ARAnchorManager? _anchorManager;

  ARPlaneAnchor? _currentAnchor;
  ARNode? _currentNode;
  PreparedArModel? _currentModel;

  @override
  bool get isBound =>
      _sessionManager != null &&
      _objectManager != null &&
      _anchorManager != null;

  @override
  Future<void> bind(ArViewHandles handles) async {
    if (handles.sessionManager is! ARSessionManager ||
        handles.objectManager is! ARObjectManager ||
        handles.anchorManager is! ARAnchorManager) {
      throw Exception('Invalid AR manager handles received.');
    }

    _sessionManager = handles.sessionManager as ARSessionManager;
    _objectManager = handles.objectManager as ARObjectManager;
    _anchorManager = handles.anchorManager as ARAnchorManager;
  }

  @override
  Future<void> initialize({
    required ArSceneErrorCallback onError,
    required ArPlaneTappedCallback onPlaneTapped,
  }) async {
    final sessionManager = _sessionManager;
    final objectManager = _objectManager;
    if (sessionManager == null || objectManager == null) {
      throw Exception('AR scene is not bound to ARView yet.');
    }

    sessionManager.onInitialize(
      showAnimatedGuide: false,
      showFeaturePoints: false,
      showPlanes: true,
      showWorldOrigin: false,
      handlePans: true,
      handleRotation: true,
    );
    objectManager.onInitialize();

    sessionManager.onPlaneOrPointTap =
        (hits) => _handlePlaneTap(hits, onPlaneTapped, onError);
    objectManager.onPanEnd = (_, __) {};
    objectManager.onRotationEnd = (_, __) {};
  }

  @override
  Future<bool> placeModelOnPlane({
    required PreparedArModel model,
    required Matrix4 planeWorldTransform,
  }) async {
    final anchorManager = _anchorManager;
    final objectManager = _objectManager;
    if (anchorManager == null || objectManager == null) {
      throw Exception('AR scene is not initialized.');
    }

    await clearPlacedModel();

    final anchor = ARPlaneAnchor(transformation: planeWorldTransform);
    final didAddAnchor = await anchorManager.addAnchor(anchor);
    if (didAddAnchor != true) {
      return false;
    }

    final node = ARNode(
      type: _toNodeType(model.renderableType),
      uri: model.nodeUri,
      position: model.initialPositionOffset,
      scale: Vector3.all(model.initialScale),
      rotation: model.initialRotation,
    );

    final didAddNode = await objectManager.addNode(node, planeAnchor: anchor);
    if (didAddNode != true) {
      await anchorManager.removeAnchor(anchor);
      return false;
    }

    _currentAnchor = anchor;
    _currentNode = node;
    _currentModel = model;
    return true;
  }

  @override
  Future<bool> scaleCurrentModel(double scaleFactorDelta) async {
    final node = _currentNode;
    if (node == null) {
      return false;
    }

    final currentScale = node.scale.x;
    final nextScale = (currentScale * scaleFactorDelta).clamp(0.06, 2.5);
    node.scale = Vector3.all(nextScale);
    return true;
  }

  @override
  Future<bool> rotateCurrentModel(double radiansDelta) async {
    final node = _currentNode;
    if (node == null) {
      return false;
    }

    final currentRotation = Quaternion.fromRotation(node.rotation);
    final deltaRotation = Quaternion.axisAngle(Vector3(0.0, 1.0, 0.0), radiansDelta);
    node.rotationFromQuaternion = deltaRotation * currentRotation;
    return true;
  }

  @override
  Future<bool> moveCurrentModel(Vector3 delta) async {
    final node = _currentNode;
    if (node == null) {
      return false;
    }

    node.position = node.position + delta;
    return true;
  }

  @override
  Future<bool> setCurrentModelAnimationPlaying(bool playing) async {
    final node = _currentNode;
    if (node == null) {
      return false;
    }

    final objectManager = _objectManager;
    final nodeName = node.name;
    if (objectManager == null || nodeName.isEmpty) {
      return false;
    }

    final result =
        playing
            ? await objectManager.resumeAnimation(nodeName)
            : await objectManager.pauseAnimation(nodeName);
    return result == true;
  }

  @override
  Future<bool> stopCurrentModelAnimation() async {
    final node = _currentNode;
    final objectManager = _objectManager;
    if (node == null || objectManager == null || node.name.isEmpty) {
      return false;
    }

    return (await objectManager.stopAnimation(node.name)) == true;
  }

  @override
  Future<bool> resetCurrentModelTransform() async {
    final node = _currentNode;
    final model = _currentModel;
    if (node == null || model == null) {
      return false;
    }

    node.position = model.initialPositionOffset;
    node.scale = Vector3.all(model.initialScale);
    node.rotationFromQuaternion = Quaternion.axisAngle(
      Vector3(
        model.initialRotation.x,
        model.initialRotation.y,
        model.initialRotation.z,
      ),
      model.initialRotation.w,
    );
    return true;
  }

  @override
  Future<void> clearPlacedModel() async {
    final anchorManager = _anchorManager;
    final currentAnchor = _currentAnchor;
    final currentNode = _currentNode;

    await stopCurrentModelAnimation();
    if (anchorManager != null && currentAnchor != null) {
      await anchorManager.removeAnchor(currentAnchor);
    } else if (_objectManager != null && currentNode != null) {
      _objectManager!.removeNode(currentNode);
    }

    _currentAnchor = null;
    _currentNode = null;
    _currentModel = null;
  }

  @override
  Future<void> pause() async {
    await dispose();
  }

  @override
  Future<void> resume() async {}

  @override
  Future<void> dispose() async {
    await stopCurrentModelAnimation();
    await _sessionManager?.dispose();
    _sessionManager = null;
    _objectManager = null;
    _anchorManager = null;
    _currentAnchor = null;
    _currentNode = null;
  }

  Future<void> _handlePlaneTap(
    List<ARHitTestResult> hitResults,
    ArPlaneTappedCallback onPlaneTapped,
    ArSceneErrorCallback onError,
  ) async {
    ARHitTestResult? planeResult;
    for (final hit in hitResults) {
      if (hit.type == ARHitTestResultType.plane) {
        planeResult = hit;
        break;
      }
    }
    if (planeResult == null) {
      onError('No horizontal surface detected. Move device and tap again.');
      return;
    }
    await onPlaneTapped(planeResult.worldTransform);
  }

  NodeType _toNodeType(ArRenderableType type) {
    return switch (type) {
      ArRenderableType.fileSystemGlb => NodeType.fileSystemAppFolderGLB,
      ArRenderableType.fileSystemGltf => NodeType.fileSystemAppFolderGLTF2,
    };
  }
}
