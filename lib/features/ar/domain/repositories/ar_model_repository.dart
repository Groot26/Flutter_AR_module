import '../entities/ar_placeable_model.dart';
import '../entities/prepared_ar_model.dart';

abstract class ArModelRepository {
  Future<PreparedArModel> prepareModel(ArPlaceableModel model);
}
