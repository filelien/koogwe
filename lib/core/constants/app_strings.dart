import 'package:easy_localization/easy_localization.dart';

class AppStrings {
  // App Info
  static const String appName = 'KOOGWE';
  static String get appSlogan => 'app_slogan'.tr(); // KOOGWE – Allons-y, en toute confiance
  
  // User Roles
  static String get rolePassenger => 'role_passenger'.tr();
  static String get roleDriver => 'role_driver'.tr();
  static String get roleAdmin => 'role_admin'.tr();
  static String get roleBusiness => 'role_business'.tr();
  
  // Auth
  static String get welcome => 'welcome'.tr();
  static String get login => 'login'.tr();
  static String get register => 'register'.tr();
  static String get logout => 'logout'.tr();
  static String get email => 'email'.tr();
  static String get password => 'password'.tr();
  static String get confirmPassword => 'confirm_password'.tr();
  static String get forgotPassword => 'forgot_password'.tr();
  static String get resetPassword => 'reset_password'.tr();
  static String get verifyOTP => 'verify_otp'.tr();
  static String get resendCode => 'resend_code'.tr();
  static String get phoneNumber => 'phone_number'.tr();
  static String get firstName => 'first_name'.tr();
  static String get lastName => 'last_name'.tr();
  static String get selectRole => 'select_role'.tr();
  static String get continueText => 'continue'.tr();
  
  // Navigation
  static String get home => 'home'.tr();
  static String get rides => 'rides'.tr();
  static String get wallet => 'wallet'.tr();
  static String get profile => 'profile'.tr();
  static String get settings => 'settings'.tr();
  static String get notifications => 'notifications'.tr();
  static String get messages => 'messages'.tr();
  static String get history => 'history'.tr();
  
  // Passenger
  static String get whereToGo => 'where_to_go'.tr();
  static String get pickupLocation => 'pickup_location'.tr();
  static String get dropoffLocation => 'dropoff_location'.tr();
  static String get selectVehicle => 'select_vehicle'.tr();
  static String get confirmRide => 'confirm_ride'.tr();
  static String get searchingDriver => 'searching_driver'.tr();
  static String get driverFound => 'driver_found'.tr();
  static String get rideInProgress => 'ride_in_progress'.tr();
  static String get arrivedDestination => 'arrived_destination'.tr();
  static String get rateYourRide => 'rate_your_ride'.tr();
  
  // Driver
  static String get goOnline => 'go_online'.tr();
  static String get goOffline => 'go_offline'.tr();
  static String get newRideRequest => 'new_ride_request'.tr();
  static String get acceptRide => 'accept_ride'.tr();
  static String get declineRide => 'decline_ride'.tr();
  static String get startRide => 'start_ride'.tr();
  static String get completeRide => 'complete_ride'.tr();
  static String get earnings => 'earnings'.tr();
  static String get statistics => 'statistics'.tr();
  
  // Wallet
  static String get balance => 'balance'.tr();
  static String get topUp => 'top_up'.tr();
  static String get withdraw => 'withdraw'.tr();
  static String get transactions => 'transactions'.tr();
  static String get addPaymentMethod => 'add_payment_method'.tr();
  
  // Common
  static String get cancel => 'cancel'.tr();
  static String get confirm => 'confirm'.tr();
  static String get save => 'save'.tr();
  static String get edit => 'edit'.tr();
  static String get delete => 'delete'.tr();
  static String get search => 'search'.tr();
  static String get filter => 'filter'.tr();
  static String get sort => 'sort'.tr();
  static String get loading => 'loading'.tr();
  static String get error => 'error'.tr();
  static String get success => 'success'.tr();
  static String get retry => 'retry'.tr();
  static String get noData => 'no_data'.tr();
  static String get showMore => 'show_more'.tr();
  static String get showLess => 'show_less'.tr();
}
