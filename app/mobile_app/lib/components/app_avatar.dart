import 'package:cupertino_ui/cupertino_ui.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:luamris_ui/luamris_ui.dart';

import 'app_network_image.dart';

class AppAvatar extends StatelessWidget {
  const AppAvatar({
    super.key,
    this.url,
    this.name,
    this.size = 40,
    this.radius,
    this.isCircle = true,
  });

  final String? url;
  final String? name;
  final double size;
  final double? radius;
  final bool isCircle;

  String _buildInitial(String? name) {
    if (name == null || name.trim().isEmpty) return '?';
    final trimmed = name.trim();
    final parts = trimmed.split(RegExp(r'\s+'));
    if (parts.length >= 2) {
      return (parts[0][0] + parts[parts.length - 1][0]).toUpperCase();
    }
    return trimmed[0].toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    final borderRadius = radius ?? (isCircle ? size / 2 : McRadii.md);
    final avatarUrl = url?.trim();
    final hasImage = avatarUrl != null && avatarUrl.isNotEmpty;
    final resolvedBg = context.mc.secondary;

    Widget? imageWidget;
    if (hasImage) {
      final lowerUrl = avatarUrl.toLowerCase();
      // Use SVG renderer for known SVG formats or DiceBear SVG URLs
      if (lowerUrl.contains('.svg') ||
          lowerUrl.contains('/svg') ||
          (lowerUrl.contains('dicebear.com') &&
              !lowerUrl.contains('/png') &&
              !lowerUrl.contains('/jpg'))) {
        imageWidget = SvgPicture.network(
          avatarUrl,
          width: size,
          height: size,
          fit: BoxFit.cover,
          placeholderBuilder: (context) => Container(
            color: resolvedBg,
            child: const Center(child: CupertinoActivityIndicator(radius: 8)),
          ),
        );
      } else {
        imageWidget = AppNetworkImage(
          url: avatarUrl,
          width: size,
          height: size,
          fit: BoxFit.cover,
          loadingPlaceholder: Container(
            color: resolvedBg,
            child: const Center(child: CupertinoActivityIndicator(radius: 8)),
          ),
          errorPlaceholder: _buildFallback(context),
        );
      }
    }

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: resolvedBg,
        borderRadius: BorderRadius.circular(borderRadius),
      ),
      clipBehavior: Clip.antiAlias,
      alignment: Alignment.center,
      child: hasImage ? imageWidget : _buildFallback(context),
    );
  }

  Widget _buildFallback(BuildContext context) {
    return Text(
      _buildInitial(name),
      style: TextStyle(
        color: context.mc.primary,
        fontWeight: FontWeight.w800,
        fontSize: size * 0.4,
      ),
    );
  }
}
