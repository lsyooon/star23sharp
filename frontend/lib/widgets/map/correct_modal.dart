import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:star23sharp/widgets/index.dart';

class CorrectModal extends StatelessWidget {
  final Map<String, dynamic> markerData;

  const CorrectModal({
    super.key,
    required this.markerData,
  });

  static void show(BuildContext context, Map<String, dynamic> markerData) {
    showDialog(
      context: context,
      builder: (_) => CorrectModal(markerData: markerData),
    );
  }

  @override
  Widget build(BuildContext context) {
    final deviceWidth = UIhelper.deviceWidth(context);
    final deviceHeight = UIhelper.deviceHeight(context);
    return Stack(
      children: [
        Positioned(
          top: deviceHeight * 0.1,
          left: deviceWidth * 0.01,
          right: deviceWidth * 0.01,
          child: Dialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15),
            ),
            child: Container(
              width: deviceWidth,
              height: deviceHeight * 0.5,
              decoration: BoxDecoration(
                color: const Color(0xFF9588E7).withOpacity(0.9),
                borderRadius: BorderRadius.circular(15),
              ),
              child: Stack(
                children: [
                  Align(
                    alignment: Alignment.topRight,
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: IconButton(
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        icon: const Icon(
                          Icons.close,
                          color: Colors.white,
                          size: 24,
                        ),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 28),
                        Center(
                          child: Text(
                            markerData['title'],
                            style: const TextStyle(
                              color: Colors.white70,
                              fontSize: 32,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        const SizedBox(
                          height: 4,
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            Padding(
                              padding: const EdgeInsets.only(right: 16.0),
                              child: Text(
                                DateFormat('yy.MM.d').format(
                                    DateTime.parse(markerData['created_at'])),
                                style: const TextStyle(
                                  color: Colors.white70,
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                        Center(
                          child: Container(
                            width: deviceWidth * 0.65,
                            height: deviceHeight * 0.25,
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.3),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.only(
                                left: 20.0,
                                right: 20.0,
                              ),
                              child: Expanded(
                                child: SingleChildScrollView(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      const SizedBox(height: 8),
                                      Text(
                                        "내용 : ${markerData['content']}",
                                        style: const TextStyle(
                                          color: Colors.black,
                                          fontSize: 24,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      const Text(
                                        "사진 :",
                                        style: TextStyle(
                                          color: Colors.black,
                                          fontSize: 24,
                                        ),
                                      ),
                                      Center(
                                        child: SizedBox(
                                          width: deviceWidth * 0.5,
                                          height: deviceWidth * 0.5,
                                          child: markerData["image"] != null
                                              ? Image.network(
                                                  markerData["image"],
                                                )
                                              : const SizedBox(),
                                        ),
                                      ),
                                      const SizedBox(height: 16),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(
                          height: 16,
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            Padding(
                              padding: const EdgeInsets.only(right: 16.0),
                              child: Text(
                                "${markerData['sender_nickname']}",
                                style: const TextStyle(
                                  color: Colors.white70,
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}
