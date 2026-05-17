import 'dart:async';
import 'dart:ui';

import 'package:flutter/material.dart';

void main() {
  runApp(const EdhChessClockApp());
}

class EdhChessClockApp extends StatelessWidget {
  const EdhChessClockApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'EDH Chess Clock',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xff1f8a70)),
        useMaterial3: true,
      ),
      home: const ClockTableScreen(),
    );
  }
}

class ClockTableScreen extends StatefulWidget {
  const ClockTableScreen({super.key});

  @override
  State<ClockTableScreen> createState() => _ClockTableScreenState();
}

class _ClockTableScreenState extends State<ClockTableScreen> {
  static const _startingTime = Duration(minutes: 15);
  static const _clockwiseLayout = <int>[0, 1, 3, 2];
  static const _playerColors = <Color>[
    Color(0xffff0051),
    Color(0xff4652ff),
    Color(0xffeb83ec),
    Color(0xffffbd08),
  ];

  final List<Duration> _remaining = List.generate(4, (_) => _startingTime);
  late final Timer _timer;
  int _activePlayer = 0;

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) => _tickClock());
  }

  @override
  void reassemble() {
    super.reassemble();
    _resetClocks();
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  void _passPriority(int playerIndex) {
    if (playerIndex != _activePlayer) {
      return;
    }

    setState(() {
      _activePlayer = (_activePlayer + 1) % _remaining.length;
    });
  }

  void _tickClock() {
    final currentTime = _remaining[_activePlayer];
    if (currentTime == Duration.zero) {
      return;
    }

    setState(() {
      final nextTime = currentTime - const Duration(seconds: 1);
      _remaining[_activePlayer] = nextTime.isNegative ? Duration.zero : nextTime;
    });
  }

  void _resetClocks() {
    setState(() {
      for (var index = 0; index < _remaining.length; index++) {
        _remaining[index] = _startingTime;
      }
      _activePlayer = 0;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xff111318),
      body: SafeArea(
        child: Stack(
          children: [
            Padding(
              padding: const EdgeInsets.all(10),
              child: Column(
                children: [
                  Expanded(
                    child: Row(
                      children: [
                        Expanded(child: _buildClockTile(0)),
                        const SizedBox(width: 10),
                        Expanded(child: _buildClockTile(1)),
                      ],
                    ),
                  ),
                  const SizedBox(height: 10),
                  Expanded(
                    child: Row(
                      children: [
                        Expanded(child: _buildClockTile(2)),
                        const SizedBox(width: 10),
                        Expanded(child: _buildClockTile(3)),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Center(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  color: const Color(0xff111318),
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: Colors.black, width: 8),
                ),
                child: IconButton(
                  tooltip: 'Reset clocks',
                  color: Colors.white,
                  iconSize: 40,
                  icon: const Icon(Icons.casino),
                  onPressed: _resetClocks,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildClockTile(int gridIndex) {
    final playerIndex = _clockwiseLayout[gridIndex];
    return PlayerClockTile(
      color: _playerColors[playerIndex],
      remaining: _remaining[playerIndex],
      isActive: playerIndex == _activePlayer,
      playerNumber: playerIndex + 1,
      quarterTurns: gridIndex.isEven ? 1 : 3,
      onTap: () => _passPriority(playerIndex),
    );
  }
}

class PlayerClockTile extends StatelessWidget {
  const PlayerClockTile({
    super.key,
    required this.color,
    required this.remaining,
    required this.isActive,
    required this.playerNumber,
    required this.quarterTurns,
    required this.onTap,
  });

  final Color color;
  final Duration remaining;
  final bool isActive;
  final int playerNumber;
  final int quarterTurns;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final markColor = Colors.black.withValues(alpha: 0.28);
    final tile = AnimatedContainer(
      duration: const Duration(milliseconds: 180),
      curve: Curves.easeOut,
      decoration: BoxDecoration(
        color: isActive ? color : Color.alphaBlend(Colors.white10, color),
        borderRadius: BorderRadius.circular(30),
        border: Border.all(
          color: isActive ? Colors.black : Colors.transparent,
          width: isActive ? 6 : 0,
        ),
        boxShadow: [
          if (isActive)
            BoxShadow(
              color: Colors.white.withValues(alpha: 0.3),
              blurRadius: 18,
              spreadRadius: 1,
            ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(30),
          onTap: onTap,
          child: Stack(
            fit: StackFit.expand,
            children: [
              Positioned(
                left: 46,
                top: 0,
                bottom: 0,
                child: Center(
                  child: _DecorativeMark(icon: Icons.add, color: markColor),
                ),
              ),
              Positioned(
                right: 46,
                top: 0,
                bottom: 0,
                child: Center(
                  child: _DecorativeMark(icon: Icons.remove, color: markColor),
                ),
              ),
              Center(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 44),
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Text(
                      _formatDuration(remaining),
                      key: ValueKey('player-$playerNumber-timer'),
                      style: const TextStyle(
                        color: Colors.black,
                        fontFeatures: [FontFeature.tabularFigures()],
                        fontSize: 128,
                        fontWeight: FontWeight.w900,
                        height: 0.9,
                        letterSpacing: 0,
                      ),
                    ),
                  ),
                ),
              ),
              Positioned(
                left: 24,
                top: 18,
                child: AnimatedOpacity(
                  duration: const Duration(milliseconds: 180),
                  opacity: isActive ? 1 : 0.46,
                  child: Text(
                    'P$playerNumber',
                    style: TextStyle(
                      color: Colors.black.withValues(alpha: 0.56),
                      fontSize: 18,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 0,
                    ),
                  ),
                ),
              ),
              Positioned(
                right: 22,
                bottom: 18,
                child: AnimatedOpacity(
                  duration: const Duration(milliseconds: 180),
                  opacity: isActive ? 1 : 0,
                  child: const Icon(
                    Icons.play_arrow_rounded,
                    color: Colors.black,
                    size: 34,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );

    if (quarterTurns == 0) {
      return tile;
    }

    return RotatedBox(quarterTurns: quarterTurns, child: tile);
  }

  static String _formatDuration(Duration duration) {
    final totalSeconds = duration.inSeconds;
    final hours = totalSeconds ~/ 3600;
    final minutes = (totalSeconds % 3600) ~/ 60;
    final seconds = totalSeconds % 60;

    if (hours > 0) {
      return '$hours:${_twoDigits(minutes)}:${_twoDigits(seconds)}';
    }

    return '$minutes:${_twoDigits(seconds)}';
  }

  static String _twoDigits(int value) => value.toString().padLeft(2, '0');
}

class _DecorativeMark extends StatelessWidget {
  const _DecorativeMark({required this.icon, required this.color});

  final IconData icon;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: Icon(icon, color: color, size: 52),
    );
  }
}
