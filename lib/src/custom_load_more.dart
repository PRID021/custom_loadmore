import 'dart:async';

import 'package:flutter/material.dart';
import 'types.dart';
import 'package:flutter/rendering.dart';

class CustomLoadMore<T> extends StatefulWidget {
  final Axis? mainAxisDirection;
  final int pageSize;
  final CustomLoadMoreController<T>? customLoadMoreController;
  final LoadmoreWidgetBuilder<T> widgetBuilder;
  final ICustomLoadMoreDataProvider<T>? loadMoreDataProvider;
  final VoidCallback? onRefresh;
  final PageStorageBucket? bucketGlobal;
  final bool autoRun;
  final double triggerLoadMoreOffset;

  const CustomLoadMore({
    super.key,
    required this.widgetBuilder,
    this.mainAxisDirection,
    this.bucketGlobal,
    this.pageSize = 20,
    this.customLoadMoreController,
    this.onRefresh,
    this.loadMoreDataProvider,
    this.autoRun = true,
    this.triggerLoadMoreOffset = 60.0,
  });

  @override
  State<CustomLoadMore<T>> createState() => _CustomLoadMoreState<T>();
}

class _CustomLoadMoreState<T> extends State<CustomLoadMore<T>> {
  late CustomLoadMoreState state;

  List<T>? _items;

  List<T>? get items => _items;

  set items(List<T>? value) {
    _items = value;
    itemsNotifier.value = value;
  }

  late ValueNotifier<List<T>?> itemsNotifier;

  late double triggerLoadMoreOffset;
  late PageStorageBucket bucketGlobal;

  ///load more controller
  late CustomLoadMoreController<T> loadMoreController;

  /// Default load more controller
  final localCustomLoadMoreController = CustomLoadMoreController<T>();

  /// The StreamSubscription that subscribe to [loadMoreController.behaviorStream] of load more widget.
  late StreamSubscription<CustomLoadMoreEvent>? localBehaviorStreamSubscription;

  /// ICustomLoadMore interface provide the load more function to load more data
  /// from server.
  late FutureCallback<T>? loadMoreProvider;

  ///  There variables using to control the load more process.
  ///  [_currentFutureIndex] is the index of the current future that is processing.
  int _currentFutureIndex = 0;

  Future<List<T>?> _executeLoadMore(Future<List<T>?> future) {
    _currentFutureIndex++;
    Completer<List<T>?> completer = Completer<List<T>?>();
    int index = _currentFutureIndex;

    future.then((value) {
      if (index == _currentFutureIndex) {
        completer.complete(value);
      }
    }).catchError((error) {
      if (index == _currentFutureIndex) {
        completer.completeError(error);
      }
    });
    return completer.future;
  }

  /// The value that trace that state have been init
  ///
  @override
  void didUpdateWidget(covariant CustomLoadMore<T> oldWidget) {
    super.didUpdateWidget(oldWidget);
    calculateResource(oldWidget: oldWidget);
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
    itemsNotifier = ValueNotifier(items);
    calculateResource();
    if (widget.autoRun) {
      firstLoad();
    }
    loadMoreController._setValueNotifier(itemsNotifier) ;
  }

  ///
  void calculateResource({covariant CustomLoadMore<T>? oldWidget}) {
    /// Instead use directly widget.loadMoreCallback, that will be remove entirely
    /// in the future. We use ICustomLoadMore interface to provide the load more
    /// function to load more data from server to better adaptation with more state management.
    loadMoreProvider = widget.loadMoreDataProvider?.loadMore;
    assert(loadMoreProvider != null,
        'Must provide load more function to load more data from server.');
    triggerLoadMoreOffset = widget.triggerLoadMoreOffset;

    if (oldWidget == null) {
      bucketGlobal = widget.bucketGlobal ?? PageStorageBucket();
      state = const CustomLoadMoreInitState();
      items = null;
      loadMoreController =
          widget.customLoadMoreController ?? localCustomLoadMoreController;
      localBehaviorStreamSubscription =
          loadMoreController.behaviorStream.stream.listen(evenHandler);
    }
    if (oldWidget != null &&
        !identical(widget.customLoadMoreController,
            oldWidget.customLoadMoreController)) {
      releaseStreamSubscription();
      loadMoreController =
          widget.customLoadMoreController ?? localCustomLoadMoreController;
      localBehaviorStreamSubscription =
          loadMoreController.behaviorStream.stream.listen(evenHandler);
    }
  }

  /// Release Resource Before Update
  void releaseStreamSubscription() {
    localBehaviorStreamSubscription?.cancel();
  }

  /// Event handler
  void evenHandler(CustomLoadMoreEvent event) {
    if (event is CustomLoadMoreEventRetryWhenInitLoadingFailed) {
      firstLoad();
      return;
    }
    if (event is CustomLoadMoreEventRetryWhenLoadMoreFailed) {
      retryLoadMoreFailed();
      return;
    }

    if (event is CustomLoadMoreEventPullToRefresh) {
      firstLoad();
      return;
    }

    if (event is CustomLoadMoreEventScrollToLoadMore) {
      loadMore();
      return;
    }

    if (event is CustomLoadMoreEventErrorOccurred) {
      handelError(errorReason: (event).errorReason);
      return;
    }
  }

  /// Call back when init failed or first load.
  void firstLoad() {
    setState(() {
      items = null;
      state = const CustomLoadMoreInitLoadingState();
    });
    final future = loadMoreProvider?.call(pageIndex, widget.pageSize);
    if (future != null) {
      _executeLoadMore(future).then((value) {
        setState(() {
          items = value;
          if (items?.isEmpty ?? false) {
            state = const CustomLoadMoreInitLoadingSuccessWithNoDataState();
          } else {
            state = const CustomLoadMoreStableState();
          }
        });
      }).catchError((error) {
        setState(() {
          state = CustomLoadMoreInitLoadingFailedState(errorReason: error);
        });
      });
    }
  }

  /// This method is used to handle error.
  void handelError({Exception? errorReason}) {
    setState(() {
      state = CustomLoadMoreInitLoadingFailedState(errorReason: errorReason);
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
    if (future != null) {
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
    if (future != null) {
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

  @override
  Widget build(BuildContext context) {
    return NotificationListener<ScrollNotification>(
      onNotification: (notification) {
        /// That code using to detect user scroll behavior (up or down as vertical and left or right with horizontal).
        /// the orientation obey the [mainAxisDirection] property.
        if (loadMoreController.scrollController.position.userScrollDirection ==
            ScrollDirection.reverse) {
          //('User is going down');
          if (state is CustomLoadMoreNoMoreDataState) {
            return false;
          }
          if (notification.metrics.pixels >
              notification.metrics.maxScrollExtent - triggerLoadMoreOffset) {
            loadMoreController.behaviorStream.sink
                .add(const CustomLoadMoreEventScrollToLoadMore());
          }
          return false;
        }

        if (loadMoreController.scrollController.position.userScrollDirection ==
            ScrollDirection.forward) {
          return false;
        }
        return false;
      },
      child: PageStorage(
        bucket: bucketGlobal,
        child: widget.widgetBuilder(
          context,
          state,
          items,
          loadMoreController,
        ),
      ),
    );
  }

  @override
  void dispose() {
    releaseStreamSubscription();
    localCustomLoadMoreController.dispose();
    super.dispose();
  }
}

class CustomLoadMoreController<T> {
  StreamController<CustomLoadMoreEvent>? _behaviorStreamController;
  ScrollController? _scrollController;
  ValueNotifier<List<T>?>? _valueNotifier;

   _setValueNotifier(ValueNotifier<List<T>?> valueNotifier) {
    _valueNotifier = valueNotifier;
  }

  List<T>? get currentItems {
    if (_valueNotifier != null) return _valueNotifier!.value;
    return null;
  }

  set behaviorStream(StreamController<CustomLoadMoreEvent> behaviorStream) {
    _behaviorStreamController = behaviorStream;
  }

  StreamController<CustomLoadMoreEvent> get behaviorStream {
    if (_behaviorStreamController != null) return _behaviorStreamController!;
    _behaviorStreamController = StreamController<CustomLoadMoreEvent>();
    return _behaviorStreamController!;
  }

  set scrollController(ScrollController scrollController) {
    _scrollController = scrollController;
  }

  ScrollController get scrollController {
    if (_scrollController != null) return _scrollController!;
    _scrollController = ScrollController();
    return _scrollController!;
  }

  void refresh() {
    _behaviorStreamController?.add(const CustomLoadMoreEventPullToRefresh());
  }

  void loadMore() {
    _behaviorStreamController?.add(const CustomLoadMoreEventScrollToLoadMore());
  }

  void retryLoadMore() {
    _behaviorStreamController
        ?.add(const CustomLoadMoreEventRetryWhenLoadMoreFailed());
  }

  void announceLoadMoreFailed({Exception? errorReason}) {
    _behaviorStreamController
        ?.add(CustomLoadMoreEventErrorOccurred(errorReason: errorReason));
  }

  void dispose() {
    _behaviorStreamController?.close();
    _scrollController?.dispose();
  }
}
