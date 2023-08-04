<!--
This README describes the package. If you publish this package to pub.dev,
this README's contents appear on the landing page for your package.

For information about how to write a good package README, see the guide for
[writing package pages](https://dart.dev/guides/libraries/writing-package-pages).

For general information about developing packages, see the Dart guide for
[creating packages](https://dart.dev/guides/libraries/create-library-packages)
and the Flutter guide for
[developing packages and plugins](https://flutter.dev/developing-packages).
-->

## **INTRODUCTION**

The `custom_loadmore` component is a convenient flutter widget that make implementation load more feature more easier, it provide a flexible and easy to use interface and can integrate with any Flutter project. This give developer focus more on another aspect when development feature also provide ability to control the layout and appearance of UI.

## **Features**

- Load more feature
- Layout modifies ability
- Handing build in ui function.

## **Installation**

To use this in your project, you need follow these steps:

1. In your `pubspec.yaml` file add follow codes

```
dependencies:
  custom_loadmore: ^1.0.0
```

1. Run `flutter pub get`.

2. Make sure import this file when use this package. </br>`import 'package:custom_loadmore/custom_loadmore.dart'`

## **Usage**

1. Create a data provider  implement  `ICustomLoadMoreDataProvider` interface.
```dart
class LoadmoreDataProvider implements ICustomLoadMoreDataProvider<int> {
  @override
  Future<List<int>?> loadMore(int pageIndex, int pageSize) async {
   /// Implement load more data logic
  }
}

```
2. Provide LoadmoreDataProvider to `CustomLoadMore` widget.

 Widget build(BuildContext context) {
  return CustomLoadMore<T>(
      customLoadMoreController: controller,
      autoRun: widget.autoRun,
      loadMoreDataProvider: widget.loadMoreDataProvider,
      widgetBuilder: (context, state, items, controller{
      /// Build your UI here
      }
  );

A longer example can be found in the `/example` folder.

