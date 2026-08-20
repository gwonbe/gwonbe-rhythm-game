import 'dart:async';

import 'package:audioplayers/audioplayers.dart';

import 'package:dungtak/data/songs.dart';
import 'package:dungtak/model/song.dart';
import 'package:dungtak/screens/music_mode_game_screen.dart';

import 'package:flutter/material.dart';

class MusicModeScreen extends StatefulWidget {
  const MusicModeScreen({super.key});

  @override
  State<MusicModeScreen> createState() => _MusicModeScreenState();
}

class _MusicModeScreenState extends State<MusicModeScreen> {

  // 곡 미리듣기
  final AudioPlayer _previewPlayer = AudioPlayer();
  Timer? _previewTimer;
  Timer? _previewDelayTimer;

  // 좌우 이동
  final int _jumpCount = 5;

  // 곡
  int _selectedIndex = 0;
  Song get _selectedSong => musicModeSongs[_selectedIndex];

  // initState
  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _playPreview();
    });
  }

  // dispose
  @override
  void dispose() {
    _previewTimer?.cancel();
    _previewDelayTimer?.cancel();
    _previewPlayer.dispose();

    super.dispose();
  }

  // 곡 이동 - amount 만큼
  void _move(int amount) {
    if (musicModeSongs.isEmpty) return;

    int newIndex = _selectedIndex + amount;
    if (newIndex < 0) newIndex = 0;
    if (newIndex >= musicModeSongs.length) newIndex = musicModeSongs.length - 1;

    if (newIndex == _selectedIndex) return; // 실제로 곡이 바뀐 경우

    setState(() {
      _selectedIndex = newIndex;
    });

    _playPreview();
  }

  // 미리듣기 재생
  Future<void> _playPreview() async {
    _previewTimer?.cancel();
    _previewDelayTimer?.cancel();
    await _previewPlayer.stop();

    final song = _selectedSong;
    await _previewPlayer.setSource(AssetSource(song.musicPath.replaceFirst("assets/", "")));
    await _previewPlayer.seek(song.previewStart);
    await _previewPlayer.resume();

    _previewTimer = Timer(
      song.previewEnd - song.previewStart,
      () async {
        await _previewPlayer.pause();
        _previewDelayTimer = Timer(
          const Duration(seconds: 2),
          () {
            if (mounted) _playPreview();
          },
        );
      },
    );
  }

  // 게임 시작
  Future<void> _startGame() async {
    _previewTimer?.cancel();
    _previewDelayTimer?.cancel();
    await _previewPlayer.stop();

    if (!mounted) return;

    Navigator.push(
      context,
      PageRouteBuilder(
        pageBuilder: (_, animation, secondaryAnimation) {
          return MusicModeGameScreen(
            song: _selectedSong,
          );
        },
        transitionDuration: Duration.zero,
        reverseTransitionDuration: Duration.zero,
      ),
    );
  }

  // 홈으로 이동
  void _goHome() {
    Navigator.popUntil(context, (route) => route.isFirst);
  }

  // 위젯 빌드
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Column(
          children: [

            // 음악 제목 & 아티스트
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 1.0, horizontal: 5.0),
              child: Column(
                children: [
                  Text(
                    _selectedSong.title,
                    textAlign: TextAlign.center,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(
                    height: 3,
                  ),
                  Text(
                    _selectedSong.artist,
                    textAlign: TextAlign.center,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: Colors.white54,
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ),

            // 음악 선택 영역
            Expanded(
              child: Center(
                child: GestureDetector(
                  onHorizontalDragEnd: (details) {
                    if (details.primaryVelocity == null) {
                      return;
                    }
                    // 좌우 이동 동작
                    if (details.primaryVelocity! < 0) {
                      _move(1);
                    } else if (details.primaryVelocity! > 0) {
                      _move(-1);
                    }
                  },
                  // 좌우 이동 버튼 & 앨범 이미지
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Row(
                        mainAxisAlignment:
                        MainAxisAlignment.center,
                        children: [
                          _ArrowButton(
                            icon: Icons.keyboard_double_arrow_left,
                            enabled: _selectedIndex > 0,
                            onPressed: () {
                              _move(-1 * _jumpCount);
                            },
                          ),
                          const SizedBox(
                            width: 8,
                          ),
                          _ArrowButton(
                            icon: Icons.chevron_left,
                            enabled: _selectedIndex > 0,
                            onPressed: () {
                              _move(-1);
                            },
                          ),
                          const SizedBox(
                            width: 20,
                          ),
                          _buildAlbum(),
                          const SizedBox(
                            width: 20,
                          ),
                          _ArrowButton(
                            icon: Icons.chevron_right,
                            enabled:
                            _selectedIndex < musicModeSongs.length - 1,
                            onPressed: () {
                              _move(1);
                            },
                          ),
                          const SizedBox(
                            width: 8,
                          ),
                          _ArrowButton(
                            icon: Icons.keyboard_double_arrow_right,
                            enabled:
                            _selectedIndex < musicModeSongs.length - 1,
                            onPressed: () {
                              _move(_jumpCount);
                            },
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // HOME & PLAY
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                children: [
                  Expanded(
                    child: SizedBox(
                      height: 56,
                      child: ElevatedButton(
                        onPressed: _goHome,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF1A1A1A),
                          foregroundColor: Colors.white,
                          splashFactory: NoSplash.splashFactory,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        child: const Text("HOME", style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold)),
                      ),
                    ),
                  ),
                  SizedBox(width: 18.0),
                  Expanded(
                    child: SizedBox(
                      height: 56,
                      child: ElevatedButton(
                        onPressed: _startGame,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          foregroundColor: Colors.black,
                          splashFactory: NoSplash.splashFactory,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        child: const Text("PLAY", style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold)),
                      ),
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

  // 앨범 이미지
  Widget _buildAlbum() {
    return Container(
      width: 160,
      height: 160,
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A1A),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white24, width: 1),
      ),
      child: _selectedSong.imagePath.isEmpty
        ? const Icon(Icons.music_note, color: Colors.white, size: 80)
        : ClipRRect(borderRadius: BorderRadius.circular(16), child: Image.asset(_selectedSong.imagePath, fit: BoxFit.cover)),
    );
  }

}

// 화살표 버튼
class _ArrowButton extends StatelessWidget {

  final IconData icon;
  final bool enabled;
  final VoidCallback onPressed;

  const _ArrowButton({
    required this.icon,
    required this.enabled,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return IconButton(
      onPressed: enabled ? onPressed : null,
      icon: Icon(
        icon,
        size: 60,
        color: enabled ? Colors.white : Colors.white12,
      ),
      splashColor: Colors.transparent,
      highlightColor: Colors.transparent,
    );
  }

}