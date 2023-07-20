import 'package:flutter/material.dart';
import 'package:custom_loadmore/custom_loadmore.dart';
import 'package:lottie/lottie.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

final CustomLoadMoreController customLoadMoreController =
    CustomLoadMoreController();

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key, required this.title}) : super(key: key);
  final String title;

  @override
  MyHomePageState createState() => MyHomePageState();
}

class MyHomePageState extends State<MyHomePage> {
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        extendBodyBehindAppBar: false,
        extendBody: true,
        body: Column(
          children: [
            const SizedBox(
              height: 24,
            ),
            Expanded(
              child: CustomLoadMore<int>(
                // customScrollableLayoutBuilderInjector:
                //     CustomSectionListViewBuilderInjector<int, String>(
                //         sectionFilter: ({required items}) {
                //   Map<String, List<int>> sortedMap = {};
                //   for (int i = 0; i < items.length; i++) {
                //     final value = items[i] ~/ 10;

                //     String collectionName = NumberToWordsEnglish.convert(value);
                //     bool haveCollection =
                //         sortedMap.keys.contains(collectionName);
                //     if (!haveCollection) {
                //       sortedMap[collectionName] = <int>[];
                //     } else {
                //       sortedMap[collectionName]!.add(items[i]);
                //     }
                //   }

                //   return sortedMap;
                // }, sectionBuilder: (key, children) {
                //   return Column(
                //     children: [
                //       Text(key),
                //       Column(
                //         mainAxisSize: MainAxisSize.min,
                //         children: children,
                //       ),
                //     ],
                //   );
                // }),
                initBuilder: (context) {
                  return const Center(child: Text("initBuilder"));
                },
                customLoadMoreController: customLoadMoreController,
                initLoaderBuilder: (context){
                  return const Center(child: CircularProgressIndicator());
                },
                initSuccessWithNoDataBuilder: (context) {
                  return const Center(child: Text("initSuccessWithNoDataBuilder"));
                },
                autoRun: false,
                onRefresh: () {},
                loadMoreBuilder: (context) {
                  return Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: const [
                      Text("Hold on, loading more..."),
                      CircularProgressIndicator(),
                    ],
                  );
                },
                initFailedBuilder: (context, reasonError, retryCallback) {
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
                        child: const Text("Retry",
                            style: TextStyle(color: Colors.white)),
                      ),
                    ],
                  );
                },
                loadMoreFailedBuilder: (context, error, retryLoadMoreCallback) {
                  return Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      const Text("load more failed"),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white38,
                        ),
                        onPressed: () {
                          retryLoadMoreCallback.call();
                        },
                        child: const Text("Retry",
                            style: TextStyle(color: Colors.white)),
                      ),
                    ],
                  );
                },
                noMoreBuilder: (context) {
                  return const Center(child: Text("no more"));
                },
                listItemBuilder: (context, index, item) {
                  return Container(
                    color: Colors.primaries[index % Colors.primaries.length],
                    width: 200,
                    child: Center(
                      child: Column(
                        children: [
                          // Text("$item...."),
                          Lottie.asset('assets/images/test2.json'),
                        ],
                      ),
                    ),
                  );
                },

                loadMoreProvider: MyController(),
                shrinkWrap: false,
              ),
            ),
            const SizedBox(
              height: 24,
            ),
            ElevatedButton(
              onPressed: () {
                customLoadMoreController.refresh();
              },
              child: const Text("Reload"),
            ),
            const SizedBox(
              height: 24,
            ),
          ],
        ),
      ),
    );
  }
}

class MyController implements ICustomLoadMoreProvider<int> {
  int indexStart = 0;
  int numberItemPerPage = 20;
  final int itemTotalCount = 100;
  bool haveMore = true;

  @override
  Future<List<int>?> loadMore(int pageIndex, int pageSize) async {
    await Future.delayed(const Duration(seconds: 3));
    return [];
    if (!haveMore) {
      return [];
    }
    var values =
        List.generate(numberItemPerPage, (index) => index + indexStart);
    indexStart += numberItemPerPage;

    if (indexStart >= itemTotalCount) {
      haveMore = false;
    }
    return values;
  }
}
