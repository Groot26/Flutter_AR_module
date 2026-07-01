import 'package:flutter/material.dart';

import '../state/ar_view_state.dart';

class ArStatusOverlay extends StatelessWidget {
  const ArStatusOverlay({super.key, required this.state});

  final ArViewState state;

  @override
  Widget build(BuildContext context) {
    final statusText = state.errorMessage ?? state.statusMessage;
    final statusBackgroundColor =
        state.errorMessage != null
            ? Colors.red.withValues(alpha: 0.86)
            : Colors.black.withValues(alpha: 0.58);

    return IgnorePointer(
      child: Stack(
        children: [
          Align(
            alignment: Alignment.center,
            child: _Reticle(isActive: state.surfaceDetected),
          ),
          if (statusText != null)
            Align(
              alignment: Alignment.topCenter,
              child: SafeArea(
                child: Container(
                  margin: const EdgeInsets.all(16),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 10,
                  ),
                  decoration: BoxDecoration(
                    color: statusBackgroundColor,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (state.isBusy) ...[
                        const SizedBox(
                          height: 16,
                          width: 16,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(width: 10),
                      ],
                      Flexible(
                        child: Text(
                          statusText,
                          style: const TextStyle(color: Colors.white),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _Reticle extends StatelessWidget {
  const _Reticle({required this.isActive});

  final bool isActive;

  @override
  Widget build(BuildContext context) {
    final color = isActive ? Colors.greenAccent : Colors.white70;
    return Container(
      height: 42,
      width: 42,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: color, width: 2),
      ),
      child: Center(
        child: Container(
          height: 6,
          width: 6,
          decoration: BoxDecoration(shape: BoxShape.circle, color: color),
        ),
      ),
    );
  }
}
