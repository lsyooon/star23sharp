import 'package:flutter/material.dart';
import 'package:star23sharp/constant/font_size.dart';

class ListItem extends StatelessWidget {
  final String title;
  final String senderNickname;
  final int? receiverType, messageId;
  final bool? kind;

  const ListItem({
    super.key,
    required this.title,
    required this.senderNickname,
    this.messageId,
    this.receiverType,
    this.kind,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.pushNamed(context, '/stardetail', arguments: messageId); 
      },
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Image.asset(
                receiverType == 0
                    ? 'assets/icon/yellow_star.png'
                    : 'assets/icon/white_star.png',
                width: 24.0,
                height: 24.0,
              ),
              const SizedBox(width: 15),
              Text(
                title,
                style: const TextStyle(fontSize: FontSizes.label, color: Colors.white),
              ),
            ],
          ),
          Text(
            senderNickname,
            style: const TextStyle(fontSize: FontSizes.body, color: Colors.white),
          ),
        ],
      ),
    );
  }
}
