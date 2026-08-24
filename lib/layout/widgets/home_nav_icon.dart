part of '../layout.dart';

class _AnimatedHomeNavIcon extends StatefulWidget {
  final bool selected;
  const _AnimatedHomeNavIcon({required this.selected});

  @override
  State<_AnimatedHomeNavIcon> createState() => _AnimatedHomeNavIconState();
}

class _AnimatedHomeNavIconState extends State<_AnimatedHomeNavIcon>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );
    if (widget.selected) _controller.repeat(reverse: true);
  }

  @override
  void didUpdateWidget(covariant _AnimatedHomeNavIcon oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.selected && !oldWidget.selected) {
      _controller.repeat(reverse: true);
    } else if (!widget.selected && oldWidget.selected) {
      _controller
        ..stop()
        ..value = 0;
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => AnimatedBuilder(
    animation: _controller,
    builder: (context, child) {
      final pulse = widget.selected ? _controller.value : 0.0;
      return Transform.translate(
        offset: Offset(0, widget.selected ? -3 - (pulse * 2) : 0),
        child: Transform.rotate(
          angle: widget.selected ? (pulse - .5) * .06 : 0,
          child: Transform.scale(
            scale: widget.selected ? 1 + (pulse * .07) : 1,
            child: child,
          ),
        ),
      );
    },
    child: AnimatedContainer(
      duration: const Duration(milliseconds: 320),
      width: widget.selected ? 50 : 38,
      height: widget.selected ? 50 : 38,
      padding: EdgeInsets.all(widget.selected ? 5 : 2),
      decoration: BoxDecoration(
        color: widget.selected
            ? Theme.of(context).colorScheme.primaryContainer
            : Colors.transparent,
        shape: BoxShape.circle,
        boxShadow: widget.selected
            ? [
                BoxShadow(
                  color: HomeColors.brand.withValues(alpha: .24),
                  blurRadius: 16,
                  offset: const Offset(0, 7),
                ),
              ]
            : null,
      ),
      child: Image.asset('assets/images/brand_icon.png'),
    ),
  );
}
