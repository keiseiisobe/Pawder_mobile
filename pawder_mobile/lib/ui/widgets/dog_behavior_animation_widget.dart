import 'package:flutter/material.dart';
import '../../models/dog_status_model.dart';

class DogBehaviorAnimationWidget extends StatefulWidget {
  final DogBehavior behavior;
  final double size;
  final Color? color;

  const DogBehaviorAnimationWidget({
    super.key,
    required this.behavior,
    this.size = 100.0,
    this.color,
  });

  @override
  State<DogBehaviorAnimationWidget> createState() =>
      _DogBehaviorAnimationWidgetState();
}

class _DogBehaviorAnimationWidgetState extends State<DogBehaviorAnimationWidget>
    with TickerProviderStateMixin {
  late AnimationController _controller;
  late AnimationController _pulseController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _rotationAnimation;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _setupAnimations();
  }

  void _setupAnimations() {
    // メインアニメーションコントローラー
    _controller = AnimationController(
      duration: _getAnimationDuration(),
      vsync: this,
    );

    // パルスアニメーションコントローラー
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );

    // スケールアニメーション
    _scaleAnimation = Tween<double>(
      begin: 0.8,
      end: 1.2,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    ));

    // 回転アニメーション（震えなどに使用）
    _rotationAnimation = Tween<double>(
      begin: -0.1,
      end: 0.1,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.elasticInOut,
    ));

    // パルスアニメーション
    _pulseAnimation = Tween<double>(
      begin: 1.0,
      end: 1.1,
    ).animate(CurvedAnimation(
      parent: _pulseController,
      curve: Curves.easeInOut,
    ));

    _startAnimation();
  }

  Duration _getAnimationDuration() {
    switch (widget.behavior) {
      case DogBehavior.drinking:
        return const Duration(milliseconds: 800);
      case DogBehavior.playing:
        return const Duration(milliseconds: 600);
      case DogBehavior.resting:
        return const Duration(milliseconds: 2000);
      case DogBehavior.shaking:
        return const Duration(milliseconds: 200);
      case DogBehavior.sniffing:
        return const Duration(milliseconds: 1000);
      case DogBehavior.trotting:
        return const Duration(milliseconds: 400);
      case DogBehavior.walking:
        return const Duration(milliseconds: 1200);
    }
  }

  void _startAnimation() {
    switch (widget.behavior) {
      case DogBehavior.resting:
        _pulseController.repeat(reverse: true);
        break;
      case DogBehavior.shaking:
        _controller.repeat(reverse: true);
        break;
      case DogBehavior.playing:
        _controller.repeat(reverse: true);
        _pulseController.repeat(reverse: true);
        break;
      default:
        _controller.repeat(reverse: true);
        break;
    }
  }

  @override
  void didUpdateWidget(DogBehaviorAnimationWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.behavior != widget.behavior) {
      _controller.stop();
      _pulseController.stop();
      _controller.duration = _getAnimationDuration();
      _startAnimation();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  Widget _buildAnimatedIcon() {
    final iconData = widget.behavior.icon;
    final iconColor = widget.color ?? widget.behavior.color;

    switch (widget.behavior) {
      case DogBehavior.shaking:
        return AnimatedBuilder(
          animation: _rotationAnimation,
          builder: (context, child) {
            return Transform.rotate(
              angle: _rotationAnimation.value,
              child: Icon(
                iconData,
                size: widget.size,
                color: iconColor,
              ),
            );
          },
        );

      case DogBehavior.resting:
        return AnimatedBuilder(
          animation: _pulseAnimation,
          builder: (context, child) {
            return Transform.scale(
              scale: _pulseAnimation.value,
              child: Icon(
                iconData,
                size: widget.size,
                color: iconColor,
              ),
            );
          },
        );

      case DogBehavior.playing:
        return AnimatedBuilder(
          animation: Listenable.merge([_scaleAnimation, _pulseAnimation]),
          builder: (context, child) {
            return Transform.scale(
              scale: _scaleAnimation.value * _pulseAnimation.value,
              child: Icon(
                iconData,
                size: widget.size,
                color: iconColor,
              ),
            );
          },
        );

      case DogBehavior.drinking:
      case DogBehavior.sniffing:
      case DogBehavior.trotting:
      case DogBehavior.walking:
        return AnimatedBuilder(
          animation: _scaleAnimation,
          builder: (context, child) {
            return Transform.scale(
              scale: _scaleAnimation.value,
              child: Icon(
                iconData,
                size: widget.size,
                color: iconColor,
              ),
            );
          },
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: widget.size * 1.5,
      height: widget.size * 1.5,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: widget.behavior.color.withOpacity(0.1),
        border: Border.all(
          color: widget.behavior.color.withOpacity(0.3),
          width: 2,
        ),
      ),
      child: Center(
        child: _buildAnimatedIcon(),
      ),
    );
  }
}

class BatteryIndicatorWidget extends StatelessWidget {
  final int? batteryLevel;
  final double width;
  final double height;

  const BatteryIndicatorWidget({
    super.key,
    required this.batteryLevel,
    this.width = 60,
    this.height = 30,
  });

  @override
  Widget build(BuildContext context) {
    if (batteryLevel == null) {
      return Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(4),
          border: Border.all(color: Colors.grey),
        ),
        child: const Center(
          child: Icon(
            Icons.bluetooth_disabled,
            size: 16,
            color: Colors.grey,
          ),
        ),
      );
    }

    final level = batteryLevel!.clamp(0, 100);
    Color batteryColor;

    if (level > 50) {
      batteryColor = Colors.green;
    } else if (level > 20) {
      batteryColor = Colors.orange;
    } else {
      batteryColor = Colors.red;
    }

    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: Colors.grey),
      ),
      child: Stack(
        children: [
          // バッテリー背景
          Container(
            margin: const EdgeInsets.all(2),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(2),
              color: Colors.grey.shade300,
            ),
          ),
          // バッテリーレベル
          Container(
            margin: const EdgeInsets.all(2),
            child: FractionallySizedBox(
              widthFactor: level / 100,
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(2),
                  color: batteryColor,
                ),
              ),
            ),
          ),
          // バッテリーキャップ
          Positioned(
            right: -4,
            top: height * 0.3,
            child: Container(
              width: 4,
              height: height * 0.4,
              decoration: BoxDecoration(
                color: Colors.grey,
                borderRadius: const BorderRadius.only(
                  topRight: Radius.circular(2),
                  bottomRight: Radius.circular(2),
                ),
              ),
            ),
          ),
          // バッテリーパーセンテージ
          Center(
            child: Text(
              '$level%',
              style: const TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }
}