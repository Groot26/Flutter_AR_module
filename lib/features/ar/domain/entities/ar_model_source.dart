enum ArModelSourceType { asset, remote }

class ArModelSource {
  const ArModelSource({required this.type, required this.uri, this.cacheKey});

  final ArModelSourceType type;
  final String uri;
  final String? cacheKey;
}
