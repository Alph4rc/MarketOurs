import 'package:cupertino_ui/cupertino_ui.dart';

import '../models/post.dart';
import '../ui/app_responsive.dart';
import 'post_card.dart';

/// Responsive post list used by the home latest/tag feeds.
class PostFeedList extends StatelessWidget {
  const PostFeedList({
    super.key,
    required this.posts,
    required this.isLoadingMore,
    this.keyPrefix = 'post-feed',
  });

  final List<PostDto> posts;
  final bool isLoadingMore;
  final String keyPrefix;

  @override
  Widget build(BuildContext context) {
    final columnCount = AppResponsive.listColumnCount(context);

    if (columnCount == 1) {
      return Column(
        key: ValueKey('$keyPrefix-columns-1'),
        children: [
          for (final post in posts)
            Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: PostCard(post: post),
            ),
          if (isLoadingMore)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 24),
              child: Center(child: CupertinoActivityIndicator()),
            ),
        ],
      );
    }

    return Column(
      key: ValueKey('$keyPrefix-columns-2'),
      children: [
        LayoutBuilder(
          builder: (context, constraints) {
            const spacing = 16.0;
            final itemWidth = (constraints.maxWidth - spacing) / 2;
            return Wrap(
              spacing: spacing,
              runSpacing: spacing,
              children: [
                for (final post in posts)
                  SizedBox(
                    width: itemWidth,
                    child: PostCard(post: post),
                  ),
              ],
            );
          },
        ),
        if (isLoadingMore)
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 24),
            child: Center(child: CupertinoActivityIndicator()),
          ),
      ],
    );
  }
}
