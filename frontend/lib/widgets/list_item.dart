import 'package:flutter/material.dart';
import 'package:star23sharp/constant/font_size.dart';
import 'package:star23sharp/main.dart';
import 'package:star23sharp/models/index.dart';

class ListItem extends StatelessWidget {
  final StarListItemModel item;

  const ListItem({
    super.key,
    required this.item
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        if(item.isSent){
          Navigator.pushNamed(context, '/star_sent_detail', arguments: item.messageId); 
        }else{
          Navigator.pushNamed(context, '/star_received_detail', arguments: item.messageId); 
        }
      },
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            mainAxisSize: MainAxisSize.min,
            children: [
              Expanded(
                flex: 6,
                child: Row(
                  children: [
                    Image.asset(
                      item.receiverType == 0
                          ? 'assets/icon/yellow_star.png'
                          : 'assets/icon/white_star.png',
                      width: 20.0,
                      height: 20.0,
                    ),
                    const SizedBox(width: 15),
                    Expanded(
                      child: Text(
                        item.title,
                        style: const TextStyle(fontSize: FontSizes.body, color: Colors.white),
                        overflow: TextOverflow.ellipsis,  
                        maxLines: 1, 
                      ),
                    ),
                  ],
                ),
              ),
              // 두 번째 자식 (senderNickname) 비율 3
              Expanded(
                flex: 4,
                child: Text(
                  item.senderNickname,
                  style: const TextStyle(fontSize: 16, color: Colors.white),
                  textAlign: TextAlign.end, // 오른쪽 정렬
                  overflow: TextOverflow.ellipsis,  
                ),
              ),
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Text(item.createdDate, style: TextStyle(color: Colors.white.withOpacity(0.8)),)
            ],
          ),
        ],
      ),
    );
  }
}
