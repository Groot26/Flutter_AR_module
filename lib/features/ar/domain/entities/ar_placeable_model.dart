import 'ar_model_source.dart';

class ArPlaceableModel {
  const ArPlaceableModel({
    required this.id,
    required this.displayName,
    required this.source,
    this.initialScale = 0.22,
  });

  final String id;
  final String displayName;
  final ArModelSource source;
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
        other.source.type == source.type &&
        other.source.uri == source.uri &&
        other.source.cacheKey == source.cacheKey;
  }

  @override
  int get hashCode => Object.hash(
    id,
    displayName,
    initialScale,
    source.type,
    source.uri,
    source.cacheKey,
  );
}
