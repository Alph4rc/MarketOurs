import 'package:flutter_riverpod/flutter_riverpod.dart';

/// The kind of feed shown by a home page top tab.
enum HomeTabKind { latest, hot, tag }

/// A home page top tab: 最新, 热榜 or one tag.
class HomeTab {
  const HomeTab.latest()
    : kind = HomeTabKind.latest,
      tagId = null,
      tagName = null;

  const HomeTab.hot() : kind = HomeTabKind.hot, tagId = null, tagName = null;

  const HomeTab.tag({required String this.tagId, this.tagName})
    : kind = HomeTabKind.tag;

  final HomeTabKind kind;
  final String? tagId;
  final String? tagName;

  bool get isLatest => kind == HomeTabKind.latest;
  bool get isHot => kind == HomeTabKind.hot;
  bool get isTag => kind == HomeTabKind.tag;

  /// Stable identity used for selection comparisons and widget keys.
  String get key => switch (kind) {
    HomeTabKind.latest => 'latest',
    HomeTabKind.hot => 'hot',
    HomeTabKind.tag => 'tag:$tagId',
  };

  @override
  bool operator ==(Object other) => other is HomeTab && other.key == key;

  @override
  int get hashCode => key.hashCode;

  @override
  String toString() => 'HomeTab($key)';
}

class HomeTabState {
  const HomeTabState({
    this.selected = const HomeTab.latest(),
    this.extraTags = const [],
  });

  final HomeTab selected;

  /// Tag tabs opened from a post tag pill before (or without) appearing in
  /// the server-provided tag list.
  final List<HomeTab> extraTags;

  HomeTabState copyWith({HomeTab? selected, List<HomeTab>? extraTags}) {
    return HomeTabState(
      selected: selected ?? this.selected,
      extraTags: extraTags ?? this.extraTags,
    );
  }
}

final homeTabControllerProvider =
    NotifierProvider<HomeTabController, HomeTabState>(HomeTabController.new);

class HomeTabController extends Notifier<HomeTabState> {
  @override
  HomeTabState build() => const HomeTabState();

  void select(HomeTab tab) {
    if (tab.key == state.selected.key) {
      return;
    }
    state = state.copyWith(selected: tab);
  }

  void selectLatest() => select(const HomeTab.latest());

  void selectHot() => select(const HomeTab.hot());

  /// Selects a tag tab, remembering tags that are not part of the loaded tag
  /// list so the tab survives until the tag list can provide it.
  void selectTag(String tagId, {String? name}) {
    final normalizedName = name?.trim();
    final tag = HomeTab.tag(
      tagId: tagId,
      tagName: normalizedName?.isEmpty == true ? null : normalizedName,
    );

    final existingIndex = state.extraTags.indexWhere(
      (item) => item.tagId == tagId,
    );
    final extraTags = [...state.extraTags];
    if (existingIndex == -1) {
      extraTags.add(tag);
    } else if (extraTags[existingIndex].tagName == null &&
        tag.tagName != null) {
      extraTags[existingIndex] = tag;
    }

    state = HomeTabState(selected: tag, extraTags: extraTags);
  }
}
