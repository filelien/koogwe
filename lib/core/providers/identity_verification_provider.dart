import 'package:flutter_riverpod/flutter_riverpod.dart';

enum VerificationStatus { notStarted, inProgress, pending, verified, rejected }
enum VerificationStep { identity, selfie, documents, background, completed }

class VerificationStepData {
  final VerificationStep step;
  final bool isCompleted;
  final String? documentUrl;
  final DateTime? completedAt;
  final String? rejectionReason;

  VerificationStepData({
    required this.step,
    this.isCompleted = false,
    this.documentUrl,
    this.completedAt,
    this.rejectionReason,
  });
}

class IdentityVerification {
  final String id;
  final VerificationStatus status;
  final List<VerificationStepData> steps;
  final double progress;
  final DateTime? verifiedAt;
  final String? badgeUrl;

  IdentityVerification({
    required this.id,
    this.status = VerificationStatus.notStarted,
    this.steps = const [],
    this.progress = 0.0,
    this.verifiedAt,
    this.badgeUrl,
  });

  bool get isVerified => status == VerificationStatus.verified;
  bool get hasBadge => isVerified && badgeUrl != null;
}

class IdentityVerificationState {
  final IdentityVerification? verification;
  final bool isLoading;
  final String? error;

  IdentityVerificationState({
    this.verification,
    this.isLoading = false,
    this.error,
  });

  IdentityVerificationState copyWith({
    IdentityVerification? verification,
    bool? isLoading,
    String? error,
  }) {
    return IdentityVerificationState(
      verification: verification ?? this.verification,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
    );
  }
}

class IdentityVerificationNotifier extends Notifier<IdentityVerificationState> {
  @override
  IdentityVerificationState build() {
    _loadVerification();
    return IdentityVerificationState();
  }

  Future<void> _loadVerification() async {
    state = state.copyWith(isLoading: true);
    await Future.delayed(const Duration(seconds: 1));

    final steps = [
      VerificationStepData(
        step: VerificationStep.identity,
        isCompleted: true,
        completedAt: DateTime.now().subtract(const Duration(days: 5)),
      ),
      VerificationStepData(
        step: VerificationStep.selfie,
        isCompleted: true,
        completedAt: DateTime.now().subtract(const Duration(days: 5)),
      ),
      VerificationStepData(
        step: VerificationStep.documents,
        isCompleted: true,
        completedAt: DateTime.now().subtract(const Duration(days: 4)),
      ),
      VerificationStepData(
        step: VerificationStep.background,
        isCompleted: false,
      ),
      VerificationStepData(
        step: VerificationStep.completed,
        isCompleted: false,
      ),
    ];

    final verification = IdentityVerification(
      id: '1',
      status: VerificationStatus.inProgress,
      steps: steps,
      progress: 60.0,
    );

    state = state.copyWith(
      verification: verification,
      isLoading: false,
    );
  }

  Future<bool> uploadDocument(VerificationStep step, String documentUrl) async {
    if (state.verification == null) return false;

    state = state.copyWith(isLoading: true);
    await Future.delayed(const Duration(seconds: 1));

    final steps = state.verification!.steps.map((s) {
      if (s.step == step) {
        return VerificationStepData(
          step: s.step,
          isCompleted: true,
          documentUrl: documentUrl,
          completedAt: DateTime.now(),
        );
      }
      return s;
    }).toList();

    final completedSteps = steps.where((s) => s.isCompleted).length;
    final progress = (completedSteps / steps.length) * 100;

    final verification = IdentityVerification(
      id: state.verification!.id,
      status: progress == 100
          ? VerificationStatus.pending
          : VerificationStatus.inProgress,
      steps: steps,
      progress: progress,
    );

    state = state.copyWith(
      verification: verification,
      isLoading: false,
    );

    return true;
  }

  Future<bool> completeVerification() async {
    if (state.verification == null) return false;

    state = state.copyWith(isLoading: true);
    await Future.delayed(const Duration(seconds: 2));

    final verification = IdentityVerification(
      id: state.verification!.id,
      status: VerificationStatus.verified,
      steps: state.verification!.steps,
      progress: 100.0,
      verifiedAt: DateTime.now(),
      badgeUrl: 'assets/badges/verified.png',
    );

    state = state.copyWith(
      verification: verification,
      isLoading: false,
    );

    return true;
  }
}

final identityVerificationProvider = NotifierProvider<IdentityVerificationNotifier, IdentityVerificationState>(
  IdentityVerificationNotifier.new,
);

