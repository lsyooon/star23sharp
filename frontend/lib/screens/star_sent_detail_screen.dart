import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:star23sharp/main.dart';
import 'package:star23sharp/models/index.dart';
import 'package:star23sharp/providers/index.dart';
import 'package:star23sharp/services/index.dart';
import 'package:star23sharp/utilities/date_formatter.dart';
import 'package:star23sharp/utilities/image_zoom_dialog.dart';
import 'package:star23sharp/widgets/index.dart';

class StarSentDetailScreen extends StatelessWidget {
  const StarSentDetailScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final int messageId = ModalRoute.of(context)!.settings.arguments as int;
    final themeProvider = Provider.of<ThemeProvider>(context, listen: false);
    
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
            
            return Container(
              width: UIhelper.deviceWidth(context) * 0.85,
              height: UIhelper.deviceHeight(context) * 0.67,
              color: Colors.white,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    color: themeProvider.mainColor,
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
                            maxHeight: UIhelper.deviceHeight(context) * 0.4,
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
                                    GestureDetector(
                                      onTap: () {
                                        showImageModal(context, item.image!); // 클릭 시 함수 실행
                                      },
                                      child: Image.network(
                                        item.image!,
                                        fit: BoxFit.contain,
                                        width: UIhelper.deviceWidth(context) * 0.8,
                                        height: UIhelper.deviceHeight(context) * 0.25, // 이미지 높이 제한
                                      ),
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
                    padding: const EdgeInsets.only(left: 5.0, bottom: 10),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Divider(
                          color: Colors.grey.withOpacity(0.2), // 수평선 색상
                          thickness: 1, // 수평선 두께
                          endIndent: 5, // 오른쪽 여백
                        ),
                        if(item.recipient != null)
                          Text(
                            '🎉 ${item.recipient}',
                            style: const TextStyle(fontSize: FontSizes.small),
                          ),
                        Text(
                          '👥 ${item.receiverNames.join(', ')}',
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
