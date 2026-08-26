import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';
import '../utils/app_fonts.dart';
import '../utils/app_strings.dart';

/// =============================================================================
/// 🎧 WIDGET COMPARTIDO: lib/ui/widgets/audio_player_card.dart
/// =============================================================================
/// Reproductor de audio con textura roja, usado tanto en el detalle de una
/// lección de Listening ([TemaDetalleScreen]) como en las preguntas de
/// Listening dentro de un Simulacro ([SimulacroScreen]) — así el usuario
/// siempre puede escuchar el audio sobre el que le preguntan, sin importar
/// desde qué pantalla llegó.
/// =============================================================================

const Color _kPrimaryRed = Color(0xFFCC0000);
const Color _kCream = Color(0xFFF5E6D0);
const Color _kCreamMuted = Color(0xAAF5E6D0);

class AudioPlayerCard extends StatefulWidget {
  final String? audioFile;

  /// true (por defecto): dibuja su propia textura roja de fondo, para usarse
  /// suelto en una pantalla (como en [TemaDetalleScreen]). false: fondo
  /// transparente, para anidarlo dentro de una tarjeta que YA tiene esa
  /// textura (como la tarjeta de pregunta del Simulacro) y no duplicarla.
  final bool standalone;

  const AudioPlayerCard({
    super.key,
    required this.audioFile,
    this.standalone = true,
  });

  @override
  State<AudioPlayerCard> createState() => _AudioPlayerCardState();
}

class _AudioPlayerCardState extends State<AudioPlayerCard> {
  late final AudioPlayer _audioPlayer;
  StreamSubscription? _positionSubscription;
  StreamSubscription? _durationSubscription;
  StreamSubscription? _playerStateSubscription;
  StreamSubscription? _completeSubscription;

  bool _isPlaying = false;
  Duration _currentPosition = Duration.zero;
  Duration _totalDuration = Duration.zero;

  // true una vez que el audio ya está descargado/preparado, para poder
  // arrancar con resume() (instantáneo) en vez de play() (que vuelve a
  // resolver la fuente desde cero y es lo que causaba el retraso de varios
  // segundos al tocar play).
  bool _fuenteLista = false;

  @override
  void initState() {
    super.initState();
    _audioPlayer = AudioPlayer();
    _audioPlayer.setReleaseMode(ReleaseMode.stop);
    _precargarAudio();

    _positionSubscription = _audioPlayer.onPositionChanged.listen((position) {
      if (mounted) {
        setState(() {
          _currentPosition = position;
        });
      }
    });

    _durationSubscription = _audioPlayer.onDurationChanged.listen((duration) {
      if (mounted) {
        setState(() {
          _totalDuration = duration;
        });
      }
    });

    _playerStateSubscription = _audioPlayer.onPlayerStateChanged.listen((
      state,
    ) {
      if (mounted) {
        setState(() {
          _isPlaying = state == PlayerState.playing;
        });
      }
    });

    _completeSubscription = _audioPlayer.onPlayerComplete.listen((event) {
      if (mounted) {
        setState(() {
          _isPlaying = false;
          _currentPosition = Duration.zero;
        });
      }
    });
  }

  /// Empieza a descargar/preparar el audio apenas se muestra la tarjeta
  /// (mientras el usuario todavía está leyendo la pregunta/lección), para
  /// que cuando toque play ya esté listo y suene al instante.
  Future<void> _precargarAudio() async {
    final audioFile = widget.audioFile;
    if (audioFile == null) return;
    try {
      final String relativePath = audioFile.replaceFirst('assets/', '');
      await _audioPlayer.setSourceAsset(relativePath);
      if (mounted) {
        setState(() => _fuenteLista = true);
      }
    } catch (e) {
      debugPrint('❌ Error precargando audio: $e');
      // Si falla la precarga, el tap en play sigue funcionando: cae al
      // camino normal de play(AssetSource(...)) más abajo.
    }
  }

  @override
  void dispose() {
    _positionSubscription?.cancel();
    _durationSubscription?.cancel();
    _playerStateSubscription?.cancel();
    _completeSubscription?.cancel();
    _audioPlayer.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final random = Random();
    final audioFile = widget.audioFile;
    final controles = Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                Row(
                  children: [
                    GestureDetector(
                      onTap: () async {
                        if (audioFile != null) {
                          try {
                            if (_isPlaying) {
                              await _audioPlayer.pause();
                            } else if (_fuenteLista) {
                              // Camino rápido: el audio ya se precargó en
                              // segundo plano, así que arranca al instante.
                              await _audioPlayer.resume();
                            } else {
                              // La precarga no alcanzó a terminar (tap muy
                              // rápido): sigue funcionando, solo que con la
                              // espera normal de siempre.
                              final String relativePath = audioFile
                                  .replaceFirst('assets/', '');
                              await _audioPlayer.play(
                                AssetSource(relativePath),
                              );
                            }
                          } catch (e) {
                            debugPrint('❌ Error playing audio: $e');
                            if (mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    AppStrings.tr(
                                      'Error al reproducir el audio: $e',
                                      'Error playing audio: $e',
                                    ),
                                  ),
                                  backgroundColor: Colors.red[800],
                                ),
                              );
                            }
                          }
                        }
                      },
                      child: Container(
                        width: 48,
                        height: 48,
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          color: _kPrimaryRed,
                        ),
                        child: Icon(
                          _isPlaying
                              ? Icons.pause_rounded
                              : Icons.play_arrow_rounded,
                          color: _kCream,
                          size: 28,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: SliderTheme(
                        data: SliderTheme.of(context).copyWith(
                          activeTrackColor: _kPrimaryRed,
                          inactiveTrackColor: Colors.white.withOpacity(0.2),
                          thumbColor: _kCream,
                          thumbShape: const RoundSliderThumbShape(
                            enabledThumbRadius: 6.0,
                          ),
                          overlayShape: const RoundSliderOverlayShape(
                            overlayRadius: 12.0,
                          ),
                        ),
                        child: Slider(
                          value: _totalDuration.inMilliseconds > 0
                              ? _currentPosition.inMilliseconds
                                    .toDouble()
                                    .clamp(
                                      0.0,
                                      _totalDuration.inMilliseconds.toDouble(),
                                    )
                              : 0.0,
                          max: _totalDuration.inMilliseconds > 0
                              ? _totalDuration.inMilliseconds.toDouble()
                              : 1.0,
                          onChanged: (value) async {
                            try {
                              await _audioPlayer.seek(
                                Duration(milliseconds: value.toInt()),
                              );
                            } catch (e) {
                              debugPrint('❌ Error seeking audio: $e');
                            }
                          },
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      '${_formatDuration(_currentPosition)} / ${_formatDuration(_totalDuration)}',
                      style: AppFonts.poppins(
                        color: _kCreamMuted,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(20, (index) {
                    return AnimatedContainer(
                      duration: const Duration(milliseconds: 900),
                      curve: Curves.easeInOut,
                      width: 3,
                      height: 8.0 + random.nextDouble() * 16.0,
                      margin: const EdgeInsets.symmetric(horizontal: 2),
                      decoration: BoxDecoration(
                        color: _kPrimaryRed.withOpacity(
                          0.5 + random.nextDouble() * 0.5,
                        ),
                        borderRadius: BorderRadius.circular(2),
                      ),
                    );
                  }),
                ),
              ],
            ),
          );

    if (!widget.standalone) {
      return controles;
    }

    return Container(
      clipBehavior: Clip.hardEdge,
      decoration: BoxDecoration(borderRadius: BorderRadius.circular(16)),
      child: Stack(
        children: [
          Positioned.fill(
            child: Image.asset('assets/images/fondo.jpg', fit: BoxFit.cover),
          ),
          Positioned.fill(
            child: Container(color: Colors.black.withOpacity(0.42)),
          ),
          controles,
        ],
      ),
    );
  }
}

String _formatDuration(Duration d) {
  final m = d.inMinutes.remainder(60).toString().padLeft(2, '0');
  final s = d.inSeconds.remainder(60).toString().padLeft(2, '0');
  return '$m:$s';
}
