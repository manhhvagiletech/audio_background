import 'dart:developer' as developer;

import 'package:audio_background/firebase/firebase_setup.dart';
import 'package:audio_background/initialize_dependencies.dart';
import 'package:audio_background/ui/blocs/blocs.dart';
import 'package:auth_nav/auth_nav.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_downloader/flutter_downloader.dart';
import 'package:get_it/get_it.dart';
import 'package:just_audio_background/just_audio_background.dart';
import 'package:sqflite/sqflite.dart';

import 'application.dart';
import 'dev_firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final firebaseSetup = FirebaseSetup();
  await firebaseSetup.registerNotification();

  await initializeDependencies();
  await JustAudioBackground.init(
    androidNotificationChannelId: "com.mobile.audio_background.channel.audio",
    androidNotificationChannelName: "Audio playback",
    androidNotificationOngoing: true,
  );
  await FlutterDownloader.initialize(
    debug: true,
    ignoreSsl: true,
  );

  runApp(
    MultiBlocProvider(
      providers: [
        BlocProvider.value(value: GetIt.instance.get<AuthNavigationBloc>()),
        BlocProvider.value(value: GetIt.instance.get<AuthBloc>())
      ],
      child: const Application(),
    ),
  );
}
