// ignore_for_file: constant_identifier_names

import 'dart:async';

import 'package:flutter/material.dart';
import 'constraints.dart';
import 'custom_load_more_controller.dart';
import 'scroll_layout_injector.dart';
import 'types.dart';
import 'package:flutter/rendering.dart';

/// The [CustomLoadMore] widget is a widget that can be used to load more data.
/// It can be used in [ListView], [GridView], [SliverList], [SliverGrid].
/// Currently we only support [ListView].

class CustomLoadMore<T> extends StatefulWidget {
  final Axis? mainAxisDirection;
  final InitBuilderDelegate initBuilder;
  final InitFailBuilderDelegate initFailedBuilder;
  final ListItemBuilderDelegate<T> listItemBuilder;
  final LoadMoreBuilderDelegate loadMoreBuilder;
  final LoadMoreFailBuilderDelegate loadMoreFailedBuilder;
  final NoMoreBuilderDelegate noMoreBuilder;
  final FutureCallback<T> loadMoreCallback;
  final int pageSize;
  final double? loadMoreOffset;
  final CustomLoadMoreController? customLoadMoreController;
  final CustomScrollableLayoutBuilderInjector<T>?
      customScrollableLayoutBuilderInjector;
  final bool shrinkWrap;
  final VoidCallback? onRefresh;
  final PageStorageBucket? bucketGlobal;
  const CustomLoadMore({
    super.key,
    this.mainAxisDirection,
    required this.initBuilder,
    required this.initFailedBuilder,
    required this.loadMoreBuilder,
    required this.loadMoreFailedBuilder,
    required this.noMoreBuilder,
    this.customScrollableLayoutBuilderInjector,
    required this.listItemBuilder,
    required this.loadMoreCallback,
    this.bucketGlobal,
    this.pageSize = 20,
    this.customLoadMoreController,
    this.shrinkWrap = false,
    this.loadMoreOffset,
    this.onRefresh,
  });

  @override
  State<CustomLoadMore<T>> createState() => _CustomLoadMoreState<T>();
}

class _CustomLoadMoreState<T> extends State<CustomLoadMore<T>> {
  late LoadMoreState state;
  late List<T>? items;
  late CustomScrollableLayoutBuilderInjector<T>
      customScrollableLayoutBuilderInjector;
  late double loadMoreOffset;
  late ScrollController scrollController;
  late final PageStorageBucket bucketGlobal;

  /// This stream is used to process event come from user.
  late final StreamController<LoadMoreEvent> behaviorStream;

  int get pageIndex {
    int index = 0;
    if (items != null) {
      index = (items!.length / widget.pageSize).round();
      return index;
    }
    return index;
  }

  @override
  void initState() {
    super.initState();
    bucketGlobal = widget.bucketGlobal ?? PageStorageBucket();
    state = LoadMoreState.INIT;
    items = null;

    CustomLoadMoreController customLoadMoreController =
        widget.customLoadMoreController ?? CustomLoadMoreController();
    scrollController = customLoadMoreController.scrollController;
    behaviorStream = customLoadMoreController.behaviorStream;

    loadMoreOffset = widget.loadMoreOffset ?? kLoadMoreExtent;
    customScrollableLayoutBuilderInjector =
        widget.customScrollableLayoutBuilderInjector ??
            CustomScrollableListViewBuilderInjector();
    customScrollableLayoutBuilderInjector.setParent = widget;
    widget.loadMoreCallback.call(pageIndex, widget.pageSize).then((value) {
      setState(() {
        items = value;
        state = LoadMoreState.STABLE;
      });
    }).catchError((error) {
      setState(() {
        state = LoadMoreState.INIT_FAILED;
      });
    });
    behaviorStream.stream.listen((event) {
      switch (event) {
        case LoadMoreEvent.RETRY_WHEN_INIT_FAILED:
          retryCallFallback();
          break;
        case LoadMoreEvent.RETRY_WHEN_LOAD_MORE_FAILED:
          retryLoadMoreFailed();
          break;
        case LoadMoreEvent.PULL_TO_REFRESH:
          pullForRefresh();
          break;
        case LoadMoreEvent.SCROLL_TO_LOAD_MORE:
          loadMore();
          break;
        case LoadMoreEvent.ERROR_OCCURRED:
          handelError();
          break;
      }
    });
  }

  /// This method is used to handle error.
  void handelError() {
    setState(() {
      state = LoadMoreState.INIT_FAILED;
    });
  }

  /// This method is used to retry load more when load more failed.
  void retryLoadMoreFailed() {
    if (state != LoadMoreState.LOAD_MORE_FAILED) {
      return;
    }
    setState(() {
      state = LoadMoreState.LOAD_MORE;
    });
    widget.loadMoreCallback(pageIndex, widget.pageSize).then((value) {
      setState(() {
        items = [...items ?? [], ...value ?? []];
        state = LoadMoreState.STABLE;
        if (value?.isEmpty ?? true) {
          state = LoadMoreState.NO_MORE;
        }
      });
    }).catchError((error) {
      setState(() {
        state = LoadMoreState.LOAD_MORE_FAILED;
      });
    });
  }

  /// This method is used to load more data.
  void loadMore() {
    if (state != LoadMoreState.STABLE) {
      return;
    }
    setState(() {
      state = LoadMoreState.LOAD_MORE;
    });
    widget.loadMoreCallback(pageIndex, widget.pageSize).then((value) {
      setState(() {
        items = [...items ?? [], ...value ?? []];
        state = LoadMoreState.STABLE;
        if (value?.isEmpty ?? true) {
          state = LoadMoreState.NO_MORE;
          return;
        }
        if (value != null && value.length < widget.pageSize) {
          state = LoadMoreState.NO_MORE;
          return;
        }
      });
    }).catchError((error) {
      setState(() {
        state = LoadMoreState.LOAD_MORE_FAILED;
      });
    });
  }

  /// Call back when init failed.
  void retryCallFallback() {
    setState(() {
      state = LoadMoreState.INIT;
    });
    widget.loadMoreCallback.call(pageIndex, widget.pageSize).then((value) {
      setState(() {
        items = value;
        state = LoadMoreState.STABLE;
      });
    }).catchError((error) {
      setState(() {
        state = LoadMoreState.INIT_FAILED;
      });
    });
  }

  /// Call back when pull for refresh.
  void pullForRefresh() {
    widget.onRefresh?.call();
    setState(() {
      items = null;
      state = LoadMoreState.INIT;
    });
    widget.loadMoreCallback.call(pageIndex, widget.pageSize).then((value) {
      setState(() {
        items = value;
        state = LoadMoreState.STABLE;
      });
    }).catchError((error) {
      setState(() {
        state = LoadMoreState.INIT_FAILED;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return NotificationListener<ScrollNotification>(
      onNotification: (notification) {
        /// That code using to detect user scroll behavior (up or down as vertical and left or right with horizontal).
        /// the orientation obey the [mainAxisDirection] property.
        if (scrollController.position.userScrollDirection ==
            ScrollDirection.reverse) {
          //('User is going down');
          if (state == LoadMoreState.NO_MORE) {
            return false;
          }
          if (notification.metrics.pixels >
              notification.metrics.maxScrollExtent - loadMoreOffset) {
            behaviorStream.sink.add(LoadMoreEvent.SCROLL_TO_LOAD_MORE);
          }
          return false;
        }

        if (scrollController.position.userScrollDirection ==
            ScrollDirection.forward) {
          return false;
        }
        return false;
      },
      child: PageStorage(
        bucket: bucketGlobal,
        child: customScrollableLayoutBuilderInjector.buildMainContent(
            context, state, items, scrollController, behaviorStream),
      ),
    );
  }

  @override
  void dispose() {
    scrollController.dispose();
    super.dispose();
  }
}
