import 'package:auth_nav/auth_nav.dart';
import 'package:flutter/material.dart';
import 'package:audio_background/initialize_dependencies.dart';
import 'package:audio_background/ui/blocs/blocs.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:just_audio_background/just_audio_background.dart';

import 'application.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await initializeDependencies();
  await JustAudioBackground.init(
    androidNotificationChannelId: "com.mobile.audio_background.channel.audio",
    androidNotificationChannelName: "Audio playback",
    androidNotificationOngoing: true,
  );

  runApp(MultiBlocProvider(
    providers: [
      BlocProvider.value(value: GetIt.instance.get<AuthNavigationBloc>()),
      BlocProvider.value(value: GetIt.instance.get<AuthBloc>())
    ],
    child: const Application(),
  ));
}
