import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../application/services/ar_scene_service.dart';
import '../../data/datasources/ar_model_cache_data_source.dart';
import '../../data/repositories/ar_model_repository_impl.dart';
import '../../domain/entities/ar_placeable_model.dart';
import '../../domain/repositories/ar_model_repository.dart';
import '../../infrastructure/services/ar_flutter_scene_service.dart';
import '../controllers/ar_view_controller.dart';
import '../state/ar_view_state.dart';

final arModelCacheDataSourceProvider = Provider<ArModelCacheDataSource>(
  (ref) => const ArModelCacheDataSource(),
);

final arModelRepositoryProvider = Provider<ArModelRepository>(
  (ref) => ArModelRepositoryImpl(ref.watch(arModelCacheDataSourceProvider)),
);

final arSceneServiceProvider = Provider.autoDispose<ArSceneService>(
  (ref) => ArFlutterSceneService(),
);

final arViewControllerProvider = StateNotifierProvider.autoDispose
    .family<ArViewController, ArViewState, ArPlaceableModel>(
      (ref, model) => ArViewController(
        model: model,
        modelRepository: ref.watch(arModelRepositoryProvider),
        sceneService: ref.watch(arSceneServiceProvider),
      ),
    );
