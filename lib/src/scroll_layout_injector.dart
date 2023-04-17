import 'dart:async';

import 'package:flutter/material.dart';

import 'custom_load_more.dart';
import 'load_more_content.dart';
import 'load_more_list.dart';
import 'types.dart';

abstract class CustomScrollableLayoutBuilderInjector<T> {
  late CustomLoadMore<T> widgetParent;

  set setParent(CustomLoadMore<T> widget) {
    widgetParent = widget;
  }

  CustomScrollableLayoutBuilderInjector();
  CustomLoadMoreContent<T> buildMainContent(
    BuildContext context,
    LoadMoreState state,
    List<T>? dataItems,
    ScrollController scrollController,
    StreamController<LoadMoreEvent> streamController,
  );
}

class CustomScrollableListViewBuilderInjector<T>
    extends CustomScrollableLayoutBuilderInjector<T> {
  @override
  CustomLoadMoreContent<T> buildMainContent(
    BuildContext context,
    LoadMoreState state,
    List<T>? dataItems,
    ScrollController scrollController,
    StreamController<LoadMoreEvent> streamController,
  ) {
    Axis scrollDirection = widgetParent.mainAxisDirection ?? Axis.vertical;
    return LoadMoreSequenceList<T>(
      widgetParent.key,
      state: state,
      mainAxisDirection: scrollDirection,
      items: dataItems,
      widget: widgetParent,
      scrollController: scrollController,
      streamController: streamController,
    );
  }
}

// class CustomSectionListViewBuilderInjector<T, K>
//     extends CustomScrollableLayoutBuilderInjector<T> {
//   final Map<K, List<T>> Function({required List<T> items}) sectionFilter;
//   final Widget Function(K key, List<Widget> children) sectionBuilder;

//   CustomSectionListViewBuilderInjector(
//       {required this.sectionFilter, required this.sectionBuilder});

//   @override
//   CustomLoadMoreContent<T> buildMainContent(
//       BuildContext context,
//       LoadMoreState state,
//       List<T>? dataItems,
//       ScrollController scrollController,
//       StreamController<LoadMoreEvent> streamController) {
//     Axis scrollDirection = widgetParent.mainAxisDirection ?? Axis.vertical;
//     return LoadMoreSectionList(
//       widgetParent.key,
//       state: state,
//       mainAxisDirection: scrollDirection,
//       items: dataItems,
//       widget: widgetParent,
//       scrollController: scrollController,
//       streamController: streamController,
//       sectionFilter: this.sectionFilter,
//       sectionBuilder: this.sectionBuilder,
//     );
//   }
// }
