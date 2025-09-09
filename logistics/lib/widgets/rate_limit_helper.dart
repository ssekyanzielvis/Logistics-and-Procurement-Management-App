import 'dart:async';
import 'package:flutter/material.dart';

class RateLimitHelper extends StatefulWidget {
  final Duration waitTime;
  final VoidCallback? onComplete;
  final String? message;

  const RateLimitHelper({
    super.key,
    required this.waitTime,
    this.onComplete,
    this.message,
  });

  @override
  State<RateLimitHelper> createState() => _RateLimitHelperState();
}

class _RateLimitHelperState extends State<RateLimitHelper> {
  late Timer _timer;
  late Duration _remainingTime;

  @override
  void initState() {
    super.initState();
    _remainingTime = widget.waitTime;
    _startTimer();
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_remainingTime.inSeconds <= 0) {
        timer.cancel();
        widget.onComplete?.call();
        if (mounted) {
          Navigator.of(context).pop();
        }
      } else {
        setState(() {
          _remainingTime = Duration(seconds: _remainingTime.inSeconds - 1);
        });
      }
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final minutes = _remainingTime.inMinutes;
    final seconds = _remainingTime.inSeconds % 60;
    
    return AlertDialog(
      icon: const Icon(
        Icons.timer_outlined,
        color: Colors.orange,
        size: 48,
      ),
      title: const Text('Rate Limit Exceeded'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            widget.message ?? 'Please wait before trying again.',
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.orange.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              minutes > 0 
                ? '${minutes}m ${seconds}s remaining'
                : '${seconds}s remaining',
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.orange,
              ),
            ),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('OK'),
        ),
      ],
    );
  }
}

class RateLimitUtils {
  /// Show rate limit dialog with countdown
  static void showRateLimitDialog(
    BuildContext context, {
    required Duration waitTime,
    String? message,
    VoidCallback? onComplete,
  }) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => RateLimitHelper(
        waitTime: waitTime,
        message: message,
        onComplete: onComplete,
      ),
    );
  }
}
