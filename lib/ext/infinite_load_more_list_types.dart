
import 'package:flutter/material.dart';

typedef InitBuilderDelegate = Widget Function(BuildContext context);
typedef InitLoaderBuilderDelegate = Widget Function(BuildContext context);
typedef InitFailBuilderDelegate = Widget Function(
    BuildContext context,dynamic errorReason);
typedef InitSuccessWithNoDataBuilderDelegate = Widget Function(
    BuildContext context);

typedef ListItemBuilderDelegate<T> = Widget Function(
    BuildContext context, int index, List<T> items);
typedef LoadMoreBuilderDelegate = Widget Function(BuildContext context);
typedef LoadMoreFailBuilderDelegate = Widget Function(
    BuildContext context,dynamic errorReason);
typedef NoMoreBuilderDelegate = Widget Function(BuildContext context);


