import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:koogwe/core/constants/app_colors.dart';
import 'package:koogwe/core/constants/app_spacing.dart';
import 'package:koogwe/core/providers/theme_provider.dart';
import 'package:koogwe/core/providers/locale_provider.dart';
import 'package:koogwe/core/providers/auth_provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:country_picker/country_picker.dart';
import 'package:currency_picker/currency_picker.dart';
import 'package:koogwe/core/widgets/koogwe_button.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:koogwe/core/constants/app_strings.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeState = ref.watch(themeProvider);
    final localeState = ref.watch(localeProvider);
    
    return Scaffold(
      appBar: AppBar(
        title: Text(AppStrings.settings),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(KoogweSpacing.lg),
        children: [
          SettingsSection(
            title: 'appearance'.tr(),
            children: [
              ListTile(
                leading: const Icon(Icons.palette),
                title: const Text('Thèmes & Apparence'),
                subtitle: Text(themeState.currentTheme.name),
                trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                onTap: () => context.push('/settings/themes'),
              ),
            ],
          ),
          const SizedBox(height: KoogweSpacing.lg),
          SettingsSection(
            title: 'language_region'.tr(),
            children: [
              ListTile(
                leading: const Icon(Icons.flag),
                title: Text('country'.tr()),
                subtitle: Text(localeState.countryCode),
                onTap: () => _showCountryPicker(context, ref),
              ),
              ListTile(
                leading: const Icon(Icons.language),
                title: Text('language'.tr()),
                subtitle: Text(_languageName(localeState.locale)),
                onTap: () => _showLanguageDialog(context, ref),
              ),
              ListTile(
                leading: const Icon(Icons.money),
                title: Text('currency'.tr()),
                subtitle: Text(localeState.currency),
                onTap: () => _showCurrencyPicker(context, ref),
              ),
            ],
          ),
          const SizedBox(height: KoogweSpacing.lg),
          SettingsSection(
            title: 'account'.tr(),
            children: [
              Builder(
                builder: (context) {
                  final authState = ref.watch(authProvider);
                  final userRole = authState.user?.role;
                  
                  return Column(
                    children: [
                      ListTile(
                        leading: const Icon(Icons.person),
                        title: Text(AppStrings.profile),
                        onTap: () {
                          // Rediriger vers le profil utilisateur selon le rôle
                          if (userRole == UserRole.passenger) {
                            context.push('/passenger/profile');
                          } else if (userRole == UserRole.driver) {
                            context.push('/driver/profile');
                          } else if (userRole == UserRole.admin) {
                            context.push('/admin/dashboard');
                          } else if (userRole == UserRole.business) {
                            context.push('/business/dashboard');
                          }
                        },
                      ),
                      const Divider(height: 0),
                      ListTile(
                        leading: const Icon(Icons.dashboard),
                        title: const Text('Accéder aux dashboards'),
                        subtitle: const Text('Basculer entre les vues selon votre rôle'),
                        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                        onTap: () => _showDashboardSelector(context, ref),
                      ),
                    ],
                  );
                },
              ),
              ListTile(
                leading: const Icon(Icons.security),
                title: Text('security'.tr()),
                onTap: () => context.push('/settings/security'),
              ),
              ListTile(
                leading: const Icon(Icons.privacy_tip),
                title: Text('privacy'.tr()),
                onTap: () => context.push('/settings/privacy'),
              ),
              ListTile(
                leading: const Icon(Icons.description),
                title: Text('terms'.tr()),
                onTap: () => context.push('/terms'),
              ),
              ListTile(
                leading: const Icon(Icons.support_agent),
                title: Text('support_chatbot'.tr()),
                onTap: () => context.push('/support/chatbot'),
              ),
            ],
          ),
          const SizedBox(height: KoogweSpacing.lg),
          SettingsSection(
            title: AppStrings.notifications,
            children: [
              SwitchListTile(
                secondary: const Icon(Icons.notifications_active),
                title: Text('push_notifications'.tr()),
                value: true,
                onChanged: (_) {},
              ),
              SwitchListTile(
                secondary: const Icon(Icons.sms),
                title: Text('inapp_notifications'.tr()),
                value: true,
                onChanged: (_) {},
              ),
            ],
          ),
          const SizedBox(height: KoogweSpacing.lg),
          SettingsSection(
            title: 'session'.tr(),
            children: [
              ListTile(
                leading: const Icon(Icons.exit_to_app, color: Colors.redAccent),
                title: Text(AppStrings.logout),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => _confirmLogout(context, ref),
              ),
            ],
          ),
        ],
      ),
    );
  }


  void _showLanguageDialog(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('choose_language'.tr()),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _langTile(context, ref, const Locale('fr'), 'Français'),
            _langTile(context, ref, const Locale('en'), 'English'),
            _langTile(context, ref, const Locale('pt'), 'Português'),
            _langTile(context, ref, const Locale('es'), 'Español'),
            _langTile(context, ref, const Locale('ht'), 'Kreyòl Ayisyen'),
          ],
        ),
      ),
    );
  }

  String _languageName(Locale l) {
    switch (l.languageCode) {
      case 'fr':
        return 'Français';
      case 'en':
        return 'English';
      case 'pt':
        return 'Português';
      case 'es':
        return 'Español';
      case 'ht':
        return 'Kreyòl Ayisyen';
      default:
        return l.languageCode;
    }
  }

  Widget _langTile(BuildContext context, WidgetRef ref, Locale locale, String label) {
    return ListTile(
      title: Text(label),
      trailing: context.locale.languageCode == locale.languageCode
          ? const Icon(Icons.check, color: Colors.green)
          : null,
      onTap: () async {
        await context.setLocale(locale);
        // persist choice via provider
        ref.read(localeProvider.notifier).setLanguage(locale.languageCode);
        if (context.mounted) context.pop();
      },
    );
  }

  void _showCountryPicker(BuildContext context, WidgetRef ref) {
    showCountryPicker(
      context: context,
      countryListTheme: CountryListThemeData(
        bottomSheetHeight: MediaQuery.of(context).size.height * 0.7,
        inputDecoration: const InputDecoration(hintText: 'Rechercher un pays'),
      ),
      onSelect: (Country c) {
        // Keep current language and currency; update country code
        final state = ref.read(localeProvider);
        ref.read(localeProvider.notifier).setLocale(
              Locale(state.locale.languageCode, c.countryCode),
              state.currency,
              c.countryCode,
            );
      },
      favorite: const ['GF', 'FR'],
    );
  }

  void _showCurrencyPicker(BuildContext context, WidgetRef ref) {
    showCurrencyPicker(
      context: context,
      showFlag: true,
      showSearchField: true,
      onSelect: (Currency currency) {
        ref.read(localeProvider.notifier).setCurrency(currency.code);
      },
      favorite: const ['EUR', 'USD'],
    );
  }

  void _showDashboardSelector(BuildContext context, WidgetRef ref) {
    final authState = ref.read(authProvider);
    final currentRole = authState.user?.role;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    showModalBottomSheet(
      context: context,
      backgroundColor: isDark ? KoogweColors.darkSurface : KoogweColors.lightSurface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Padding(
        padding: const EdgeInsets.all(KoogweSpacing.lg),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Sélectionner un dashboard',
              style: GoogleFonts.inter(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: isDark ? KoogweColors.darkTextPrimary : KoogweColors.lightTextPrimary,
              ),
            ),
            const SizedBox(height: KoogweSpacing.lg),
            _DashboardOption(
              icon: Icons.person,
              title: 'Passager',
              subtitle: 'Réservation et suivi de trajets',
              color: KoogweColors.primary,
              isCurrent: currentRole == UserRole.passenger,
              onTap: () {
                context.pop();
                context.go('/passenger/home');
              },
            ),
            const SizedBox(height: KoogweSpacing.md),
            _DashboardOption(
              icon: Icons.drive_eta,
              title: 'Chauffeur',
              subtitle: 'Gestion des courses et revenus',
              color: KoogweColors.secondary,
              isCurrent: currentRole == UserRole.driver,
              onTap: () {
                context.pop();
                if (currentRole == UserRole.driver || currentRole == UserRole.admin) {
                  context.go('/driver/home');
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Accès réservé aux chauffeurs')),
                  );
                }
              },
            ),
            const SizedBox(height: KoogweSpacing.md),
            _DashboardOption(
              icon: Icons.business,
              title: 'Entreprise',
              subtitle: 'Gestion des trajets professionnels',
              color: KoogweColors.accent,
              isCurrent: currentRole == UserRole.business,
              onTap: () {
                context.pop();
                if (currentRole == UserRole.business || currentRole == UserRole.admin) {
                  context.go('/business/dashboard');
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Accès réservé aux entreprises')),
                  );
                }
              },
            ),
            const SizedBox(height: KoogweSpacing.md),
            _DashboardOption(
              icon: Icons.admin_panel_settings,
              title: 'Administrateur',
              subtitle: 'Gestion complète de la plateforme',
              color: KoogweColors.error,
              isCurrent: currentRole == UserRole.admin,
              onTap: () {
                context.pop();
                if (currentRole == UserRole.admin) {
                  context.go('/admin/dashboard');
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Accès réservé aux administrateurs')),
                  );
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  void _confirmLogout(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    showModalBottomSheet(
      context: context,
      showDragHandle: true,
      backgroundColor: isDark ? KoogweColors.darkSurface : KoogweColors.lightSurface,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(KoogweSpacing.lg),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'confirm_logout'.tr(),
                style: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: KoogweSpacing.sm),
              Text(
                'logout_hint'.tr(),
                style: GoogleFonts.inter(color: isDark ? KoogweColors.darkTextSecondary : KoogweColors.lightTextSecondary),
              ),
              const SizedBox(height: KoogweSpacing.xl),
              Row(
                children: [
                  Expanded(
                    child: KoogweLogoutButton(
                      onConfirm: () async {
                        debugPrint('Logout requested');
                        await ref.read(authProvider.notifier).logout();
                        if (context.mounted) {
                          context.go('/home-hero');
                        }
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: KoogweSpacing.md),
              Center(
                child: TextButton(
                  onPressed: () => context.pop(),
                  child: Text(AppStrings.cancel),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class KoogweLogoutButton extends StatelessWidget {
  final VoidCallback onConfirm;
  const KoogweLogoutButton({super.key, required this.onConfirm});

  @override
  Widget build(BuildContext context) {
    return KoogweButton(
      text: AppStrings.logout,
      icon: Icons.logout,
      customColor: Colors.redAccent,
      onPressed: onConfirm,
      size: ButtonSize.large,
    );
  }
}

class _DashboardOption extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final Color color;
  final bool isCurrent;
  final VoidCallback onTap;

  const _DashboardOption({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.color,
    required this.isCurrent,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return InkWell(
      onTap: onTap,
      borderRadius: KoogweRadius.lgRadius,
      child: Container(
        padding: const EdgeInsets.all(KoogweSpacing.md),
        decoration: BoxDecoration(
          color: isCurrent ? color.withValues(alpha: 0.1) : Colors.transparent,
          borderRadius: KoogweRadius.lgRadius,
          border: Border.all(
            color: isCurrent ? color : KoogweColors.lightBorder,
            width: isCurrent ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.2),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: color),
            ),
            const SizedBox(width: KoogweSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: GoogleFonts.inter(
                      fontWeight: FontWeight.w600,
                      color: isDark ? KoogweColors.darkTextPrimary : KoogweColors.lightTextPrimary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      color: isDark ? KoogweColors.darkTextSecondary : KoogweColors.lightTextSecondary,
                    ),
                  ),
                ],
              ),
            ),
            if (isCurrent)
              Icon(Icons.check_circle, color: color),
          ],
        ),
      ),
    );
  }
}

class SettingsSection extends StatelessWidget {
  final String title;
  final List<Widget> children;

  const SettingsSection({
    super.key,
    required this.title,
    required this.children,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: KoogweSpacing.lg, vertical: KoogweSpacing.sm),
          child: Text(
            title,
            style: GoogleFonts.inter(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: isDark ? KoogweColors.darkTextSecondary : KoogweColors.lightTextSecondary,
            ),
          ),
        ),
        Container(
          decoration: BoxDecoration(
            color: isDark ? KoogweColors.darkSurface : KoogweColors.lightSurface,
            borderRadius: KoogweRadius.lgRadius,
            border: Border.all(
              color: isDark ? KoogweColors.darkBorder : KoogweColors.lightBorder,
            ),
          ),
          child: Column(children: children),
        ),
      ],
    );
  }
}
