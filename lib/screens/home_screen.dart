import 'package:dungtak/model/song.dart';
import 'package:dungtak/screens/game_screen.dart';

import 'package:flutter/material.dart';

class HomeScreen extends StatefulWidget {

  final String title;
  const HomeScreen({super.key, required this.title});

  @override
  State<HomeScreen> createState() => _HomeScreenState();

}

class _HomeScreenState extends State<HomeScreen> {

  @override
  void initState() {
    super.initState();
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
    );
  }

}