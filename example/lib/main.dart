import 'package:flutter/material.dart';
import 'package:custom_loadmore/custom_loadmore.dart';
import 'package:lottie/lottie.dart';
import 'package:number_to_words_english/number_to_words_english.dart';

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

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key, required this.title}) : super(key: key);
  final String title;

  @override
  MyHomePageState createState() => MyHomePageState();
}

class MyHomePageState extends State<MyHomePage> {
  int indexStart = 0;
  int numberItemPerPage = 2000;
  final int itemTotalCount = 6000;
  bool haveMore = true;
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
                  return const Center(child: CircularProgressIndicator());
                },
                onRefresh: () {
                  indexStart = 0;
                  numberItemPerPage = 20;
                  haveMore = true;
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
                        child: const Text("Retry",
                            style: TextStyle(color: Colors.white)),
                      ),
                    ],
                  );
                },
                loadMoreFailedBuilder: (context, retryLoadMoreCallback) {
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
                          Text("$item...."),
                          Lottie.asset('assets/images/test2.json'),
                        ],
                      ),
                    ),
                  );
                },
                loadMoreCallback: (pageIndex, pageSize) async {
                  ScaffoldMessengerState scaffoldMessengerState =
                      ScaffoldMessenger.of(context);
                  await Future.delayed(const Duration(seconds: 1));
                  if (!haveMore) {
                    return [];
                  }
                  var values = List.generate(
                      numberItemPerPage, (index) => index + indexStart);
                  indexStart += numberItemPerPage;

                  SnackBar snackBar = SnackBar(
                    content:
                        Text('Load more success! with ${values.length} items'),
                    duration: const Duration(microseconds: 700),
                  );
                  scaffoldMessengerState.showSnackBar(snackBar);

                  if (indexStart >= itemTotalCount) {
                    haveMore = false;
                  }
                  return values;
                },
                shrinkWrap: false,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
