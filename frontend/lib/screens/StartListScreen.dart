import 'package:flutter/material.dart';
import 'package:star23sharp/models/received_star_model.dart';
import 'package:star23sharp/services/star_service.dart';
import 'package:star23sharp/widgets/index.dart';

class StarListScreen extends StatelessWidget {
  StarListScreen({super.key});

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
    {
      "messageId": 1,
      "title": "테스트 편지1",
      "senderNickname": "레스기릿",
      "receiverType": 0,
      "createdDate": "2024-11-01",
      "kind": false
    },
    {
      "messageId": 1,
      "title": "테스트 편지1",
      "senderNickname": "레스기릿",
      "receiverType": 0,
      "createdDate": "2024-11-01",
      "kind": false
    },
    {
      "messageId": 1,
      "title": "테스트 편지1",
      "senderNickname": "레스기릿",
      "receiverType": 0,
      "createdDate": "2024-11-01",
      "kind": false
    },
  ].map((json) => ReceivedStarModel.fromJson(json)).toList();

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // 배경 이미지
        Center(
          child: SizedBox(
            width: UIhelper.deviceWidth(context) * 0.85,
            height: UIhelper.deviceHeight(context) * 0.67,
            child: Image.asset(
              'assets/img/main_bg.png',
              fit: BoxFit.cover,
            ),
          ),
        ),
        // 로그인 타이틀과 입력 폼을 묶는 Column
        Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // 로그인 타이틀
              const Text(
                "별모음",
                style: TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold),
              ),
              // 여기에 내가 보낸 별 / 내가 받은 별 탭을 만들어줘
              SizedBox(
                width: UIhelper.deviceWidth(context) * 0.8,
                height: UIhelper.deviceHeight(context) * 0.5,
                child: DefaultTabController(
                  length: 2,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // 탭바
                      const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 8, vertical: 20),
                        child: TabBar(
                          labelColor: Colors.white,
                          unselectedLabelColor: Colors.white70,
                          indicatorColor: Colors.white,
                          labelStyle: TextStyle(fontSize: 18),
                          tabs: [
                            Tab(text: "내가 보낸 별"),
                            Tab(text: "내가 받은 별"),
                          ],
                        ),
                      ),
                      // 탭바 뷰
                      Expanded(
                        child: TabBarView(
                          children: [
                            // 내가 보낸 별 리스트
                            const Center(
                              child: Text(
                                "내가 보낸 별 리스트",
                                style: TextStyle(color: Colors.white),
                              ),
                            ),
                            // 내가 받은 별 리스트를 격자 형태로
                            Container(
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.3),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: GridView.builder(
                                padding: EdgeInsets.zero, // padding을 0으로 설정하여 여백 제거
                                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                                  crossAxisCount: 1, // 열의 개수 설정
                                  childAspectRatio: 6, // 아이템 비율
                                  mainAxisSpacing: 5, // 세로 간격
                                  crossAxisSpacing: 10, // 가로 간격
                                ),
                                itemCount: items.length,
                                itemBuilder: (context, index) {
                                  return Container(
                                    padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
                                    decoration: BoxDecoration(
                                      color: index % 2 == 0 ? const Color(0xFFF6F6F6).withOpacity(0.2) : Colors.white.withOpacity(0),
                                    ),
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Row(
                                          children: [
                                            const Icon(Icons.star, color: Colors.yellow),
                                            const SizedBox(width: 15),
                                            Text(
                                              items[index].title,
                                              style: const TextStyle(fontSize: 19, color: Colors.white),
                                            ),
                                          ],
                                        ),
                                        Text(
                                          items[index].senderNickname,
                                          style: const TextStyle(fontSize: 16, color: Colors.white),
                                        ),
                                      ],
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
