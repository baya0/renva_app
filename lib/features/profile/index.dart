import 'dart:io';
import 'dart:ui';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:renva0/core/constants/controllers_tags.dart';
import 'package:shimmer/shimmer.dart';

import '../../core/config/app_builder.dart';
import '../../core/localization/strings.dart';
import '../../core/services/state_management/obs.dart';
import '../../core/services/state_management/widgets/obs_widget.dart';
import '../../core/style/repo.dart';
import '../../core/widgets/image.dart';
import '../../gen/assets.gen.dart';
import 'controller.dart';
import 'models/user_model.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(ProfileController(), tag: ControllersTags.profileController);
    final theme = Theme.of(context);
    final size = MediaQuery.of(context).size;

    return Scaffold(
      body: ObsVariableBuilder<User?>(
        obs: controller.user,
        onRefresh: controller.refreshData,
        builder: (context, userData) {
          // Main content when data is loaded
          return _buildMainContent(context, controller, theme, size, userData);
        },
        loader: (context) => _buildLoadingState(),
        errorBuilder: (context, error) => _buildErrorState(controller, error),
      ),
    );
  }

  // Loading state
  Widget _buildLoadingState() {
    return Scaffold(
      body: Stack(
        children: [
          _buildDefaultBackground(),

          SafeArea(
            child: Column(
              children: [
                // Top section with profile info
                Expanded(
                  flex: 45,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // Profile picture shimmer
                        _buildSimpleShimmer(
                          child: Container(
                            width: 140,
                            height: 140,
                            decoration: BoxDecoration(
                              color: StyleRepo.softWhite,
                              shape: BoxShape.circle,
                            ),
                          ),
                        ),

                        SizedBox(height: 12),

                        // Name shimmer
                        _buildSimpleShimmer(
                          child: Container(
                            width: 120,
                            height: 20,
                            decoration: BoxDecoration(
                              color: StyleRepo.softWhite,
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                        ),

                        SizedBox(height: 8),

                        // Phone shimmer
                        _buildSimpleShimmer(
                          child: Container(
                            width: 100,
                            height: 16,
                            decoration: BoxDecoration(
                              color: StyleRepo.softWhite,
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                        ),

                        SizedBox(height: 20),

                        // Edit profile button shimmer
                        _buildSimpleShimmer(
                          child: Container(
                            width: 140,
                            height: 24,
                            decoration: BoxDecoration(
                              color: StyleRepo.softWhite,
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ),

                        SizedBox(height: 16),

                        // Stats row shimmer
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            _buildStatShimmer(),
                            Container(
                              width: 1,
                              height: 16,
                              color: StyleRepo.softWhite.withOpacity(0.3),
                            ),
                            _buildStatShimmer(),
                            Container(
                              width: 1,
                              height: 16,
                              color: StyleRepo.softWhite.withOpacity(0.3),
                            ),
                            _buildStatShimmer(),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),

                SizedBox(height: 16),

                // Bottom white section
                Expanded(
                  flex: 55,
                  child: Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: StyleRepo.softWhite,
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(30),
                        topRight: Radius.circular(30),
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: StyleRepo.grey.withOpacity(0.3),
                          blurRadius: 10,
                          offset: Offset(0, -3),
                        ),
                      ],
                    ),
                    child: Padding(
                      padding: EdgeInsets.all(24),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Handle
                          Center(
                            child: Container(
                              width: 40,
                              height: 4,
                              decoration: BoxDecoration(
                                color: StyleRepo.grey.withOpacity(0.3),
                                borderRadius: BorderRadius.circular(2),
                              ),
                            ),
                          ),

                          SizedBox(height: 20),

                          // Switch provider button shimmer
                          _buildGreyShimmer(
                            child: Container(
                              width: double.infinity,
                              height: 54,
                              decoration: BoxDecoration(
                                color: StyleRepo.grey.withOpacity(0.3),
                                borderRadius: BorderRadius.circular(25),
                              ),
                            ),
                          ),

                          SizedBox(height: 20),

                          // Two cards shimmer
                          Row(
                            children: [
                              Expanded(
                                child: _buildGreyShimmer(
                                  child: Container(
                                    height: 140,
                                    decoration: BoxDecoration(
                                      color: StyleRepo.grey.withOpacity(0.3),
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                  ),
                                ),
                              ),
                              SizedBox(width: 16),
                              Expanded(
                                child: _buildGreyShimmer(
                                  child: Container(
                                    height: 140,
                                    decoration: BoxDecoration(
                                      color: StyleRepo.grey.withOpacity(0.3),
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),

                          SizedBox(height: 30),

                          // "Account" title shimmer
                          _buildGreyShimmer(
                            child: Container(
                              width: 100,
                              height: 20,
                              decoration: BoxDecoration(
                                color: StyleRepo.grey.withOpacity(0.3),
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                          ),

                          SizedBox(height: 20),

                          // Menu items shimmer
                          Expanded(
                            child: ListView(
                              children: [
                                _buildMenuItemShimmer(),
                                _buildMenuItemShimmer(),
                                _buildMenuItemShimmer(),
                                _buildMenuItemShimmer(),
                                _buildMenuItemShimmer(),
                                _buildMenuItemShimmer(),
                                _buildMenuItemShimmer(),
                                _buildMenuItemShimmer(),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // For white shimmer on blue background
  Widget _buildSimpleShimmer({required Widget child}) {
    return Shimmer.fromColors(
      baseColor: Colors.white.withOpacity(0.3),
      highlightColor: Colors.white.withOpacity(0.6),
      child: child,
    );
  }

  // For grey shimmer on white background
  Widget _buildGreyShimmer({required Widget child}) {
    return Shimmer.fromColors(
      baseColor: Colors.grey[300]!,
      highlightColor: Colors.grey[100]!,
      child: child,
    );
  }

  // Stats shimmer (for the numbers and labels)
  Widget _buildStatShimmer() {
    return Column(
      children: [
        _buildSimpleShimmer(
          child: Container(
            width: 30,
            height: 16,
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(8)),
          ),
        ),
        SizedBox(height: 4),
        _buildSimpleShimmer(
          child: Container(
            width: 40,
            height: 12,
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(6)),
          ),
        ),
      ],
    );
  }

  // Menu item shimmer (icon + text)
  Widget _buildMenuItemShimmer() {
    return Padding(
      padding: EdgeInsets.only(bottom: 16),
      child: Row(
        children: [
          _buildGreyShimmer(
            child: Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(22),
              ),
            ),
          ),
          SizedBox(width: 16),
          _buildGreyShimmer(
            child: Container(
              width: 150,
              height: 16,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Error state
  Widget _buildErrorState(ProfileController controller, String error) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomCenter,
            colors: [StyleRepo.deepBlue, Color(0xff0048D9)],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.error_outline,
                    size: 64,
                    color: StyleRepo.softWhite.withValues(alpha: 0.7),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Failed to load profile',
                    style: TextStyle(
                      color: StyleRepo.softWhite,
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    error,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: StyleRepo.softWhite.withValues(alpha: 0.8),
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: controller.refreshData,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: StyleRepo.softWhite,
                      foregroundColor: StyleRepo.deepBlue,
                    ),
                    child: Text('Retry'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  // Main content with proper sizing
  Widget _buildMainContent(
    BuildContext context,
    ProfileController controller,
    ThemeData theme,
    Size size,
    User? userData,
  ) {
    // Calculate header height based on screen size
    final headerHeight =
        size.height < 700
            ? size.height *
                0.35 // Smaller screens
            : size.height * 0.45; // Larger screens

    return Stack(
      children: [
        _buildBlurredBackground(controller),

        // Main scrollable content
        NestedScrollView(
          headerSliverBuilder: (context, innerBoxIsScrolled) {
            return [
              // Profile header with dynamic height
              SliverToBoxAdapter(
                child: SizedBox(
                  height: headerHeight,
                  width: double.infinity,
                  child: SafeArea(child: _buildProfileHeader(controller, theme, size, userData)),
                ),
              ),
              // Space between header and white container
              SliverToBoxAdapter(child: SizedBox(height: 16)),
            ];
          },
          body: Container(
            width: double.infinity,
            decoration: const BoxDecoration(
              color: StyleRepo.softWhite,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(30),
                topRight: Radius.circular(30),
              ),
              boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 10, offset: Offset(0, -3))],
            ),
            child: CustomScrollView(
              physics: const BouncingScrollPhysics(),
              slivers: [
                // Small handle at the top
                SliverToBoxAdapter(
                  child: Center(
                    child: Padding(
                      padding: const EdgeInsets.only(top: 12, bottom: 20),
                      child: Container(
                        width: 40,
                        height: 4,
                        decoration: BoxDecoration(
                          color: Colors.grey[300],
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ),
                  ),
                ),
                SliverToBoxAdapter(child: _buildLoginBasedOnRole(controller, context)),
                // Points and Payment section
                SliverToBoxAdapter(child: _buildPointsAndPaymentSection(controller, context, size)),

                // Account section
                SliverToBoxAdapter(child: _buildAccountSection(controller, theme)),
                // Bottom padding for navigation bar
                const SliverToBoxAdapter(child: SizedBox(height: 100)),
              ],
            ),
          ),
        ),

        // Refresh button
        Positioned(
          top: 50,
          right: 20,
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(20),
            ),
            child: IconButton(
              onPressed: controller.refreshData,
              icon: Icon(Icons.refresh, color: Colors.white, size: 24),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildBlurredBackground(ProfileController controller) {
    return Positioned.fill(
      child: ObsVariableBuilder<String>(
        obs: controller.profileImagePath,
        builder: (context, imagePath) {
          // Check for local image first
          if (imagePath.isNotEmpty) {
            return ImageFiltered(
              imageFilter: ImageFilter.blur(sigmaX: 25, sigmaY: 25),
              child: Image.file(
                File(imagePath),
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return _buildDefaultBackground();
                },
              ),
            );
          }

          // Check for API image
          if (controller.hasProfileImageUrl) {
            return ImageFiltered(
              imageFilter: ImageFilter.blur(sigmaX: 25, sigmaY: 25),
              child: AppImage(
                path: controller.profileImageUrl,
                type: ImageType.CachedNetwork,
                fit: BoxFit.cover,
                errorWidget: _buildDefaultBackground(),
                loadingWidget: _buildDefaultBackground(),
              ),
            );
          }

          return _buildDefaultBackground();
        },
        loader: (context) => _buildDefaultBackground(),
        errorBuilder: (context, error) => _buildDefaultBackground(),
      ),
    );
  }

  Widget _buildDefaultBackground() {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomCenter,
          colors: [StyleRepo.deepBlue, Color(0xff0048D9)],
        ),
      ),
    );
  }

  // Profile header with flexible sizing
  Widget _buildProfileHeader(
    ProfileController controller,
    ThemeData theme,
    Size size,
    User? userData,
  ) {
    // Adjust sizes based on screen size
    final isSmallScreen = size.height < 700;
    final profileImageSize = isSmallScreen ? 100.0 : 140.0;
    final cameraIconSize = isSmallScreen ? 32.0 : 41.0;
    final titleFontSize = isSmallScreen ? 20.0 : 24.0;
    final subtitleFontSize = isSmallScreen ? 14.0 : 16.0;
    final buttonFontSize = isSmallScreen ? 14.0 : 16.0;

    return Container(
      decoration: BoxDecoration(color: Colors.transparent),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Profile Picture with dynamic sizing
            Stack(
              children: [
                Container(
                  width: profileImageSize,
                  height: profileImageSize,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(color: Colors.black.withValues(alpha: 0.3), blurRadius: 15),
                    ],
                  ),
                  child: ClipOval(child: _buildProfileImage(controller, profileImageSize)),
                ),
                Positioned(
                  bottom: 0,
                  right: 0,
                  child: GestureDetector(
                    onTap: controller.changeProfilePicture,
                    child: Container(
                      width: cameraIconSize,
                      height: cameraIconSize,
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(color: Colors.black12, blurRadius: 6, offset: Offset(0, 3)),
                        ],
                      ),
                      child: Center(
                        child: Assets.icons.essentials.photoCamera.svg(
                          width: cameraIconSize * 0.4,
                          height: cameraIconSize * 0.4,
                          colorFilter: ColorFilter.mode(StyleRepo.deepBlue, BlendMode.srcIn),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),

            SizedBox(height: isSmallScreen ? 8 : 12),

            Obx(() {
              return Text(
                controller.displayName,
                style: theme.textTheme.titleMedium?.copyWith(
                  color: StyleRepo.softWhite,
                  fontWeight: FontWeight.w700,
                  fontSize: titleFontSize,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              );
            }),

            SizedBox(height: isSmallScreen ? 4 : 8),

            Obx(() {
              return Text(
                controller.displayPhone,
                style: theme.textTheme.titleSmall?.copyWith(
                  color: StyleRepo.softWhite.withValues(alpha: 0.9),
                  fontWeight: FontWeight.w500,
                  fontSize: subtitleFontSize,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              );
            }),

            SizedBox(height: isSmallScreen ? 12 : 20),

            GestureDetector(
              onTap: controller.editProfile,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    tr(LocaleKeys.profile_edit_profile),
                    style: theme.textTheme.titleSmall?.copyWith(
                      color: StyleRepo.softWhite,
                      fontWeight: FontWeight.w600,
                      fontSize: buttonFontSize,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Assets.icons.arrows.rightCircle.svg(
                    colorFilter: ColorFilter.mode(StyleRepo.softWhite, BlendMode.srcIn),
                    width: buttonFontSize + 2,
                    height: buttonFontSize + 2,
                  ),
                ],
              ),
            ),

            SizedBox(height: isSmallScreen ? 8 : 16),

            _buildStatsRow(controller, theme, isSmallScreen, userData),
          ],
        ),
      ),
    );
  }

  //
  Widget _buildProfileImage(ProfileController controller, double imageSize) {
    return ObsVariableBuilder<String>(
      obs: controller.profileImagePath,
      builder: (context, imagePath) {
        // Local image takes priority
        if (imagePath.isNotEmpty) {
          return ClipOval(
            child: Image.file(
              File(imagePath),
              fit: BoxFit.cover,
              width: imageSize,
              height: imageSize,
              errorBuilder: (context, error, stackTrace) => _buildDefaultAvatar(imageSize),
            ),
          );
        }

        if (controller.hasProfileImageUrl) {
          return ClipOval(
            child: AppImage(
              path: controller.profileImageUrl,
              type: ImageType.CachedNetwork,
              fit: BoxFit.cover,
              width: imageSize,
              height: imageSize,
              errorWidget: _buildDefaultAvatar(imageSize),
              loadingWidget: _buildDefaultAvatar(imageSize),
            ),
          );
        }

        // Default avatar
        return _buildDefaultAvatar(imageSize);
      },
      loader: (context) => _buildDefaultAvatar(imageSize),
      errorBuilder: (context, error) => _buildDefaultAvatar(imageSize),
    );
  }

  Widget _buildDefaultAvatar(double size) {
    return Container(
      width: size * 0.6,
      height: size * 0.6,
      decoration: BoxDecoration(shape: BoxShape.circle, color: StyleRepo.softGrey),
      child: Center(
        child: Assets.images.logo.logo.svg(
          colorFilter: ColorFilter.mode(StyleRepo.softWhite, BlendMode.srcIn),
        ),
      ),
    );
  }

  Widget _buildStatsRow(
    ProfileController controller,
    ThemeData theme,
    bool isSmallScreen,
    User? userData,
  ) {
    final statFontSize = isSmallScreen ? 16.0 : 24.0;
    final labelFontSize = isSmallScreen ? 10.0 : 16.0;

    return Flexible(
      child: Container(
        constraints: BoxConstraints(maxHeight: isSmallScreen ? 50 : 60),
        child: IntrinsicHeight(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                child: _buildStatItem(
                  controller.ordersCount.toString(),
                  tr(LocaleKeys.profile_orders),
                  theme,
                  statFontSize,
                  labelFontSize,
                ),
              ),
              Container(
                width: 1,
                height: isSmallScreen ? 12 : 16,
                color: StyleRepo.darkwhite.withValues(alpha: 0.3),
              ),
              Expanded(
                child: _buildStatItem(
                  controller.pointsCount.toString(),
                  tr(LocaleKeys.profile_points),
                  theme,
                  statFontSize,
                  labelFontSize,
                ),
              ),
              Container(
                width: 1,
                height: isSmallScreen ? 12 : 16,
                color: StyleRepo.darkwhite.withValues(alpha: 0.3),
              ),
              Expanded(
                child: _buildStatItem(
                  controller.userRate.toStringAsFixed(1),
                  tr(LocaleKeys.stats_rating),
                  theme,
                  statFontSize,
                  labelFontSize,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatItem(
    String value,
    String label,
    ThemeData theme,
    double valueFontSize,
    double labelFontSize,
  ) {
    return Container(
      constraints: BoxConstraints(maxHeight: 50),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Flexible(
            child: FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(
                value,
                style: theme.textTheme.titleMedium?.copyWith(
                  color: StyleRepo.softWhite,
                  fontWeight: FontWeight.w700,
                  fontSize: valueFontSize,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ),
          SizedBox(height: 2),
          Flexible(
            child: FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(
                label,
                style: theme.textTheme.titleSmall?.copyWith(
                  color: StyleRepo.softWhite.withValues(alpha: 0.8),
                  fontWeight: FontWeight.w700,
                  fontSize: labelFontSize,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoginBasedOnRole(ProfileController controller, BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 0, 24, 20),
      child: ObsVariableBuilder<bool>(
        obs: controller.isSwitchingMode,
        builder: (context, isSwitching) {
          final appBuilder = Get.find<AppBuilder>();
          final isProvider = appBuilder.isProvider.value;
          final isProviderMode = appBuilder.isProviderMode.value;

          return GestureDetector(
            onTap: isSwitching ? null : controller.switchProviderMode,
            child: AnimatedBuilder(
              animation: controller.animationController,
              builder: (context, child) {
                final bool user = !(isProvider && isProviderMode);

                // Color before halfway
                final Color oldBg =
                    isProviderMode
                        ? StyleRepo
                            .lightdeepblue // currently provider
                        : StyleRepo.lightForestGreen; // currently user

                final Color newBg =
                    user
                        ? StyleRepo
                            .lightdeepblue // next will be provider
                        : StyleRepo.lightForestGreen; // next will be user

                final Color oldBorder = isProviderMode ? StyleRepo.deepBlue : StyleRepo.forestGreen;

                final Color newBorder = user ? StyleRepo.deepBlue : StyleRepo.forestGreen;

                // Switch after halfway
                final bool pastHalf = controller.slideAnimation.value >= 0.4;

                return Container(
                  width: double.infinity,
                  height: 54,
                  decoration: BoxDecoration(
                    color: pastHalf ? newBg : oldBg,
                    borderRadius: BorderRadius.circular(25),
                    border: Border.all(color: pastHalf ? newBorder : oldBorder, width: 1),
                  ),
                  child: Stack(
                    children: [
                      // Rolling icon
                      Positioned(
                        left: _calculateIconPosition(controller.slideAnimation.value, context),
                        top: 3.5,
                        child: Transform.rotate(
                          angle: controller.rotationAnimation.value,
                          child: SizedBox(
                            width: 47,
                            height: 47,
                            child: _getCurrentIcon(isProvider, isProviderMode),
                          ),
                        ),
                      ),

                      // Text (hidden while switching)
                      Positioned.fill(
                        child: Center(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 60),
                            child: AnimatedOpacity(
                              opacity: isSwitching ? 0.0 : 1.0,
                              duration: const Duration(milliseconds: 150),
                              child: Text(
                                isProvider && isProviderMode
                                    ? tr(LocaleKeys.profile_login_as_user)
                                    : isProvider
                                    ? tr(LocaleKeys.profile_login_as_provider)
                                    : tr(LocaleKeys.profile_login_as_user),
                                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                                  color: pastHalf ? newBorder : oldBorder,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }

  // Calculate icon position during animation
  double _calculateIconPosition(double animationValue, BuildContext context) {
    // Get the container width
    final containerWidth = MediaQuery.of(context).size.width - 48; // Minus horizontal padding

    // Icon width
    const iconWidth = 47.0;

    // Calculate the maximum travel distance
    final maxTravel = containerWidth - iconWidth - 8; // Minus some padding from the right

    // Position during animation: from 4 (left padding) to maxTravel
    return 4 + (animationValue * (maxTravel - 4));
  }

  // Get the current icon based on mode
  Widget _getCurrentIcon(bool isProvider, bool isProviderMode) {
    return (isProvider && isProviderMode
            ? Assets.icons.profile.switchUser
            : Assets.icons.profile.switchProvider)
        .svg();
  }

  Widget _buildPointsAndPaymentSection(
    ProfileController controller,
    BuildContext context,
    Size size,
  ) {
    final isSmallScreen = size.height < 700;
    final cardHeight = isSmallScreen ? 120.0 : 140.0;
    final titleFontSize = isSmallScreen ? 12.0 : 14.0;

    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 0, 24, 30),
      child: Row(
        children: [
          // Loyalty Points Card
          Expanded(
            child: GestureDetector(
              onTap: controller.viewLoyaltyPoints,
              child: Container(
                height: cardHeight,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  image: DecorationImage(
                    image: AssetImage(Assets.images.styling.loyaityPoints.path),
                    fit: BoxFit.cover,
                    alignment: Alignment.topCenter,
                  ),
                ),
                child: Column(
                  children: [
                    // Title
                    Padding(
                      padding: const EdgeInsets.only(top: 8),
                      child: Text(
                        tr(LocaleKeys.profile_loyalty_points),
                        style: Theme.of(context).textTheme.labelLarge?.copyWith(
                          fontWeight: FontWeight.w700,
                          fontSize: titleFontSize,
                          color: StyleRepo.black,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          const SizedBox(width: 16),

          // Payment Card
          Expanded(
            child: GestureDetector(
              onTap: controller.managePayment,
              child: Container(
                height: cardHeight,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  image: DecorationImage(
                    image: AssetImage(Assets.images.styling.payment.path),
                    fit: BoxFit.cover,
                    alignment: Alignment.topCenter,
                  ),
                ),
                child: Column(
                  children: [
                    // Title
                    Padding(
                      padding: const EdgeInsets.only(top: 8),
                      child: Text(
                        tr(LocaleKeys.profile_payment),
                        style: Theme.of(context).textTheme.labelLarge?.copyWith(
                          fontWeight: FontWeight.w700,
                          fontSize: titleFontSize,
                          color: StyleRepo.black,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAccountSection(ProfileController controller, ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 0, 24, 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            tr(LocaleKeys.profile_account),
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w700,
              fontSize: 20,
              color: StyleRepo.black,
            ),
          ),
          const SizedBox(height: 20),

          // Account Menu Items
          _buildMenuItem(
            assetIcon: Assets.icons.profile.location,
            title: tr(LocaleKeys.profile_menu_my_location),
            onTap: controller.myLocation,
          ),
          _buildMenuItem(
            assetIcon: Assets.icons.profile.changePassword,
            title: tr(LocaleKeys.profile_menu_change_password),
            onTap: controller.resetPasswordFromProfile,
          ),

          _buildMenuItemWithToggle(
            assetIcon: Assets.icons.profile.appNotifications,
            title: tr(LocaleKeys.profile_menu_app_notifications),
            obsValue: controller.appNotificationsEnabled,
            onChanged: controller.toggleAppNotifications,
          ),
          _buildMenuItem(
            assetIcon: Assets.icons.essentials.globe,
            title: tr(LocaleKeys.profile_menu_app_language),
            onTap: controller.toggleLanguage,
          ),
          _buildMenuItem(
            assetIcon: Assets.icons.profile.privacyPolicy,
            title: tr(LocaleKeys.profile_menu_privacy_policy),
            onTap: controller.privacyPolicy,
          ),
          _buildMenuItem(
            assetIcon: Assets.icons.profile.contactUs,
            title: tr(LocaleKeys.profile_menu_contact_us),
            onTap: controller.contactUs,
          ),
          _buildMenuItem(
            assetIcon: Assets.icons.profile.faq,
            title: tr(LocaleKeys.profile_menu_faq),
            onTap: controller.faq,
          ),
          _buildMenuItem(
            assetIcon: Assets.icons.profile.exit,
            title: tr(LocaleKeys.profile_menu_logout),
            onTap: controller.logout,
            isDestructive: true,
          ),
          _buildMenuItem(
            assetIcon: Assets.icons.profile.trash,
            title: tr(LocaleKeys.profile_menu_delete_my_account),
            onTap: controller.deleteAccount,
            isDestructive: true,
          ),
        ],
      ),
    );
  }

  Widget _buildMenuItem({
    required SvgGenImage assetIcon,
    required String title,
    required VoidCallback onTap,
    bool isDestructive = false,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 5),
          child: Row(
            children: [
              SizedBox(
                width: 44,
                height: 44,
                child: Center(
                  child: assetIcon.svg(
                    width: 22,
                    height: 22,
                    colorFilter: ColorFilter.mode(
                      isDestructive ? Colors.red : StyleRepo.grey,
                      BlendMode.srcIn,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    color: isDestructive ? Colors.red : StyleRepo.grey,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMenuItemWithToggle({
    required SvgGenImage assetIcon,
    required String title,
    required ObsVar<bool> obsValue,
    required Function(bool) onChanged,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        children: [
          SizedBox(
            width: 44,
            height: 44,
            child: Center(
              child: assetIcon.svg(
                width: 22,
                height: 22,
                colorFilter: ColorFilter.mode(StyleRepo.grey, BlendMode.srcIn),
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              title,
              style: TextStyle(color: StyleRepo.grey, fontSize: 14, fontWeight: FontWeight.w500),
            ),
          ),
          ObsVariableBuilder<bool>(
            obs: obsValue,
            builder: (context, value) {
              return Transform.scale(
                scale: 0.8,
                child: Switch(
                  value: value,
                  onChanged: onChanged,
                  activeColor: StyleRepo.softWhite,
                  activeTrackColor: StyleRepo.forestGreen,
                  inactiveThumbColor: Colors.grey[400],
                  inactiveTrackColor: Colors.grey[300],
                  materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
