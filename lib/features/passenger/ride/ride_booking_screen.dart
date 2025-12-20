import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:koogwe/core/constants/app_colors.dart';
import 'package:koogwe/core/constants/app_spacing.dart';
import 'package:koogwe/core/widgets/koogwe_button.dart';
import 'package:koogwe/core/widgets/koogwe_text_field.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:koogwe/core/providers/ride_provider.dart';
import 'package:koogwe/core/widgets/route_preview.dart';
import 'package:koogwe/core/widgets/floating_sheet.dart';

class RideBookingScreen extends ConsumerStatefulWidget {
  const RideBookingScreen({super.key});

  @override
  ConsumerState<RideBookingScreen> createState() => _RideBookingScreenState();
}

class _RideBookingScreenState extends ConsumerState<RideBookingScreen> {
  final _pickupController = TextEditingController();
  final _dropoffController = TextEditingController();
  bool _loading = true;

  @override
  void dispose() {
    _pickupController.dispose();
    _dropoffController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(milliseconds: 800), () {
      if (mounted) setState(() => _loading = false);
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Scaffold(
      body: Stack(
        children: [
          // Dominant map area
          const Positioned.fill(child: RoutePreview()),
          // Back button overlay
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(KoogweSpacing.lg),
                child: Align(
                  alignment: Alignment.topLeft,
                  child: Container(
                    decoration: BoxDecoration(
                      color: (isDark ? KoogweColors.darkSurface : KoogweColors.lightSurface).withValues(alpha: 0.9),
                      shape: BoxShape.circle,
                    ),
                    child: IconButton(
                      icon: const Icon(Icons.arrow_back),
                      onPressed: () {
                        if (context.canPop()) {
                          context.pop();
                        } else {
                          context.go('/passenger/home');
                        }
                      },
                    ),
                  ),
                ),
              ),
            ),
          ),
          DraggableScrollableSheet(
            initialChildSize: 0.4,
            minChildSize: 0.3,
            maxChildSize: 0.9,
            builder: (context, scrollController) {
              return FloatingSheet(
                scrollController: scrollController,
                child: ListView(
                  shrinkWrap: true,
                  controller: scrollController,
                  children: [
                    _loading
                        ? _skel(isDark)
                        : KoogweTextField(
                            controller: _pickupController,
                            hint: 'Lieu de prise en charge',
                            prefixIcon: Icon(Icons.my_location, color: KoogweColors.success),
                          ),
                    const SizedBox(height: KoogweSpacing.lg),
                    _loading
                        ? _skel(isDark)
                        : KoogweTextField(
                            controller: _dropoffController,
                            hint: 'Destination',
                            prefixIcon: Icon(Icons.location_on, color: KoogweColors.error),
                          ),
                    const SizedBox(height: KoogweSpacing.xxl),
                    KoogweButton(
                      text: 'Choisir un véhicule',
                      onPressed: () {
                        ref.read(rideProvider.notifier).setDraft(
                              pickup: _pickupController.text.trim(),
                              dropoff: _dropoffController.text.trim(),
                            );
                        context.push('/passenger/vehicle-selection');
                      },
                      isFullWidth: true,
                      size: ButtonSize.large,
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _skel(bool isDark) => Container(
        height: 56,
        decoration: BoxDecoration(
          color: isDark ? KoogweColors.darkSurfaceVariant : KoogweColors.lightSurfaceVariant,
          borderRadius: KoogweRadius.mdRadius,
        ),
      );
}
