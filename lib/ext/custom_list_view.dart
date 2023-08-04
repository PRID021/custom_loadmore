import 'package:flutter/material.dart';

import '../custom_loadmore.dart';
import 'custom_list_view_types.dart';



class CustomListView<T> extends StatefulWidget {
  final InitBuilderDelegate initBuilder;
  final InitLoaderBuilderDelegate initLoaderBuilder;
  final InitFailBuilderDelegate initFailedBuilder;
  final InitSuccessWithNoDataBuilderDelegate initSuccessWithNoDataBuilder;
  final ListItemBuilderDelegate<T> listItemBuilder;
  final LoadMoreBuilderDelegate loadMoreBuilder;
  final LoadMoreFailBuilderDelegate loadMoreFailedBuilder;
  final NoMoreBuilderDelegate noMoreBuilder;
  final ICustomLoadMoreDataProvider<T>? loadMoreDataProvider;
  final CustomLoadMoreController<T>? customLoadMoreController;
  final bool shrinkWrap;
  final bool autoRun;
  final Axis scrollDirection;
  final ScrollPhysics physics;

  const CustomListView({
    super.key,
    required this.initBuilder,
    required this.initLoaderBuilder,
    required this.initFailedBuilder,
    required this.initSuccessWithNoDataBuilder,
    required this.listItemBuilder,
    required this.loadMoreBuilder,
    required this.loadMoreFailedBuilder,
    required this.noMoreBuilder,
    required this.loadMoreDataProvider,
    this.customLoadMoreController,
    this.shrinkWrap = false,
    this.autoRun = true,
    this.scrollDirection = Axis.vertical,
    this.physics = const AlwaysScrollableScrollPhysics(),
  });

  @override
  State<CustomListView<T>> createState() => _CustomListViewState<T>();
}

class _CustomListViewState<T> extends State<CustomListView<T>> {
  late CustomLoadMoreController<T> controller;
  final localController = CustomLoadMoreController<T>();

  @override
  void initState() {
    super.initState();
    controller = widget.customLoadMoreController ?? localController;
  }

  @override
  void dispose() {
    super.dispose();
    localController.dispose();
  }

  Widget? buildStateContent(BuildContext context, CustomLoadMoreState state) {
    if (state is CustomLoadMoreInitState) {
      return null;
    }
    if (state is CustomLoadMoreInitLoadingFailedState) {
      return null;
    }
    if (state is CustomLoadMoreStableState) {
      return null;
    }

    if (state is CustomLoadMoreLoadingMoreState) {
      return widget.loadMoreBuilder(context);
    }

    if (state is CustomLoadMoreLoadMoreFailedState) {
      Exception? errorReason = state.errorReason;
      return widget.loadMoreFailedBuilder(context, errorReason);
    }

    if (state is CustomLoadMoreNoMoreDataState) {
      return widget.noMoreBuilder(context);
    }
    return null;
  }

  List<Widget> buildBody(
      BuildContext context, CustomLoadMoreState state, List<T>? items) {
    List<Widget> body = [];
    Widget? statusWidget = buildStateContent(context, state);
    List<Widget> bodyContent = buildListItems(items, context);
    if (statusWidget == null) {
      body = bodyContent;
      return body;
    }
    statusWidget = Center(child: statusWidget);
    body = [...bodyContent, statusWidget];
    return body;
  }

  List<Widget> buildListItems(List<T>? items, BuildContext context) {
    if (items == null) {
      return [];
    }
    return items.asMap().entries.map((e) {
      int idx = e.key;
      return widget.listItemBuilder(context, idx, items);
    }).toList();
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
        ),
      );
    }
    if (state is CustomLoadMoreInitLoadingSuccessWithNoDataState) {
      return Center(
        child: widget.initSuccessWithNoDataBuilder(context),
      );
    }
    return const SizedBox.shrink();
  }

  @override
  Widget build(BuildContext context) {
    return CustomLoadMore<T>(
      customLoadMoreController: controller,
      autoRun: widget.autoRun,
      loadMoreDataProvider: widget.loadMoreDataProvider,
      widgetBuilder: (context, state, items, controller) {
        return CustomScrollView(
          scrollDirection: widget.scrollDirection,
          controller: controller.scrollController,
          shrinkWrap: widget.shrinkWrap,
          physics: widget.physics,
          slivers: [
            SliverList(
              delegate: SliverChildListDelegate(
                buildBody(context, state, items),
              ),
            ),
            SliverFillRemaining(
              hasScrollBody: false,
              child: AnimatedScale(
                duration: const Duration(milliseconds: 600),
                scale: (state is CustomLoadMoreInitState ||
                        state is CustomLoadMoreInitLoadingState ||
                        state is CustomLoadMoreInitLoadingFailedState ||
                        state
                            is CustomLoadMoreInitLoadingSuccessWithNoDataState)
                    ? 1
                    : 0,
                child: AnimatedOpacity(
                  duration: const Duration(milliseconds: 600),
                  opacity: (state is CustomLoadMoreInitState ||
                          state is CustomLoadMoreInitLoadingState ||
                          state is CustomLoadMoreInitLoadingFailedState ||
                          state
                              is CustomLoadMoreInitLoadingSuccessWithNoDataState)
                      ? 1
                      : 0,
                  child: _buildInitState(context, state),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}
