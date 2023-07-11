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
    if(state is CustomLoadMoreInitState){
      return null;
    }
    if(state is  CustomLoadMoreInitLoadingFailedState){
      return null;
    }
    if(state is CustomLoadMoreStableState){
      return null;
    }

    if(state is CustomLoadMoreLoadingMoreState){
      return widget.loadMoreBuilder(context);
    }

    if(state is CustomLoadMoreLoadMoreFailedState){
      Exception? errorReason = (state as CustomLoadMoreLoadMoreFailedState).errorReason;
      return widget.loadMoreFailedBuilder(context, errorReason,() {
        streamController.add(const CustomLoadMoreEventRetryWhenLoadMoreFailed());
      });
    }

    if(state is CustomLoadMoreNoMoreDataState){
      return widget.noMoreBuilder(context);
    }
    return null;
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
                scale: (state is CustomLoadMoreInitState ||  state is CustomLoadMoreInitLoadingState ||
                        state is  CustomLoadMoreInitLoadingFailedState)
                    ? 1
                    : 0,
                child: AnimatedOpacity(
                  duration: const Duration(milliseconds: 600),
                  opacity: (state is CustomLoadMoreInitState || state is CustomLoadMoreInitLoadingState ||
                          state is CustomLoadMoreInitLoadingFailedState)
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

  Widget _buildInitState(BuildContext context, CustomLoadMoreState state) {
    if (state is CustomLoadMoreInitState) {
      return Center(
        child: widget.initBuilder(context),
      );
    }
    if (state is CustomLoadMoreInitLoadingState) {
      return Center(
        child: widget.initLoaderBuilder(context),
      );
    }
    if (state is CustomLoadMoreInitLoadingFailedState) {
      return Center(
        child: widget.initFailedBuilder(
          context,
          state.errorReason,
          () {
            streamController.add(const CustomLoadMoreEventRetryWhenInitLoadingFailed());
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
      return widget.listItemBuilder(context, idx, items);
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

