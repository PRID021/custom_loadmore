// ignore_for_file: invalid_sealed_annotation

import 'dart:async';
import 'package:flutter/cupertino.dart';
import 'custom_load_more.dart';
import 'types.dart';

abstract class CustomLoadMoreContent<T> extends StatelessWidget {
  final CustomLoadMoreState state;
  final Axis mainAxisDirection;
  final List<T>? items;
  final CustomLoadMore<T> widget;
  final ScrollController scrollController;
  final bool shrinkWrap;
  final StreamController<CustomLoadMoreEvent> streamController;

  const CustomLoadMoreContent(
    Key? key, {
    required this.state,
    this.mainAxisDirection = Axis.vertical,
    required this.items,
    required this.scrollController,
    required this.widget,
    required this.streamController,
    this.shrinkWrap = false,
  }) : super(key: key);
}
