import 'dart:async';
import 'package:flutter/material.dart';

import 'types.dart';

class CustomLoadMoreController {
  StreamController<CustomLoadMoreEvent>? _behaviorStreamController;
  ScrollController? _scrollController;

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
    _behaviorStreamController?.add(
      const CustomLoadMoreEventPullToRefresh()
    );
  }

  void loadMore() {
    _behaviorStreamController?.add(const CustomLoadMoreEventScrollToLoadMore());
  }

  void retryLoadMore() {
    _behaviorStreamController?.add(const CustomLoadMoreEventRetryWhenLoadMoreFailed());
  }

  void announceLoadMoreFailed({Exception? errorReason}) {
    _behaviorStreamController?.add(CustomLoadMoreEventErrorOccurred(errorReason: errorReason));
  }

  void dispose() {
    _behaviorStreamController?.close();
    _scrollController?.dispose();
  }
}
