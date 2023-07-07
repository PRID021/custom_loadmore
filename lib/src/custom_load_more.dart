
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
  final FutureCallback<T>? loadMoreCallback;
  final int pageSize;
  final double? loadMoreOffset;
  final CustomLoadMoreController? customLoadMoreController;
  final CustomScrollableLayoutBuilderInjector<T>?
      customScrollableLayoutBuilderInjector;
  final ICustomLoadMoreProvider<T>? loadMoreProvider;
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
    @Deprecated('Use ICustomLoadMoreProvider instead')
    this.loadMoreCallback,
    this.bucketGlobal,
    this.pageSize = 20,
    this.customLoadMoreController,
    this.shrinkWrap = false,
    this.loadMoreOffset,
    this.onRefresh,
    this.loadMoreProvider,
  });

  @override
  State<CustomLoadMore<T>> createState() => _CustomLoadMoreState<T>();
}

class _CustomLoadMoreState<T> extends State<CustomLoadMore<T>> {
  late CustomLoadMoreState state;
  late List<T>? items;
  late CustomScrollableLayoutBuilderInjector<T>
      customScrollableLayoutBuilderInjector;
  late double loadMoreOffset;
  late ScrollController scrollController;
  late final PageStorageBucket bucketGlobal;

  /// This stream is used to process event come from user.
  late final StreamController<CustomLoadMoreEvent> behaviorStream;

  // ICustomLoadMore interface provide the load more function to load more data
  // from server.
  late  FutureCallback<T>? loadMoreProvider;

  ///  There variables using to control the load more process.
  ///  [_currentFutureIndex] is the index of the current future that is processing.
  int _currentFutureIndex = 0;
  Future<List<T>?> _executeLoadMore(Future<List<T>?> future)  {
    _currentFutureIndex++;
    Completer<List<T>?> completer = Completer<List<T>?>();
    int index = _currentFutureIndex;

    future.then((value) {
      if(index == _currentFutureIndex){
        completer.complete(value);
      }
    }).catchError((error) {
      if(index == _currentFutureIndex){
        completer.completeError(error);
      }
    });
    return completer.future;
  }


  @override
  void didUpdateWidget(covariant CustomLoadMore<T> oldWidget) {
    super.didUpdateWidget(oldWidget);

    customScrollableLayoutBuilderInjector.setParent = widget;
  }

  int get pageIndex {
    int index = 0;
    if (items != null) {
      index = (items!.length / widget.pageSize).ceil();
      return index;
    }
    return index;
  }

  @override
  void initState() {
    super.initState();
    bucketGlobal = widget.bucketGlobal ?? PageStorageBucket();
    state = const CustomLoadMoreInitState();
    items = null;

    /// Instead use directly widget.loadMoreCallback, that will be remove entirely
    /// in the future. We use ICustomLoadMore interface to provide the load more
    /// function to load more data from server to better adaptation with more state management.
    loadMoreProvider = (widget.loadMoreProvider?.loadMore) ?? (widget.loadMoreCallback);
    assert(loadMoreProvider != null, 'Must provide load more function to load more data from server.');
    CustomLoadMoreController customLoadMoreController =
        widget.customLoadMoreController ?? CustomLoadMoreController();
    scrollController = customLoadMoreController.scrollController;
    behaviorStream = customLoadMoreController.behaviorStream;

    loadMoreOffset = widget.loadMoreOffset ?? kLoadMoreExtent;
    customScrollableLayoutBuilderInjector =
        widget.customScrollableLayoutBuilderInjector ??
            CustomScrollableListViewBuilderInjector();
    customScrollableLayoutBuilderInjector.setParent = widget;

    final future =  loadMoreProvider?.call(pageIndex, widget.pageSize);
    if(future!= null){
      _executeLoadMore(future).then((value) {
        setState(() {
          items = value;
          state = const CustomLoadMoreStableState();
        });
      }).catchError((error) {
        setState(() {
          state = CustomLoadMoreInitFailedState(errorReason: error);
        });
      });
    }



    behaviorStream.stream.listen((event) {

      if(event is  CustomLoadMoreEventRetryWhenInitFailed){
        retryCallFallback();
        return;
      }
      if(event is CustomLoadMoreEventRetryWhenLoadMoreFailed){
        retryLoadMoreFailed();
        return;
      }

      if(event is CustomLoadMoreEventPullToRefresh){
        pullForRefresh();
        return;
      }

      if(event is CustomLoadMoreEventScrollToLoadMore){
        loadMore();
        return;
      }

      if(event is CustomLoadMoreEventErrorOccurred){

        handelError(
            errorReason:
            (event).errorReason);
        return;
      }
    });
  }

  /// This method is used to handle error.
  void handelError({Exception? errorReason}) {
    setState(() {
      state = CustomLoadMoreInitFailedState(errorReason: errorReason);
    });
  }

  /// This method is used to retry load more when load more failed.
  void retryLoadMoreFailed() {
    if (state is! CustomLoadMoreLoadMoreFailedState) {
      return;
    }
    setState(() {
      state = const CustomLoadMoreLoadingMoreState();
    });



    final future = loadMoreProvider?.call(pageIndex, widget.pageSize);
    if(future != null){
      _executeLoadMore(future).then((value) {
        setState(() {
          items = [...items ?? [], ...value ?? []];
          state = const CustomLoadMoreStableState();
          if (value?.isEmpty ?? true) {
            state = const CustomLoadMoreNoMoreDataState();
          }
        });
      }).catchError((error) {
        setState(() {
          state = CustomLoadMoreLoadMoreFailedState(errorReason: error);
        });
      });
    }

  }

  /// This method is used to load more data.
  void loadMore() {
    if (state is! CustomLoadMoreStableState) {
      return;
    }
    setState(() {
      state = const CustomLoadMoreLoadingMoreState();
    });
    final future = loadMoreProvider?.call(pageIndex, widget.pageSize);
    if(future != null){
      _executeLoadMore(future).then((value) {
        setState(() {
          items = [...items ?? [], ...value ?? []];
          state = const CustomLoadMoreStableState();
          if (value?.isEmpty ?? true) {
            state = const CustomLoadMoreNoMoreDataState();
            return;
          }
          if (value != null && value.length < widget.pageSize) {
            state = const CustomLoadMoreNoMoreDataState();
            return;
          }
        });
      }).catchError((error) {
        setState(() {
          state = CustomLoadMoreLoadMoreFailedState(errorReason: error);
        });
      });
    }

  }

  /// Call back when init failed.
  void retryCallFallback() {
    setState(() {
      state = const CustomLoadMoreInitState();
    });
    final future = loadMoreProvider?.call(pageIndex, widget.pageSize);
    if(future != null){
      _executeLoadMore(future).then((value) {
        setState(() {
          items = value;
          state = const CustomLoadMoreStableState();
        });
      }).catchError((error) {
        setState(() {
          state = const CustomLoadMoreInitFailedState();
        });
      });
    }

  }

  /// Call back when pull for refresh.
  void pullForRefresh() {
    widget.onRefresh?.call();
    setState(() {
      items = null;
      state = const CustomLoadMoreInitState();
    });

    final future = loadMoreProvider?.call(pageIndex, widget.pageSize);
    if(future!=null){
      _executeLoadMore(future).then((value) {
        setState(() {
          items = value;
          state = const CustomLoadMoreStableState();
        });
      }).catchError((error) {
        setState(() {
          state = CustomLoadMoreInitFailedState(errorReason: error);
        });
      });
    }
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
          if (state is CustomLoadMoreNoMoreDataState) {
            return false;
          }
          if (notification.metrics.pixels >
              notification.metrics.maxScrollExtent - loadMoreOffset) {
            behaviorStream.sink
                .add(const CustomLoadMoreEventScrollToLoadMore());
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
