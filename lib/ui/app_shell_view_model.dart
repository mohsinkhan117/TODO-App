// lib/ui/views/app_shell_view_model.dart

import 'package:flutter/material.dart';

class AppShellViewModel extends ChangeNotifier {
  int _currentIndex = 0;
  final PageController pageController = PageController();

  int get currentIndex => _currentIndex;

  void setInitialIndex(int index) {
    _currentIndex = index;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      pageController.jumpToPage(index);
    });
  }

  void onNavItemTapped(int index) {
    _currentIndex = index;
    pageController.jumpToPage(index);
    notifyListeners();
  }

  void onPageChanged(int index) {
    _currentIndex = index;
    notifyListeners();
  }
}
