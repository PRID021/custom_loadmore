// ignore_for_file: constant_identifier_names

import 'package:flutter/material.dart';

/// The type of [CustomLoadMore] widget.
/// Currently, we support only  [LIST].

enum LoadMoreType {
  LIST,
  SLIVER_LIST,
  GRID,
  SLIVER_GRID,
}


/// An abstract mixin that interface that provide the load more function in order to
/// custom load more widget working with.
///

abstract class ICustomLoadMoreProvider<T>{
  Future<List<T>?> loadMore(int pageIndex, int pageSize);
}


// The state of [CustomLoadMore] widget.

abstract class CustomLoadMoreState{
 const CustomLoadMoreState();
}

class CustomLoadMoreInitState extends CustomLoadMoreState{
  const CustomLoadMoreInitState();
}

class CustomLoadMoreInitFailedState extends CustomLoadMoreState{
  final dynamic errorReason;
  const CustomLoadMoreInitFailedState({this.errorReason});
}

class CustomLoadMoreStableState extends CustomLoadMoreState{
  const CustomLoadMoreStableState();
}
class CustomLoadMoreLoadingMoreState extends CustomLoadMoreState{
  const CustomLoadMoreLoadingMoreState();
}

class CustomLoadMoreLoadMoreFailedState extends CustomLoadMoreState{
  final dynamic errorReason;
  const CustomLoadMoreLoadMoreFailedState({this.errorReason});
}

class CustomLoadMoreNoMoreDataState extends CustomLoadMoreState{
  const CustomLoadMoreNoMoreDataState();
}


// The event of [CustomLoadMore] widget.

abstract class CustomLoadMoreEvent {
  const CustomLoadMoreEvent();
}
class CustomLoadMoreEventRetryWhenInitFailed extends CustomLoadMoreEvent{
  const CustomLoadMoreEventRetryWhenInitFailed();
}

class CustomLoadMoreEventRetryWhenLoadMoreFailed extends CustomLoadMoreEvent{
  const CustomLoadMoreEventRetryWhenLoadMoreFailed();
}

class CustomLoadMoreEventPullToRefresh extends CustomLoadMoreEvent{
  const CustomLoadMoreEventPullToRefresh();
}

class CustomLoadMoreEventScrollToLoadMore extends CustomLoadMoreEvent{
  const CustomLoadMoreEventScrollToLoadMore();
}

class CustomLoadMoreEventErrorOccurred extends CustomLoadMoreEvent{
  final Exception? errorReason;
  const CustomLoadMoreEventErrorOccurred({this.errorReason});
}





typedef InitBuilderDelegate = Widget Function(BuildContext context);
typedef InitFailBuilderDelegate = Widget Function(
    BuildContext context,Exception? errorReason ,VoidCallback retryCallback);
typedef ListItemBuilderDelegate<T> = Widget Function(
    BuildContext context, int index, List<T> items);
typedef LoadMoreBuilderDelegate = Widget Function(BuildContext context);
typedef LoadMoreFailBuilderDelegate = Widget Function(
    BuildContext context,Exception? errorReason ,VoidCallback retryLoadMoreCallback);
typedef NoMoreBuilderDelegate = Widget Function(BuildContext context);

/// The callback function of [CustomLoadMore] widget.
/// It will be called when [CustomLoadMore] widget is initialized or load more.
/// The return value of this function is a [Future] object.
/// If the [Future] object complete with [true] value mean the that callback is successes.
/// null value or [false] value mean the callback is failed.


@Deprecated('Use ICustomLoadMoreProvider instead')
typedef FutureCallback<T> = Future<List<T>?> Function(
    int pageIndex, int pageSize);
