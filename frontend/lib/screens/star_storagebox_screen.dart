import 'package:flutter/material.dart';
import 'package:star23sharp/models/received_star_model.dart';
import 'package:star23sharp/widgets/list_item.dart';
import 'package:star23sharp/widgets/index.dart';


class StarStoragebox extends StatelessWidget {
  StarStoragebox({super.key});

  final List<ReceivedStarModel> items = [
    {
      "messageId": 1,
      "title": "테스트 편지1",
      "senderNickname": "레스기릿",
      "receiverType": 0,
      "createdDate": "2024-11-01",
      "kind": false
    },
    {
      "messageId": 2,
      "title": "테스트 편지2",
      "senderNickname": "목용ㅇㅇ빈",
      "receiverType": 0,
      "createdDate": "2024-10-01",
      "kind": false
    },
    {
      "messageId": 3,
      "title": "단체 테스트 편지",
      "senderNickname": "전영주",
      "receiverType": 1,
      "createdDate": "2024-11-01",
      "kind": false
    },
  ].map((json) => ReceivedStarModel.fromJson(json)).toList();

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
                        padding: EdgeInsets.symmetric(horizontal: 8, vertical: 20),
                        child: TabBar(
                          labelColor: Colors.white,
                          unselectedLabelColor: Colors.white70,
                          indicatorColor: Colors.white,
                          labelStyle: TextStyle(fontSize: FontSizes.label, fontFamily: 'Hakgyoansim Chilpanjiugae',), 
                          tabs: [
                            Tab(text: "내가 보낸 별"),
                            Tab(text: "내가 받은 별"),
                          ],
                        ),
                      ),
                      Expanded(
                        child: TabBarView(
                          children: [
                            const Center(
                              child: Text(
                                "내가 보낸 별 리스트",
                                style: TextStyle(color: Colors.white),
                              ),
                            ),
                            Container(
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.3),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: GridView.builder(
                                padding: EdgeInsets.zero,
                                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                                  crossAxisCount: 1,
                                  childAspectRatio: 6,
                                  mainAxisSpacing: 5,
                                  crossAxisSpacing: 10,
                                ),
                                itemCount: items.length,
                                itemBuilder: (context, index) {
                                  return Container(
                                    padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
                                    decoration: BoxDecoration(
                                      color: index % 2 == 0
                                          ? const Color(0xFFF6F6F6).withOpacity(0.2)
                                          : Colors.white.withOpacity(0),
                                    ),
                                    child: ListItem(
                                      title: items[index].title,
                                      senderNickname: items[index].senderNickname,
                                      messageId: items[index].messageId,
                                      receiverType: items[index].receiverType,
                                    ),
                                  );
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
