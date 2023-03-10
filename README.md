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
  custom_loadmore:
    git:
      url: https://github.com/PRID021/custom_loadmore.git
      ref: main
```

2. Run `flutter pub get`.

3. Make sure import this file when use this package. </br>`import 'package:custom_loadmore/custom_loadmore.dart'`

## **Usage**

Here's a short example of how to use the package to implement the load more feature:

```dart
CustomLoadMore<T>(
      customLoadMoreController: widget.customLoadMoreController,
      bucketGlobal: bucketGlobal,
      customScrollableLayoutBuilderInjector:
          MonkeyScrollableLayoutBuilderInjector(),
      mainAxisDirection: Axis.vertical,
      initBuilder: (context) {
        return const Center(child: CircularProgressIndicator());
      },
      loadMoreBuilder: (context) {
        return Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: const [
            Text("Hold on, loading more..."),
            CircularProgressIndicator(),
          ],
        );
      },
      initFailedBuilder: (context, retryCallback) {
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text("init failed"),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white38,
              ),
              onPressed: () {
                retryCallback.call();
              },
              child: const Text("Retry"),
            ),
          ],
        );
      },
      loadMoreFailedBuilder: (context, retryLoadMoreCallback) {
        return Row(
          children: [
            const Text("load more failed"),
            ElevatedButton(
              onPressed: () {
                retryLoadMoreCallback.call();
              },
              child: const Text("Retry"),
            ),
          ],
        );
      },
      noMoreBuilder: (context) {
        return const Center(child: Text("no more"));
      },
      loadMoreCallback: (int pageIndex, int pageSize) async {
        List<T>? response =
            await  getInvoiceList(pageIndex, pageSize);
        return response;
      },
      listItemBuilder: (context, index, item) {
        return Text("item ${item}")
      },
      shrinkWrap: false,
    )
```

A longer example can be found in the `/example` folder.

## **Modifying the Layout**

To change the default layout behavior (the list view layout), follow these steps:
<br>

1. Create new `class` that `extend CustomScrollableLayoutBuilderInjector<T>`. Then override the `buildMainContent` method. This method return an `CustomLoadMoreContent<T>` that abstract the layout appearance.
2. Next you must create a specific implementation of `CustomLoadMoreContent` with scarify your demands by create a class that `extend CustomLoadMoreContent`. The abstract class provide you some necessary property to build your layout.

- `items` : The `List<T>` where you can get the items need to use when build the item widget in the list. Usually it data come from the call to the server.
- `mainAxisDirection`: provide you the scroll direction.
- `scrollController`: support you the ability to manuals the scroll behavior.
- `streamController`: help you more convenience to change the state of load more widget.
- `state` : supplies you the current state of the widget.

3. Attach it new layout injector to `CustomLoadMore`.
   <br>
   Here is example code that demonstrate these above step.

<br>

```dart
1.
class CustomScrollableListViewBuilderInjector<T>
    extends CustomScrollableLayoutBuilderInjector<T> {
  @override
  CustomLoadMoreContent<T> buildMainContent(
    BuildContext context,
    LoadMoreState state,
    List<T>? dataItems,
    ScrollController scrollController,
    StreamController<LoadMoreEvent> streamController,
  ) {
    return LoadMoreList<T>(
      widgetParent.key,
      state: state,
      mainAxisDirection: widgetParent.mainAxisDirection,
      items: dataItems,
      widget: widgetParent,
      scrollController: scrollController,
      streamController: streamController,
    );
  }
}

2.
class LoadMoreList<T> extends CustomLoadMoreContent<T>{
  const LoadMoreList(super.key,
      {required super.state,
      required super.mainAxisDirection,
      required super.items,
      required super.scrollController,
      required super.streamController,
      required super.widget});

  ///
   <!-- ...some other methods -->
  ///
  @override
  Widget build(BuildContext context){
    return yourWidgetLayout(content);
  }
}

3.
CustomLoadMore<T>(
    customScrollableLayoutBuilderInjector: YourNewLayoutInjector(),
    <!-- Some other properties -->
);

```
