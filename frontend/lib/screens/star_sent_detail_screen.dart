import 'package:flutter/material.dart';
import 'package:star23sharp/main.dart';
import 'package:star23sharp/models/index.dart';
import 'package:star23sharp/services/index.dart';
import 'package:star23sharp/utilities/date_formatter.dart';
import 'package:star23sharp/widgets/index.dart';

class StarSentDetailScreen extends StatelessWidget {
  const StarSentDetailScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final int messageId = ModalRoute.of(context)!.settings.arguments as int;

    return Center(
      child: FutureBuilder<SentStarModel?>(
        future: StarService.getSentStar(messageId),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            logger.e(snapshot.error);
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData) {
            return const Center(child: Text('별을 조회할 수 없습니다.'));
          } else {
            var item = snapshot.data!;
            final List<String> sortedReceiverNames = [
              if (item.recipient != null && item.receiverNames.contains(item.recipient))
                item.recipient!,
              ...item.receiverNames.where((name) => name != item.recipient),
            ];

            return Container(
              width: UIhelper.deviceWidth(context) * 0.85,
              height: UIhelper.deviceHeight(context) * 0.67,
              color: Colors.white,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    color: const Color(0xFFA292EC),
                    padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 20.0),
                    child: Container(
                      width: UIhelper.deviceWidth(context) * 0.85,
                      alignment: Alignment.center,
                      child: const Text(
                        "보낸 별 보기",
                        style: TextStyle(
                          fontSize: 20.0,
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 15.0),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 15),
                        child: Text(
                          item.title,
                          style: const TextStyle(
                            fontSize: FontSizes.label,
                            color: Colors.black,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 15),
                        child: Container(
                          constraints: BoxConstraints(
                            minWidth: UIhelper.deviceWidth(context) * 0.8,
                            maxHeight: UIhelper.deviceHeight(context) * 0.44,
                          ),
                          decoration: const BoxDecoration(
                            color: Colors.white,
                          ),
                          child: Scrollbar(
                            thumbVisibility: true,
                            child: SingleChildScrollView(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  if (item.image != null)
                                    Image.network(
                                      item.image!,
                                      fit: BoxFit.contain,
                                      width: UIhelper.deviceWidth(context) * 0.8,
                                      height: UIhelper.deviceHeight(context) * 0.3, // 이미지 높이 제한
                                    ),
                                  const SizedBox(height: 10),
                                  Text(
                                    item.content,
                                    style: const TextStyle(
                                      fontSize: 16.0,
                                      color: Colors.black87,
                                      height: 1.5,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const Spacer(),
                  Padding(
                    padding: const EdgeInsets.only(left: 5.0, bottom: 2),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text.rich(
                          TextSpan(
                            children: [
                              const TextSpan(
                                text: '👥 ',
                                style: TextStyle(fontSize: FontSizes.small),
                              ),
                              if (item.recipient != null && sortedReceiverNames.isNotEmpty)
                                TextSpan(
                                  text: sortedReceiverNames.first,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    // decoration: TextDecoration.underline,
                                  ),
                                ),
                              if (item.recipient == null || sortedReceiverNames.length > 1)
                                TextSpan(
                                  text: item.recipient == null
                                      ? sortedReceiverNames.join(', ')
                                      : ', ${sortedReceiverNames.skip(1).join(', ')}',
                                  style: const TextStyle(fontWeight: FontWeight.normal),
                                ),
                            ],
                          ),
                          style: const TextStyle(fontSize: FontSizes.small),
                        ),
                        Text(
                          '📅 ${formatDate(item.createdAt)}',
                          style: const TextStyle(fontSize: FontSizes.small),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          }
        },
      ),
    );
  }
}
