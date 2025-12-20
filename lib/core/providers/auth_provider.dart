import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:koogwe/core/config/env.dart';

enum UserRole { passenger, driver, admin, business }

class User {
  final String id;
  final String email;
  final String firstName;
  final String lastName;
  final String? phoneNumber;
  final UserRole role;
  final String? profileImageUrl;

  User({
    required this.id,
    required this.email,
    required this.firstName,
    required this.lastName,
    this.phoneNumber,
    required this.role,
    this.profileImageUrl,
  });

  String get fullName => '$firstName $lastName';
}

class AuthState {
  final User? user;
  final bool isAuthenticated;
  final bool isLoading;
  final String? error;

  AuthState({
    this.user,
    this.isAuthenticated = false,
    this.isLoading = false,
    this.error,
  });

  AuthState copyWith({
    User? user,
    bool? isAuthenticated,
    bool? isLoading,
    String? error,
  }) {
    return AuthState(
      user: user ?? this.user,
      isAuthenticated: isAuthenticated ?? this.isAuthenticated,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
    );
  }
}

class AuthNotifier extends Notifier<AuthState> {
  SupabaseClient get _supabase => Supabase.instance.client;

  @override
  AuthState build() {
    final current = _supabase.auth.currentUser;
    if (current == null) return AuthState();
    final meta = current.userMetadata ?? {};
    return AuthState(
      user: User(
        id: current.id,
        email: current.email ?? '',
        firstName: (meta['firstName'] ?? meta['first_name'] ?? '').toString(),
        lastName: (meta['lastName'] ?? meta['last_name'] ?? '').toString(),
        phoneNumber: (meta['phoneNumber'] ?? meta['phone_number'])?.toString(),
        role: _roleFrom(meta['role']),
        profileImageUrl: meta['avatar_url']?.toString(),
      ),
      isAuthenticated: true,
    );
  }

  UserRole _roleFrom(dynamic raw) {
    final r = (raw ?? 'passenger').toString();
    switch (r) {
      case 'driver':
        return UserRole.driver;
      case 'admin':
        return UserRole.admin;
      case 'business':
        return UserRole.business;
      default:
        return UserRole.passenger;
    }
  }

  Future<void> login(String email, String password) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      debugPrint('[Auth] Attempting login for: $email');
      debugPrint('[Auth] Supabase URL: ${Env.supabaseUrl}');
      
      await _supabase.auth.signInWithPassword(email: email, password: password);
      final u = _supabase.auth.currentUser;
      
      if (u != null) {
        debugPrint('[Auth] Login successful, user ID: ${u.id}');
        final meta = u.userMetadata ?? {};
        state = state.copyWith(
          user: User(
            id: u.id,
            email: u.email ?? email,
            firstName: (meta['firstName'] ?? meta['first_name'] ?? '').toString(),
            lastName: (meta['lastName'] ?? meta['last_name'] ?? '').toString(),
            phoneNumber: (meta['phoneNumber'] ?? meta['phone_number'])?.toString(),
            role: _roleFrom(meta['role']),
            profileImageUrl: meta['avatar_url']?.toString(),
          ),
          isAuthenticated: true,
          isLoading: false,
        );
      } else {
        debugPrint('[Auth] Login failed: No user returned');
        state = state.copyWith(isLoading: false, error: 'Échec de l\'authentification. Vérifiez vos identifiants.');
      }
    } on AuthApiException catch (e) {
      debugPrint('[Auth] AuthApiException: ${e.message}');
      debugPrint('[Auth] Status code: ${e.statusCode}');
      
      String userMessage;
      if (e.message.toLowerCase().contains('invalid login credentials') || 
          e.message.toLowerCase().contains('invalid credentials')) {
        userMessage = 'Email ou mot de passe incorrect.';
      } else if (e.message.toLowerCase().contains('email not confirmed')) {
        userMessage = 'Veuillez confirmer votre email avant de vous connecter.';
      } else if (e.message.toLowerCase().contains('too many requests')) {
        userMessage = 'Trop de tentatives. Veuillez patienter quelques instants.';
      } else {
        userMessage = 'Erreur de connexion: ${e.message}';
      }
      
      state = state.copyWith(isLoading: false, error: userMessage);
    } catch (e, stackTrace) {
      debugPrint('[Auth] Login error: $e');
      debugPrint('[Auth] Stack trace: $stackTrace');
      
      final errorStr = e.toString().toLowerCase();
      String userMessage;
      if (errorStr.contains('failed to fetch') || 
          errorStr.contains('network') || 
          errorStr.contains('connection')) {
        userMessage = 'Erreur de connexion. Vérifiez votre connexion internet et réessayez.';
      } else {
        userMessage = 'Erreur lors de la connexion. Veuillez réessayer.';
      }
      
      state = state.copyWith(isLoading: false, error: userMessage);
    }
  }

  Future<void> register({
    required String email,
    required String password,
    required String firstName,
    required String lastName,
    required String phoneNumber,
    required UserRole role,
  }) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      debugPrint('[Auth] Attempting registration for: $email');
      debugPrint('[Auth] Supabase URL: ${Env.supabaseUrl}');
      
      // Retry logic for network issues
      int retries = 3;
      AuthResponse? response;
      Exception? lastError;
      
      while (retries > 0) {
        try {
          debugPrint('[Auth] SignUp attempt ${4 - retries}/3');
          response = await _supabase.auth.signUp(
        email: email,
        password: password,
        data: {
          'firstName': firstName,
          'lastName': lastName,
          'phoneNumber': phoneNumber,
          'role': role.name,
        },
      );
          debugPrint('[Auth] SignUp successful, user ID: ${response.user?.id}');
          break; // Success, exit retry loop
        } on AuthApiException catch (e) {
          lastError = e;
          debugPrint('[Auth] AuthApiException: ${e.message}');
          debugPrint('[Auth] Status code: ${e.statusCode}');
          
          // Don't retry on auth errors (email already exists, etc.)
          break;
        } catch (e) {
          lastError = e is Exception ? e : Exception(e.toString());
          debugPrint('[Auth] SignUp error: $e');
          
          // Check if it's a network/retryable error
          final errorStr = e.toString().toLowerCase();
          final isNetworkError = errorStr.contains('failed to fetch') || 
                                 errorStr.contains('network') || 
                                 errorStr.contains('retryable') ||
                                 errorStr.contains('connection') ||
                                 errorStr.contains('timeout');
          
          if (isNetworkError && retries > 1) {
            retries--;
            debugPrint('[Auth] Retry signup attempt, $retries remaining...');
            await Future.delayed(Duration(seconds: 4 - retries)); // Progressive delay
          } else {
            break; // Non-retryable error or last retry failed
          }
        }
      }
      
      if (response == null && lastError != null) {
        // Provide user-friendly error messages
        String userMessage;
        
        if (lastError is AuthApiException) {
          final e = lastError;
          final msg = e.message.toLowerCase();
          
          if (msg.contains('user already registered') || 
              msg.contains('email already') ||
              msg.contains('already registered')) {
            userMessage = 'Cet email est déjà utilisé. Connectez-vous ou utilisez un autre email.';
          } else if (msg.contains('password') && msg.contains('weak')) {
            userMessage = 'Le mot de passe est trop faible. Utilisez au moins 6 caractères avec des lettres et chiffres.';
          } else if (msg.contains('invalid email')) {
            userMessage = 'Format d\'email invalide.';
          } else {
            userMessage = 'Erreur lors de l\'inscription: ${e.message}';
          }
        } else {
          final errorStr = lastError.toString().toLowerCase();
          if (errorStr.contains('failed to fetch') || 
              errorStr.contains('network') || 
              errorStr.contains('connection')) {
            userMessage = 'Erreur de connexion. Vérifiez votre connexion internet et réessayez.';
          } else {
            userMessage = 'Erreur lors de l\'inscription. Veuillez réessayer.';
          }
        }
        
        debugPrint('[Auth] Registration failed: $userMessage');
        state = state.copyWith(isLoading: false, error: userMessage);
        return;
      }
      // Generate a username and persist in user metadata and optional profiles table.
      final u = response?.user ?? _supabase.auth.currentUser;
      if (u != null) {
        final username = _generateUsername(firstName, lastName, email);
        try {
          await _supabase.auth.updateUser(UserAttributes(data: {
            'username': username,
            'firstName': firstName,
            'lastName': lastName,
            'phoneNumber': phoneNumber,
            'role': role.name,
          }));
        } catch (e) {
          debugPrint('Update user metadata failed: $e');
        }
        // Try to upsert into profiles table if it exists
        try {
          debugPrint('[Auth] Upserting profile for user: ${u.id}');
          await _supabase.from('profiles').upsert({
            'id': u.id,
            'email': email,
            'username': username,
            'first_name': firstName,
            'last_name': lastName,
            'phone_number': phoneNumber,
            'role': role.name,
            'avatar_url': null,
          }, onConflict: 'id');
          debugPrint('[Auth] Profile upserted successfully');
        } catch (e, st) {
          debugPrint('[Auth] Profile upsert failed: $e');
          debugPrint('[Auth] Stack: $st');
          // Don't fail registration if profile upsert fails
          // The trigger should create it automatically
        }
        // Fire welcome email via Edge Function (best-effort)
        try {
          await _supabase.functions.invoke('send_welcome_email', body: {
            'email': email,
            'firstName': firstName,
          });
        } catch (e) {
          debugPrint('send_welcome_email invoke failed: $e');
        }
        final meta = u.userMetadata ?? {};
        state = state.copyWith(
          user: User(
            id: u.id,
            email: u.email ?? email,
            firstName: (meta['firstName'] ?? meta['first_name'] ?? firstName).toString(),
            lastName: (meta['lastName'] ?? meta['last_name'] ?? lastName).toString(),
            phoneNumber: (meta['phoneNumber'] ?? meta['phone_number'] ?? phoneNumber).toString(),
            role: _roleFrom(meta['role'] ?? role.name),
            profileImageUrl: meta['avatar_url']?.toString(),
          ),
          isAuthenticated: true,
          isLoading: false,
        );
      } else {
        // Email confirmation may be required - Supabase sends confirmation email automatically
        // User should check their email and confirm before logging in
        state = state.copyWith(
          isLoading: false,
          error: 'Un email de confirmation a été envoyé. Veuillez vérifier votre boîte de réception et confirmer votre email avant de vous connecter.',
        );
      }
    } on AuthApiException catch (e) {
      debugPrint('SignUp error: ${e.message}');
      state = state.copyWith(isLoading: false, error: e.message);
    } catch (e) {
      debugPrint('Register error: $e');
      state = state.copyWith(isLoading: false, error: 'Registration error');
    }
  }

  Future<void> logout() async {
    try {
      await _supabase.auth.signOut();
    } catch (e) {
      debugPrint('Logout error: $e');
    }
    state = AuthState();
  }

  Future<void> verifyOTP(String code) async {
    // Optional: Hook up Supabase OTP verification if you use Email OTP
    state = state.copyWith(isLoading: false);
  }

  /// Resend email confirmation
  Future<void> resendConfirmationEmail(String email) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      await _supabase.auth.resend(
        type: OtpType.signup,
        email: email,
      );
      state = state.copyWith(
        isLoading: false,
      );
      // Success - UI should show success message
    } catch (e) {
      debugPrint('Resend confirmation email error: $e');
      state = state.copyWith(
        isLoading: false,
        error: 'Erreur lors de l\'envoi de l\'email de confirmation. Veuillez réessayer.',
      );
    }
  }

  /// Check if current user email is confirmed
  bool get isEmailConfirmed {
    final user = _supabase.auth.currentUser;
    return user?.emailConfirmedAt != null;
  }

  Future<void> signInWithGoogle() async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      String redirect;
      if (kIsWeb) {
        // For web, use the current origin (localhost or production domain)
        redirect = Uri.base.origin;
        // If running on localhost, ensure we use the correct port
        if (redirect.contains('localhost') || redirect.contains('127.0.0.1')) {
          // Keep the current origin as-is for localhost
        }
      } else {
        redirect = 'koogwe://login-callback';
      }
      debugPrint('Starting Google OAuth. redirectTo=$redirect');
      await _supabase.auth.signInWithOAuth(
        OAuthProvider.google,
        // On web, provide an explicit origin to prevent blocked redirects when the
        // Supabase project has strict allowed URLs. On mobile, use the app scheme.
        redirectTo: redirect,
        queryParams: {
          // Better refresh behavior on some devices/browsers
          'access_type': 'offline',
          'prompt': 'consent',
        },
      );
      // onAuthStateChange will update session; reflect in state now
      final u = _supabase.auth.currentUser;
      if (u != null) {
        final meta = u.userMetadata ?? {};
        state = state.copyWith(
          user: User(
            id: u.id,
            email: u.email ?? '',
            firstName: (meta['given_name'] ?? meta['firstName'] ?? '').toString(),
            lastName: (meta['family_name'] ?? meta['lastName'] ?? '').toString(),
            phoneNumber: meta['phoneNumber']?.toString(),
            role: _roleFrom(meta['role']),
            profileImageUrl: (meta['picture'] ?? meta['avatar_url'])?.toString(),
          ),
          isAuthenticated: true,
          isLoading: false,
        );
      } else {
        state = state.copyWith(isLoading: false);
      }
    } on AuthApiException catch (e) {
      debugPrint('Google OAuth error: ${e.message}');
      final msg = e.message;
      if (msg.toLowerCase().contains('unsupported provider') || msg.toLowerCase().contains('provider is not enabled')) {
        state = state.copyWith(isLoading: false, error: 'google_provider_disabled');
      } else {
        state = state.copyWith(isLoading: false, error: msg);
      }
    } catch (e) {
      debugPrint('Google SignIn error: $e');
      state = state.copyWith(isLoading: false, error: 'Google Sign-In failed');
    }
  }

  String _generateUsername(String firstName, String lastName, String email) {
    final base = (firstName + lastName)
        .toLowerCase()
        .replaceAll(RegExp(r'[^a-z0-9]'), '');
    final handle = email.split('@').first.replaceAll(RegExp(r'[^a-z0-9]'), '');
    final suffix = DateTime.now().millisecondsSinceEpoch.toString().substring(8);
    final candidate = (base.isNotEmpty ? base : handle);
    return '${candidate}_$suffix';
  }
}

final authProvider = NotifierProvider<AuthNotifier, AuthState>(AuthNotifier.new);
