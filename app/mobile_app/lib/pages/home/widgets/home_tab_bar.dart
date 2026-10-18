import 'package:cupertino_ui/cupertino_ui.dart';
import 'package:luamris_ui/luamris_ui.dart';

import '../../../l10n/app_localizations.dart';
import '../../../providers/home_tab_provider.dart';
import '../../../ui/app_responsive.dart';

/// Horizontally scrollable top tab bar used by the home page.
///
/// Shows 最新, 热榜 and one tab per active tag.
class HomeTabBar extends StatefulWidget {
  const HomeTabBar({
    super.key,
    required this.tabs,
    required this.selectedKey,
    required this.onSelected,
    this.isLoadingTags = false,
    this.hasTagError = false,
    this.onRetryTags,
  });

  final List<HomeTab> tabs;
  final String selectedKey;
  final ValueChanged<HomeTab> onSelected;
  final bool isLoadingTags;
  final bool hasTagError;
  final VoidCallback? onRetryTags;

  static const double height = 48;

  @override
  State<HomeTabBar> createState() => _HomeTabBarState();
}

class _HomeTabBarState extends State<HomeTabBar> {
  final ScrollController _scrollController = ScrollController();
  final GlobalKey _rowKey = GlobalKey();
  final Map<String, GlobalKey> _itemKeys = {};

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _ensureSelectedVisible();
    });
  }

  @override
  void didUpdateWidget(HomeTabBar oldWidget) {
    super.didUpdateWidget(oldWidget);
    _itemKeys.removeWhere(
      (key, _) => !widget.tabs.any((tab) => tab.key == key),
    );
    final selectionChanged = oldWidget.selectedKey != widget.selectedKey;
    final tabsChanged = oldWidget.tabs.length != widget.tabs.length;
    if (selectionChanged || tabsChanged) {
      _ensureSelectedVisible();
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _ensureSelectedVisible() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted || !_scrollController.hasClients) return;

      final itemContext = _itemKeys[widget.selectedKey]?.currentContext;
      final rowContext = _rowKey.currentContext;
      if (itemContext == null || rowContext == null) return;

      final itemBox = itemContext.findRenderObject();
      final rowBox = rowContext.findRenderObject();
      if (itemBox is! RenderBox || rowBox is! RenderBox) return;

      final offset = _scrollController.offset;
      final viewportWidth = _scrollController.position.viewportDimension;
      final itemOffset = itemBox.localToGlobal(Offset.zero, ancestor: rowBox);
      final leading = itemOffset.dx;
      final trailing = leading + itemBox.size.width;

      // Already fully visible: don't disturb the user's scroll position.
      if (leading >= offset && trailing <= offset + viewportWidth) {
        return;
      }

      final itemCenter = leading + itemBox.size.width / 2;
      final target = (itemCenter - viewportWidth / 2).clamp(
        0.0,
        _scrollController.position.maxScrollExtent,
      );
      _scrollController.animateTo(
        target,
        duration: const Duration(milliseconds: 220),
        curve: Curves.easeOutCubic,
      );
    });
  }

  String _labelFor(BuildContext context, HomeTab tab) {
    final l10n = AppLocalizations.of(context);
    return switch (tab.kind) {
      HomeTabKind.latest => l10n.homeTabLatest,
      HomeTabKind.hot => l10n.tabHot,
      HomeTabKind.tag =>
        tab.tagName?.trim().isNotEmpty == true
            ? tab.tagName!.trim()
            : l10n.unnamedTag,
    };
  }

  Widget _buildTab(BuildContext context, HomeTab tab) {
    final isSelected = tab.key == widget.selectedKey;
    final itemKey = _itemKeys.putIfAbsent(tab.key, GlobalKey.new);

    return Semantics(
      button: true,
      selected: isSelected,
      child: GestureDetector(
        key: ValueKey('home-tab-${tab.key}'),
        behavior: HitTestBehavior.opaque,
        onTap: () => widget.onSelected(tab),
        child: Padding(
          key: itemKey,
          padding: const EdgeInsets.symmetric(horizontal: 10),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 160),
                child: AnimatedDefaultTextStyle(
                  duration: const Duration(milliseconds: 160),
                  curve: Curves.easeOut,
                  style: TextStyle(
                    fontSize: isSelected ? 17 : 15,
                    fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                    color: isSelected
                        ? context.mc.foreground
                        : context.mc.secondaryLabel,
                  ),
                  child: Text(
                    _labelFor(context, tab),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ),
              const SizedBox(height: 5),
              AnimatedContainer(
                duration: const Duration(milliseconds: 160),
                curve: Curves.easeOut,
                width: isSelected ? 18 : 0,
                height: 3,
                decoration: BoxDecoration(
                  color: context.mc.primary,
                  borderRadius: BorderRadius.circular(999),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: HomeTabBar.height,
      child: Row(
        children: [
          Expanded(
            child: SingleChildScrollView(
              controller: _scrollController,
              scrollDirection: Axis.horizontal,
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.symmetric(horizontal: 6),
              child: Row(
                key: _rowKey,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  for (final tab in widget.tabs) _buildTab(context, tab),
                  if (widget.isLoadingTags)
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 10),
                      child: Center(
                        child: CupertinoActivityIndicator(radius: 8),
                      ),
                    ),
                  if (widget.hasTagError && widget.onRetryTags != null)
                    CupertinoButton(
                      padding: const EdgeInsets.symmetric(horizontal: 10),
                      minimumSize: Size.zero,
                      onPressed: widget.onRetryTags,
                      child: Semantics(
                        label: AppLocalizations.of(context).retry,
                        button: true,
                        child: Icon(
                          CupertinoIcons.arrow_clockwise,
                          size: 18,
                          color: context.mc.secondaryLabel,
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Pinned sliver header hosting the [HomeTabBar].
class HomeTabBarHeaderDelegate extends SliverPersistentHeaderDelegate {
  HomeTabBarHeaderDelegate({
    required this.child,
    required this.backgroundColor,
  });

  final Widget child;
  final Color backgroundColor;

  @override
  double get minExtent => HomeTabBar.height;

  @override
  double get maxExtent => HomeTabBar.height;

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
    final horizontalPadding = AppResponsive.horizontalPadding(context);
    return DecoratedBox(
      decoration: BoxDecoration(
        color: backgroundColor,
        border: Border(
          bottom: BorderSide(
            color: context.mc.border.withValues(alpha: 0.3),
            width: 0.5,
          ),
        ),
      ),
      child: Align(
        alignment: Alignment.center,
        child: ConstrainedBox(
          constraints: BoxConstraints(
            maxWidth: AppResponsive.contentMaxWidth(context),
          ),
          child: Padding(
            // HomeTabBar adds 6px of its own padding around the tabs.
            padding: EdgeInsets.symmetric(
              horizontal: horizontalPadding > 6 ? horizontalPadding - 6 : 0,
            ),
            child: child,
          ),
        ),
      ),
    );
  }

  @override
  bool shouldRebuild(covariant HomeTabBarHeaderDelegate oldDelegate) {
    return oldDelegate.child != child ||
        oldDelegate.backgroundColor != backgroundColor;
  }
}
