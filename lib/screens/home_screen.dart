import 'package:dungtak/data/songs.dart';
import 'package:dungtak/model/song.dart';
import 'package:dungtak/screens/game_music_mode_screen.dart';
import 'package:dungtak/screens/game_spin_mode_screen.dart';
import 'package:dungtak/screens/song_select_screen.dart';
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
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Column(
          children: [
            const Spacer(),

            // 모드 버튼
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(
                  width: screenWidth * 0.3,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      splashFactory: NoSplash.splashFactory,
                    ),
                    onPressed: () {
                      Navigator.push(
                        context,
                        PageRouteBuilder(
                          pageBuilder: (_, animation, secondaryAnimation) {
                            return SongSelectScreen(
                              songs: musicModeSongs,
                              gameScreenBuilder: (Song song) {
                                return GameMusicModeScreen(song: song);
                              },
                              onHome: () {
                                Navigator.popUntil(context, (route) => route.isFirst);
                              },
                            );
                          },
                          transitionDuration: Duration.zero,
                          reverseTransitionDuration: Duration.zero,
                        ),
                      );
                    },
                    child: const Text("MUSIC MODE"),
                  ),
                ),
                SizedBox(
                  width: screenWidth * 0.02,
                ),
                SizedBox(
                  width: screenWidth * 0.3,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      splashFactory: NoSplash.splashFactory,
                    ),
                    onPressed: () {
                      Navigator.push(
                        context,
                        PageRouteBuilder(
                          pageBuilder: (_, animation, secondaryAnimation) {
                            return SongSelectScreen(
                              songs: musicModeSongs,
                              gameScreenBuilder: (Song song) {
                                return GameSpinModeScreen(song: song);
                              },
                              onHome: () {
                                Navigator.pop(context);
                              },
                            );
                          },
                          transitionDuration: Duration.zero,
                          reverseTransitionDuration: Duration.zero,
                        ),
                      );
                    },
                    child: const Text("SPIN MODE"),
                  ),
                ),
              ],
            ),

            const Spacer(),

            // 버전
            Padding(
              padding: const EdgeInsets.all(5),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Text(_version, style: const TextStyle(color: Colors.white70, fontSize: 12)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

}