import 'package:flutter/material.dart';

class AnimatedListItem extends StatelessWidget {
  const AnimatedListItem({
    required this.index,
    required this.child,
    this.duration = const Duration(milliseconds: 420),
    super.key,
  });

  final int index;
  final Widget child;
  final Duration duration;

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: duration + Duration(milliseconds: index * 55),
      curve: Curves.easeOutCubic,
      builder: (context, value, child) {
        return Opacity(
          opacity: value,
          child: Transform.translate(
            offset: Offset(0, 18 * (1 - value)),
            child: child,
          ),
        );
      },
      child: child,
    );
  }
}
