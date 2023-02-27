import 'package:flutter/material.dart';
import 'package:audio_background/utils/navigator_support.dart';

import '../pages.dart';

class AuthenticationNavigator extends StatefulWidget {
  const AuthenticationNavigator({Key? key}) : super(key: key);

  @override
  _AuthenticationNavigatorState createState() =>
      _AuthenticationNavigatorState();
}

class _AuthenticationNavigatorState extends State<AuthenticationNavigator> {
  @override
  Widget build(BuildContext context) {
    return NavigatorSupport(
      initialRoute: 'login',
      onGenerateRoute: (settings) {
        return MaterialPageRoute(builder: (context) => const SignInPage());
      },
    );
  }
}
