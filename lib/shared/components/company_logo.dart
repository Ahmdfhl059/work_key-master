import 'package:flutter/material.dart';

class CompanyLogo extends StatelessWidget {
  final String? url;
  final String companyName;
  final double size;
  final Color? backgroundColor;
  final Color? foregroundColor;
  final IconData fallbackIcon;

  const CompanyLogo({
    super.key,
    this.url,
    this.companyName = '',
    this.size = 52,
    this.backgroundColor,
    this.foregroundColor,
    this.fallbackIcon = Icons.business_rounded,
  });

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final fallback = _fallback(colors);
    final imageUrl = url?.trim() ?? '';
    return ClipOval(
      child: SizedBox.square(
        dimension: size,
        child: imageUrl.isEmpty
            ? fallback
            : Image.network(
                imageUrl,
                fit: BoxFit.cover,
                filterQuality: FilterQuality.medium,
                errorBuilder: (_, __, ___) => fallback,
                loadingBuilder: (context, child, progress) =>
                    progress == null ? child : fallback,
              ),
      ),
    );
  }

  Widget _fallback(ColorScheme colors) {
    final letters = companyName
        .trim()
        .split(RegExp(r'\s+'))
        .where((part) => part.isNotEmpty)
        .take(2)
        .map((part) => part[0].toUpperCase())
        .join();
    return ColoredBox(
      color: backgroundColor ?? colors.primaryContainer,
      child: Center(
        child: letters.isEmpty
            ? Icon(
                fallbackIcon,
                color: foregroundColor ?? colors.onPrimaryContainer,
                size: size * .43,
              )
            : Text(
                letters,
                style: TextStyle(
                  color: foregroundColor ?? colors.onPrimaryContainer,
                  fontSize: size * .31,
                  fontWeight: FontWeight.w900,
                ),
              ),
      ),
    );
  }
}
