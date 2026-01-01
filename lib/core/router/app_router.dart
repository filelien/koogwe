import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:koogwe/features/splash/splash_screen.dart';
import 'package:koogwe/features/onboarding/onboarding_screen.dart';
import 'package:koogwe/features/home/home_hero_screen.dart';
import 'package:koogwe/features/auth/screens/country_selection_screen.dart';
import 'package:koogwe/features/auth/screens/language_selection_screen.dart';
import 'package:koogwe/features/auth/screens/role_selection_screen.dart';
import 'package:koogwe/features/auth/screens/login_screen.dart';
import 'package:koogwe/features/auth/screens/register_screen.dart';
import 'package:koogwe/features/auth/screens/otp_screen.dart';
import 'package:koogwe/features/auth/screens/two_factor_auth_screen.dart';
import 'package:koogwe/features/auth/screens/forgot_password_screen.dart';
import 'package:koogwe/features/passenger/home/passenger_home_screen.dart';
import 'package:koogwe/features/passenger/ride/ride_booking_screen.dart';
import 'package:koogwe/features/passenger/ride/vehicle_selection_screen.dart';
import 'package:koogwe/features/passenger/ride/ride_tracking_screen.dart';
import 'package:koogwe/features/passenger/profile/passenger_profile_screen.dart';
import 'package:koogwe/features/passenger/wallet/wallet_screen.dart';
import 'package:koogwe/features/passenger/history/ride_history_screen.dart';
import 'package:koogwe/features/passenger/scheduled/scheduled_ride_screen_improved.dart';
import 'package:koogwe/features/passenger/negotiation/price_negotiation_screen.dart';
import 'package:koogwe/features/passenger/comfort/comfort_preferences_screen.dart';
import 'package:koogwe/features/passenger/share/share_location_screen.dart';
import 'package:koogwe/features/passenger/reputation/reputation_screen.dart';
import 'package:koogwe/features/passenger/disputes/disputes_screen.dart';
import 'package:koogwe/features/passenger/services/service_selection_screen.dart';
import 'package:koogwe/features/passenger/assistant/assistant_screen.dart';
import 'package:koogwe/features/driver/driving_mode/driving_mode_screen.dart';
import 'package:koogwe/features/passenger/subscription/subscription_screen.dart';
import 'package:koogwe/features/driver/documents/driver_documents_screen.dart';
import 'package:koogwe/features/passenger/predictive_pricing/predictive_pricing_screen.dart';
import 'package:koogwe/features/passenger/family/family_mode_screen.dart';
import 'package:koogwe/features/passenger/identity_verification/identity_verification_screen.dart';
import 'package:koogwe/features/passenger/mobility_analytics/mobility_analytics_screen.dart';
import 'package:koogwe/features/passenger/eco_trip/eco_trip_screen.dart';
import 'package:koogwe/features/driver/vehicles/vehicle_catalog_screen.dart';
import 'package:koogwe/features/driver/vehicles/add_vehicle_screen.dart';
import 'package:koogwe/features/passenger/ride/ride_preview_screen.dart';
import 'package:koogwe/features/passenger/advanced_sos/advanced_sos_screen.dart';
import 'package:koogwe/features/passenger/notifications/notifications_screen.dart';
import 'package:koogwe/features/passenger/feedback/advanced_feedback_screen.dart';
import 'package:koogwe/features/passenger/chat/driver_chat_screen.dart';
import 'package:koogwe/features/passenger/invoice/invoice_detail_screen.dart';
import 'package:koogwe/features/passenger/favorites/favorites_destinations_screen.dart';
import 'package:koogwe/features/passenger/promotions/promotions_screen.dart';
import 'package:koogwe/features/passenger/help/faq_screen.dart';
import 'package:koogwe/features/passenger/share/share_eta_screen.dart';
import 'package:koogwe/features/passenger/multi_stop/multi_stop_ride_screen.dart';
import 'package:koogwe/features/passenger/price_comparison/price_comparison_screen.dart';
import 'package:koogwe/features/passenger/search_history/search_history_screen.dart';
import 'package:koogwe/features/passenger/suggestions/smart_suggestions_screen.dart';
import 'package:koogwe/features/passenger/carpool/carpool_screen.dart';
import 'package:koogwe/features/passenger/help/help_center_screen.dart';
import 'package:koogwe/features/driver/performance/driver_performance_screen.dart';
import 'package:koogwe/features/business/reports/business_reports_screen.dart';
import 'package:koogwe/features/driver/home/driver_home_screen.dart';
import 'package:koogwe/features/driver/earnings/earnings_screen.dart';
import 'package:koogwe/features/driver/profile/driver_profile_screen.dart';
import 'package:koogwe/features/settings/settings_screen.dart';
import 'package:koogwe/features/settings/theme_settings_screen.dart';
import 'package:koogwe/features/settings/security_settings_screen.dart';
import 'package:koogwe/features/settings/privacy_settings_screen.dart';
import 'package:koogwe/features/driver/onboarding/driver_onboarding_screen.dart';
import 'package:koogwe/features/driver/rides/driver_rides_screen.dart';
import 'package:koogwe/features/driver/statistics/driver_statistics_screen.dart';
import 'package:koogwe/features/business/onboarding/business_onboarding_screen.dart';
import 'package:koogwe/features/business/employees/business_employees_screen.dart';
import 'package:koogwe/features/business/bookings/business_bookings_screen.dart';
import 'package:koogwe/features/business/budget/business_budget_screen.dart';
import 'package:koogwe/features/business/invoices/business_invoices_screen.dart';
import 'package:koogwe/features/admin/admin_dashboard_screen.dart';
import 'package:koogwe/features/admin/users/admin_users_screen.dart';
import 'package:koogwe/features/admin/rides/admin_rides_screen.dart';
import 'package:koogwe/features/admin/payments/admin_payments_screen.dart';
import 'package:koogwe/features/admin/security/admin_security_screen.dart';
import 'package:koogwe/features/admin/pricing/admin_pricing_screen.dart';
import 'package:koogwe/features/business/business_dashboard_screen.dart';
import 'package:koogwe/features/support/chatbot_screen.dart';
import 'package:koogwe/features/misc/maintenance_screen.dart';
import 'package:koogwe/features/misc/network_error_screen.dart';
import 'package:koogwe/features/misc/terms_screen.dart';
import 'package:koogwe/features/misc/supabase_test_screen.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:koogwe/core/providers/auth_provider.dart';
import 'dart:async';

class AppRoutes {
  static const splash = '/';
  static const homeHero = '/home-hero';
  static const onboarding = '/onboarding';
  static const countrySelection = '/country-selection';
  static const languageSelection = '/language-selection';
  static const roleSelection = '/role-selection';
  static const login = '/login';
  static const register = '/register';
  static const otp = '/otp';
  static const twoFactorAuth = '/2fa';
  static const forgotPassword = '/forgot-password';
  
  static const passengerHome = '/passenger/home';
  static const rideBooking = '/passenger/ride-booking';
  static const vehicleSelection = '/passenger/vehicle-selection';
  static const rideTracking = '/passenger/ride-tracking';
  static const passengerProfile = '/passenger/profile';
  static const wallet = '/passenger/wallet';
  static const rideHistory = '/passenger/history';
  static const scheduledRide = '/passenger/scheduled';
  static const priceNegotiation = '/passenger/negotiation';
  static const comfortPreferences = '/passenger/comfort';
  static const shareLocation = '/passenger/share';
  static const reputation = '/passenger/reputation';
  static const disputes = '/passenger/disputes';
  static const serviceSelection = '/passenger/services';
  static const assistant = '/passenger/assistant';
  static const drivingMode = '/driver/driving-mode';
  static const subscription = '/passenger/subscription';
  static const driverDocuments = '/driver/documents';
  static const vehicleCatalog = '/driver/vehicles';
  static const addVehicle = '/driver/vehicles/add';
  static const predictivePricing = '/passenger/predictive-pricing';
  static const familyMode = '/passenger/family';
  static const identityVerification = '/passenger/identity-verification';
  static const mobilityAnalytics = '/passenger/mobility-analytics';
  static const ecoTrip = '/passenger/eco-trip';
  static const ridePreview = '/passenger/ride-preview';
  static const advancedSOS = '/passenger/advanced-sos';
  static const notifications = '/passenger/notifications';
  static const advancedFeedback = '/passenger/feedback';
  static const driverChat = '/passenger/chat';
  static const invoiceDetail = '/passenger/invoice';
  static const favoritesDestinations = '/passenger/favorites';
  static const promotions = '/passenger/promotions';
  static const faq = '/passenger/faq';
  static const shareETA = '/passenger/share-eta';
  static const multiStop = '/passenger/multi-stop';
  static const priceComparison = '/passenger/price-comparison';
  static const searchHistory = '/passenger/search-history';
  static const smartSuggestions = '/passenger/suggestions';
  static const helpCenter = '/passenger/help-center';
  static const carpool = '/passenger/carpool';
  static const driverPerformance = '/driver/performance';
  static const businessReports = '/business/reports';
  
  static const driverHome = '/driver/home';
  static const earnings = '/driver/earnings';
  static const driverProfile = '/driver/profile';
  
  static const settings = '/settings';
  static const themeSettings = '/settings/themes';
  static const securitySettings = '/settings/security';
  static const privacySettings = '/settings/privacy';
  static const driverOnboarding = '/driver/onboarding';
  static const driverRides = '/driver/rides';
  static const driverStatistics = '/driver/statistics';
  static const businessOnboarding = '/business/onboarding';
  static const businessEmployees = '/business/employees';
  static const businessBookings = '/business/bookings';
  static const businessBudget = '/business/budget';
  static const businessInvoices = '/business/invoices';
  static const adminDashboard = '/admin/dashboard';
  static const adminUsers = '/admin/users';
  static const adminRides = '/admin/rides';
  static const adminPayments = '/admin/payments';
  static const adminSecurity = '/admin/security';
  static const adminPricing = '/admin/pricing';
  static const businessDashboard = '/business/dashboard';
  static const supportChatbot = '/support/chatbot';
  static const maintenance = '/maintenance';
  static const networkError = '/network-error';
  static const terms = '/terms';
  static const supabaseTest = '/test-supabase';
}

bool _isProtected(String location) {
  return location.startsWith('/passenger') ||
      location.startsWith('/driver') ||
      location.startsWith('/admin') ||
      location.startsWith('/business') ||
      location.startsWith('/settings');
}

/// Get the home route based on user role
String? _getHomeRouteForRole(UserRole? role) {
  switch (role) {
    case UserRole.admin:
      return AppRoutes.adminDashboard;
    case UserRole.driver:
      return AppRoutes.driverHome;
    case UserRole.business:
      return AppRoutes.businessDashboard;
    case UserRole.passenger:
    default:
      return AppRoutes.passengerHome;
  }
}

/// Check if user has access to a route based on their role
bool _hasAccessToRoute(String route, UserRole? role) {
  if (route.startsWith('/admin')) {
    return role == UserRole.admin;
  }
  if (route.startsWith('/driver')) {
    return role == UserRole.driver || role == UserRole.admin;
  }
  if (route.startsWith('/business')) {
    return role == UserRole.business || role == UserRole.admin;
  }
  if (route.startsWith('/passenger')) {
    return role == UserRole.passenger || role == UserRole.admin;
  }
  if (route.startsWith('/settings')) {
    return true; // Settings accessible to all authenticated users
  }
  return true; // Other routes accessible
}

final appRouter = GoRouter(
  initialLocation: AppRoutes.splash,
  // Ensure router reevaluates redirects when auth state changes (login/logout)
  refreshListenable: GoRouterRefreshStream(
    Supabase.instance.client.auth.onAuthStateChange,
  ),
  redirect: (context, state) {
    final user = Supabase.instance.client.auth.currentUser;
    final goingTo = state.uri.toString();
    
    // Allow public routes
    final publiclyAccessible = {
      AppRoutes.splash,
      AppRoutes.homeHero,
      AppRoutes.onboarding,
      AppRoutes.countrySelection,
      AppRoutes.languageSelection,
      AppRoutes.roleSelection,
      AppRoutes.login,
      AppRoutes.register,
      AppRoutes.otp,
      AppRoutes.twoFactorAuth,
      AppRoutes.forgotPassword,
      AppRoutes.maintenance,
      AppRoutes.networkError,
      AppRoutes.terms,
      AppRoutes.supabaseTest, // Allow test screen for debugging
    };
    
    if (publiclyAccessible.contains(goingTo)) return null;
    
    // If route is protected and user is not logged in, redirect to login
    if (_isProtected(goingTo) && user == null) {
      return AppRoutes.login;
    }
    
    // If user is logged in and trying to access login/register, redirect to their home
    if ((goingTo == AppRoutes.login || goingTo == AppRoutes.register) && user != null) {
      final meta = user.userMetadata ?? {};
      final roleStr = (meta['role'] ?? 'passenger').toString();
      UserRole role;
      switch (roleStr) {
        case 'driver':
          role = UserRole.driver;
          break;
        case 'admin':
          role = UserRole.admin;
          break;
        case 'business':
          role = UserRole.business;
          break;
        default:
          role = UserRole.passenger;
      }
      return _getHomeRouteForRole(role);
    }
    
    // Check if user has access to the route based on their role
    if (user != null && _isProtected(goingTo)) {
      final meta = user.userMetadata ?? {};
      final roleStr = (meta['role'] ?? 'passenger').toString();
      UserRole role;
      switch (roleStr) {
        case 'driver':
          role = UserRole.driver;
          break;
        case 'admin':
          role = UserRole.admin;
          break;
        case 'business':
          role = UserRole.business;
          break;
        default:
          role = UserRole.passenger;
      }
      
      if (!_hasAccessToRoute(goingTo, role)) {
        // User doesn't have access, redirect to their home
        return _getHomeRouteForRole(role);
      }
    }
    
    return null;
  },
  routes: [
    GoRoute(
      path: AppRoutes.splash,
      builder: (context, state) => const SplashScreen(),
    ),
    GoRoute(
      path: AppRoutes.homeHero,
      builder: (context, state) => const HomeHeroScreen(),
    ),
    GoRoute(
      path: AppRoutes.onboarding,
      builder: (context, state) => const OnboardingScreen(),
    ),
    GoRoute(
      path: AppRoutes.countrySelection,
      builder: (context, state) => const CountrySelectionScreen(),
    ),
    GoRoute(
      path: AppRoutes.languageSelection,
      builder: (context, state) => const LanguageSelectionScreen(),
    ),
    GoRoute(
      path: AppRoutes.roleSelection,
      builder: (context, state) => const RoleSelectionScreen(),
    ),
    GoRoute(
      path: AppRoutes.login,
      builder: (context, state) => const LoginScreen(),
    ),
    GoRoute(
      path: AppRoutes.register,
      builder: (context, state) => const RegisterScreen(),
    ),
    GoRoute(
      path: AppRoutes.otp,
      builder: (context, state) => const OTPScreen(),
    ),
    GoRoute(
      path: AppRoutes.twoFactorAuth,
      builder: (context, state) => const TwoFactorAuthScreen(),
    ),
    GoRoute(
      path: AppRoutes.forgotPassword,
      builder: (context, state) => const ForgotPasswordScreen(),
    ),
    GoRoute(
      path: AppRoutes.passengerHome,
      builder: (context, state) => const PassengerHomeScreen(),
    ),
    GoRoute(
      path: AppRoutes.rideBooking,
      builder: (context, state) => const RideBookingScreen(),
    ),
    GoRoute(
      path: AppRoutes.vehicleSelection,
      builder: (context, state) => const VehicleSelectionScreen(),
    ),
    GoRoute(
      path: AppRoutes.rideTracking,
      builder: (context, state) => const RideTrackingScreen(),
    ),
    GoRoute(
      path: AppRoutes.passengerProfile,
      builder: (context, state) => const PassengerProfileScreen(),
    ),
    GoRoute(
      path: AppRoutes.wallet,
      builder: (context, state) => const WalletScreen(),
    ),
    GoRoute(
      path: AppRoutes.rideHistory,
      builder: (context, state) => const RideHistoryScreen(),
    ),
    GoRoute(
      path: AppRoutes.scheduledRide,
      builder: (context, state) => const ScheduledRideScreenImproved(),
    ),
    GoRoute(
      path: AppRoutes.priceNegotiation,
      builder: (context, state) => const PriceNegotiationScreen(),
    ),
    GoRoute(
      path: AppRoutes.comfortPreferences,
      builder: (context, state) => const ComfortPreferencesScreen(),
    ),
    GoRoute(
      path: AppRoutes.shareLocation,
      builder: (context, state) => const ShareLocationScreen(),
    ),
    GoRoute(
      path: AppRoutes.reputation,
      builder: (context, state) => const ReputationScreen(),
    ),
    GoRoute(
      path: AppRoutes.disputes,
      builder: (context, state) => const DisputesScreen(),
    ),
    GoRoute(
      path: AppRoutes.serviceSelection,
      builder: (context, state) => const ServiceSelectionScreen(),
    ),
    GoRoute(
      path: AppRoutes.assistant,
      builder: (context, state) => const AssistantScreen(),
    ),
    GoRoute(
      path: AppRoutes.drivingMode,
      builder: (context, state) => const DrivingModeScreen(),
    ),
    GoRoute(
      path: AppRoutes.subscription,
      builder: (context, state) => const SubscriptionScreen(),
    ),
    GoRoute(
      path: AppRoutes.driverDocuments,
      builder: (context, state) => const DriverDocumentsScreen(),
    ),
    GoRoute(
      path: AppRoutes.predictivePricing,
      builder: (context, state) => const PredictivePricingScreen(),
    ),
    GoRoute(
      path: AppRoutes.familyMode,
      builder: (context, state) => const FamilyModeScreen(),
    ),
    GoRoute(
      path: AppRoutes.identityVerification,
      builder: (context, state) => const IdentityVerificationScreen(),
    ),
    GoRoute(
      path: AppRoutes.mobilityAnalytics,
      builder: (context, state) => const MobilityAnalyticsScreen(),
    ),
    GoRoute(
      path: AppRoutes.ecoTrip,
      builder: (context, state) => const EcoTripScreen(),
    ),
    GoRoute(
      path: AppRoutes.vehicleCatalog,
      builder: (context, state) => const VehicleCatalogScreen(),
    ),
    GoRoute(
      path: AppRoutes.addVehicle,
      builder: (context, state) => const AddVehicleScreen(),
    ),
    GoRoute(
      path: AppRoutes.ridePreview,
      builder: (context, state) {
        final vehicleType = state.uri.queryParameters['vehicleType'] ?? 'Confort';
        final pickup = state.uri.queryParameters['pickup'] ?? '';
        final dropoff = state.uri.queryParameters['dropoff'] ?? '';
        final price = double.tryParse(state.uri.queryParameters['price'] ?? '0') ?? 0.0;
        final duration = int.tryParse(state.uri.queryParameters['duration'] ?? '20') ?? 20;
        final driverName = state.uri.queryParameters['driverName'];
        final driverRating = double.tryParse(state.uri.queryParameters['driverRating'] ?? '');
        final driverStoreAddress = state.uri.queryParameters['driverStoreAddress'];
        final carModel = state.uri.queryParameters['carModel'];
        final carNumber = state.uri.queryParameters['carNumber'];
        return RidePreviewScreen(
          vehicleType: vehicleType,
          pickup: pickup,
          dropoff: dropoff,
          estimatedPrice: price,
          estimatedDuration: duration,
          driverName: driverName,
          driverRating: driverRating,
          driverStoreAddress: driverStoreAddress ?? 'Midnight transportation store',
          carModel: carModel ?? 'Toyota Camry',
          carNumber: carNumber ?? '23-10-00',
        );
      },
    ),
    GoRoute(
      path: AppRoutes.advancedSOS,
      builder: (context, state) => const AdvancedSOSScreen(),
    ),
    GoRoute(
      path: AppRoutes.notifications,
      builder: (context, state) => const NotificationsScreen(),
    ),
    GoRoute(
      path: AppRoutes.advancedFeedback,
      builder: (context, state) {
        final rideId = state.uri.queryParameters['rideId'] ?? '';
        final driverName = state.uri.queryParameters['driverName'] ?? 'Chauffeur';
        final price = double.tryParse(state.uri.queryParameters['price'] ?? '0') ?? 0.0;
        return AdvancedFeedbackScreen(
          rideId: rideId,
          driverName: driverName,
          ridePrice: price,
        );
      },
    ),
    GoRoute(
      path: AppRoutes.driverChat,
      builder: (context, state) {
        final rideId = state.uri.queryParameters['rideId'];
        final driverId = state.uri.queryParameters['driverId'];
        final driverName = state.uri.queryParameters['driverName'];
        final driverAvatar = state.uri.queryParameters['driverAvatar'];
        return DriverChatScreen(
          rideId: rideId,
          driverId: driverId,
          driverName: driverName,
          driverAvatar: driverAvatar,
        );
      },
    ),
    GoRoute(
      path: AppRoutes.invoiceDetail,
      builder: (context, state) {
        final rideId = state.uri.queryParameters['rideId'];
        final invoiceId = state.uri.queryParameters['invoiceId'];
        return InvoiceDetailScreen(
          rideId: rideId,
          invoiceId: invoiceId,
        );
      },
    ),
    GoRoute(
      path: AppRoutes.favoritesDestinations,
      builder: (context, state) => const FavoritesDestinationsScreen(),
    ),
    GoRoute(
      path: AppRoutes.promotions,
      builder: (context, state) => const PromotionsScreen(),
    ),
    GoRoute(
      path: AppRoutes.faq,
      builder: (context, state) => const FAQScreen(),
    ),
    GoRoute(
      path: AppRoutes.shareETA,
      builder: (context, state) {
        final rideId = state.uri.queryParameters['rideId'];
        final pickup = state.uri.queryParameters['pickup'];
        final dropoff = state.uri.queryParameters['dropoff'];
        final eta = state.uri.queryParameters['eta'];
        return ShareETAScreen(
          rideId: rideId,
          pickup: pickup,
          dropoff: dropoff,
          eta: eta,
        );
      },
    ),
    GoRoute(
      path: AppRoutes.multiStop,
      builder: (context, state) => const MultiStopRideScreen(),
    ),
    GoRoute(
      path: AppRoutes.priceComparison,
      builder: (context, state) {
        final pickup = state.uri.queryParameters['pickup'] ?? '';
        final dropoff = state.uri.queryParameters['dropoff'] ?? '';
        return PriceComparisonScreen(
          pickup: pickup,
          dropoff: dropoff,
        );
      },
    ),
    GoRoute(
      path: AppRoutes.searchHistory,
      builder: (context, state) => const SearchHistoryScreen(),
    ),
    GoRoute(
      path: AppRoutes.smartSuggestions,
      builder: (context, state) => const SmartSuggestionsScreen(),
    ),
    GoRoute(
      path: AppRoutes.helpCenter,
      builder: (context, state) => const HelpCenterScreen(),
    ),
    GoRoute(
      path: AppRoutes.carpool,
      builder: (context, state) => const CarpoolScreen(),
    ),
    GoRoute(
      path: AppRoutes.driverPerformance,
      builder: (context, state) => const DriverPerformanceScreen(),
    ),
    GoRoute(
      path: AppRoutes.businessReports,
      builder: (context, state) => const BusinessReportsScreen(),
    ),
    GoRoute(
      path: AppRoutes.driverHome,
      builder: (context, state) => const DriverHomeScreen(),
    ),
    GoRoute(
      path: AppRoutes.earnings,
      builder: (context, state) => const EarningsScreen(),
    ),
    GoRoute(
      path: AppRoutes.driverProfile,
      builder: (context, state) => const DriverProfileScreen(),
    ),
    GoRoute(
      path: AppRoutes.settings,
      builder: (context, state) => const SettingsScreen(),
    ),
    GoRoute(
      path: AppRoutes.themeSettings,
      builder: (context, state) => const ThemeSettingsScreen(),
    ),
    GoRoute(
      path: AppRoutes.adminDashboard,
      builder: (context, state) => const AdminDashboardScreen(),
    ),
    GoRoute(
      path: AppRoutes.adminUsers,
      builder: (context, state) => const AdminUsersScreen(),
    ),
    GoRoute(
      path: AppRoutes.adminRides,
      builder: (context, state) => const AdminRidesScreen(),
    ),
    GoRoute(
      path: AppRoutes.adminPayments,
      builder: (context, state) => const AdminPaymentsScreen(),
    ),
    GoRoute(
      path: AppRoutes.adminSecurity,
      builder: (context, state) => const AdminSecurityScreen(),
    ),
    GoRoute(
      path: AppRoutes.adminPricing,
      builder: (context, state) => const AdminPricingScreen(),
    ),
    GoRoute(
      path: AppRoutes.businessDashboard,
      builder: (context, state) => const BusinessDashboardScreen(),
    ),
    GoRoute(
      path: AppRoutes.supportChatbot,
      builder: (context, state) => const ChatbotScreen(),
    ),
    GoRoute(
      path: AppRoutes.maintenance,
      builder: (context, state) => const MaintenanceScreen(),
    ),
    GoRoute(
      path: AppRoutes.networkError,
      builder: (context, state) => const NetworkErrorScreen(),
    ),
    GoRoute(
      path: AppRoutes.terms,
      builder: (context, state) => const TermsScreen(),
    ),
    GoRoute(
      path: AppRoutes.supabaseTest,
      builder: (context, state) => const SupabaseTestScreen(),
    ),
    GoRoute(
      path: AppRoutes.securitySettings,
      builder: (context, state) => const SecuritySettingsScreen(),
    ),
    GoRoute(
      path: AppRoutes.privacySettings,
      builder: (context, state) => const PrivacySettingsScreen(),
    ),
    GoRoute(
      path: AppRoutes.driverOnboarding,
      builder: (context, state) => const DriverOnboardingScreen(),
    ),
    GoRoute(
      path: AppRoutes.driverRides,
      builder: (context, state) => const DriverRidesScreen(),
    ),
    GoRoute(
      path: AppRoutes.driverStatistics,
      builder: (context, state) => const DriverStatisticsScreen(),
    ),
    GoRoute(
      path: AppRoutes.businessOnboarding,
      builder: (context, state) => const BusinessOnboardingScreen(),
    ),
    GoRoute(
      path: AppRoutes.businessEmployees,
      builder: (context, state) => const BusinessEmployeesScreen(),
    ),
    GoRoute(
      path: AppRoutes.businessBookings,
      builder: (context, state) => const BusinessBookingsScreen(),
    ),
    GoRoute(
      path: AppRoutes.businessBudget,
      builder: (context, state) => const BusinessBudgetScreen(),
    ),
    GoRoute(
      path: AppRoutes.businessInvoices,
      builder: (context, state) => const BusinessInvoicesScreen(),
    ),
  ],
);

/// Bridges a Stream to GoRouter's refreshListenable so that route guards
/// re-run when authentication or any other reactive state changes.
class GoRouterRefreshStream extends ChangeNotifier {
  GoRouterRefreshStream(Stream<dynamic> stream) {
    _subscription = stream.asBroadcastStream().listen((_) {
      notifyListeners();
    });
  }

  late final StreamSubscription<dynamic> _subscription;

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }
}
