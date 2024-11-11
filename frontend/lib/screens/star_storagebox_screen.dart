import 'package:flutter/material.dart';
import 'package:star23sharp/models/star_list_item_model.dart';
import 'package:star23sharp/services/index.dart';
import 'package:star23sharp/widgets/index.dart';

class StarStoragebox extends StatelessWidget {
  StarStoragebox({super.key});

  final Future<List<StarListItemModel>?> sent = StarService.getStarList(true);
  final Future<List<StarListItemModel>?> receieved =
      StarService.getStarList(false);

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Center(
          child: SizedBox(
            width: MediaQuery.of(context).size.width * 0.85,
            height: MediaQuery.of(context).size.height * 0.67,
            child: Image.asset(
              'assets/img/main_bg.png',
              fit: BoxFit.cover,
            ),
          ),
        ),
        Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                "별모음",
                style: TextStyle(
                    color: Colors.white,
                    fontSize: FontSizes.title,
                    fontWeight: FontWeight.bold),
              ),
              SizedBox(
                width: MediaQuery.of(context).size.width * 0.8,
                height: MediaQuery.of(context).size.height * 0.5,
                child: DefaultTabController(
                  length: 2,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Padding(
                        padding:
                            EdgeInsets.symmetric(horizontal: 8, vertical: 20),
                        child: TabBar(
                          labelColor: Colors.white,
                          unselectedLabelColor: Colors.white70,
                          indicatorColor: Colors.white,
                          labelStyle: TextStyle(
                            fontSize: FontSizes.label,
                            fontFamily: 'Hakgyoansim Chilpanjiugae',
                          ),
                          tabs: [
                            Tab(text: "내가 보낸 별"),
                            Tab(text: "내가 받은 별"),
                          ],
                        ),
                      ),
                      Expanded(
                        child: TabBarView(
                          children: [
                            Container(
                              decoration: BoxDecoration(
                                color: const Color(0xFFE3E1E1).withOpacity(0.4),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: FutureBuilder<List<StarListItemModel>?>(
                                future: sent,
                                builder: (context, snapshot) {
                                  if (snapshot.connectionState ==
                                      ConnectionState.waiting) {
                                    return Center(
                                      child: Image.asset(
                                        "assets/img/logo/loading_logo.gif",
                                        // width: UIhelper.deviceWidth(context) * 0.4, // 별 로고 너비
                                        height: UIhelper.deviceHeight(context) *
                                            0.3, // 별 로고 높이
                                      ),
                                    );
                                  } else if (snapshot.hasError) {
                                    return Center(
                                        child:
                                            Text('Error: ${snapshot.error}'));
                                  } else if (!snapshot.hasData ||
                                      snapshot.data!.isEmpty) {
                                    return const Center(
                                        child: Text('보낸 별이 없습니다.',
                                            style: TextStyle(
                                                fontSize: FontSizes.body,
                                                color: Colors.white)));
                                  } else {
                                    final List<StarListItemModel> itemsData =
                                        snapshot.data!;
                                    return GridView.builder(
                                      padding: EdgeInsets.zero,
                                      gridDelegate:
                                          const SliverGridDelegateWithFixedCrossAxisCount(
                                        crossAxisCount: 1,
                                        childAspectRatio: 5.3, // 작을수록 높이 길어짐
                                        mainAxisSpacing: 5,
                                        crossAxisSpacing: 10,
                                      ),
                                      itemCount: itemsData.length,
                                      itemBuilder: (context, index) {
                                        return Container(
                                          padding: const EdgeInsets.symmetric(
                                              vertical: 2, horizontal: 10),
                                          decoration: BoxDecoration(
                                            color: index % 2 == 1
                                                ? const Color(0xFFF6F6F6)
                                                    .withOpacity(0.2)
                                                : Colors.transparent,
                                          ),
                                          child: ListItem(
                                            item: itemsData[index],
                                          ),
                                        );
                                      },
                                    );
                                  }
                                },
                              ),
                            ),
                            Container(
                              decoration: BoxDecoration(
                                color: const Color(0xFFE3E1E1).withOpacity(0.4),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: FutureBuilder<List<StarListItemModel>?>(
                                future: receieved,
                                builder: (context, snapshot) {
                                  if (snapshot.connectionState ==
                                      ConnectionState.waiting) {
                                    return Center(
                                      child: Image.asset(
                                        "assets/img/logo/loading_logo.gif",
                                        // width: UIhelper.deviceWidth(context) * 0.4, // 별 로고 너비
                                        height: UIhelper.deviceHeight(context) *
                                            0.3, // 별 로고 높이
                                      ),
                                    );
                                  } else if (snapshot.hasError) {
                                    return Center(
                                        child:
                                            Text('Error: ${snapshot.error}'));
                                  } else if (!snapshot.hasData ||
                                      snapshot.data!.isEmpty) {
                                    return const Center(
                                        child: Text(
                                      '받은 별이 없습니다.',
                                      style: TextStyle(
                                          fontSize: FontSizes.body,
                                          color: Colors.white),
                                    ));
                                  } else {
                                    final List<StarListItemModel> itemsData =
                                        snapshot.data!;
                                    return GridView.builder(
                                      padding: EdgeInsets.zero,
                                      gridDelegate:
                                          const SliverGridDelegateWithFixedCrossAxisCount(
                                        crossAxisCount: 1,
                                        childAspectRatio: 5.3,
                                        mainAxisSpacing: 5,
                                        crossAxisSpacing: 10,
                                      ),
                                      itemCount: itemsData.length,
                                      itemBuilder: (context, index) {
                                        return Container(
                                          padding: const EdgeInsets.symmetric(
                                              vertical: 2, horizontal: 10),
                                          decoration: BoxDecoration(
                                            color: index % 2 == 1
                                                ? const Color(0xFFF6F6F6)
                                                    .withOpacity(0.2)
                                                : Colors.white.withOpacity(0),
                                          ),
                                          child: ListItem(
                                            item: itemsData[index],
                                          ),
                                        );
                                      },
                                    );
                                  }
                                },
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
