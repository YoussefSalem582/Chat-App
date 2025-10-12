import 'package:flutter/material.dart';

class VoiceMessageBubble extends StatefulWidget {
  final bool isCurrentUser;
  final Duration duration;
  final VoidCallback onPlay;
  final bool isPlaying;
  final Duration currentPosition;

  const VoiceMessageBubble({
    super.key,
    required this.isCurrentUser,
    required this.duration,
    required this.onPlay,
    this.isPlaying = false,
    this.currentPosition = Duration.zero,
  });

  @override
  State<VoiceMessageBubble> createState() => _VoiceMessageBubbleState();
}

class _VoiceMessageBubbleState extends State<VoiceMessageBubble> {
  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final minutes = twoDigits(duration.inMinutes.remainder(60));
    final seconds = twoDigits(duration.inSeconds.remainder(60));
    return '$minutes:$seconds';
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final progress =
        widget.duration.inSeconds > 0
            ? widget.currentPosition.inSeconds / widget.duration.inSeconds
            : 0.0;

    return Container(
      padding: const EdgeInsets.all(12),
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        gradient:
            widget.isCurrentUser
                ? LinearGradient(
                  colors:
                      isDark
                          ? [Colors.blue.shade700, Colors.blue.shade600]
                          : [Colors.blue.shade500, Colors.blue.shade600],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                )
                : null,
        color:
            !widget.isCurrentUser
                ? (isDark ? Colors.grey.shade800 : Colors.grey.shade200)
                : null,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Play/Pause Button
          GestureDetector(
            onTap: widget.onPlay,
            child: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color:
                    widget.isCurrentUser
                        ? Colors.white.withOpacity(0.3)
                        : (isDark
                            ? Colors.blue.shade700
                            : Colors.blue.shade500),
                shape: BoxShape.circle,
              ),
              child: Icon(
                widget.isPlaying ? Icons.pause : Icons.play_arrow,
                color: widget.isCurrentUser ? Colors.white : Colors.white,
              ),
            ),
          ),
          const SizedBox(width: 12),
          // Waveform/Progress
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Waveform visualization (simplified)
                SizedBox(
                  height: 24,
                  child: Row(
                    children: List.generate(20, (index) {
                      final height = (index % 3 + 1) * 8.0;
                      final isPassed = (index / 20) <= progress;
                      return Container(
                        width: 3,
                        height: height,
                        margin: const EdgeInsets.symmetric(horizontal: 1),
                        decoration: BoxDecoration(
                          color:
                              isPassed
                                  ? (widget.isCurrentUser
                                      ? Colors.white
                                      : (isDark
                                          ? Colors.blue.shade400
                                          : Colors.blue.shade600))
                                  : (widget.isCurrentUser
                                      ? Colors.white.withOpacity(0.3)
                                      : (isDark
                                          ? Colors.grey.shade600
                                          : Colors.grey.shade400)),
                          borderRadius: BorderRadius.circular(2),
                        ),
                      );
                    }),
                  ),
                ),
                const SizedBox(height: 4),
                // Duration
                Text(
                  widget.isPlaying
                      ? _formatDuration(widget.currentPosition)
                      : _formatDuration(widget.duration),
                  style: TextStyle(
                    fontSize: 11,
                    color:
                        widget.isCurrentUser
                            ? Colors.white.withOpacity(0.8)
                            : (isDark
                                ? Colors.grey.shade400
                                : Colors.grey.shade600),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
