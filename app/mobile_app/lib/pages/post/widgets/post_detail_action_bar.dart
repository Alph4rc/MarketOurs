import 'package:cupertino_ui/cupertino_ui.dart';
import 'package:luamris_ui/luamris_ui.dart';

import '../../../../l10n/app_localizations.dart';

class PostDetailActionBar extends StatelessWidget {
  const PostDetailActionBar({
    super.key,
    required this.likes,
    required this.dislikes,
    required this.watch,
    required this.isWorking,
    required this.isLiked,
    required this.isDisliked,
    required this.onShare,
    required this.onLike,
    required this.onDislike,
  });

  final int likes;
  final int dislikes;
  final int watch;
  final bool isWorking;
  final bool isLiked;
  final bool isDisliked;
  final VoidCallback onShare;
  final VoidCallback onLike;
  final VoidCallback onDislike;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16),
      decoration: BoxDecoration(
        border: Border(
          top: BorderSide(color: context.mc.border.withValues(alpha: 0.3)),
          bottom: BorderSide(color: context.mc.border.withValues(alpha: 0.3)),
        ),
      ),
      child: Row(
        children: [
          _ActionChip(
            icon: isLiked ? CupertinoIcons.heart_fill : CupertinoIcons.heart,
            label: '$likes',
            onTap: isWorking ? null : onLike,
            color: context.mc.pink,
            active: isLiked,
          ),
          const SizedBox(width: 12),
          _ActionChip(
            icon: isDisliked
                ? CupertinoIcons.hand_thumbsdown_fill
                : CupertinoIcons.hand_thumbsdown,
            label: '$dislikes',
            onTap: isWorking ? null : onDislike,
            color: context.mc.secondaryLabel,
            active: isDisliked,
          ),
          const Spacer(),
          Text(
            AppLocalizations.of(context).postWatchCount(watch),
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: context.mc.secondaryLabel,
            ),
          ),
          const SizedBox(width: 12),
          CupertinoButton(
            padding: EdgeInsets.zero,
            minimumSize: Size.zero,
            onPressed: onShare,
            child: Icon(
              CupertinoIcons.share,
              size: 18,
              color: context.mc.secondaryLabel,
            ),
          ),
        ],
      ),
    );
  }
}

class _ActionChip extends StatelessWidget {
  const _ActionChip({
    required this.icon,
    required this.label,
    this.onTap,
    required this.color,
    this.active = false,
  });

  final IconData icon;
  final String label;
  final VoidCallback? onTap;
  final Color color;
  final bool active;

  @override
  Widget build(BuildContext context) {
    return CupertinoButton(
      padding: EdgeInsets.zero,
      onPressed: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: active ? color.withValues(alpha: 0.1) : context.mc.secondary,
          borderRadius: BorderRadius.circular(McRadii.pill),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 18,
              color: active ? color : context.mc.secondaryLabel,
            ),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: active ? color : context.mc.foreground,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
