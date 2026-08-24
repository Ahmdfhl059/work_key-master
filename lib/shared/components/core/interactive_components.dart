part of '../components.dart';

class DefaultButton extends StatelessWidget {
  final double width;
  final double height;
  final Color background;
  final String text;
  final double fontSize;
  final VoidCallback onPress;
  final double borderRadius;
  final Color textColor;
  final bool uppercase;

  const DefaultButton({
    super.key,
    required this.background,
    this.width = double.infinity,
    this.height = 50.0,
    required this.text,
    this.fontSize = 20,
    required this.onPress,
    this.borderRadius = 5,
    this.textColor = Colors.white,
    this.uppercase = true,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final endColor = Color.lerp(background, const Color(0xFF087B3C), .42)!;
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [background, endColor],
        ),
        borderRadius: BorderRadius.circular(borderRadius.clamp(14, 24)),
        border: Border.all(color: Colors.white.withValues(alpha: .14)),
        boxShadow: [
          BoxShadow(
            color: background.withValues(alpha: isDark ? .28 : .34),
            blurRadius: 22,
            offset: const Offset(0, 10),
            spreadRadius: -5,
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(borderRadius.clamp(14, 24)),
          onTap: onPress,
          child: Center(
            child: Text(
              uppercase
                  ? AppLocalizations.of(context).text(text).toUpperCase()
                  : AppLocalizations.of(context).text(text),
              style: TextStyle(
                letterSpacing: .2,
                fontWeight: FontWeight.w800,
                color: textColor,
                fontSize: fontSize.clamp(13, 17),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class ModernRetryButton extends StatefulWidget {
  final FutureOr<void> Function() onRetry;
  final String text;
  final double width;

  const ModernRetryButton({
    super.key,
    required this.onRetry,
    this.text = 'common.retry',
    this.width = 178,
  });

  @override
  State<ModernRetryButton> createState() => _ModernRetryButtonState();
}

class AnimatedPressableCard extends StatefulWidget {
  final Widget child;
  final VoidCallback? onTap;
  final BorderRadius borderRadius;

  const AnimatedPressableCard({
    super.key,
    required this.child,
    this.onTap,
    this.borderRadius = const BorderRadius.all(Radius.circular(24)),
  });

  @override
  State<AnimatedPressableCard> createState() => _AnimatedPressableCardState();
}

class _AnimatedPressableCardState extends State<AnimatedPressableCard> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) => TweenAnimationBuilder<double>(
    tween: Tween(begin: 0, end: 1),
    duration: const Duration(milliseconds: 460),
    curve: Curves.easeOutCubic,
    builder: (context, value, child) => Opacity(
      opacity: value,
      child: Transform.translate(
        offset: Offset(0, 18 * (1 - value)),
        child: child,
      ),
    ),
    child: AnimatedScale(
      scale: _pressed ? .975 : 1,
      duration: const Duration(milliseconds: 130),
      curve: Curves.easeOut,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: widget.onTap,
          onTapDown: widget.onTap == null
              ? null
              : (_) => setState(() => _pressed = true),
          onTapCancel: widget.onTap == null
              ? null
              : () => setState(() => _pressed = false),
          onTapUp: widget.onTap == null
              ? null
              : (_) => setState(() => _pressed = false),
          borderRadius: widget.borderRadius,
          child: widget.child,
        ),
      ),
    ),
  );
}

class _ModernRetryButtonState extends State<ModernRetryButton> {
  bool _loading = false;

  Future<void> _retry() async {
    if (_loading) return;
    setState(() => _loading = true);
    final started = DateTime.now();
    try {
      await Future.sync(widget.onRetry);
    } finally {
      final elapsed = DateTime.now().difference(started);
      if (elapsed < const Duration(milliseconds: 650)) {
        await Future<void>.delayed(const Duration(milliseconds: 650) - elapsed);
      }
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) => AnimatedScale(
    scale: _loading ? .97 : 1,
    duration: const Duration(milliseconds: 180),
    child: SizedBox(
      width: widget.width,
      height: 50,
      child: DecoratedBox(
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [HomeColors.brand, HomeColors.purple],
          ),
          borderRadius: BorderRadius.circular(16),
          boxShadow: const [
            BoxShadow(
              color: Color(0x3529B148),
              blurRadius: 18,
              offset: Offset(0, 8),
            ),
          ],
        ),
        child: FilledButton.icon(
          onPressed: _loading ? null : _retry,
          style: FilledButton.styleFrom(
            disabledBackgroundColor: Colors.transparent,
            backgroundColor: Colors.transparent,
            shadowColor: Colors.transparent,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
          ),
          icon: _loading
              ? const SizedBox.square(
                  dimension: 19,
                  child: CircularProgressIndicator(
                    strokeWidth: 2.3,
                    color: Colors.white,
                  ),
                )
              : const Icon(Icons.refresh_rounded, color: Colors.white),
          label: AnimatedSwitcher(
            duration: const Duration(milliseconds: 180),
            child: Text(
              _loading
                  ? context.tr('common.refreshing')
                  : context.tr(widget.text),
              key: ValueKey(_loading),
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
        ),
      ),
    ),
  );
}
