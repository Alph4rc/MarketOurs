import 'package:cupertino_ui/cupertino_ui.dart';
import 'package:image_picker/image_picker.dart';
import 'package:luamris_ui/luamris_ui.dart';

import 'package:mobile_app/l10n/app_localizations.dart';
import 'package:mobile_app/utils/dto_validation.dart';

import 'editable_image_wrap.dart';
import '../models/post.dart';
import '../ui/app_responsive.dart';
import 'post_tag_selector.dart';

enum PostEditorLayout { page, sheet }

class PostEditorForm extends StatelessWidget {
  const PostEditorForm({
    super.key,
    required this.layout,
    required this.titleController,
    required this.contentController,
    required this.selectedTag,
    required this.existingImages,
    required this.localImages,
    required this.submitLabel,
    required this.onSubmit,
    this.headerText,
    this.titleValidator,
    this.contentValidator,
    this.onPickTag,
    this.onPickImages,
    this.onRemoveExistingImage,
    this.onRemoveLocalImage,
    this.uploadProgress,
    required this.tagEmptyText,
    this.isSubmitting = false,
    // Reorderable mode
    this.reorderableEntries,
    this.onReorderImages,
    this.onRemoveImageEntry,
  });

  final PostEditorLayout layout;
  final String? headerText;
  final TextEditingController titleController;
  final TextEditingController contentController;
  final FormFieldValidator<String>? titleValidator;
  final FormFieldValidator<String>? contentValidator;
  final PostTagDto? selectedTag;
  final List<String> existingImages;
  final List<XFile> localImages;
  final VoidCallback? onPickTag;
  final VoidCallback? onPickImages;
  final ValueChanged<int>? onRemoveExistingImage;
  final ValueChanged<int>? onRemoveLocalImage;
  final VoidCallback? onSubmit;
  final String submitLabel;
  final double? uploadProgress;
  final String tagEmptyText;
  final bool isSubmitting;

  // Reorderable mode
  final List<EditableImageEntry>? reorderableEntries;
  final void Function(int oldIndex, int newIndex)? onReorderImages;
  final ValueChanged<String>? onRemoveImageEntry;

  @override
  Widget build(BuildContext context) {
    if (layout == PostEditorLayout.page) {
      return AppResponsiveCenter(
        maxWidth: AppResponsive.formMaxWidth(context),
        padding: AppResponsive.pagePadding(context, narrow: 20),
        child: AppTwoPane(
          primary: _buildEditorCard(context),
          secondary: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildImageCard(context),
              const SizedBox(height: 12),
              _buildTagCard(context),
              if (uploadProgress != null) ...[
                const SizedBox(height: 12),
                _buildUploadProgress(context),
              ],
              const SizedBox(height: 20),
              McButton.primary(onPressed: onSubmit, child: Text(submitLabel)),
            ],
          ),
        ),
      );
    }

    return SingleChildScrollView(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (headerText != null) ...[
            Text(headerText!, style: context.mc.textSection),
            const SizedBox(height: 16),
          ],
          _buildEditorCard(context),
          const SizedBox(height: 12),
          _buildImageCard(context),
          const SizedBox(height: 12),
          _buildTagCard(context),
          if (uploadProgress != null) ...[
            const SizedBox(height: 12),
            _buildUploadProgress(context),
          ],
          const SizedBox(height: 20),
          McButton.primary(onPressed: onSubmit, child: Text(submitLabel)),
        ],
      ),
    );
  }

  Widget _buildEditorCard(BuildContext context) {
    final contentMaxLines = layout == PostEditorLayout.page
        ? (AppResponsive.isDesktop(context) ? 12 : 8)
        : 6;

    return McCard.elevated(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          McField.text(
            controller: titleController,
            placeholder: AppLocalizations.of(context).postCreateTitle,
            maxLength: DtoLimits.postTitleMax,
            validator: titleValidator,
          ),
          const SizedBox(height: 16),
          McField.text(
            controller: contentController,
            placeholder: AppLocalizations.of(context).postCreateContent,
            maxLines: contentMaxLines,
            maxLength: DtoLimits.postContentMax,
            validator: contentValidator,
          ),
        ],
      ),
    );
  }

  Widget _buildImageCard(BuildContext context) {
    final useReorderable = reorderableEntries != null;
    final hasImages = useReorderable
        ? reorderableEntries!.isNotEmpty
        : (existingImages.isNotEmpty || localImages.isNotEmpty);

    return McCard.elevated(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                AppLocalizations.of(context).postCreateImages,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                ),
              ),
              CupertinoButton(
                padding: EdgeInsets.zero,
                onPressed: onPickImages,
                child: Text(
                  AppLocalizations.of(context).postCreateAddImages,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          if (!hasImages)
            Container(
              height: 120,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: context.mc.secondary,
                borderRadius: BorderRadius.circular(McRadii.md),
              ),
              child: Text(
                AppLocalizations.of(context).postCreateNoImages,
                style: TextStyle(color: context.mc.secondaryLabel),
              ),
            )
          else if (useReorderable)
            EditableImageWrap(
              reorderable: true,
              entries: reorderableEntries,
              onReorder: onReorderImages,
              onRemoveEntry: onRemoveImageEntry,
              tileSize: 90,
              spacing: 12,
            )
          else
            EditableImageWrap(
              existingImages: existingImages,
              localImages: localImages,
              onRemoveExisting: onRemoveExistingImage,
              onRemoveLocal: onRemoveLocalImage,
              tileSize: 90,
              spacing: 12,
              runSpacing: 12,
            ),
        ],
      ),
    );
  }

  Widget _buildTagCard(BuildContext context) {
    return PostTagSelectorCard(
      tag: selectedTag,
      onPressed: onPickTag,
      enabled: onPickTag != null,
      emptyText: tagEmptyText,
      label: AppLocalizations.of(context).postCreateTag,
    );
  }

  Widget _buildUploadProgress(BuildContext context) {
    final fraction = uploadProgress ?? 0;
    final percent = (fraction * 100).round();
    return McCard.elevated(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                AppLocalizations.of(context).postUploading,
                style: TextStyle(
                  fontSize: 14,
                  color: context.mc.secondaryLabel,
                ),
              ),
              Text(
                '$percent%',
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(McRadii.sm),
            child: Container(
              height: 6,
              color: context.mc.secondary,
              alignment: Alignment.centerLeft,
              child: FractionallySizedBox(
                widthFactor: fraction,
                child: Container(height: 6, color: context.mc.primary),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
