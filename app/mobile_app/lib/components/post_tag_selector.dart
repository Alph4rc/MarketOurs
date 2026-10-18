import 'package:cupertino_ui/cupertino_ui.dart';
import 'package:luamris_ui/luamris_ui.dart';
import 'package:mobile_app/l10n/app_localizations.dart';

import '../models/post.dart';
import 'post_tag_pill.dart';

Future<PostTagDto?> showPostTagPicker(
  BuildContext context, {
  required List<PostTagDto> tags,
  required PostTagDto? selectedTag,
}) async {
  if (tags.isEmpty) return selectedTag;

  return showCupertinoModalPopup<PostTagDto?>(
    context: context,
    builder: (ctx) => CupertinoActionSheet(
      title: Text(AppLocalizations.of(context).postSelectTag),
      message: Text(AppLocalizations.of(context).postTagAdminPreset),
      actions: [
        CupertinoActionSheetAction(
          onPressed: () => Navigator.of(ctx).pop(null),
          child: Text(AppLocalizations.of(context).postCreateNoTag),
        ),
        for (final tag in tags)
          CupertinoActionSheetAction(
            onPressed: () => Navigator.of(ctx).pop(tag),
            child: Text(tag.name ?? AppLocalizations.of(context).unnamedTag),
          ),
      ],
      cancelButton: CupertinoActionSheetAction(
        onPressed: () => Navigator.of(ctx).pop(selectedTag),
        child: Text(AppLocalizations.of(context).cancel),
      ),
    ),
  );
}

class PostTagSelectorCard extends StatelessWidget {
  const PostTagSelectorCard({
    super.key,
    required this.tag,
    required this.onPressed,
    this.emptyText = '',
    this.enabled = true,
    this.label = 'Tag',
  });

  final PostTagDto? tag;
  final VoidCallback? onPressed;
  final String emptyText;
  final bool enabled;
  final String label;

  @override
  Widget build(BuildContext context) {
    return McCard.elevated(
      padding: const EdgeInsets.all(20),
      onPressed: enabled ? onPressed : null,
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 6),
                PostTagPill(tag: tag, emptyText: emptyText, clickable: false),
              ],
            ),
          ),
          Icon(
            CupertinoIcons.chevron_down,
            size: 18,
            color: enabled
                ? context.mc.secondaryLabel
                : context.mc.secondaryLabel.withValues(alpha: 0.5),
          ),
        ],
      ),
    );
  }
}

class PostTagInlineSelector extends StatelessWidget {
  const PostTagInlineSelector({
    super.key,
    required this.tag,
    required this.onPressed,
    this.emptyText = '',
    this.enabled = true,
    this.label = 'Tag',
    this.actionLabel = 'Change',
  });

  final PostTagDto? tag;
  final VoidCallback? onPressed;
  final String emptyText;
  final bool enabled;
  final String label;
  final String actionLabel;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(label, style: context.mc.textLabel),
        const SizedBox(width: 10),
        GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: enabled ? onPressed : null,
          child: PostTagPill(tag: tag, emptyText: emptyText, clickable: false),
        ),
        const Spacer(),
        if (enabled)
          CupertinoButton(
            padding: EdgeInsets.zero,
            onPressed: onPressed,
            child: Text(actionLabel),
          ),
      ],
    );
  }
}
