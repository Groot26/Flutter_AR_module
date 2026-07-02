import 'package:vector_math/vector_math_64.dart';

import 'ar_model_source.dart';

class ArPlaceableModel {
  ArPlaceableModel({
    required this.id,
    required this.displayName,
    required this.source,
    Vector3? initialPositionOffset,
    Vector4? initialRotation,
    double? initialScale,
  })  : initialPositionOffset = initialPositionOffset ?? Vector3.zero(),
        initialRotation =
            initialRotation ?? Vector4(1.0, 0.0, 0.0, 0.0),
        initialScale = initialScale ?? 0.22;

  final String id;
  final String displayName;
  final ArModelSource source;
  final Vector3 initialPositionOffset;
  final Vector4 initialRotation;
  final double initialScale;

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }

    return other is ArPlaceableModel &&
        other.id == id &&
        other.displayName == displayName &&
        other.initialScale == initialScale &&
        other.initialPositionOffset == initialPositionOffset &&
        other.initialRotation == initialRotation &&
        other.source.type == source.type &&
        other.source.uri == source.uri &&
        other.source.cacheKey == source.cacheKey;
  }

  @override
  int get hashCode => Object.hash(
    id,
    displayName,
    initialScale,
    initialPositionOffset,
    initialRotation,
    source.type,
    source.uri,
    source.cacheKey,
  );
}
