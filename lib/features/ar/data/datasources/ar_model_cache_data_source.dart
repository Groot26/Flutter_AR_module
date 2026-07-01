import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';

import '../../domain/entities/ar_model_source.dart';

class CachedModelFile {
  const CachedModelFile({required this.fileName, required this.extension});

  final String fileName;
  final String extension;
}

class ArModelCacheDataSource {
  const ArModelCacheDataSource();

  Future<CachedModelFile> ensureLocalModel(ArModelSource source) async {
    final extension = _extractExtension(source.uri);
    if (!_isSupportedExtension(extension)) {
      throw Exception('Unsupported model extension "$extension".');
    }

    final fileName = _buildCacheFileName(source: source, extension: extension);

    final appDirectory = await getApplicationDocumentsDirectory();
    final modelsDirectory = Directory(
      '${appDirectory.path}${Platform.pathSeparator}ar_models',
    );
    if (!await modelsDirectory.exists()) {
      await modelsDirectory.create(recursive: true);
    }

    final cachedFile = File(
      '${modelsDirectory.path}${Platform.pathSeparator}$fileName',
    );
    if (await cachedFile.exists()) {
      return CachedModelFile(fileName: fileName, extension: extension);
    }

    switch (source.type) {
      case ArModelSourceType.asset:
        await _writeAssetToFile(source.uri, cachedFile);
        break;
      case ArModelSourceType.remote:
        await _downloadRemoteFile(source.uri, cachedFile);
        break;
    }

    return CachedModelFile(fileName: fileName, extension: extension);
  }

  Future<void> _writeAssetToFile(String assetPath, File outputFile) async {
    try {
      final byteData = await rootBundle.load(assetPath);
      final bytes = byteData.buffer.asUint8List(
        byteData.offsetInBytes,
        byteData.lengthInBytes,
      );
      await outputFile.writeAsBytes(bytes, flush: true);
    } on FlutterError catch (error) {
      throw Exception('Failed to load local model asset "$assetPath": $error');
    }
  }

  Future<void> _downloadRemoteFile(String remoteUrl, File outputFile) async {
    final uri = Uri.parse(remoteUrl);
    final httpClient = HttpClient();
    try {
      final request = await httpClient.getUrl(uri);
      final response = await request.close();
      if (response.statusCode != HttpStatus.ok) {
        throw Exception(
          'Failed to download model ($remoteUrl), status ${response.statusCode}.',
        );
      }
      final bytes = await consolidateHttpClientResponseBytes(response);
      await outputFile.writeAsBytes(bytes, flush: true);
    } finally {
      httpClient.close(force: true);
    }
  }

  String _extractExtension(String uri) {
    final path = Uri.parse(uri).path.toLowerCase();
    if (path.endsWith('.glb')) {
      return 'glb';
    }
    if (path.endsWith('.gltf')) {
      return 'gltf';
    }
    throw Exception('Only .glb and .gltf models are supported.');
  }

  String _buildCacheFileName({
    required ArModelSource source,
    required String extension,
  }) {
    final rawBaseName = source.cacheKey ?? source.uri;
    final normalized =
        rawBaseName
            .replaceAll(RegExp(r'[^a-zA-Z0-9]+'), '_')
            .replaceAll(RegExp(r'_+'), '_')
            .replaceAll(RegExp(r'^_|_$'), '')
            .toLowerCase();
    final safeBaseName = normalized.isEmpty ? 'ar_model' : normalized;
    return '$safeBaseName.$extension';
  }

  bool _isSupportedExtension(String extension) =>
      extension == 'glb' || extension == 'gltf';
}
