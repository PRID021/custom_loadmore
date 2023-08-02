import 'dart:math';

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
              child: CustomListView<int>(
                customLoadMoreController: customLoadMoreController,
                initBuilder: (context) {
                  return const Text("Init");
                },
                initLoaderBuilder: (context) {
                  return const CircularProgressIndicator();
                },
                initFailedBuilder: (context, error) {
                  return Text(" $error");
                },
                initSuccessWithNoDataBuilder: (context) {
                  return const Text("Init success with no data");
                },
                listItemBuilder: (context, index, items) {
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
                loadMoreBuilder: (context) {
                  return const ListTile(
                    title: Center(
                      child: CircularProgressIndicator(),
                    ),
                  );
                },
                loadMoreFailedBuilder: (context, error) {
                  return ListTile(
                    leading: const Text("Load more failed"),
                    trailing: ElevatedButton(
                      onPressed: () {
                        customLoadMoreController.retryLoadMore();
                      },
                      child: const Text("Reload"),
                    ),
                  );
                },
                noMoreBuilder: (context) {
                  return const Text("No more");
                },
                loadMoreDataProvider: MyController(),
              ),
            ),
            const Divider(
              height: 1,
              thickness: 1,
              color: Colors.black,
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

class MyController implements ICustomLoadMoreDataProvider<int> {
  int indexStart = 0;
  int numberItemPerPage = 20;
  final int itemTotalCount = 100;
  bool haveMore = true;

  @override
  Future<List<int>?> loadMore(int pageIndex, int pageSize) async {
    await Future.delayed(const Duration(seconds: 3));
    // return [1,2,3,4];
    if (!haveMore) {
      return [];
    }
    if (Random().nextBool()) {
      throw Exception("Load more failed");
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
