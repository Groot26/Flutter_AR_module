import 'package:flutter/material.dart';

import '../state/ar_view_state.dart';

class ArModelControlsOverlay extends StatelessWidget {
  const ArModelControlsOverlay({
    super.key,
    required this.state,
    required this.onToggleAnimation,
    required this.onZoomIn,
    required this.onZoomOut,
    required this.onRotateLeft,
    required this.onRotateRight,
    required this.onNudgeLeft,
    required this.onNudgeRight,
    required this.onNudgeForward,
    required this.onNudgeBack,
    required this.onResetTransform,
  });

  final ArViewState state;
  final VoidCallback onToggleAnimation;
  final VoidCallback onZoomIn;
  final VoidCallback onZoomOut;
  final VoidCallback onRotateLeft;
  final VoidCallback onRotateRight;
  final VoidCallback onNudgeLeft;
  final VoidCallback onNudgeRight;
  final VoidCallback onNudgeForward;
  final VoidCallback onNudgeBack;
  final VoidCallback onResetTransform;

  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: 12,
      right: 12,
      bottom: 12,
      child: SafeArea(
        top: false,
        child: Center(
          child: DecoratedBox(
            decoration: BoxDecoration(
              color: Colors.black.withValues(alpha: 0.52),
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: Colors.white24),
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    alignment: WrapAlignment.center,
                    children: [
                      _ActionButton(
                        icon: state.isAnimationPlaying
                            ? Icons.pause_circle_outline
                            : Icons.play_circle_outline,
                        label: 'Anim',
                        onPressed: onToggleAnimation,
                      ),
                      _ActionButton(
                        icon: Icons.rotate_left,
                        label: 'Rot -',
                        onPressed: onRotateLeft,
                      ),
                      _ActionButton(
                        icon: Icons.rotate_right,
                        label: 'Rot +',
                        onPressed: onRotateRight,
                      ),
                      _ActionButton(
                        icon: Icons.zoom_in,
                        label: 'Zoom +',
                        onPressed: onZoomIn,
                      ),
                      _ActionButton(
                        icon: Icons.zoom_out,
                        label: 'Zoom -',
                        onPressed: onZoomOut,
                      ),
                      _ActionButton(
                        icon: Icons.center_focus_strong,
                        label: 'Reset',
                        onPressed: onResetTransform,
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      _MiniMoveButton(
                        icon: Icons.keyboard_arrow_left,
                        onPressed: onNudgeLeft,
                      ),
                      Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          _MiniMoveButton(
                            icon: Icons.keyboard_arrow_up,
                            onPressed: onNudgeForward,
                          ),
                          const SizedBox(height: 4),
                          _MiniMoveButton(
                            icon: Icons.keyboard_arrow_down,
                            onPressed: onNudgeBack,
                          ),
                        ],
                      ),
                      _MiniMoveButton(
                        icon: Icons.keyboard_arrow_right,
                        onPressed: onNudgeRight,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  const _ActionButton({
    required this.icon,
    required this.label,
    required this.onPressed,
  });

  final IconData icon;
  final String label;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return TextButton.icon(
      onPressed: onPressed,
      style: TextButton.styleFrom(
        foregroundColor: Colors.white,
        backgroundColor: Colors.white.withValues(alpha: 0.08),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      ),
      icon: Icon(icon, size: 20),
      label: Text(label),
    );
  }
}

class _MiniMoveButton extends StatelessWidget {
  const _MiniMoveButton({
    required this.icon,
    required this.onPressed,
  });

  final IconData icon;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: IconButton.filledTonal(
        onPressed: onPressed,
        icon: Icon(icon),
      ),
    );
  }
}
