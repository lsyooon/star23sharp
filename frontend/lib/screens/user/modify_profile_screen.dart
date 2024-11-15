import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:star23sharp/main.dart';
import 'package:star23sharp/providers/index.dart';
import 'package:star23sharp/widgets/index.dart';

class ModifyProfileScreen extends StatefulWidget {
  const ModifyProfileScreen({super.key});

  @override
  _ModifyProfileScreenState createState() => _ModifyProfileScreenState();
}

class _ModifyProfileScreenState extends State<ModifyProfileScreen> {
  int? selectedThemeIndex; // 선택된 테마의 인덱스를 저장

  void _selectTheme(int index) {
    setState(() {
      selectedThemeIndex = index; // 선택된 테마 인덱스를 업데이트
    });
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
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
        Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                "테마 변경",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: FontSizes.title,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 10),
              Container(
                width: UIhelper.deviceWidth(context) * 0.8,
                height: UIhelper.deviceHeight(context) * 0.35,
                decoration: BoxDecoration(
                  color: const Color(0xFFE3E1E1).withOpacity(0.4),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        "테마를 선택해주세요.",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: FontSizes.label,
                        ),
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          _buildThemeOption(0, 'assets/img/theme_black.png'),
                          _buildThemeOption(1, 'assets/img/theme_blue.png'),
                          _buildThemeOption(2, 'assets/img/theme_red.png'),
                        ],
                      ),
                      GestureDetector(
                        onTap: () {
                          if (selectedThemeIndex != null) {
                            logger.d("선택된 테마: $selectedThemeIndex");
                            if(selectedThemeIndex == 0){
                              Provider.of<ThemeProvider>(context, listen: false).setTheme(AppTheme.black);
                            }else if(selectedThemeIndex == 1){
                              Provider.of<ThemeProvider>(context, listen: false).setTheme(AppTheme.blue);
                            }else{
                              Provider.of<ThemeProvider>(context, listen: false).setTheme(AppTheme.red);
                            }
                          }
                        },
                        child: SizedBox(
                          width: UIhelper.deviceWidth(context) * 0.5,
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 16.0),
                            decoration: BoxDecoration(
                              color: const Color(0xFFA292EC).withOpacity(0.6),
                              borderRadius: BorderRadius.circular(8.0),
                            ),
                            child: const Center(
                              child: Text(
                                '변경하기',
                                style: TextStyle(
                                  fontSize: 20.0,
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
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

  Widget _buildThemeOption(int index, String imagePath) {
    return GestureDetector(
      onTap: () => _selectTheme(index),
      child: Container(
        padding: const EdgeInsets.all(15),
        decoration: BoxDecoration(
          color: const Color(0xFFA292EC).withOpacity(0.3),
          borderRadius: BorderRadius.circular(20),
          border: selectedThemeIndex == index
              ? Border.all(color: const Color(0xFFA292EC), width: 3) // 선택된 테마에 테두리 추가
              : null,
        ),
        child: Image.asset(
          imagePath,
          fit: BoxFit.cover,
        ),
      ),
    );
  }
}
