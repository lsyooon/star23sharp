import 'package:flutter/material.dart';
import 'package:star23sharp/models/index.dart';
import 'package:star23sharp/widgets/index.dart';

class MenuList extends StatelessWidget {
  final Function(MenuItem) onItemSelected;
  final bool isMenuTouched;

  const MenuList({
    Key? key,
    required this.onItemSelected,
    required this.isMenuTouched,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        _showMenu(context);
      },
      child: Container(
        width: 50,
        height: 50,
        decoration: const BoxDecoration(),
        child: Image(
          image: AssetImage(
            isMenuTouched
                ? "assets/img/map/close_menu_button.png"
                : "assets/img/map/menu_button.png",
          ),
          fit: BoxFit.cover,
        ),
      ),
    );
  }

  void _showMenu(BuildContext context) {
    showMenu<MenuItem>(
      context: context,
      color: const Color(0xFF505050),
      position: RelativeRect.fromLTRB(
        UIhelper.deviceWidth(context),
        UIhelper.deviceHeight(context) * 0.32,
        UIhelper.deviceWidth(context) * 0.13,
        0,
      ),
      items: MenuItem.values.map((option) {
        return PopupMenuItem<MenuItem>(
          value: option,
          height: 10,
          child: SizedBox(
            width: 130,
            child: ListTile(
              contentPadding: const EdgeInsets.only(left: 16),
              title: Text(
                option.displayText,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                ),
              ),
            ),
          ),
        );
      }).toList(),
    ).then((selectedOption) {
      if (selectedOption != null) {
        onItemSelected(selectedOption);
      }
    });
  }
}
