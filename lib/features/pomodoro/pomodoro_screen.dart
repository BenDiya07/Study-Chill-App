import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../core/constants/app_constants.dart';
import '../core/theme/app_theme.dart';
import '../core/utils/time_formatter.dart';
import 'pomodoro_state.dart';

class PomodoroScreen extends HookConsumerWidget {
  const PomodoroScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(pomodoroProvider);
    final notifier = ref.read(pomodoroProvider.notifier);
    final theme = Theme.of(context);
    final custom = theme.extension<_CustomColorsLight>() ?? theme.extension<_CustomColorsDark>()!;
    
    final progressAnimation = useAnimationController(
      duration: const Duration(milliseconds: 500),
      initialValue: 1.0 - state.progress,
    );
    progressAnimation.animateTo(1.0 - state.progress);

    final color = switch (state.mode) {
      TimerMode.work => custom.timerWorkColor,
      TimerMode.shortBreak => custom.timerBreakColor,
      TimerMode.longBreak => custom.timerLongBreakColor,
    };

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              const SizedBox(height: 8),
              _ModeIndicator(mode: state.mode),
              const SizedBox(height: 32),
              Expanded(
                child: Center(
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      SizedBox(
                        width: 280,
                        height: 280,
                        child: AnimatedBuilder(
                          animation: progressAnimation,
                          builder: (_, __) => CustomPaint(
                            painter: _CircularProgressPainter(
                              progress: progressAnimation.value,
                              color: color,
                              strokeWidth: 12,
                            ),
                          ),
                        ),
                      ),
                      Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            state.formattedTime,
                            style: GoogleFonts.jetBrainsMono(
                              fontSize: 64,
                              fontWeight: FontWeight.w600,
                              color: theme.colorScheme.onSurface,
                            ),
                          ),
                          const SizedBox(height: 8),
                          if (state.activeTaskId != null)
                            _ActiveTaskChip(taskId: state.activeTaskId!),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 32),
              _TimerControls(
                isRunning: state.isRunning,
                onStart: notifier.start,
                onPause: notifier.pause,
                onReset: notifier.reset,
                onSkip: notifier.skip,
              ),
              const SizedBox(height: 16),
              _SessionCounter(count: state.completedSessions),
            ],
          ),
        ),
      ),
    );
  }
}

class _ModeIndicator extends StatelessWidget {
  final TimerMode mode;

  const _ModeIndicator({required this.mode});

  @override
  Widget build(BuildContext context) {
    final (label, icon) = switch (mode) {
      TimerMode.work => ('Concentration', Icons.center_focus_strong),
      TimerMode.shortBreak => ('Pause courte', Icons.coffee),
      TimerMode.longBreak => ('Pause longue', Icons.beach_access),
    };

    return Semantics(
      label: label,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 20, color: Theme.of(context).colorScheme.primary),
          const SizedBox(width: 8),
          Text(
            label,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Theme.of(context).colorScheme.primary,
            ),
          ),
        ],
      ),
    );
  }
}

class _ActiveTaskChip extends ConsumerWidget {
  final String taskId;

  const _ActiveTaskChip({required this.taskId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Semantics(
      label: 'Tâche active: $taskId',
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.primaryContainer,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.task_alt, size: 16, color: Theme.of(context).colorScheme.onPrimaryContainer),
            const SizedBox(width: 6),
            Text(
              taskId,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: Theme.of(context).colorScheme.onPrimaryContainer,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TimerControls extends StatelessWidget {
  final bool isRunning;
  final VoidCallback onStart;
  final VoidCallback onPause;
  final VoidCallback onReset;
  final VoidCallback onSkip;

  const _TimerControls({
    required this.isRunning,
    required this.onStart,
    required this.onPause,
    required this.onReset,
    required this.onSkip,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _ControlButton(
          icon: Icons.refresh,
          label: 'Reset',
          onPressed: onReset,
          semanticLabel: 'Réinitialiser le minuteur',
        ),
        const SizedBox(width: 16),
        _ControlButton(
          icon: isRunning ? Icons.pause : Icons.play_arrow,
          label: isRunning ? 'Pause' : 'Démarrer',
          onPressed: isRunning ? onPause : onStart,
          isPrimary: true,
          semanticLabel: isRunning ? 'Mettre en pause' : 'Démarrer le minuteur',
        ),
        const SizedBox(width: 16),
        _ControlButton(
          icon: Icons.skip_next,
          label: 'Passer',
          onPressed: onSkip,
          semanticLabel: 'Passer à la session suivante',
        ),
      ],
    );
  }
}

class _ControlButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onPressed;
  final bool isPrimary;
  final String semanticLabel;

  const _ControlButton({
    required this.icon,
    required this.label,
    required this.onPressed,
    this.isPrimary = false,
    required this.semanticLabel,
  });

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: semanticLabel,
      button: true,
      child: FilledButton.icon(
        onPressed: onPressed,
        icon: Icon(icon, size: 20),
        label: Text(label, style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w600)),
        style: FilledButton.styleFrom(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          backgroundColor: isPrimary ? null : Theme.of(context).colorScheme.surfaceContainerHighest,
          foregroundColor: isPrimary ? null : Theme.of(context).colorScheme.onSurfaceVariant,
        ),
      ),
    );
  }
}

class _SessionCounter extends StatelessWidget {
  final int count;

  const _SessionCounter({required this.count});

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: 'Sessions complétées: $count',
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: List.generate(
          4,
          (i) => Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: Icon(
              Icons.circle,
              size: 12,
              color: i < count
                  ? Theme.of(context).colorScheme.primary
                  : Theme.of(context).colorScheme.outline.withValues(alpha: 0.3),
            ),
          ),
        ),
      ),
    );
  }
}

class _CircularProgressPainter extends CustomPainter {
  final double progress;
  final Color color;
  final double strokeWidth;

  _CircularProgressPainter({
    required this.progress,
    required this.color,
    required this.strokeWidth,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width - strokeWidth) / 2;
    
    final bgPaint = Paint()
      ..color = color.withValues(alpha: 0.1)
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;
    
    final fgPaint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    canvas.drawCircle(center, radius, bgPaint);
    
    final sweepAngle = 2 * 3.14159 * progress;
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -3.14159 / 2,
      sweepAngle,
      false,
      fgPaint,
    );
  }

  @override
  bool shouldRepaint(covariant _CircularProgressPainter old) {
    return old.progress != progress || old.color != color || old.strokeWidth != strokeWidth;
  }
}