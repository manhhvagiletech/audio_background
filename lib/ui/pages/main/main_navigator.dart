import 'package:audio_background/ui/pages/main/audio/audio_page.dart';
import 'package:flutter/material.dart';
import 'package:audio_background/utils/navigator_support.dart';

import '../pages.dart';

class MainNavigator extends StatefulWidget {
  const MainNavigator({Key? key}) : super(key: key);

  @override
  _MainNavigatorState createState() => _MainNavigatorState();
}

class _MainNavigatorState extends State<MainNavigator> {
  @override
  Widget build(BuildContext context) {
    return NavigatorSupport(
      initialRoute: 'home',
      onGenerateRoute: (setting) {
        switch (setting.name) {
          case 'home':
            return MaterialPageRoute(builder: (context) => const HomePage());
          case AudioPage.routeName:
            return MaterialPageRoute(builder: (context) => const AudioPage());
        }
      },
    );
  }
}
