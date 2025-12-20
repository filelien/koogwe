import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:koogwe/core/constants/app_colors.dart';
import 'package:koogwe/core/constants/app_spacing.dart';
import 'package:koogwe/core/providers/driver_documents_provider.dart';
import 'package:koogwe/core/widgets/koogwe_button.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';

class DriverDocumentsScreen extends ConsumerWidget {
  const DriverDocumentsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final state = ref.watch(driverDocumentsProvider);
    final notifier = ref.read(driverDocumentsProvider.notifier);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Mes Documents'),
        elevation: 0,
      ),
      body: state.isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(KoogweSpacing.xl),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Indicateur de progression
                  Container(
                    padding: const EdgeInsets.all(KoogweSpacing.xl),
                    decoration: BoxDecoration(
                      color: isDark ? KoogweColors.darkSurface : KoogweColors.lightSurface,
                      borderRadius: KoogweRadius.lgRadius,
                      border: Border.all(
                        color: isDark ? KoogweColors.darkBorder : KoogweColors.lightBorder,
                      ),
                    ),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Progression',
                              style: GoogleFonts.inter(
                                fontSize: 18,
                                fontWeight: FontWeight.w600,
                                color: isDark ? KoogweColors.darkTextPrimary : KoogweColors.lightTextPrimary,
                              ),
                            ),
                            if (state.isVerified)
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                decoration: BoxDecoration(
                                  color: KoogweColors.success.withValues(alpha: 0.2),
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Row(
                                  children: [
                                    Icon(Icons.verified, color: KoogweColors.success, size: 16),
                                    const SizedBox(width: 4),
                                    Text(
                                      'Vérifié',
                                      style: GoogleFonts.inter(
                                        fontSize: 12,
                                        color: KoogweColors.success,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                          ],
                        ),
                        const SizedBox(height: KoogweSpacing.lg),
                        LinearProgressIndicator(
                          value: state.overallProgress / 100,
                          backgroundColor: isDark ? KoogweColors.darkSurfaceVariant : KoogweColors.lightSurfaceVariant,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            state.overallProgress == 100
                                ? KoogweColors.success
                                : KoogweColors.primary,
                          ),
                          minHeight: 8,
                        ),
                        const SizedBox(height: KoogweSpacing.sm),
                        Text(
                          '${state.overallProgress.toStringAsFixed(0)}% complété',
                          style: GoogleFonts.inter(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: isDark ? KoogweColors.darkTextSecondary : KoogweColors.lightTextSecondary,
                          ),
                        ),
                      ],
                    ),
                  ).animate().fadeIn().scale(),
                  
                  const SizedBox(height: KoogweSpacing.xxxl),
                  
                  Text(
                    'Documents requis',
                    style: GoogleFonts.inter(
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      color: isDark ? KoogweColors.darkTextPrimary : KoogweColors.lightTextPrimary,
                    ),
                  ).animate().fadeIn(delay: 200.ms).slideX(begin: -0.2, end: 0),
                  const SizedBox(height: KoogweSpacing.lg),
                  
                  ...state.documents.map((doc) => _DocumentCard(
                    document: doc,
                    onUpload: () => _pickAndUploadDocument(context, ref, doc.type),
                    onDelete: () => notifier.deleteDocument(doc.id),
                  )),
                ],
              ),
            ),
    );
  }

  Future<void> _pickAndUploadDocument(
    BuildContext context,
    WidgetRef ref,
    DocumentType type,
  ) async {
    final picker = ImagePicker();
    final image = await picker.pickImage(source: ImageSource.gallery);
    
    if (image != null) {
      await ref.read(driverDocumentsProvider.notifier).uploadDocument(type, image.path);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Document uploadé avec succès')),
        );
      }
    }
  }
}

class _DocumentCard extends StatelessWidget {
  final DriverDocument document;
  final VoidCallback onUpload;
  final VoidCallback onDelete;

  const _DocumentCard({
    required this.document,
    required this.onUpload,
    required this.onDelete,
  });

  String _getDocumentIcon(DocumentType type) {
    switch (type) {
      case DocumentType.identityCard:
      case DocumentType.passport:
        return '🪪';
      case DocumentType.selfie:
        return '📸';
      case DocumentType.drivingLicense:
        return '🚗';
      case DocumentType.vehicleRegistration:
        return '📄';
      case DocumentType.insurance:
        return '🛡️';
      case DocumentType.medicalCertificate:
        return '🏥';
      case DocumentType.backgroundCheck:
        return '🔍';
      case DocumentType.contract:
        return '📝';
      default:
        return '📎';
    }
  }

  Color _getStatusColor(DocumentStatus status) {
    switch (status) {
      case DocumentStatus.approved:
        return KoogweColors.success;
      case DocumentStatus.rejected:
        return KoogweColors.error;
      case DocumentStatus.pending:
        return KoogweColors.accent;
      case DocumentStatus.expired:
        return KoogweColors.error;
    }
  }

  String _getStatusText(DocumentStatus status) {
    switch (status) {
      case DocumentStatus.approved:
        return 'Approuvé';
      case DocumentStatus.rejected:
        return 'Refusé';
      case DocumentStatus.pending:
        return 'En attente';
      case DocumentStatus.expired:
        return 'Expiré';
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final statusColor = _getStatusColor(document.status);

    return Container(
      margin: const EdgeInsets.only(bottom: KoogweSpacing.md),
      padding: const EdgeInsets.all(KoogweSpacing.lg),
      decoration: BoxDecoration(
        color: isDark ? KoogweColors.darkSurface : KoogweColors.lightSurface,
        borderRadius: KoogweRadius.lgRadius,
        border: Border.all(
          color: document.status == DocumentStatus.approved
              ? KoogweColors.success
              : (isDark ? KoogweColors.darkBorder : KoogweColors.lightBorder),
          width: document.status == DocumentStatus.approved ? 2 : 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                _getDocumentIcon(document.type),
                style: const TextStyle(fontSize: 32),
              ),
              const SizedBox(width: KoogweSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            document.name,
                            style: GoogleFonts.inter(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: isDark ? KoogweColors.darkTextPrimary : KoogweColors.lightTextPrimary,
                            ),
                          ),
                        ),
                        if (document.isRequired)
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: KoogweColors.error.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              'Requis',
                              style: GoogleFonts.inter(
                                fontSize: 10,
                                color: KoogweColors.error,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: statusColor.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        _getStatusText(document.status),
                        style: GoogleFonts.inter(
                          fontSize: 12,
                          color: statusColor,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          if (document.rejectionReason != null) ...[
            const SizedBox(height: KoogweSpacing.md),
            Container(
              padding: const EdgeInsets.all(KoogweSpacing.md),
              decoration: BoxDecoration(
                color: KoogweColors.error.withValues(alpha: 0.1),
                borderRadius: KoogweRadius.mdRadius,
              ),
              child: Row(
                children: [
                  Icon(Icons.info_outline, color: KoogweColors.error, size: 16),
                  const SizedBox(width: KoogweSpacing.sm),
                  Expanded(
                    child: Text(
                      document.rejectionReason!,
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        color: KoogweColors.error,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
          if (document.expiryDate != null) ...[
            const SizedBox(height: KoogweSpacing.sm),
            Text(
              document.isExpired
                  ? '⚠️ Expiré le ${document.expiryDate!.day}/${document.expiryDate!.month}/${document.expiryDate!.year}'
                  : 'Expire le ${document.expiryDate!.day}/${document.expiryDate!.month}/${document.expiryDate!.year}',
              style: GoogleFonts.inter(
                fontSize: 12,
                color: document.isExpired ? KoogweColors.error : (isDark ? KoogweColors.darkTextSecondary : KoogweColors.lightTextSecondary),
              ),
            ),
          ],
          const SizedBox(height: KoogweSpacing.md),
          if (document.fileUrl == null)
            KoogweButton(
              text: 'Télécharger le document',
              icon: Icons.upload_file,
              onPressed: onUpload,
              isFullWidth: true,
              size: ButtonSize.medium,
            )
          else
            Row(
              children: [
                Expanded(
                  child: KoogweButton(
                    text: 'Voir le document',
                    icon: Icons.visibility,
                    onPressed: () {
                      // TODO: Ouvrir le document
                    },
                    variant: ButtonVariant.outline,
                    size: ButtonSize.medium,
                  ),
                ),
                const SizedBox(width: KoogweSpacing.md),
                Expanded(
                  child: KoogweButton(
                    text: 'Remplacer',
                    icon: Icons.refresh,
                    onPressed: onUpload,
                    variant: ButtonVariant.outline,
                    size: ButtonSize.medium,
                  ),
                ),
              ],
            ),
          if (document.uploadProgress > 0 && document.uploadProgress < 100) ...[
            const SizedBox(height: KoogweSpacing.sm),
            LinearProgressIndicator(
              value: document.uploadProgress / 100,
              minHeight: 4,
            ),
          ],
        ],
      ),
    );
  }
}

