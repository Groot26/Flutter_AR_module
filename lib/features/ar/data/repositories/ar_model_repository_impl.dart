import '../../domain/entities/ar_placeable_model.dart';
import '../../domain/entities/prepared_ar_model.dart';
import '../../domain/repositories/ar_model_repository.dart';
import '../datasources/ar_model_cache_data_source.dart';

class ArModelRepositoryImpl implements ArModelRepository {
  ArModelRepositoryImpl(this._cacheDataSource);

  final ArModelCacheDataSource _cacheDataSource;

  @override
  Future<PreparedArModel> prepareModel(ArPlaceableModel model) async {
    final cached = await _cacheDataSource.ensureLocalModel(model.source);
    final renderableType = switch (cached.extension) {
      'glb' => ArRenderableType.fileSystemGlb,
      'gltf' => ArRenderableType.fileSystemGltf,
      _ =>
        throw Exception('Unsupported model extension "${cached.extension}".'),
    };

    return PreparedArModel(
      nodeUri: cached.relativeUri,
      renderableType: renderableType,
      initialPositionOffset: model.initialPositionOffset,
      initialRotation: model.initialRotation,
      initialScale: model.initialScale,
    );
  }
}
