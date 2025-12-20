import 'package:flutter_riverpod/flutter_riverpod.dart';

enum DocumentType {
  identityCard,
  passport,
  selfie,
  drivingLicense,
  vehicleRegistration,
  insurance,
  medicalCertificate,
  backgroundCheck,
  contract,
  other,
}

enum DocumentStatus { pending, approved, rejected, expired }

class DriverDocument {
  final String id;
  final DocumentType type;
  final String name;
  final DocumentStatus status;
  final String? fileUrl;
  final DateTime? uploadDate;
  final DateTime? expiryDate;
  final String? rejectionReason;
  final double uploadProgress;

  DriverDocument({
    required this.id,
    required this.type,
    required this.name,
    this.status = DocumentStatus.pending,
    this.fileUrl,
    this.uploadDate,
    this.expiryDate,
    this.rejectionReason,
    this.uploadProgress = 0.0,
  });

  bool get isExpired => expiryDate != null && DateTime.now().isAfter(expiryDate!);
  bool get isRequired => [
    DocumentType.identityCard,
    DocumentType.drivingLicense,
    DocumentType.vehicleRegistration,
    DocumentType.insurance,
  ].contains(type);
}

class DriverDocumentsState {
  final List<DriverDocument> documents;
  final double overallProgress;
  final bool isVerified;
  final bool isLoading;
  final String? error;

  DriverDocumentsState({
    this.documents = const [],
    this.overallProgress = 0.0,
    this.isVerified = false,
    this.isLoading = false,
    this.error,
  });

  DriverDocumentsState copyWith({
    List<DriverDocument>? documents,
    double? overallProgress,
    bool? isVerified,
    bool? isLoading,
    String? error,
  }) {
    return DriverDocumentsState(
      documents: documents ?? this.documents,
      overallProgress: overallProgress ?? this.overallProgress,
      isVerified: isVerified ?? this.isVerified,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
    );
  }
}

class DriverDocumentsNotifier extends Notifier<DriverDocumentsState> {
  @override
  DriverDocumentsState build() {
    _loadDocuments();
    return DriverDocumentsState();
  }

  Future<void> _loadDocuments() async {
    state = state.copyWith(isLoading: true);
    await Future.delayed(const Duration(seconds: 1));

    final documents = [
      DriverDocument(
        id: '1',
        type: DocumentType.identityCard,
        name: 'Carte d\'identité',
        status: DocumentStatus.approved,
        uploadDate: DateTime.now().subtract(const Duration(days: 10)),
        expiryDate: DateTime.now().add(const Duration(days: 1825)),
      ),
      DriverDocument(
        id: '2',
        type: DocumentType.selfie,
        name: 'Photo selfie',
        status: DocumentStatus.approved,
        uploadDate: DateTime.now().subtract(const Duration(days: 10)),
      ),
      DriverDocument(
        id: '3',
        type: DocumentType.drivingLicense,
        name: 'Permis de conduire',
        status: DocumentStatus.approved,
        uploadDate: DateTime.now().subtract(const Duration(days: 8)),
        expiryDate: DateTime.now().add(const Duration(days: 730)),
      ),
      DriverDocument(
        id: '4',
        type: DocumentType.vehicleRegistration,
        name: 'Carte grise',
        status: DocumentStatus.pending,
        uploadDate: DateTime.now().subtract(const Duration(days: 2)),
      ),
      DriverDocument(
        id: '5',
        type: DocumentType.insurance,
        name: 'Assurance véhicule',
        status: DocumentStatus.pending,
        uploadDate: DateTime.now().subtract(const Duration(days: 1)),
        expiryDate: DateTime.now().add(const Duration(days: 60)),
      ),
      DriverDocument(
        id: '6',
        type: DocumentType.medicalCertificate,
        name: 'Certificat médical',
        status: DocumentStatus.rejected,
        uploadDate: DateTime.now().subtract(const Duration(days: 5)),
        rejectionReason: 'Document expiré. Veuillez fournir un certificat récent.',
      ),
    ];

    final approvedCount = documents.where((d) => d.status == DocumentStatus.approved).length;
    final requiredCount = documents.where((d) => d.isRequired).length;
    final progress = requiredCount > 0 ? (approvedCount / requiredCount) * 100 : 0.0;
    final verified = progress == 100 && documents.every((d) => !d.isExpired);

    state = state.copyWith(
      documents: documents,
      overallProgress: progress,
      isVerified: verified,
      isLoading: false,
    );
  }

  Future<bool> uploadDocument(DocumentType type, String filePath) async {
    state = state.copyWith(isLoading: true);

    // Simuler l'upload avec progression
    for (int i = 0; i <= 100; i += 20) {
      await Future.delayed(const Duration(milliseconds: 200));
      final documents = state.documents.map((doc) {
        if (doc.type == type) {
          return DriverDocument(
            id: doc.id,
            type: doc.type,
            name: doc.name,
            status: doc.status,
            fileUrl: filePath,
            uploadDate: DateTime.now(),
            uploadProgress: i.toDouble(),
          );
        }
        return doc;
      }).toList();

      state = state.copyWith(documents: documents);
    }

    // Après upload, statut passe en attente
    final documents = state.documents.map((doc) {
      if (doc.type == type) {
        return DriverDocument(
          id: doc.id,
          type: doc.type,
          name: doc.name,
          status: DocumentStatus.pending,
          fileUrl: filePath,
          uploadDate: DateTime.now(),
          uploadProgress: 100.0,
        );
      }
      return doc;
    }).toList();

    state = state.copyWith(
      documents: documents,
      isLoading: false,
    );

    return true;
  }

  Future<bool> deleteDocument(String documentId) async {
    state = state.copyWith(isLoading: true);
    await Future.delayed(const Duration(milliseconds: 300));

    state = state.copyWith(
      documents: state.documents.where((d) => d.id != documentId).toList(),
      isLoading: false,
    );

    return true;
  }
}

final driverDocumentsProvider = NotifierProvider<DriverDocumentsNotifier, DriverDocumentsState>(
  DriverDocumentsNotifier.new,
);

