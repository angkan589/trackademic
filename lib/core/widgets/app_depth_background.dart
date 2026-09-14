import 'package:flutter/material.dart';
import 'package:trackademic/core/theme/app_colors.dart';

class AppDepthBackground extends StatelessWidget {
  final Widget child;

  const AppDepthBackground({required this.child, super.key});

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: AppColors.background,
      child: DecoratedBox(
        decoration: const BoxDecoration(gradient: AppGradients.page),
        child: Stack(
          fit: StackFit.expand,
          children: [
            const IgnorePointer(child: _AmbientShapes()),
            child,
          ],
        ),
      ),
    );
  }
}

class DepthSurface extends StatefulWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;
  final BorderRadius borderRadius;
  final VoidCallback? onTap;

  const DepthSurface({
    required this.child,
    this.padding = const EdgeInsets.all(20),
    this.borderRadius = const BorderRadius.all(Radius.circular(22)),
    this.onTap,
    super.key,
  });

  @override
  State<DepthSurface> createState() => _DepthSurfaceState();
}

class _DepthSurfaceState extends State<DepthSurface> {
  bool _isHovered = false;
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    final isInteractive = widget.onTap != null;
    var offset = 0.0;
    var scale = 1.0;

    if (_isPressed) {
      offset = 2.0;
      scale = 0.985;
    } else if (_isHovered && isInteractive) {
      offset = -2.0;
      scale = 1.008;
    }

    final content = AnimatedScale(
      scale: scale,
      duration: const Duration(milliseconds: 170),
      curve: Curves.easeOutCubic,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 170),
        curve: Curves.easeOutCubic,
        transform: Matrix4.translationValues(0, offset, 0),
        padding: widget.padding,
        decoration: BoxDecoration(
          gradient: AppGradients.surface,
          borderRadius: widget.borderRadius,
          border: Border.all(color: Colors.white.withValues(alpha: 0.92)),
          boxShadow: _isPressed ? AppShadows.soft : AppShadows.raised,
        ),
        child: widget.child,
      ),
    );

    if (!isInteractive) {
      return content;
    }

    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() {
        _isHovered = false;
        _isPressed = false;
      }),
      child: Semantics(
        button: true,
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: widget.onTap,
          onTapDown: (_) => setState(() => _isPressed = true),
          onTapCancel: () => setState(() => _isPressed = false),
          onTapUp: (_) => setState(() => _isPressed = false),
          child: content,
        ),
      ),
    );
  }
}

class DepthIconBadge extends StatelessWidget {
  final IconData icon;
  final Color color;
  final double size;

  const DepthIconBadge({
    required this.icon,
    this.color = AppColors.primary,
    this.size = 48,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Colors.white, color.withValues(alpha: 0.13)],
        ),
        borderRadius: BorderRadius.circular(size * 0.31),
        border: Border.all(color: Colors.white),
        boxShadow: AppShadows.soft,
      ),
      child: Icon(icon, color: color, size: size * 0.52),
    );
  }
}

class _AmbientShapes extends StatelessWidget {
  const _AmbientShapes();

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: const [
        Positioned(
          top: -150,
          right: -100,
          child: _GlowOrb(
            size: 390,
            colors: [Color(0x337892FF), Color(0x006D5CE7)],
          ),
        ),
        Positioned(
          bottom: -170,
          left: -130,
          child: _GlowOrb(
            size: 420,
            colors: [Color(0x2422B8CF), Color(0x003454D1)],
          ),
        ),
      ],
    );
  }
}

class _GlowOrb extends StatelessWidget {
  final double size;
  final List<Color> colors;

  const _GlowOrb({required this.size, required this.colors});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: RadialGradient(colors: colors),
      ),
    );
  }
}
