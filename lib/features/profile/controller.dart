import 'dart:io';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:renva0/core/style/repo.dart';
import 'package:renva0/features/profile/edit_profile/index.dart';
import 'package:renva0/gen/assets.gen.dart';

import '../../../core/config/app_builder.dart';
import '../../../core/localization/strings.dart';
import '../../../core/services/rest_api/rest_api.dart';
import '../../../core/widgets/modern_toast.dart';
import '../../core/routes/routes.dart';
import '../../core/services/state_management/obs.dart';
import '../../core/services/state_management/widgets/obs_widget.dart';
import '../main/controller.dart';
import 'models/user_model.dart';

class ProfileController extends GetxController with GetSingleTickerProviderStateMixin {
  final ObsVar<User?> user = ObsVar<User?>(null);
  final ObsVar<String> profileImagePath = ObsVar<String>('');
  final ObsVar<bool> appNotificationsEnabled = ObsVar<bool>(true);
  final ObsVar<bool> isDeletingAccount = ObsVar<bool>(false);
  final ObsVar<bool> isSwitchingMode = ObsVar<bool>(false);

  late AnimationController _animationController;
  late Animation<double> _slideAnimation;
  late Animation<double> _rotationAnimation;

  // Scroll controller for handling scroll animations
  final ScrollController scrollController = ScrollController();

  // App builder for logout functionality
  late AppBuilder appBuilder;

  @override
  void onInit() {
    super.onInit();
    appBuilder = Get.find<AppBuilder>();

    // Initialize animation controller
    _initializeAnimations();
    loadUserData();
    ever(appBuilder.isProviderMode, (bool isProviderMode) {
      _forceProfileRefresh();
    });
  }

  @override
  void onClose() {
    scrollController.dispose();
    _animationController.dispose();
    super.onClose();
  }

  // Initialize animations for rolling effect
  void _initializeAnimations() {
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    // Animation for sliding the icon from left to right
    _slideAnimation = Tween<double>(
      begin: 0.0, // Start position (left side)
      end: 1.0, // End position (right side)
    ).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeInOut, // Smooth easing curve
      ),
    );

    // Animation for rotating the icon (rolling effect)
    _rotationAnimation = Tween<double>(
      begin: 0.0, // Start rotation
      end: 2 * 3.14159, // Full rotation (2π radians = 360 degrees)
    ).animate(CurvedAnimation(parent: _animationController, curve: Curves.easeInOut));

    // Listen to animation status
    _animationController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        // Animation completed, reset and update mode
        _finalizeModeSwitch();
      }
    });
  }

  //  Switch provider mode with rolling animation
  Future<void> switchProviderMode() async {
    // Prevent multiple taps
    if (isSwitchingMode.value == true) return;

    final isProvider = appBuilder.isProvider.value;

    if (!isProvider) {
      PopUpToast.show('User is not a provider');
      return;
    }

    //
    isSwitchingMode.value = true;

    try {
      // Start the rolling animation
      await _animationController.forward();
    } catch (e) {
      print(' Error during mode switch animation: $e');
      PopUpToast.show('Failed to switch mode. Please try again.');
      _resetAnimation();
    }
  }

  void _finalizeModeSwitch() async {
    try {
      final currentMode = appBuilder.isProviderMode.value;
      final newMode = !currentMode;

      // Update app state
      appBuilder.setProviderMode(newMode);

      // Just reset page index
      try {
        final mainController = Get.find<MainPageController>();
        mainController.handleModeSwitch(newMode);
      } catch (e) {
        print(' MainPageController not found: $e');
      }

      // Force profile widgets to refresh
      _forceProfileRefresh();

      // Show success message
      final modeText = newMode ? "Provider" : "User";
      PopUpToast.show('Switched to $modeText mode');
    } catch (e) {
      PopUpToast.show('Failed to switch mode. Please try again.');
    } finally {
      _resetAnimation();
    }
  }

  //  Reset animation to initial state
  void _resetAnimation() {
    _animationController.reset();
    isSwitchingMode.value = false;
  }

  //  Get animation values for ui
  AnimationController get animationController => _animationController;
  Animation<double> get slideAnimation => _slideAnimation;
  Animation<double> get rotationAnimation => _rotationAnimation;

  // Load user data with proper error handling
  Future<void> loadUserData() async {
    try {
      ResponseModel response = await APIService.instance.request(
        Request(
          endPoint: EndPoints.getProfile,
          method: RequestMethod.Get,
          fromJson: (json) => json,
        ),
      );

      if (response.success && response.data != null) {
        if (response.data is Map<String, dynamic>) {
          final userData = response.data as Map<String, dynamic>;

          user.value = User.fromJson(userData);

          _updateProviderState(userData);
        } else {
          throw Exception('Invalid response format');
        }
      } else {
        throw Exception('API returned error: ${response.message}');
      }
    } catch (e) {
      user.error = e.toString();
      PopUpToast.show(tr(LocaleKeys.errors_failed_to_load_profile));
    }
  }

  void _updateProviderState(Map<String, dynamic> userData) {
    // Check if user has provider_id or provider object
    if (userData['provider_id'] != null || userData['provider'] != null) {
      print(' User IS a provider - updating AppBuilder state');

      appBuilder.setIsProvider(true);

      // Set provider status if available
      if (userData['provider'] != null) {
        final providerData = userData['provider'] as Map<String, dynamic>;
        final status = providerData['status'] ?? 'Not approved';
        appBuilder.setProviderStatus(status);

        print('   Provider ID: ${userData['provider_id']}');
        print('   Provider Name: ${providerData['name']}');
        print('   Provider Status: $status');
      } else {
        appBuilder.setProviderStatus('Not approved');
      }

      // Debug the final state
      appBuilder.debugPrintState();
    } else {
      print(' User is not a provider');
      appBuilder.setIsProvider(false);
    }
  }

  void _forceProfileRefresh() {
    // Trigger all my ObsVariableBuilder widgets to rebuild
    user.value = user.value;
    profileImagePath.value = profileImagePath.value;
    appNotificationsEnabled.value = appNotificationsEnabled.value;
  }

  //
  Future<void> refreshData() async {
    user.reset(); // remember :') This automatically sets loading state
    await loadUserData();
  }

  void toggleLanguage() async {
    try {
      //  Get current language and store it
      final currentLanguage = Get.context!.locale.languageCode;

      //  Decide what the NEW language should be
      final newLanguage = currentLanguage == 'ar' ? 'en' : 'ar';
      final newLocale = Locale(newLanguage);

      //  Update EasyLocalization
      await EasyLocalization.of(Get.context!)!.setLocale(newLocale);

      //  Update GetX
      Get.updateLocale(newLocale);

      //  Force the app to rebuild everything (this is the key!)
      Get.forceAppUpdate();

      //  Show success message ^____^
      PopUpToast.show('Language changed to ${newLanguage == 'ar' ? 'العربية' : 'English'}');
    } catch (e) {
      PopUpToast.show(tr(LocaleKeys.profile_language_failed));
    }
  }

  void changeProfilePicture() async {
    try {
      final ImageSource? source = await Get.dialog<ImageSource>(
        AlertDialog(
          title: Text(tr(LocaleKeys.dialogs_select_image_source)),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: Container(
                  padding: const EdgeInsets.all(8),
                  child: Assets.icons.essentials.photoCamera.svg(),
                ),
                title: Text(tr(LocaleKeys.dialogs_camera)),
                onTap: () => Get.back(result: ImageSource.camera),
              ),
              ListTile(
                leading: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: StyleRepo.forestGreen,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(Icons.photo_library, color: StyleRepo.grey),
                ),
                title: Text(tr(LocaleKeys.dialogs_gallery)),
                onTap: () => Get.back(result: ImageSource.gallery),
              ),
            ],
          ),
        ),
      );

      if (source != null) {
        final ImagePicker picker = ImagePicker();
        final XFile? pickedImage = await picker.pickImage(
          source: source,
          maxWidth: 1024,
          maxHeight: 1024,
          imageQuality: 85,
        );

        if (pickedImage != null) {
          final file = File(pickedImage.path);
          final exists = await file.exists();
          final size = exists ? await file.length() : 0;

          if (exists && size > 0) {
            profileImagePath.value = pickedImage.path;
            PopUpToast.show(tr(LocaleKeys.success_profile_picture_updated));
          } else {
            PopUpToast.show(tr(LocaleKeys.errors_invalid_image_file));
          }
        }
      }
    } catch (e) {
      PopUpToast.show(tr(LocaleKeys.errors_failed_to_select_image));
    }
  }

  void removeProfilePicture() {
    Get.dialog(
      AlertDialog(
        title: Text(tr(LocaleKeys.dialogs_remove_profile_picture)),
        content: Text(tr(LocaleKeys.dialogs_remove_confirmation)),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        actions: [
          TextButton(onPressed: () => Get.back(), child: Text(tr(LocaleKeys.common_cancel))),
          TextButton(
            onPressed: () {
              profileImagePath.value = '';
              Get.back();
            },
            child: Text(tr(LocaleKeys.dialogs_remove), style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  void editProfile() {
    Get.to(() => const EditProfilePage());
  }

  void myLocation() {
    Get.dialog(
      AlertDialog(
        title: Text(tr(LocaleKeys.profile_menu_my_location)),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        content: Text(tr(LocaleKeys.profile_menu_location_settings)),
        actions: [
          TextButton(onPressed: () => Get.back(), child: Text(tr(LocaleKeys.common_close))),
        ],
      ),
    );
  }

  Future<void> resetPasswordFromProfile() async {
    final userData = user.value; //  access user

    if (userData == null) {
      PopUpToast.show('User data not found. Please login again.');
      return;
    }

    // Get phone number - I  have fullPhoneNumber in my user model
    String? userPhone = userData.fullPhoneNumber;

    if (userPhone.isEmpty) {
      PopUpToast.show('Phone number not found. Please contact support.');
      return;
    }

    // Show confirmation dialog
    bool? confirm = await Get.dialog<bool>(
      AlertDialog(
        title: Text('Reset Password'),
        content: Text('Do you want to reset your password?'),
        actions: [
          TextButton(onPressed: () => Get.back(result: false), child: Text('Cancel')),
          ElevatedButton(onPressed: () => Get.back(result: true), child: Text('Continue')),
        ],
      ),
    );

    if (confirm != true) return;

    try {
      // Parse phone number (assuming format is "+963911111111 which is my account :D ")
      String cleanPhone = '';
      String dialCode = '';

      if (userPhone.startsWith('+963')) {
        dialCode = '963';
        cleanPhone = userPhone.replaceFirst('+963', ''); // Remove +963 to get clean number
      } else {
        // Fallback parsing
        dialCode = '963';
        cleanPhone = userPhone.replaceAll('+', '').replaceAll(' ', '');
        if (cleanPhone.startsWith('963')) {
          cleanPhone = cleanPhone.replaceFirst('963', '');
        }
      }

      Map<String, dynamic> jsonData = {'phone': cleanPhone, 'dial_country_code': dialCode};

      ResponseModel response = await APIService.instance.request(
        Request(
          endPoint: EndPoints.forgetPassword,
          method: RequestMethod.Post,
          body: jsonData,
          copyHeader: {'Accept': 'application/json', 'Content-Type': 'application/json'},
        ),
      );

      if (response.success) {
        PopUpToast.show('Verification code sent to your phone');

        // Navigate to verification with forgot password context
        Get.toNamed(
          Pages.verify.value,
          arguments: {
            'phoneNumber': userPhone,
            'cleanPhone': cleanPhone,
            'dialCode': dialCode,
            'fromForgotPassword': true,
          },
        );
      } else {
        PopUpToast.show('Failed to send verification code. Please try again.');
      }
    } catch (e) {
      print(' Profile reset password error: $e');
      PopUpToast.show('Network error. Please check your connection and try again.');
    }
  }

  void toggleAppNotifications(bool value) {
    appNotificationsEnabled.value = value;
    String message =
        value
            ? tr(LocaleKeys.success_notifications_enabled)
            : tr(LocaleKeys.success_notifications_disabled);
    PopUpToast.show(message);
  }

  void privacyPolicy() {
    Get.dialog(
      AlertDialog(
        title: Text(tr(LocaleKeys.profile_menu_privacy_policy)),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        content: Text(tr(LocaleKeys.profile_menu_privacy_policy_content)),
        actions: [
          TextButton(onPressed: () => Get.back(), child: Text(tr(LocaleKeys.common_close))),
        ],
      ),
    );
  }

  void contactUs() {
    Get.dialog(
      AlertDialog(
        title: Text(tr(LocaleKeys.profile_menu_contact_us)),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        content: Text(tr(LocaleKeys.profile_menu_contact_info)),
        actions: [
          TextButton(onPressed: () => Get.back(), child: Text(tr(LocaleKeys.common_close))),
        ],
      ),
    );
  }

  void faq() {
    Get.dialog(
      AlertDialog(
        title: Text(tr(LocaleKeys.profile_menu_faq)),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        content: Text(tr(LocaleKeys.profile_menu_faq_content)),
        actions: [
          TextButton(onPressed: () => Get.back(), child: Text(tr(LocaleKeys.common_close))),
        ],
      ),
    );
  }

  void logout() {
    Get.dialog(
      AlertDialog(
        title: Text(tr(LocaleKeys.dialogs_confirm_logout)),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        content: Text(tr(LocaleKeys.dialogs_confirm_logout)),
        actions: [
          TextButton(onPressed: () => Get.back(), child: Text(tr(LocaleKeys.common_cancel))),
          TextButton(
            onPressed: () {
              Get.back(); // Close dialog
              _performLogout();
            },
            child: Text(tr(LocaleKeys.profile_menu_logout), style: TextStyle(color: StyleRepo.red)),
          ),
        ],
      ),
    );
  }

  Future<void> _performLogout() async {
    try {
      // Try to make API logout call first
      await _makeLogoutAPICall();

      // Clear local data
      profileImagePath.value = '';
      await appBuilder.logout();

      PopUpToast.show(tr(LocaleKeys.success_logged_out));
    } catch (e) {
      // Even if API fails, still perform local logout for security
      try {
        profileImagePath.value = '';
        await appBuilder.logout();
        PopUpToast.show('Logged out locally due to network error');
      } catch (localError) {
        PopUpToast.show(tr(LocaleKeys.errors_something_went_wrong));
      }
    }
  }

  // Make logout API call
  Future<void> _makeLogoutAPICall() async {
    try {
      if (appBuilder.token == null || appBuilder.token!.isEmpty) {
        return;
      }

      ResponseModel response = await APIService.instance.request(
        Request(
          endPoint: EndPoints.logout,
          method: RequestMethod.Get,
          copyHeader: {'Accept': 'application/json', 'Content-Type': 'application/json'},
        ),
      );

      if (response.success) {
        print('Server logout successful');
      } else {
        print('Server logout failed: ${response.message}');
      }
    } catch (e) {
      print('Server logout error: $e');
      //we  did not use rethrow  here -  to continue with local logout (do not forget it =>  to my future self with short memory :D  )
    }
  }

  // Delete account functionality
  void deleteAccount() {
    Get.dialog(
      AlertDialog(
        title: Text(tr(LocaleKeys.dialogs_delete_account)),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        content: Text(tr(LocaleKeys.dialogs_delete_account_warning)),
        actions: [
          TextButton(onPressed: () => Get.back(), child: Text(tr(LocaleKeys.common_cancel))),
          TextButton(
            onPressed: () {
              Get.back();
              _confirmDeleteAccount();
            },
            child: Text(tr(LocaleKeys.common_delete), style: TextStyle(color: StyleRepo.red)),
          ),
        ],
      ),
    );
  }

  void _confirmDeleteAccount() {
    Get.dialog(
      AlertDialog(
        title: Text(tr(LocaleKeys.dialogs_final_confirmation)),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        content: Text(tr(LocaleKeys.dialogs_delete_account_final)),
        actions: [
          TextButton(onPressed: () => Get.back(), child: Text(tr(LocaleKeys.common_cancel))),

          _buildDeleteButton(),
        ],
      ),
    );
  }

  Widget _buildDeleteButton() {
    return ObsVariableBuilder<bool>(
      obs: isDeletingAccount,
      builder: (context, isDeleting) {
        return TextButton(
          onPressed:
              isDeleting
                  ? null
                  : () {
                    Get.back(); // Close dialog
                    _performDeleteAccount();
                  },
          child:
              isDeleting
                  ? Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(StyleRepo.red),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text('Deleting...', style: TextStyle(color: StyleRepo.red)),
                    ],
                  )
                  : Text(
                    tr(LocaleKeys.dialogs_delete_forever),
                    style: TextStyle(color: StyleRepo.red, fontWeight: FontWeight.bold),
                  ),
        );
      },
    );
  }

  Future<void> _performDeleteAccount() async {
    if (isDeletingAccount.value == true) return;

    isDeletingAccount.value = true;

    try {
      await _makeDeleteAccountAPICall();

      // Only clear local data AFTER successful API deletion
      profileImagePath.value = '';
      await appBuilder.logout();

      PopUpToast.show(tr(LocaleKeys.success_account_deleted));
    } catch (e) {
      PopUpToast.show('Failed to delete account: ${e.toString()}');
    } finally {
      isDeletingAccount.value = false;
    }
  }

  Future<void> _makeDeleteAccountAPICall() async {
    if (appBuilder.token == null || appBuilder.token!.isEmpty) {
      throw Exception(tr(LocaleKeys.errors_no_auth_token));
    }

    if (user.value?.id == null) {
      throw Exception('User ID not found');
    }

    final userId = user.value!.id;

    ResponseModel response = await APIService.instance.request(
      Request(
        endPoint: EndPoints.deleteProfile(userId),
        method: RequestMethod.Delete,
        copyHeader: {'Accept': 'application/json', 'Content-Type': 'application/json'},
      ),
    );

    if (response.success) {
      return;
    } else {
      String errorMessage =
          response.message.isNotEmpty ? response.message : tr(LocaleKeys.errors_unknown_error);

      if (response.data != null) {
        try {
          if (response.data is Map<String, dynamic>) {
            final errorData = response.data as Map<String, dynamic>;
            if (errorData['message'] != null) {
              errorMessage = errorData['message'].toString();
            } else if (errorData['error'] != null) {
              errorMessage = errorData['error'].toString();
            }
          } else if (response.data is List && (response.data as List).isNotEmpty) {
            List errors = response.data as List;
            errorMessage = errors.join('\n');
          }
        } catch (e) {
          // Keep default error message
        }
      }

      throw Exception(errorMessage);
    }
  }

  // Loyalty points action
  void viewLoyaltyPoints() {
    Get.dialog(
      AlertDialog(
        title: Text(tr(LocaleKeys.profile_menu_loyalty_points)),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Assets.icons.essentials.star.svg(color: StyleRepo.amber, width: 48, height: 48),
            const SizedBox(height: 16),

            ObsVariableBuilder<User?>(
              obs: user,
              builder: (context, userData) {
                return Text(
                  tr(
                    LocaleKeys.profile_menu_you_have_points,
                  ).replaceAll('{points}', '${userData?.points ?? 0}'),
                  style: const TextStyle(fontSize: 16),
                );
              },
              loader: (context) => CircularProgressIndicator(),
              errorBuilder: (context, error) => Text('Error loading points'),
            ),
            const SizedBox(height: 8),
            Text(
              tr(LocaleKeys.profile_menu_earn_more_points),
              style: TextStyle(fontSize: 14, color: Colors.grey),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Get.back(), child: Text(tr(LocaleKeys.common_close))),
        ],
      ),
    );
  }

  // Payment action
  void managePayment() {
    Get.dialog(
      AlertDialog(
        title: Text(tr(LocaleKeys.profile_menu_payment_methods)),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Assets.icons.services.coins.svg(color: StyleRepo.deepBlue, width: 48, height: 48),
            const SizedBox(height: 16),
            Text(tr(LocaleKeys.profile_menu_payment_management), style: TextStyle(fontSize: 16)),
            const SizedBox(height: 8),

            ObsVariableBuilder<User?>(
              obs: user,
              builder: (context, userData) {
                return Text(
                  tr(LocaleKeys.profile_menu_current_balance),
                  style: TextStyle(fontSize: 14, color: Colors.grey),
                );
              },
              loader: (context) => CircularProgressIndicator(),
              errorBuilder: (context, error) => Text('Error loading balance'),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Get.back(), child: Text(tr(LocaleKeys.common_close))),
        ],
      ),
    );
  }

  bool get hasProfileImage => profileImagePath.value?.isNotEmpty == true;
  bool get hasProfileImageUrl => user.value?.profileImageUrl.isNotEmpty ?? false;
  int get pointsCount => user.value?.points ?? 0;

  String get displayName {
    final appBuilder = Get.find<AppBuilder>();
    final isProviderMode = appBuilder.isProviderMode.value;
    final userData = user.value;

    if (userData == null) return 'User';

    if (isProviderMode && userData.isProvider) {
      // Show provider name: "bayan"
      final providerData = userData.provider;
      if (providerData != null && providerData['name'] != null) {
        return providerData['name'];
      }
    }

    // Show user name: "bayaa aa"
    return userData.fullName;
  }

  String get displayPhone {
    final appBuilder = Get.find<AppBuilder>();
    final isProviderMode = appBuilder.isProviderMode.value;
    final userData = user.value;

    if (userData == null) return 'No phone';

    if (isProviderMode && userData.isProvider) {
      // Show provider phone: "+963 91234567"
      final providerData = userData.provider;
      if (providerData != null) {
        final dialCode = providerData['dial_country_code']?.toString() ?? '';
        final phone = providerData['phone']?.toString() ?? '';
        if (dialCode.isNotEmpty && phone.isNotEmpty) {
          return '+$dialCode $phone';
        }
      }
    }

    // Show user phone: "+963 911111111"
    return userData.fullPhoneNumber;
  }

  String get profileImageUrl {
    final appBuilder = Get.find<AppBuilder>();
    final isProviderMode = appBuilder.isProviderMode.value;
    final userData = user.value;

    if (userData == null) return '';

    if (isProviderMode && userData.isProvider) {
      // Show provider avatar: "https://renva.nu/storage/99/avatar.jpg"
      final providerData = userData.provider;
      if (providerData != null &&
          providerData['avatar'] != null &&
          providerData['avatar']['original_url'] != null) {
        return providerData['avatar']['original_url'];
      }
    }

    // Show user avatar: "https://renva.nu/empty_profile.png"
    return userData.profileImageUrl;
  }

  int get ordersCount {
    final appBuilder = Get.find<AppBuilder>();
    final isProviderMode = appBuilder.isProviderMode.value;
    final userData = user.value;

    if (userData == null) return 0;

    if (isProviderMode && userData.isProvider) {
      // Show provider orders: pending + completed
      final providerData = userData.provider;
      if (providerData != null) {
        int pending = providerData['pending_orders_cnt'] ?? 0;
        int completed = providerData['completed_orders_cnt'] ?? 0;
        return pending + completed;
      }
    }

    // Show user orders: orders_cnt = 0
    return userData.ordersCount;
  }

  double get userRate {
    final appBuilder = Get.find<AppBuilder>();
    final isProviderMode = appBuilder.isProviderMode.value;
    final userData = user.value;

    if (userData == null) return 0.0;

    if (isProviderMode && userData.isProvider) {
      // Show provider rate: rate = 0
      final providerData = userData.provider;
      if (providerData != null && providerData['rate'] != null) {
        return (providerData['rate'] as num).toDouble();
      }
    }

    // Show user rate: rate = 0
    return userData.rate?.toDouble() ?? 0.0;
  }

  int get balance {
    final appBuilder = Get.find<AppBuilder>();
    final isProviderMode = appBuilder.isProviderMode.value;
    final userData = user.value;

    if (userData == null) return 0;

    if (isProviderMode && userData.isProvider) {
      // Show provider balance: balance = 1000000
      final providerData = userData.provider;
      if (providerData != null && providerData['balance'] != null) {
        return providerData['balance'];
      }
    }

    // Show user balance: balance = 1000000
    return userData.balance;
  }

  //  Provider status getter
  String get providerStatus {
    final userData = user.value;
    if (userData?.isProvider == true) {
      final providerData = userData!.provider;
      if (providerData != null && providerData['status'] != null) {
        return providerData['status']; // "Not approved"
      }
    }
    return 'Not a provider';
  }

  //  Get the image to display (local first, then mode-specific API)
  String get displayImageUrl {
    if (hasProfileImage) return profileImagePath.value!;
    if (profileImageUrl.isNotEmpty) return profileImageUrl;
    return '';
  }
}
