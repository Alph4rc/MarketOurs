import 'package:cupertino_ui/cupertino_ui.dart';
import 'package:luamris_ui/luamris_ui.dart';

import '../../../../l10n/app_localizations.dart';

class PostDetailErrorView extends StatelessWidget {
  const PostDetailErrorView({
    super.key,
    required this.message,
    required this.onRetry,
  });

  final String message;
  final Future<void> Function() onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: McEmpty.retry(
          title: AppLocalizations.of(context).detailLoadFailed,
          description: message,
          icon: CupertinoIcons.doc_text,
          onRetry: onRetry,
          retryLabel: AppLocalizations.of(context).reload,
        ),
      ),
    );
  }
}
