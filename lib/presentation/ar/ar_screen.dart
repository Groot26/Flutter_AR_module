import 'package:ar_demo/domain/models/animal_model.dart';
import 'package:flutter/material.dart';
import 'package:model_viewer_plus/model_viewer_plus.dart';

class ARScreen extends StatelessWidget {
  final AnimalModel animal;

  const ARScreen({super.key, required this.animal});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(animal.name)),
      body: _ARView(animal: animal),
    );
  }
}

class _ARView extends StatelessWidget {
  final AnimalModel animal;

  const _ARView({super.key, required this.animal});

  @override
  Widget build(BuildContext context) {
    // return ModelViewer(
    //   backgroundColor: const Color(0xFFEEEEEE),
    //   // src: 'https://modelviewer.dev/shared-assets/models/Astronaut.usdz',
    //   src: animal.modelPath,
    //   alt: animal.name,
    //   ar: true,
    //   arModes: const ['scene-viewer', 'quick-look', 'webxr'],
    //   autoRotate: true,
    //   cameraControls: true,
    //   disableZoom: false,
    //   // iosSrc: 'https://modelviewer.dev/shared-assets/models/Astronaut.usdz',
    //   iosSrc: animal.modelPath,
    //   autoPlay: true,
    //   arPlacement: ArPlacement.floor,
    //   arScale: ArScale.fixed,
    //   disablePan: false,
    //   disableTap: false,
    // );

    return ModelViewer(
      src: animal.modelPath,
      alt: animal.name,

      // ---------- AR ----------
      ar: true,
      arModes: const ['scene-viewer', 'quick-look'],
      arPlacement: ArPlacement.floor,
      arScale: ArScale.auto,

      // ---------- Preview ----------
      cameraControls: true,
      autoRotate: true,
      autoRotateDelay: 500,
      rotationPerSecond: "20deg",

      // Better initial view
      cameraOrbit: "0deg 75deg 105%",
      fieldOfView: "30deg",

      // Limit zoom
      minCameraOrbit: "auto auto 80%",
      maxCameraOrbit: "auto auto 250%",

      // Smooth movement
      interpolationDecay: 150,

      // Better lighting
      environmentImage: "neutral",
      exposure: 1.2,
      shadowIntensity: 1.0,
      shadowSoftness: 0.8,

      // Animation
      autoPlay: true,

      // Better UX
      interactionPrompt: InteractionPrompt.auto,
      interactionPromptStyle: InteractionPromptStyle.wiggle,
      interactionPromptThreshold: 1500,

      backgroundColor: Colors.white,
    );
  }
}
