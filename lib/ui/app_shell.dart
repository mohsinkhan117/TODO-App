// lib/app_shell.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:todo_app/ui/app_shell_view_model.dart';
import 'package:todo_app/ui/project_view/project_view.dart';

class AppShell extends StatelessWidget {
  static const String routeName = '/app-shell';
  static Route route() {
    return MaterialPageRoute(
      builder: (context) => ChangeNotifierProvider(
        create: (_) => AppShellViewModel(),
        child: const AppShell(),
      ),
      settings: const RouteSettings(name: routeName),
    );
  }

  final int initialIndex = 0;

  const AppShell({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) {
        final model = AppShellViewModel();
        model.setInitialIndex(initialIndex);
        return model;
      },
      child: Consumer<AppShellViewModel>(
        builder: (context, model, child) {
          return Scaffold(
            body: PageView(
              controller: model.pageController,
              physics: const NeverScrollableScrollPhysics(),
              onPageChanged: model.onPageChanged,
              children: [TodoProject()],
            ),
            bottomNavigationBar: Container(
              decoration: BoxDecoration(
                color: Theme.of(context).navigationBarTheme.backgroundColor,
              ),
              child: BottomNavigationBar(
                currentIndex: model.currentIndex,
                onTap: model.onNavItemTapped,
                type: BottomNavigationBarType.fixed,
                selectedItemColor: Colors.green,
                backgroundColor: Colors.transparent,
                elevation: 0,
                items: const [
                  BottomNavigationBarItem(
                    icon: Icon(Icons.home_max),
                    label: '',
                  ),
                  BottomNavigationBarItem(
                    icon: Icon(Icons.assignment_outlined),
                    label: '',
                  ),
                  BottomNavigationBarItem(
                    icon: Icon(Icons.settings_outlined),
                    label: '',
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
