import 'package:flutter/material.dart';
import 'package:star23sharp/constant/font_size.dart';
import 'package:star23sharp/models/index.dart';

class ListItem extends StatelessWidget {
  final StarListItemModel item;

  const ListItem({super.key, required this.item});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        if (item.isSent) {
          Navigator.pushNamed(context, '/star_sent_detail',
              arguments: item.messageId);
        } else {
          Navigator.pushNamed(context, '/star_received_detail',
              arguments: item.messageId);
        }
      },
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        mainAxisSize: MainAxisSize.min,
        children: [
          Expanded(
            flex: 6,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                Image.asset(
                  item.kind == true
                      ? 'assets/icon/yellow_star${item.receiverType != 0 ? '_grp' : ''}.png' // 보물
                      : 'assets/icon/white_star${item.receiverType != 0 ? '_grp' : ''}.png', // 일반
                  width: 25.0,
                  height: 25.0,
                ),
                const SizedBox(width: 15),
                Expanded(
                  child: Text(
                    item.title,
                    style: TextStyle(
                      fontSize: 28,
                      color: Colors.white,
                      fontWeight: item.isSent
                          ? FontWeight.normal
                          : (item.state ? FontWeight.normal : FontWeight.bold),
                    ),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                  ),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Text(
                item.senderNickname,
                style: const TextStyle(
                  fontSize: 20,
                  color: Colors.white,
                ),
                textAlign: TextAlign.end, // 오른쪽 정렬
                overflow: TextOverflow.ellipsis,
              ),
              Text(
                item.createdDate,
                style: TextStyle(
                  fontSize: 20,
                  color: Colors.white.withOpacity(0.8),
                ),
              )
            ],
          ),
        ],
      ),
    );
  }
}
