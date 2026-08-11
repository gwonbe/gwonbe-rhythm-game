import 'package:dungtak/model/song.dart';
import 'package:dungtak/screens/game_screen.dart';

import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';

class HomeScreen extends StatefulWidget {

  final String title;
  const HomeScreen({super.key, required this.title});

  @override
  State<HomeScreen> createState() => _HomeScreenState();

}

class _HomeScreenState extends State<HomeScreen> {

  String _version = "";

  @override
  void initState() {
    super.initState();
    _loadVersion();
  }

  Future<void> _loadVersion() async {
    final packageInfo = await PackageInfo.fromPlatform();
    final version = packageInfo.version;

    // 두자릿수로 맞추기
    final parts = version.split('.');
    final formattedVersion = parts.take(3).map((part) => part.padLeft(2, '0')).join('.');

    if (!mounted) return;
    setState(() { _version = formattedVersion; });
  }

  @override
  Widget build(BuildContext context) {

    final song = Song(
      title: "Sample",
      artist: "Unknown",
      musicPath: "assets/music/sample.mp3",
      beatMapPath: "assets/beatmaps/sample.json",
      imagePath: "",
    );

    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [

            // 시작 버튼
            Expanded(
              child: Center(
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    splashFactory: NoSplash.splashFactory,
                  ),
                  onPressed: () {
                    Navigator.push(
                      context,
                      PageRouteBuilder(
                        pageBuilder: (_, animation, secondaryAnimation) {
                          return GameScreen(song: song);
                        },
                        transitionDuration: Duration.zero,
                        reverseTransitionDuration: Duration.zero,
                      ),
                    );
                  },
                  child: const Text("START"),
                ),
              ),
            ),

            // 버전
            Padding(
              padding: EdgeInsets.all(5),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Text(
                    _version,
                    style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

}