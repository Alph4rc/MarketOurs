import 'package:cupertino_ui/cupertino_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:luamris_ui/luamris_ui.dart';

import '../models/post.dart';
import '../providers/home_tab_provider.dart';
import '../router/app_router.dart';

class PostTagPill extends ConsumerWidget {
  const PostTagPill({
    super.key,
    required this.tag,
    this.emptyText = 'Tag',
    this.clickable = true,
  });

  final PostTagDto? tag;
  final String emptyText;
  final bool clickable;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final hasTag = tag != null;
    final label = tag?.name?.trim().isNotEmpty == true
        ? tag!.name!.trim()
        : emptyText;
    final child = Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: hasTag
            ? context.mc.primary.withValues(alpha: 0.12)
            : context.mc.secondary,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(
          color: hasTag
              ? context.mc.primary.withValues(alpha: 0.28)
              : context.mc.border,
        ),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w700,
          color: hasTag ? context.mc.primary : context.mc.secondaryLabel,
        ),
      ),
    );

    if (!clickable || tag == null) {
      return child;
    }

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () {
        ref
            .read(homeTabControllerProvider.notifier)
            .selectTag(tag!.id, name: tag!.name);
        context.go(AppRoutePaths.home);
      },
      child: child,
    );
  }
}
