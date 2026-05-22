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
  static const _clockwiseLayout = <int>[0, 1, 3, 2];
  int _initialMinutes = 15;
  static const _playerColors = <Color>[
    Color(0xffff0051),
    Color(0xff4652ff),
    Color(0xffeb83ec),
    Color(0xffffbd08),
  ];

  final List<ValueNotifier<Duration>> _remaining = List.generate(
    4,
    (_) => ValueNotifier<Duration>(Duration(minutes: 15)),
  );
  final List<int> _lifeTotals = List.generate(4, (_) => 40);
  final List<List<int>> _commanderDamage = List.generate(
    4,
    (_) => List.generate(4, (_) => 0),
  );
  late final Timer _timer;
  int _activePlayer = 0;
  int? _lifeControlsPlayer;

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) => _tickClock());
  }

  @override
  void reassemble() {
    super.reassemble();
    for (var i = 0; i < 4; i++) {
      _remaining[i].value = Duration(minutes: _initialMinutes);
    }
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

  void _toggleLifeControls(int playerIndex) {
    setState(() {
      _lifeControlsPlayer =
          _lifeControlsPlayer == playerIndex ? null : playerIndex;
    });
  }

  void _changeLife(int playerIndex, int delta) {
    setState(() {
      _lifeTotals[playerIndex] += delta;
    });
  }

  void _changeCommanderDamage(int fromPlayer, int toPlayer, int delta) {
    setState(() {
      final current = _commanderDamage[fromPlayer][toPlayer];
      final newValue = current + delta;
      if (newValue < 0) {
        return;
      }
      _commanderDamage[fromPlayer][toPlayer] = newValue.clamp(0, 999);
      _lifeTotals[toPlayer] -= delta;
    });
  }

  void _tickClock() {
    if (_lifeControlsPlayer != null) {
      return;
    }

    final currentTime = _remaining[_activePlayer].value;
    if (currentTime == Duration.zero) {
      return;
    }

    final nextTime = currentTime - const Duration(seconds: 1);
    _remaining[_activePlayer].value = nextTime.isNegative ? Duration.zero : nextTime;
  }

  void _resetAll() {
    final start = Duration(minutes: _initialMinutes);
    for (var i = 0; i < 4; i++) {
      _remaining[i].value = start;
      _lifeTotals[i] = 40;
      for (var j = 0; j < 4; j++) {
        _commanderDamage[i][j] = 0;
      }
    }
    setState(() {
      _activePlayer = 0;
      _lifeControlsPlayer = null;
    });
  }

  void _showSettings() {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xff1a1c20),
      builder: (context) {
        var localMinutes = _initialMinutes;
        return StatefulBuilder(
          builder: (context, setSheetState) {
            return Padding(
              padding: const EdgeInsets.fromLTRB(24, 12, 24, 24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 40,
                    height: 4,
                    margin: const EdgeInsets.only(bottom: 16),
                    decoration: BoxDecoration(
                      color: Colors.white24,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  const Text(
                    'Settings',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text(
                        'Initial timer',
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.white10,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: InkWell(
                          borderRadius: BorderRadius.circular(8),
                          onTap: localMinutes > 1
                              ? () => setSheetState(() => localMinutes--)
                              : null,
                          child: const Padding(
                            padding: EdgeInsets.all(8),
                            child: Icon(Icons.remove,
                                color: Colors.white70, size: 28),
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: Text(
                          '$localMinutes min',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 22,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ),
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.white10,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: InkWell(
                          borderRadius: BorderRadius.circular(8),
                          onTap: localMinutes < 99
                              ? () => setSheetState(() => localMinutes++)
                              : null,
                          child: const Padding(
                            padding: EdgeInsets.all(8),
                            child: Icon(Icons.add,
                                color: Colors.white70, size: 28),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton.icon(
                      style: FilledButton.styleFrom(
                        backgroundColor: const Color(0xff1f8a70),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      icon: const Icon(Icons.refresh),
                      label: const Text(
                        'Reset All',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      onPressed: () {
                        _initialMinutes = localMinutes;
                        _resetAll();
                        Navigator.pop(context);
                      },
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
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
                  tooltip: 'Settings',
                  color: Colors.white,
                  iconSize: 40,
                  icon: const Icon(Icons.casino),
                  onPressed: _showSettings,
                ),
              ),
            ),
          ],
      )));
  }

  Widget _buildClockTile(int gridIndex) {
    final playerIndex = _clockwiseLayout[gridIndex];
    final isAnyLifeTracking = _lifeControlsPlayer != null;
    final isThisLifeTracking = playerIndex == _lifeControlsPlayer;
    final isCommanderDmgTracking = isAnyLifeTracking && !isThisLifeTracking;
    return RepaintBoundary(
      child: PlayerClockTile(
        color: _playerColors[playerIndex],
        remainingNotifier: _remaining[playerIndex],
        lifeTotal: _lifeTotals[playerIndex],
        isActive: playerIndex == _activePlayer,
        isLifeTracking: isThisLifeTracking,
        isCommanderDamageTracking: isCommanderDmgTracking,
        commanderDamage: isCommanderDmgTracking
            ? _commanderDamage[playerIndex][_lifeControlsPlayer!]
            : 0,
        playerNumber: playerIndex + 1,
        quarterTurns: gridIndex.isEven ? 1 : 3,
        isEven: gridIndex.isEven,
        onTap: () => _passPriority(playerIndex),
        onLifePressed: () => _toggleLifeControls(playerIndex),
        onLifeChanged: (delta) => _changeLife(playerIndex, delta),
        onCommanderDamageChanged: isCommanderDmgTracking
            ? (delta) => _changeCommanderDamage(playerIndex, _lifeControlsPlayer!, delta)
            : null,
      ),
    );
  }
}

class PlayerClockTile extends StatelessWidget {
  const PlayerClockTile({
    super.key,
    required this.color,
    required this.remainingNotifier,
    required this.lifeTotal,
    required this.isActive,
    required this.isLifeTracking,
    required this.isCommanderDamageTracking,
    required this.commanderDamage,
    required this.playerNumber,
    required this.quarterTurns,
    required this.isEven,
    required this.onTap,
    required this.onLifePressed,
    required this.onLifeChanged,
    this.onCommanderDamageChanged,
  });

  final Color color;
  final ValueNotifier<Duration> remainingNotifier;
  final int lifeTotal;
  final bool isActive;
  final bool isLifeTracking;
  final bool isCommanderDamageTracking;
  final int commanderDamage;
  final int playerNumber;
  final int quarterTurns;
  final bool isEven;
  final VoidCallback onTap;
  final VoidCallback onLifePressed;
  final ValueChanged<int> onLifeChanged;
  final ValueChanged<int>? onCommanderDamageChanged;

  @override
  Widget build(BuildContext context) {
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
        boxShadow: isActive
            ? [
                BoxShadow(
                  color: Colors.white.withValues(alpha: 0.3),
                  blurRadius: 6,
                  spreadRadius: 1,
                ),
              ]
            : null,
      ),
      child: Material(
        color: Colors.transparent,
        child: Stack(
          fit: StackFit.expand,
          children: [
            if (!isLifeTracking && !isCommanderDamageTracking)
              Positioned.fill(
                child: InkWell(
                  borderRadius: BorderRadius.circular(30),
                  onTap: onTap,
                ),
              ),
            if (isLifeTracking)
              _buildLifeAdjusters()
            else if (isCommanderDamageTracking)
              _buildCommanderDamageAdjusters(),
            // else
              // ..._buildMarks(),
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 250),
              child: isLifeTracking
                  ? IgnorePointer(
                      key: const ValueKey('life'),
                      child: Center(
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 28,
                            vertical: 10,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.transparent,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            '$lifeTotal',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 72,
                              fontWeight: FontWeight.w900,
                              height: 1,
                              letterSpacing: 0,
                            ),
                          ),
                        ),
                      ),
                    )
                  : isCommanderDamageTracking
                      ? IgnorePointer(
                          key: const ValueKey('commander'),
                          child: Center(
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 28,
                                vertical: 10,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.black,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                '$commanderDamage',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 64,
                                  fontWeight: FontWeight.w900,
                                  height: 1,
                                  letterSpacing: 0,
                                ),
                              ),
                            ),
                          ),
                        )
                      : _buildTimerText(key: const ValueKey('timer')),
            ),
            _buildPlayerLabel(),
            _buildActiveIndicator(),
            if (!isCommanderDamageTracking) _buildLifeButton(),
          ],
        ),
      ),
    );

    if (quarterTurns == 0) {
      return tile;
    }

    return RotatedBox(quarterTurns: quarterTurns, child: tile);
  }

  Widget _buildLifeAdjusters() {
    return Positioned.fill(
      child: Row(
        children: [
          Expanded(
            child: _LifeAdjustButton(
              icon: Icons.remove,
              onTap: () => onLifeChanged(-1),
            ),
          ),
          Expanded(
            child: _LifeAdjustButton(
              icon: Icons.add,
              onTap: () => onLifeChanged(1),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCommanderDamageAdjusters() {
    return Positioned.fill(
      child: Row(
        children: [
          Expanded(
            child: _LifeAdjustButton(
              icon: Icons.remove,
              onTap: () => onCommanderDamageChanged?.call(-1),
            ),
          ),
          Expanded(
            child: _LifeAdjustButton(
              icon: Icons.add,
              onTap: () => onCommanderDamageChanged?.call(1),
            ),
          ),
        ],
      ),
    );
  }

  List<Widget> _buildMarks() {
    final markColor = Colors.black.withValues(alpha: 0.28);

    return [
      Positioned(
        left: 46,
        top: 0,
        bottom: 0,
        child: Center(
          child: _DecorativeMark(icon: Icons.remove, color: markColor),
        ),
      ),
      Positioned(
        right: 46,
        top: 0,
        bottom: 0,
        child: Center(
          child: _DecorativeMark(icon: Icons.add, color: markColor),
        ),
      ),
    ];
  }

  Widget _buildTimerText({Key? key}) {
    return IgnorePointer(
      key: key,
      child: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 44),
          child: ValueListenableBuilder<Duration>(
            valueListenable: remainingNotifier,
            builder: (context, remaining, _) {
              return Text(
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
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildPlayerLabel() {
    return Positioned(
      right: playerNumber.isEven ? 24 : null,
      left: playerNumber.isEven ? null : 24,
      top: 18,
      child: IgnorePointer(
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
    );
  }

  Widget _buildActiveIndicator() {
    return Positioned(
      right: 22,
      bottom: 18,
      child: IgnorePointer(
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
    );
  }

  Widget _buildLifeButton() {
    return Positioned(
      left: playerNumber.isEven ? 10 : null,
      right: playerNumber.isEven ? null : 10,
      top: 10,
      child: _LifeButton(
        lifeTotal: lifeTotal,
        onPressed: onLifePressed,
      ),
    );
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

class _LifeButton extends StatelessWidget {
  const _LifeButton({required this.lifeTotal, required this.onPressed});

  final int lifeTotal;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return FilledButton(
      style: FilledButton.styleFrom(
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        minimumSize: const Size(72, 42),
        padding: const EdgeInsets.symmetric(horizontal: 16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
      onPressed: onPressed,
      child: Text(
        '$lifeTotal',
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w900,
          letterSpacing: 0,
        ),
      ),
    );
  }
}

class _LifeAdjustButton extends StatelessWidget {
  const _LifeAdjustButton({required this.icon, required this.onTap});

  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.black.withValues(alpha: 0.08),
      child: InkWell(
        onTap: onTap,
        child: SizedBox.expand(
          child: Center(
            child: Icon(
              icon,
              color: Colors.black.withValues(alpha: 0.42),
              size: 76,
            ),
          ),
        ),
      ),
    );
  }
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
