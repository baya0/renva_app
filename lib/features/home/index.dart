import 'dart:ui';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../core/localization/strings.dart';
import '../../core/services/state_management/widgets/obs_widget.dart';
import '../../core/style/repo.dart';
import '../../core/widgets/image.dart';
import '../../core/widgets/svg_icon.dart';
import '../../gen/assets.gen.dart';
import 'controller.dart';
import 'models/service_categories.dart';
import 'story_model.dart';
import 'widgets/service_card.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final controller = Get.put(HomePageController());

    return Scaffold(
      backgroundColor: StyleRepo.deepBlue,
      body: Stack(
        children: [
          Positioned(
            top: -117,
            left: -262,
            right: 0,
            bottom: MediaQuery.of(context).size.height * 0.5,
            child: Opacity(
              opacity: 0.18,
              child: Container(
                decoration: BoxDecoration(
                  image: DecorationImage(
                    image: Assets.images.background.background.provider(),
                    fit: BoxFit.cover,
                    colorFilter: ColorFilter.mode(
                      StyleRepo.deepBlue.withValues(alpha: 0.8),
                      BlendMode.multiply,
                    ),
                  ),
                ),
              ),
            ),
          ),
          Column(
            children: [
              SafeArea(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Logo and notifications row
                    Padding(
                      padding: const EdgeInsets.fromLTRB(20, 5, 20, 0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Assets.images.logo.renva.svg(
                            width: 111,
                            height: 27.75,
                            color: StyleRepo.softWhite,
                          ),
                          GestureDetector(
                            onTap: () => controller.onNotificationTap(),
                            child: SvgIcon(
                              icon: Assets.icons.messages.notifications,
                              color: StyleRepo.softWhite,
                              size: 24,
                            ),
                          ),
                        ],
                      ),
                    ),

                    Padding(
                      padding: const EdgeInsets.fromLTRB(20, 15.25, 20, 11),
                      child: GestureDetector(
                        onTap: () => controller.onLocationTap(),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              tr(LocaleKeys.home_your_location),
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w700,
                                fontFamily: 'CustomFont',
                                color: StyleRepo.softWhite,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Row(
                              children: [
                                ObsVariableBuilder<String>(
                                  obs: controller.currentLocation,
                                  builder: (context, location) {
                                    return Text(
                                      location,
                                      style: TextStyle(
                                        color: StyleRepo.softWhite,
                                        fontWeight: FontWeight.w400,
                                        fontSize: 10,
                                      ),
                                    );
                                  },
                                  // Custom loader for location
                                  loader:
                                      (context) => SizedBox(
                                        width: 60,
                                        height: 10,
                                        child: LinearProgressIndicator(
                                          backgroundColor: StyleRepo.softWhite.withValues(
                                            alpha: 0.3,
                                          ),
                                          valueColor: AlwaysStoppedAnimation<Color>(
                                            StyleRepo.softWhite,
                                          ),
                                        ),
                                      ),
                                  // Custom error for location
                                  errorBuilder:
                                      (context, error) => Text(
                                        'Location Error',
                                        style: TextStyle(
                                          color: StyleRepo.softWhite.withValues(alpha: 0.7),
                                          fontWeight: FontWeight.w400,
                                          fontSize: 10,
                                        ),
                                      ),
                                ),
                                const SizedBox(width: 4),
                                SvgIcon(
                                  icon: Assets.icons.arrows.down,
                                  color: StyleRepo.softWhite,
                                  height: 8,
                                  width: 8,
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // Scrollable part (services and white container)
              Expanded(
                child: MediaQuery(
                  data: MediaQuery.of(
                    context,
                  ).copyWith(padding: const EdgeInsets.only(top: 0, bottom: 0)),
                  child: NestedScrollView(
                    headerSliverBuilder: (context, innerBoxIsScrolled) {
                      return [
                        SliverPadding(
                          padding: const EdgeInsets.fromLTRB(47, 8, 47, 22),
                          sliver: SliverToBoxAdapter(
                            child: SizedBox(
                              height: size.height * 0.30,

                              child: ObsListBuilder<ServiceCategoryModel>(
                                obs: controller.serviceCategories,
                                onRefresh: controller.refreshData,
                                builder: (context, categories) {
                                  if (categories.isNotEmpty) {
                                    return _buildServicesFromBackend(categories);
                                  } else {
                                    return _buildEmptyServiceBoxes();
                                  }
                                },
                                // Custom loader for services grid
                                loader: (context) => _buildServiceGridSkeleton(),
                                // Custom error widget for services
                                errorBuilder:
                                    (context, error) => _buildServiceErrorState(controller, error),
                              ),
                            ),
                          ),
                        ),
                      ];
                    },
                    body: Container(
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
                      ),
                      child: CustomScrollView(
                        physics: const BouncingScrollPhysics(),
                        slivers: [
                          // Small handle at the top
                          SliverToBoxAdapter(
                            child: Center(
                              child: Padding(
                                padding: const EdgeInsets.only(top: 15, bottom: 5),
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

                          SliverToBoxAdapter(child: _buildStoriesSection(context, controller)),

                          // Join as Service Providers section
                          SliverToBoxAdapter(child: _buildJoinSection(context, controller)),

                          // Bottom padding for navigation bar
                          const SliverToBoxAdapter(child: SizedBox(height: 80)),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // Services from backend
  Widget _buildServicesFromBackend(List<ServiceCategoryModel> categories) {
    return GridView.builder(
      physics: const ClampingScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        childAspectRatio: 1.23,
      ),
      itemCount: categories.length,
      itemBuilder: (context, index) {
        final service = categories[index];
        return ServiceCard(service: service);
      },
    );
  }

  // Empty service boxes
  Widget _buildEmptyServiceBoxes() {
    return GridView.builder(
      physics: ClampingScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        childAspectRatio: 1.23,
      ),
      itemCount: 4,
      itemBuilder: (context, index) {
        return _buildEmptyServiceBox();
      },
    );
  }

  Widget _buildEmptyServiceBox() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(17),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 25.8, sigmaY: 25.8),
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                StyleRepo.softWhite.withValues(alpha: 0.15),
                StyleRepo.softWhite,
                StyleRepo.softWhite,
                StyleRepo.softWhite.withValues(alpha: 0.15),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(17),
            color: Colors.white.withValues(alpha: 0.1),
          ),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.category_outlined, color: Colors.white.withValues(alpha: 0.3), size: 40),
                const SizedBox(height: 8),
                Text(
                  tr(LocaleKeys.home_service),
                  style: TextStyle(color: Colors.white.withValues(alpha: 0.3), fontSize: 12),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  //  Custom error state for services
  Widget _buildServiceErrorState(HomePageController controller, String error) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error_outline, size: 64, color: Colors.white.withValues(alpha: 0.7)),
          const SizedBox(height: 16),
          Text(
            'Failed to load services',
            style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 8),
          Text(
            error,
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.white.withValues(alpha: 0.8), fontSize: 12),
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: controller.retryFetch,
            style: ElevatedButton.styleFrom(
              backgroundColor: StyleRepo.softWhite,
              foregroundColor: StyleRepo.deepBlue,
            ),
            child: Text('Retry'),
          ),
        ],
      ),
    );
  }

  // Loading skeleton for service cards
  Widget _buildServiceGridSkeleton() {
    return GridView.builder(
      physics: ClampingScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        childAspectRatio: 1.25,
      ),
      itemCount: 4,
      itemBuilder: (context, index) {
        return Container(
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(17),
          ),
          child: Center(
            child: CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(StyleRepo.softWhite),
            ),
          ),
        );
      },
    );
  }

  Widget _buildStoriesSection(BuildContext context, HomePageController controller) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(tr(LocaleKeys.home_curated_stories), style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 4),
          Text(
            tr(LocaleKeys.home_discover_horizons),
            style: Theme.of(context).textTheme.labelSmall,
          ),
          const SizedBox(height: 16),

          SizedBox(
            height: 215,
            child: ObsListBuilder<StoryModel>(
              obs: controller.stories,
              onRefresh: controller.refreshData,
              builder: (context, stories) {
                if (stories.isEmpty) {
                  return _buildEmptyStories();
                }

                // Build the stories list
                return ListView.builder(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.only(left: 4),
                  itemCount: stories.length,
                  itemBuilder: (context, index) {
                    final story = stories[index];
                    return _buildStoryItem(story, controller);
                  },
                );
              },
              // Custom loader for stories
              loader: (context) => _buildStoriesSkeleton(),
              // Custom error for stories
              errorBuilder:
                  (context, error) => Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.error_outline, size: 48, color: Colors.grey),
                        const SizedBox(height: 8),
                        Text('Failed to load stories', style: TextStyle(color: Colors.grey)),
                        const SizedBox(height: 8),
                        ElevatedButton(onPressed: controller.retryFetch, child: Text('Retry')),
                      ],
                    ),
                  ),
            ),
          ),
        ],
      ),
    );
  }

  // Story item with progress indicators
  Widget _buildStoryItem(StoryModel story, HomePageController controller) {
    return GestureDetector(
      onTap: () => controller.onStoryTap(story),
      child: Container(
        width: 159,
        height: 213,
        margin: const EdgeInsets.only(right: 12),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: Stack(
            children: [
              story.isRenvaStory
                  ? Container(
                    width: double.infinity,
                    height: double.infinity,
                    color: StyleRepo.deepBlue,
                    child: Center(
                      child: Assets.images.logo.logo.svg(
                        width: 40,
                        height: 40,
                        color: Colors.white,
                      ),
                    ),
                  )
                  : AppImage(
                    path: story.imageUrl,
                    type: ImageType.CachedNetwork,
                    fit: BoxFit.cover,
                    height: 213,
                    width: double.infinity,
                    errorWidget: Container(
                      color: Colors.grey[300],
                      child: Center(
                        child: Icon(Icons.image_not_supported, color: Colors.grey[500], size: 30),
                      ),
                    ),
                  ),

              Positioned(
                top: 8,
                left: 8,
                right: 8,
                child: Row(
                  children: List.generate(3, (index) {
                    return Expanded(
                      child: Container(
                        height: 2,
                        margin: EdgeInsets.only(right: index < 2 ? 4 : 0),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.8),
                          borderRadius: BorderRadius.circular(1),
                        ),
                      ),
                    );
                  }),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStoriesSkeleton() {
    return ListView.builder(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.only(left: 4),
      itemCount: 5,
      itemBuilder: (context, index) {
        return Container(
          width: 159,
          height: 213,
          margin: const EdgeInsets.only(right: 12),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Stack(
              children: [
                Container(color: Colors.grey[200]),
                // Progress indicators
                Positioned(
                  top: 8,
                  left: 8,
                  right: 8,
                  child: Row(
                    children: List.generate(3, (index) {
                      return Expanded(
                        child: Container(
                          height: 2,
                          margin: EdgeInsets.only(right: index < 2 ? 4 : 0),
                          decoration: BoxDecoration(
                            color: Colors.grey[400],
                            borderRadius: BorderRadius.circular(1),
                          ),
                        ),
                      );
                    }),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // Empty stories
  Widget _buildEmptyStories() {
    return Center(
      child: SizedBox(
        width: 159,
        height: 213,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: Stack(
            children: [
              Container(
                color: StyleRepo.deepBlue,
                child: Center(
                  child: Assets.images.logo.logo.svg(width: 40, height: 40, color: Colors.white),
                ),
              ),
              // Progress indicators
              Positioned(
                top: 8,
                left: 8,
                right: 8,
                child: Row(
                  children: List.generate(3, (index) {
                    return Expanded(
                      child: Container(
                        height: 2,
                        margin: EdgeInsets.only(right: index < 2 ? 4 : 0),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.8),
                          borderRadius: BorderRadius.circular(1),
                        ),
                      ),
                    );
                  }),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Join section
  Widget _buildJoinSection(BuildContext context, HomePageController controller) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 20, 24, 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            tr(LocaleKeys.home_join_as_service_provider),
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 4),
          Text(tr(LocaleKeys.home_top_providers), style: Theme.of(context).textTheme.labelSmall),
          const SizedBox(height: 16),

          Container(
            height: 140,
            width: double.infinity,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              color: StyleRepo.deepBlue,
            ),
            child: Stack(
              children: [
                Positioned(
                  left: 231,
                  child: Opacity(
                    opacity: 0.1,
                    child: Assets.images.logo.logoBlue.svg(width: 138, height: 138),
                  ),
                ),
                Row(
                  children: [
                    SizedBox(
                      width: 120,
                      height: 140,
                      child: ClipRRect(
                        child: Assets.images.styling.joinBannerModelPng.image(
                          width: 120,
                          height: 140,
                        ),
                      ),
                    ),

                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Expanded(
                                  child: Row(
                                    crossAxisAlignment: CrossAxisAlignment.center,
                                    children: [
                                      Flexible(
                                        child: Text(
                                          tr(LocaleKeys.home_join_as_service_provider),
                                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                            color: Colors.white,
                                            fontSize: 14,
                                          ),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      Assets.icons.essentials.securityUser.svg(
                                        width: 14,
                                        height: 14,
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),

                            const SizedBox(height: 10),

                            // Bullet points
                            Text(
                              tr(LocaleKeys.home_personal_services),
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 10,
                                fontWeight: FontWeight.w300,
                              ),
                            ),
                            const SizedBox(height: 9),
                            Text(
                              tr(LocaleKeys.home_professional_services),
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 10,
                                fontWeight: FontWeight.w300,
                              ),
                            ),

                            const Spacer(),

                            Align(
                              alignment: Alignment.centerRight,
                              child: GestureDetector(
                                onTap: () => controller.onJoinProvider(),
                                child: Container(
                                  width: 81,
                                  height: 21,
                                  decoration: BoxDecoration(
                                    color: StyleRepo.forestGreen,
                                    borderRadius: BorderRadius.circular(25),
                                  ),
                                  child: const Center(
                                    child: Text(
                                      "Join",
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 13,
                                        fontWeight: FontWeight.w400,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
