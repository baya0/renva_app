import 'package:flutter/material.dart';

import '../../core/demo/media.dart';
import '../../core/style/repo.dart';
import '../../core/widgets/image.dart';
import '../../core/widgets/svg_icon.dart';
import '../../gen/assets.gen.dart';

class ChatPage extends StatelessWidget {
  const ChatPage({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.topRight,
            colors: [StyleRepo.deepBlue, Color(0xff0048D9)],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Text(
                          'My Messages',
                          style: theme.textTheme.titleMedium?.copyWith(
                            color: StyleRepo.softWhite,
                            fontWeight: FontWeight.w700,
                            fontSize: 20,
                          ),
                        ),
                      ],
                    ),

                    SvgIcon(
                      icon: Assets.icons.messages.notifications,
                      color: StyleRepo.softWhite,
                      size: 24,
                    ),
                  ],
                ),
              ),

              Expanded(
                child: Container(
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
                  ),
                  child: Column(
                    children: [
                      // Chat list
                      Expanded(
                        child: ListView.builder(
                          padding: const EdgeInsets.symmetric(horizontal: 20),

                          itemCount: 12,
                          itemBuilder: (context, index) {
                            return _buildChatItem(index);
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildChatItem(int index) {
    String timeAgo = index % 2 == 0 ? '5 min' : '7 min';

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16)),

      child: Row(
        children: [
          // Profile picture
          AppImage(
            path: DemoMedia.getAppRandomImage,
            type: ImageType.CachedNetwork,
            width: 56,
            height: 56,
            decoration: const BoxDecoration(shape: BoxShape.circle),
            errorWidget: Container(
              width: 56,
              height: 56,
              decoration: const BoxDecoration(color: StyleRepo.softGrey, shape: BoxShape.circle),
              child: const Icon(Icons.person, color: StyleRepo.grey, size: 28),
            ),
          ),

          const SizedBox(width: 12),

          // Chat info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Name
                    const Text(
                      'Joni provider',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: StyleRepo.black,
                      ),
                    ),

                    Text(
                      timeAgo,
                      style: const TextStyle(
                        fontSize: 12,
                        color: StyleRepo.grey,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 4),

                const Text(
                  'Lorem Ipsum Dolor Sit Amet, Consectetur...',
                  style: TextStyle(
                    fontSize: 14,
                    color: StyleRepo.grey,
                    fontWeight: FontWeight.w400,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
