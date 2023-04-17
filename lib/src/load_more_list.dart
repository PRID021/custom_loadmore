import 'package:flutter/material.dart';

import 'load_more_content.dart';
import 'types.dart';

abstract class LoadMoreList<T> extends CustomLoadMoreContent<T> {
  const LoadMoreList(super.key,
      {required super.state,
      required super.mainAxisDirection,
      required super.items,
      required super.scrollController,
      required super.streamController,
      required super.widget});

  List<Widget> buildBody(BuildContext context);

  Widget? buildStateContent(BuildContext context) {
    switch (state) {
      case LoadMoreState.INIT:
        return null;
      case LoadMoreState.INIT_FAILED:
        return null;
      case LoadMoreState.STABLE:
        return null;
      case LoadMoreState.LOAD_MORE:
        return widget.loadMoreBuilder(context);
      case LoadMoreState.LOAD_MORE_FAILED:
        return widget.loadMoreFailedBuilder(context, () {
          streamController.add(LoadMoreEvent.RETRY_WHEN_LOAD_MORE_FAILED);
        });
      case LoadMoreState.NO_MORE:
        return widget.noMoreBuilder(context);
      default:
        return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: ((p0, constrains) {
        double height = constrains.maxHeight;
        double width = constrains.maxWidth;
        return SizedBox(
          width: width,
          height: height,
          child: Stack(
            children: [
              CustomScrollView(
                controller: scrollController,
                scrollDirection: mainAxisDirection,
                physics: const AlwaysScrollableScrollPhysics(),
                slivers: [
                  SliverList(
                    delegate: SliverChildListDelegate(
                      buildBody(context),
                    ),
                  ),
                ],
              ),
              AnimatedScale(
                duration: const Duration(milliseconds: 600),
                scale: (state == LoadMoreState.INIT ||
                        state == LoadMoreState.INIT_FAILED)
                    ? 1
                    : 0,
                child: AnimatedOpacity(
                  duration: const Duration(milliseconds: 600),
                  opacity: (state == LoadMoreState.INIT ||
                          state == LoadMoreState.INIT_FAILED)
                      ? 1
                      : 0,
                  child: _buildInitState(context, state),
                ),
              )
            ],
          ),
        );
      }),
    );
  }

  Widget _buildInitState(BuildContext context, LoadMoreState state) {
    if (state == LoadMoreState.INIT) {
      return Center(
        child: widget.initBuilder(context),
      );
    }
    if (state == LoadMoreState.INIT_FAILED) {
      return Center(
        child: widget.initFailedBuilder(
          context,
          () {
            streamController.add(LoadMoreEvent.RETRY_WHEN_INIT_FAILED);
          },
        ),
      );
    }
    return const SizedBox.shrink();
  }
}

class LoadMoreSequenceList<T> extends LoadMoreList<T> {
  const LoadMoreSequenceList(super.key,
      {required super.state,
      required super.mainAxisDirection,
      required super.items,
      required super.scrollController,
      required super.streamController,
      required super.widget});

  List<Widget> buildListItems(List<T>? items, BuildContext context) {
    if (items == null) {
      return [];
    }
    return items.asMap().entries.map((e) {
      int idx = e.key;
      T item = e.value;
      return widget.listItemBuilder(context, idx, item);
    }).toList();
  }

  @override
  List<Widget> buildBody(BuildContext context) {
    List<Widget> body = [];
    Widget? statusWidget = buildStateContent(context);
    List<Widget> bodyContent = buildListItems(items, context);
    if (statusWidget == null) {
      body = bodyContent;
      return body;
    }
    body = [...bodyContent, statusWidget];
    return body;
  }
}

class LoadMoreSectionList<T, K> extends LoadMoreList<T> {
  final Map<K, List<T>> Function({required List<T> items}) sectionFilter;
  final Widget Function(K key, List<Widget> children) sectionBuilder;
  const LoadMoreSectionList(
    super.key, {
    required super.state,
    required super.mainAxisDirection,
    required super.items,
    required super.scrollController,
    required super.streamController,
    required super.widget,
    required this.sectionBuilder,
    required this.sectionFilter,
  });

  Map<K, List<Widget>> buildMapItems(List<T>? items, BuildContext context) {
    if (items == null) {
      return {};
    }
    final mapItems = sectionFilter(items: items);
    final mapSection = <K, List<Widget>>{};

    for (int i = 0; i < mapItems.length; i++) {
      K key = mapItems.keys.toList()[i];
      List<T>? items = mapItems[key];
      final widgets = items?.map((item) {
        return widget.listItemBuilder(context, items.indexOf(item), item);
      }).toList();
      mapSection[key] = widgets ?? [];
    }
    return mapSection;
  }

  @override
  List<Widget> buildBody(BuildContext context) {
    List<Widget> body = [];
    Widget? statusWidget = buildStateContent(context);
    Map<K, List<Widget>> bodyContentRaw = buildMapItems(items, context);
    List<Widget> bodyContent = bodyContentRaw.entries.map((e) {
      return sectionBuilder(e.key, e.value);
    }).toList();

    if (statusWidget == null) {
      body = bodyContent;

      return body;
    }
    body = [...bodyContent, statusWidget];

    return body;
  }
}
