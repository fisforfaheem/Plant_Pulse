import 'package:flutter/material.dart';

class TabIconData {
  TabIconData({
    required this.imagePath,
    required this.index,
    required this.selectedImagePath,
    required this.isSelected,
    required this.animationController,
    required this.label,
  });

  String imagePath;
  String selectedImagePath;
  bool isSelected;
  int index;
  String label;
  AnimationController? animationController;

  static List<TabIconData> tabIconsList = <TabIconData>[
    TabIconData(
      imagePath: 'assets/images/home-4-128.png',
      selectedImagePath: 'assets/images/home-4-128-selected.png',
      index: 0,
      isSelected: true,
      label: 'Home',
      animationController: null,
    ),
    TabIconData(
      imagePath: 'assets/images/plus-8-128.png',
      selectedImagePath: 'assets/images/plus-8-128-selected.png',
      index: 1,
      isSelected: false,
      label: 'Add Device',
      animationController: null,
    ),
    TabIconData(
      imagePath: 'assets/images/detective-128.png',
      selectedImagePath: 'assets/images/detective-128-selected.png',
      index: 2,
      isSelected: false,
      label: 'Plant ID',
      animationController: null,
    ),
    TabIconData(
      imagePath: 'assets/images/user-6-128.png',
      selectedImagePath: 'assets/images/user-6-128-selected.png',
      index: 3,
      isSelected: false,
      label: 'Me',
      animationController: null,
    ),
  ];
}
