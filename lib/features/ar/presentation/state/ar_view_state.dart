class ArViewState {
  const ArViewState({
    required this.sessionReady,
    required this.modelPrepared,
    required this.surfaceDetected,
    required this.isLoading,
    required this.isPlacing,
    required this.isPlaced,
    required this.isAnimationPlaying,
    required this.isPaused,
    required this.sceneRevision,
    this.statusMessage,
    this.errorMessage,
  });

  factory ArViewState.initial() {
    return const ArViewState(
      sessionReady: false,
      modelPrepared: false,
      surfaceDetected: false,
      isLoading: false,
      isPlacing: false,
      isPlaced: false,
      isAnimationPlaying: false,
      isPaused: false,
      sceneRevision: 0,
      statusMessage: 'Initializing AR module...',
    );
  }

  final bool sessionReady;
  final bool modelPrepared;
  final bool surfaceDetected;
  final bool isLoading;
  final bool isPlacing;
  final bool isPlaced;
  final bool isAnimationPlaying;
  final bool isPaused;
  final int sceneRevision;
  final String? statusMessage;
  final String? errorMessage;

  bool get isBusy => isLoading || isPlacing;

  ArViewState copyWith({
    bool? sessionReady,
    bool? modelPrepared,
    bool? surfaceDetected,
    bool? isLoading,
    bool? isPlacing,
    bool? isPlaced,
    bool? isAnimationPlaying,
    bool? isPaused,
    int? sceneRevision,
    String? statusMessage,
    String? errorMessage,
    bool clearError = false,
  }) {
    return ArViewState(
      sessionReady: sessionReady ?? this.sessionReady,
      modelPrepared: modelPrepared ?? this.modelPrepared,
      surfaceDetected: surfaceDetected ?? this.surfaceDetected,
      isLoading: isLoading ?? this.isLoading,
      isPlacing: isPlacing ?? this.isPlacing,
      isPlaced: isPlaced ?? this.isPlaced,
      isAnimationPlaying: isAnimationPlaying ?? this.isAnimationPlaying,
      isPaused: isPaused ?? this.isPaused,
      sceneRevision: sceneRevision ?? this.sceneRevision,
      statusMessage: statusMessage ?? this.statusMessage,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
    );
  }
}
