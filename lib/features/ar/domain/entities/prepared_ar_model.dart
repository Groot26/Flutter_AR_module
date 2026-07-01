enum ArRenderableType { fileSystemGlb, fileSystemGltf }

class PreparedArModel {
  const PreparedArModel({
    required this.nodeUri,
    required this.renderableType,
    required this.initialScale,
  });

  final String nodeUri;
  final ArRenderableType renderableType;
  final double initialScale;
}
