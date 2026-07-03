import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vector_math/vector_math_64.dart';

import '../../application/services/ar_scene_service.dart';
import '../../domain/entities/ar_placeable_model.dart';
import '../../domain/entities/prepared_ar_model.dart';
import '../../domain/repositories/ar_model_repository.dart';
import '../state/ar_view_state.dart';

class ArViewController extends StateNotifier<ArViewState> {
  ArViewController({
    required ArPlaceableModel model,
    required ArModelRepository modelRepository,
    required ArSceneService sceneService,
  }) : _model = model,
       _modelRepository = modelRepository,
       _sceneService = sceneService,
       super(ArViewState.initial());

  final ArPlaceableModel _model;
  final ArModelRepository _modelRepository;
  final ArSceneService _sceneService;

  PreparedArModel? _preparedModel;
  bool _hasSceneInitialization = false;
  bool _isPreparingModel = false;

  Future<void> prepareModel() async {
    if (_isPreparingModel || _preparedModel != null) {
      return;
    }

    _isPreparingModel = true;
    state = state.copyWith(
      isLoading: true,
      statusMessage: 'Preparing ${_model.displayName} model...',
      clearError: true,
    );

    try {
      _preparedModel = await _modelRepository.prepareModel(_model);
      state = state.copyWith(
        modelPrepared: true,
        isLoading: false,
        statusMessage:
            state.sessionReady
                ? 'Move device to detect a horizontal plane, then tap to place.'
                : 'Waiting for AR camera initialization...',
        clearError: true,
      );
    } catch (error) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: error.toString(),
        statusMessage: 'Failed to prepare model.',
      );
    } finally {
      _isPreparingModel = false;
    }
  }

  Future<void> onArViewCreated({
    required Object sessionManager,
    required Object objectManager,
    required Object anchorManager,
  }) async {
    try {
      await _sceneService.bind(
        ArViewHandles(
          sessionManager: sessionManager,
          objectManager: objectManager,
          anchorManager: anchorManager,
        ),
      );

      await _sceneService.initialize(
        onError: (message) {
          state = state.copyWith(
            errorMessage: message,
            statusMessage: 'AR session reported an issue.',
          );
        },
        onPlaneTapped: _onPlaneTapped,
      );

      _hasSceneInitialization = true;
      state = state.copyWith(
        sessionReady: true,
        statusMessage:
            state.modelPrepared
                ? 'Move device to detect a horizontal plane, then tap to place.'
                : 'Preparing model...',
        clearError: true,
      );
    } catch (error) {
      state = state.copyWith(
        sessionReady: false,
        errorMessage: error.toString(),
        statusMessage: 'AR session initialization failed.',
      );
    }
  }

  Future<void> clearPlacedModel() async {
    await _sceneService.clearPlacedModel();
    state = state.copyWith(
      isPlaced: false,
      isAnimationPlaying: false,
      statusMessage: 'Model cleared. Tap on a horizontal plane to place again.',
      clearError: true,
    );
  }

  Future<void> onPause() async {
    debugPrint(
      '================================== Pause =====================',
    );
    await _sceneService.pause();
    _hasSceneInitialization = false;
    state = state.copyWith(
      isPaused: true,
      sessionReady: false,
      statusMessage: 'AR session paused.',
    );
  }

  Future<void> onResume() async {
    debugPrint(
      '================================== Resume =====================',
    );

    await _sceneService.resume();
    _hasSceneInitialization = false;
    state = state.copyWith(
      isPaused: false,
      sessionReady: false,
      isPlaced: false,
      isAnimationPlaying: false,
      surfaceDetected: false,
      sceneRevision: state.sceneRevision + 1,
      statusMessage: 'Reinitializing AR session...',
      clearError: true,
    );
  }

  Future<void> onScaleGesture(double scaleFactorDelta) async {
    if (!state.isPlaced || !state.sessionReady || scaleFactorDelta.isNaN) {
      return;
    }
    final safeDelta = scaleFactorDelta.clamp(0.7, 1.35).toDouble();
    await _sceneService.scaleCurrentModel(safeDelta);
  }

  Future<void> zoomIn() async {
    debugPrint(
      '================================== ZoomIn =====================',
    );
    if (!state.isPlaced) return;
    await _sceneService.scaleCurrentModel(1.12);
  }

  Future<void> zoomOut() async {
    debugPrint(
      '================================== ZoomOut =====================',
    );
    if (!state.isPlaced) return;
    await _sceneService.scaleCurrentModel(0.89);
  }

  Future<void> rotateLeft() async {
    if (!state.isPlaced) return;
    await _sceneService.rotateCurrentModel(-0.16);
  }

  Future<void> rotateRight() async {
    if (!state.isPlaced) return;
    await _sceneService.rotateCurrentModel(0.16);
  }

  Future<void> nudgeLeft() async {
    if (!state.isPlaced) return;
    await _sceneService.moveCurrentModel(Vector3(-0.02, 0.0, 0.0));
  }

  Future<void> nudgeRight() async {
    if (!state.isPlaced) return;
    await _sceneService.moveCurrentModel(Vector3(0.02, 0.0, 0.0));
  }

  Future<void> nudgeForward() async {
    if (!state.isPlaced) return;
    await _sceneService.moveCurrentModel(Vector3(0.0, 0.0, -0.02));
  }

  Future<void> nudgeBack() async {
    if (!state.isPlaced) return;
    await _sceneService.moveCurrentModel(Vector3(0.0, 0.0, 0.02));
  }

  Future<void> resetTransform() async {
    if (!state.isPlaced) return;
    await _sceneService.resetCurrentModelTransform();
    state = state.copyWith(
      statusMessage: 'Model transform reset.',
      clearError: true,
    );
  }

  Future<void> toggleAnimation() async {
    if (!state.isPlaced) return;
    final nextPlaying = !state.isAnimationPlaying;
    final didUpdate = await _sceneService.setCurrentModelAnimationPlaying(
      nextPlaying,
    );
    if (didUpdate) {
      state = state.copyWith(
        isAnimationPlaying: nextPlaying,
        statusMessage: nextPlaying ? 'Animation playing.' : 'Animation paused.',
        clearError: true,
      );
    }
  }

  Future<void> _onPlaneTapped(Matrix4 worldTransform) async {
    debugPrint(
      '================================== On Tap =====================',
    );
    if (state.isBusy || !_hasSceneInitialization) {
      return;
    }
    if (state.isPlaced) {
      return;
    }

    final preparedModel = _preparedModel;
    if (preparedModel == null) {
      state = state.copyWith(
        errorMessage: 'Model is not ready yet.',
        statusMessage: 'Preparing model...',
      );
      return;
    }

    state = state.copyWith(
      surfaceDetected: true,
      isPlacing: true,
      statusMessage: 'Placing ${_model.displayName}...',
      clearError: true,
    );

    try {
      final didPlaceModel = await _sceneService.placeModelOnPlane(
        model: preparedModel,
        planeWorldTransform: worldTransform,
      );
      if (!didPlaceModel) {
        state = state.copyWith(
          isPlacing: false,
          isPlaced: false,
          isAnimationPlaying: false,
          errorMessage: 'Unable to place model on this surface.',
          statusMessage: 'Try another horizontal surface.',
        );
        return;
      }

      state = state.copyWith(
        isPlacing: false,
        isPlaced: true,
        isAnimationPlaying: true,
        statusMessage:
            'Model placed. Use drag to reposition, rotate gesture to rotate, pinch to scale, or the toolbar for more controls.',
        clearError: true,
      );
    } catch (error) {
      state = state.copyWith(
        isPlacing: false,
        isPlaced: false,
        isAnimationPlaying: false,
        errorMessage: error.toString(),
        statusMessage: 'Model placement failed.',
      );
    }
  }

  @override
  void dispose() {
    _sceneService.dispose();
    super.dispose();
  }
}
