import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'screens/home_screen.dart';
import 'screens/splash_screen.dart';
import 'providers/game_provider.dart';
import 'services/audio_service.dart';
import 'services/ad_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // 오디오 서비스 초기화
  await AudioService().initialize();

  // 광고 서비스 초기화 (테스트 모드)
  await AdService().initialize(testMode: true);

  runApp(const WordBujaApp());
}

class WordBujaApp extends StatelessWidget {
  const WordBujaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => GameProvider(),
      child: MaterialApp(
        title: '단어부자',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(
            seedColor: const Color(0xFF4CAF50),
            brightness: Brightness.light,
          ),
          useMaterial3: true,
          fontFamily: 'Pretendard',
        ),
        home: const SplashScreen(),
      ),
    );
  }
}
