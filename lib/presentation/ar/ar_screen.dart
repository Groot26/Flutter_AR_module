import 'package:ar_demo/domain/models/animal_model.dart';
import 'package:ar_demo/features/ar/domain/entities/ar_model_source.dart';
import 'package:ar_demo/features/ar/domain/entities/ar_placeable_model.dart';
import 'package:ar_demo/features/ar/presentation/providers/ar_module_providers.dart';
import 'package:ar_demo/features/ar/presentation/widgets/ar_model_controls_overlay.dart';
import 'package:ar_demo/features/ar/presentation/widgets/ar_scene_view.dart';
import 'package:ar_demo/features/ar/presentation/widgets/ar_status_overlay.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vector_math/vector_math_64.dart';

class ARScreen extends ConsumerStatefulWidget {
  const ARScreen({super.key, required this.animal});

  final AnimalModel animal;

  @override
  ConsumerState<ARScreen> createState() => _ARScreenState();
}

class _ARScreenState extends ConsumerState<ARScreen>
    with WidgetsBindingObserver {
  late final ArPlaceableModel _placeableModel = _buildPlaceableModel(
    widget.animal,
  );

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    Future.microtask(
      () =>
          ref
              .read(arViewControllerProvider(_placeableModel).notifier)
              .prepareModel(),
    );
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    final controller = ref.read(
      arViewControllerProvider(_placeableModel).notifier,
    );
    switch (state) {
      case AppLifecycleState.paused:
      case AppLifecycleState.inactive:
        controller.onPause();
        break;
      case AppLifecycleState.resumed:
        controller.onResume();
        break;
      case AppLifecycleState.hidden:
      case AppLifecycleState.detached:
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    final viewState = ref.watch(arViewControllerProvider(_placeableModel));
    final controller = ref.read(
      arViewControllerProvider(_placeableModel).notifier,
    );

    return Scaffold(
      appBar: AppBar(title: Text(widget.animal.name)),
      body: Stack(
        fit: StackFit.expand,
        children: [
          ArSceneView(
            sceneRevision: viewState.sceneRevision,
            onManagersCreated: controller.onArViewCreated,
          ),
          ArStatusOverlay(state: viewState),
          if (viewState.isPlaced)
            ArModelControlsOverlay(
              state: viewState,
              onToggleAnimation: controller.toggleAnimation,
              onZoomIn: controller.zoomIn,
              onZoomOut: controller.zoomOut,
              onRotateLeft: controller.rotateLeft,
              onRotateRight: controller.rotateRight,
              onNudgeLeft: controller.nudgeLeft,
              onNudgeRight: controller.nudgeRight,
              onNudgeForward: controller.nudgeForward,
              onNudgeBack: controller.nudgeBack,
              onResetTransform: controller.resetTransform,
            ),
        ],
      ),
      floatingActionButton:
          viewState.isPlaced
              ? FloatingActionButton.small(
                onPressed: controller.clearPlacedModel,
                child: const Icon(Icons.delete_outline),
              )
              : null,
    );
  }

  ArPlaceableModel _buildPlaceableModel(AnimalModel animal) {
    final isRemote =
        animal.modelPath.startsWith('http://') ||
        animal.modelPath.startsWith('https://');
    final source = ArModelSource(
      type: isRemote ? ArModelSourceType.remote : ArModelSourceType.asset,
      uri: animal.modelPath,
      cacheKey: animal.name.toLowerCase().replaceAll(' ', '_'),
    );

    final metadata = _modelMetadata(animal.name);
    return ArPlaceableModel(
      id: animal.name.toLowerCase().replaceAll(' ', '_'),
      displayName: animal.name,
      source: source,
      initialScale: metadata.initialScale,
      initialRotation: metadata.initialRotation,
      initialPositionOffset: metadata.initialPositionOffset,
    );
  }

  _ArModelMetadata _modelMetadata(String name) {
    switch (name.toLowerCase()) {
      case 'cat':
        return _ArModelMetadata(
          initialScale: 0.12,
          initialRotation: Vector4(1.0, 0.0, 0.0, 1.57079632679),
        );
      case 'tiger':
        return _ArModelMetadata(
          initialScale: 0.10,
          initialRotation: Vector4(1.0, 0.0, 0.0, 1.57079632679),
        );
      case 'koi fish':
        return _ArModelMetadata(initialScale: 0.18);
      case 'ducky':
      case 'astronaut':
        return _ArModelMetadata(initialScale: 0.16);
      default:
        return _ArModelMetadata();
    }
  }
}

class _ArModelMetadata {
  _ArModelMetadata({
    double? initialScale,
    Vector4? initialRotation,
    Vector3? initialPositionOffset,
  })  : initialScale = initialScale ?? 0.22,
        initialRotation = initialRotation ?? Vector4(1.0, 0.0, 0.0, 0.0),
        initialPositionOffset = initialPositionOffset ?? Vector3.zero();

  final double initialScale;
  final Vector4 initialRotation;
  final Vector3 initialPositionOffset;
}
