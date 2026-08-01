import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../services/gemma_service.dart';

/// 🤖 AI State — Tracks Gemma / LiteRT initialization progress.
///
/// Drives the splash screen loader and the inference panel inside the
/// triage capture sheet.
enum AiPhase { idle, loading, ready, error }

class AiState {
  const AiState({
    required this.phase,
    required this.progress,
    required this.message,
  });

  final AiPhase phase;
  final double progress;
  final String message;

  static const AiState initial = AiState(
    phase: AiPhase.idle,
    progress: 0,
    message: 'Initializing MedGemma engine...',
  );

  AiState copyWith({
    AiPhase? phase,
    double? progress,
    String? message,
  }) {
    return AiState(
      phase: phase ?? this.phase,
      progress: progress ?? this.progress,
      message: message ?? this.message,
    );
  }
}

class AiStateNotifier extends StateNotifier<AiState> {
  AiStateNotifier(this._service) : super(AiState.initial);

  final GemmaService _service;

  Future<void> initialize() async {
    state = state.copyWith(
      phase: AiPhase.loading,
      progress: 0.1,
      message: 'Loading MedGemma Engine...',
    );
    try {
      await _service.initialize(
        onProgress: (double p, String message) {
          state = state.copyWith(
            progress: p,
            message: message,
          );
        },
      );
      state = state.copyWith(
        phase: AiPhase.ready,
        progress: 1.0,
        message: 'Engine ready — running on-device.',
      );
    } catch (e) {
      state = state.copyWith(
        phase: AiPhase.error,
        progress: state.progress,
        message: 'Engine failed to load: $e',
      );
    }
  }
}

final StateNotifierProvider<AiStateNotifier, AiState> aiStateProvider =
    StateNotifierProvider<AiStateNotifier, AiState>((ref) {
  final GemmaService service = ref.watch(gemmaServiceProvider);
  return AiStateNotifier(service);
});