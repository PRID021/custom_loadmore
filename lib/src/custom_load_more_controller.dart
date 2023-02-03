import 'dart:async';
import 'package:flutter/material.dart';

import 'types.dart';

class CustomLoadMoreController {
  StreamController<LoadMoreEvent>? _behaviorStreamController;
  ScrollController? _scrollController;

  set behaviorStream(StreamController<LoadMoreEvent> behaviorStream) {
    _behaviorStreamController = behaviorStream;
  }

  StreamController<LoadMoreEvent> get behaviorStream {
    if (_behaviorStreamController != null) return _behaviorStreamController!;
    _behaviorStreamController = StreamController<LoadMoreEvent>();
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
    _behaviorStreamController!.add(
      LoadMoreEvent.PULL_TO_REFRESH,
    );
  }

  void loadMore() {
    _behaviorStreamController?.add(LoadMoreEvent.SCROLL_TO_LOAD_MORE);
  }

  void announceLoadMoreFailed() {
    _behaviorStreamController?.add(LoadMoreEvent.ERROR_OCCURRED);
  }

  void dispose() {
    _behaviorStreamController?.close();
    _scrollController?.dispose();
  }
}
