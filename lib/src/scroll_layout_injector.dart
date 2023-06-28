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
    CustomLoadMoreState state,
    List<T>? dataItems,
    ScrollController scrollController,
    StreamController<CustomLoadMoreEvent> streamController,
  );
}

class CustomScrollableListViewBuilderInjector<T>
    extends CustomScrollableLayoutBuilderInjector<T> {
  @override
  CustomLoadMoreContent<T> buildMainContent(
    BuildContext context,
    CustomLoadMoreState state,
    List<T>? dataItems,
    ScrollController scrollController,
    StreamController<CustomLoadMoreEvent> streamController,
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
