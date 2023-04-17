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

/// This enum type using to trace the state of [CustomLoadMore] widget.

enum LoadMoreState {
  INIT,
  INIT_FAILED,
  STABLE,
  LOAD_MORE,
  LOAD_MORE_FAILED,
  NO_MORE,
}

enum LoadMoreEvent {
  RETRY_WHEN_INIT_FAILED,
  RETRY_WHEN_LOAD_MORE_FAILED,
  PULL_TO_REFRESH,
  SCROLL_TO_LOAD_MORE,
  ERROR_OCCURRED,
}

typedef InitBuilderDelegate = Widget Function(BuildContext context);
typedef InitFailBuilderDelegate = Widget Function(
    BuildContext context, VoidCallback retryCallback);
typedef ListItemBuilderDelegate<T> = Widget Function(
    BuildContext context, int index, List<T> items);
typedef LoadMoreBuilderDelegate = Widget Function(BuildContext context);
typedef LoadMoreFailBuilderDelegate = Widget Function(
    BuildContext context, VoidCallback retryLoadMoreCallback);
typedef NoMoreBuilderDelegate = Widget Function(BuildContext context);

/// The callback function of [CustomLoadMore] widget.
/// It will be called when [CustomLoadMore] widget is initialized or load more.
/// The return value of this function is a [Future] object.
/// If the [Future] object complete with [true] value mean the that callback is successes.
/// null value or [false] value mean the callback is failed.

typedef FutureCallback<T> = Future<List<T>?> Function(
    int pageIndex, int pageSize);
