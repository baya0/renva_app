// ignore_for_file: avoid_print

import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:renva0/core/config/role.dart';

import '../routes/routes.dart';
import '../services/rest_api/rest_api.dart';

class AppBuilder extends GetxService {
  final box = GetStorage("app");
  late Role role;
  String? token;
  bool? isVerified;
  bool? isProfileCompleted;

  //  Provider mode state
  final RxBool isProviderMode = false.obs;
  final RxBool isProvider = false.obs;
  final RxString providerStatus = ''.obs;

  // Add navigation state to prevent conflicts
  bool _isNavigating = false;

  Future<void> loadData() async {
    await box.initStorage;

    // Load from storage
    role = box.hasData("role") ? Role.fromString(box.read("role")) : Role.unregistered;
    token = box.read("token");
    isVerified = box.read("isVerified") ?? false;
    isProfileCompleted = box.read("isProfileCompleted") ?? false;

    //  Load provider state
    isProviderMode.value = box.read("isProviderMode") ?? false;
    isProvider.value = box.read("isProvider") ?? false;
    providerStatus.value = box.read("providerStatus") ?? '';

    print(' AppBuilder loaded from storage:');
    print('   Role: $role');
    print('   Token: ${token != null ? "yes" : "no"}');
    print('   Verified: $isVerified');
    print('   Complete: $isProfileCompleted');
    print('   Provider Mode: ${isProviderMode.value}');
    print('   Is Provider: ${isProvider.value}');
    print('   Provider Status: ${providerStatus.value}');
  }

  Future<void> init() async {
    await loadData();

    Get.put(APIService(token: token));

    // Centralized session-expiry handling: any request that comes back 401
    // (expired/invalid token) drops the user cleanly back to login instead of
    // leaving them stuck in a broken "logged-in" state where every call fails.
    APIService.onUnauthorized = _handleUnauthorized;

    await _navigateToInitialScreen();
  }

  bool _handlingUnauthorized = false;

  void _handleUnauthorized() {
    // Only react if there is actually a session to invalidate, and never
    // re-enter (a burst of 401s must trigger exactly one logout).
    if (_handlingUnauthorized) return;
    if (token == null || token!.isEmpty) return;

    _handlingUnauthorized = true;
    print(' Session expired (401) → logging out');
    logout().whenComplete(() => _handlingUnauthorized = false);
  }

  // Navigation logic
  Future<void> _navigateToInitialScreen() async {
    if (_isNavigating) {
      print(' Navigation already in progress, skipping...');
      return;
    }

    _isNavigating = true;

    try {
      String targetRoute = _determineRoute();
      print('Target route: $targetRoute');

      await Future.delayed(Duration(milliseconds: 100));
      Get.offAllNamed(targetRoute);
    } finally {
      _isNavigating = false;
    }
  }

  String _determineRoute() {
    // Guests and authenticated users both land on Home; the Home/Main layer
    // decides user-vs-provider presentation from isProviderMode. Only a missing
    // token forces login.
    if (role == Role.guest) return Pages.home.value;
    if (token != null && token!.isNotEmpty) return Pages.home.value;
    return Pages.login.value;
  }

  // Safe refresh navigation
  Future<void> refreshNavigation() async {
    print(' Refreshing navigation...');
    await _navigateToInitialScreen();
  }

  // Update user state from API response
  void updateFromAPIResponse(Map<String, dynamic> apiResponse) {
    print(' Updating app state from API response...');
    print(' API Response: $apiResponse');

    // Update token if present
    if (apiResponse.containsKey('token') && apiResponse['token'] != null) {
      String newToken = apiResponse['token'].toString();
      setToken(newToken);
      APIService.instance.setToken(newToken);
    }

    // Update verification status
    if (apiResponse.containsKey('phone_verified_at')) {
      bool verified = apiResponse['phone_verified_at'] != null;
      setVerified(verified);
    }

    // Update profile completion
    if (apiResponse.containsKey('is_completed')) {
      bool completed = (apiResponse['is_completed'] ?? 0) == 1;
      setProfileCompleted(completed);
    }

    //  Update provider state from API response
    _updateProviderStateFromAPI(apiResponse);

    // Set role to user if we have a token
    if (token != null && token!.isNotEmpty) {
      setRole(Role.user);
    }

    print(' App state updated from API:');
    debugPrintState();
  }

  //  Update provider state from API
  void _updateProviderStateFromAPI(Map<String, dynamic> apiResponse) {
    // Check if response contains provider data
    if (apiResponse.containsKey('provider') && apiResponse['provider'] != null) {
      final providerData = apiResponse['provider'] as Map<String, dynamic>;

      setIsProvider(true);
      setProviderStatus(providerData['status'] ?? 'Not approved');

      print(' Provider data found in API response:');
      print('   Status: ${providerData['status']}');
      print('   Name: ${providerData['name']}');
    } else if (apiResponse.containsKey('provider_id') && apiResponse['provider_id'] != null) {
      // User has a provider_id but no provider object means they're a provider
      setIsProvider(true);
      setProviderStatus('Not approved'); // Default status

      print(' Provider ID found: ${apiResponse['provider_id']}');
    }
  }

  //  Handle successful provider registration
  void handleProviderRegistrationSuccess(Map<String, dynamic> providerData) {
    print(' Provider registration successful!');
    print(' Provider data: $providerData');

    setIsProvider(true);
    setProviderStatus(providerData['status'] ?? 'Not approved');

    // Optionally switch to provider mode immediately
    setProviderMode(true);

    print(' Provider state updated after registration');
    debugPrintState();
  }

  // SAFE SETTERS with state validation
  void setRole(Role newRole) {
    if (role != newRole) {
      role = newRole;
      box.write("role", newRole.name);
      print(' Role updated: $role');
    }
  }

  void setToken(String? newToken) {
    token = newToken;
    if (newToken != null) {
      box.write("token", newToken);
      print(' Token set: ');
    } else {
      box.remove("token");
      print(' Token cleared: ');
    }

    // Single source of truth: keep the API layer's Authorization header in
    // sync automatically so callers can never forget to update both places
    // (which is how the stored token and the request header used to drift).
    if (Get.isRegistered<APIService>()) {
      APIService.instance.setToken(newToken);
    }
  }

  void setVerified(bool verified) {
    if (isVerified != verified) {
      isVerified = verified;
      box.write("isVerified", verified);
      print(' Verified status updated: $verified');
    }
  }

  void setProfileCompleted(bool completed) {
    if (isProfileCompleted != completed) {
      isProfileCompleted = completed;
      box.write("isProfileCompleted", completed);
      print(' Profile completion updated: $completed');
    }
  }

  // Provider state setters
  void setProviderMode(bool mode) {
    if (isProviderMode.value != mode) {
      isProviderMode.value = mode;
      box.write("isProviderMode", mode);
      print(' Provider mode updated: $mode');
    }
  }

  void setIsProvider(bool provider) {
    if (isProvider.value != provider) {
      isProvider.value = provider;
      box.write("isProvider", provider);
      print(' Is provider updated: $provider');
    }
  }

  void setProviderStatus(String status) {
    if (providerStatus.value != status) {
      providerStatus.value = status;
      box.write("providerStatus", status);
      print(' Provider status updated: $status');
    }
  }

  void toggleProviderMode() {
    if (isProvider.value) {
      setProviderMode(!isProviderMode.value);
      print(' Toggled to ${isProviderMode.value ? "Provider" : "User"} mode');
    } else {
      print(' Cannot switch to provider mode - user is not a provider');
    }
  }

  // Logout method - fully reset per-user state.
  //
  // IMPORTANT: all of these flags are stored globally on the device, not per
  // account. If we preserve them (as the old code did) and a DIFFERENT user
  // signs in on the same device, they inherit the previous user's
  // provider/verification/profile-completion state until an API reload happens
  // to overwrite it — a real data-leak between the two kinds of users this app
  // handles. They are always repopulated from the API on the next login /
  // profile load, so clearing them here is both safe and correct.
  Future<void> logout() async {
    setRole(Role.unregistered);
    setToken(null); // also clears the APIService Authorization header
    setVerified(false);
    setProfileCompleted(false);
    setProviderMode(false);
    setIsProvider(false);
    setProviderStatus('');

    print(' User logged out successfully');

    await Future.delayed(Duration(milliseconds: 100));
    Get.offAllNamed(Pages.login.value);
  }

  // Utility methods
  bool get isFullyAuthenticated {
    return role == Role.user &&
        token != null &&
        token!.isNotEmpty &&
        isVerified == true &&
        isProfileCompleted == true;
  }

  String get userStatusDescription {
    if (role == Role.guest) return "Guest user";
    if (role == Role.unregistered) return "Not registered";
    if (role == Role.new_user) return "Needs verification";
    if (role == Role.user) {
      if (isVerified != true) return "Needs phone verification";
      if (token == null || token!.isEmpty) return "Needs authentication";
      if (isProfileCompleted != true) return "Needs profile completion";

      // Add provider status
      if (isProvider.value) {
        String mode = isProviderMode.value ? "Provider" : "User";
        return "Fully authenticated ($mode mode) - ${providerStatus.value}";
      }

      return "Fully authenticated";
    }
    return "Unknown status";
  }

  // Current mode description
  String get currentModeDescription {
    if (!isProvider.value) return "User";
    if (isProviderMode.value) return "Provider (${providerStatus.value})";
    return "User (Provider available)";
  }

  // Debug helper
  void debugPrintState() {
    print(' === CURRENT APP STATE ===');
    print('   Role: $role');
    print('   Token: ${token != null ? "✅" : "❌"}');
    print('   Verified: $isVerified');
    print('   Complete: $isProfileCompleted');
    print('   Is Provider: ${isProvider.value}');
    print('   Provider Mode: ${isProviderMode.value}');
    print('   Provider Status: ${providerStatus.value}');
    print('   Current Mode: $currentModeDescription');
    print('   Status: $userStatusDescription');
    print('   Fully Authenticated: $isFullyAuthenticated');
  }
}
