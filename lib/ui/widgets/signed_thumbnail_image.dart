import 'package:flutter/material.dart';

import '../../services/model_asset_service.dart';

/// Renders a thumbnail image from Cloudflare R2 securely via short-lived signed URLs.
/// Never attempts to render unsigned raw R2 asset URLs directly.
class SignedThumbnailImage extends StatefulWidget {
  const SignedThumbnailImage({
    super.key,
    required this.assetKey,
    this.fit = BoxFit.cover,
    this.width = double.infinity,
    this.height = double.infinity,
    this.placeholder,
    this.errorBuilder,
  });

  final String assetKey;
  final BoxFit fit;
  final double width;
  final double height;
  final Widget? placeholder;
  final Widget Function(BuildContext context)? errorBuilder;

  @override
  State<SignedThumbnailImage> createState() => _SignedThumbnailImageState();
}

class _SignedThumbnailImageState extends State<SignedThumbnailImage> {
  String? _signedUrl;
  bool _isLoading = true;
  bool _hasError = false;

  @override
  void initState() {
    super.initState();
    _loadSignedUrl();
  }

  @override
  void didUpdateWidget(SignedThumbnailImage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.assetKey != widget.assetKey) {
      _loadSignedUrl();
    }
  }

  Future<void> _loadSignedUrl() async {
    final key = ModelAssetService.extractKey(widget.assetKey);
    if (key.isEmpty) {
      if (mounted) {
        setState(() {
          _signedUrl = null;
          _isLoading = false;
          _hasError = true;
        });
      }
      return;
    }

    setState(() {
      _isLoading = true;
      _hasError = false;
    });

    final url = await ModelAssetService.generateSignedUrl(key);

    if (!mounted) return;

    if (url != null && url.isNotEmpty && url.contains('token=')) {
      print('[THUMBNAIL_RENDER] key=$key signed=true');
      setState(() {
        _signedUrl = url;
        _isLoading = false;
        _hasError = false;
      });
    } else {
      print('[THUMBNAIL_RENDER] key=$key signed=false');
      setState(() {
        _signedUrl = null;
        _isLoading = false;
        _hasError = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return widget.placeholder ??
          Container(
            width: widget.width,
            height: widget.height,
            color: Theme.of(context).brightness == Brightness.dark
                ? const Color(0xFF1E293B)
                : const Color(0xFFF1F5F9),
            alignment: Alignment.center,
            child: const SizedBox(
              width: 18,
              height: 18,
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
          );
    }

    if (_hasError || _signedUrl == null) {
      return widget.errorBuilder?.call(context) ??
          widget.placeholder ??
          Container(
            width: widget.width,
            height: widget.height,
            color: Theme.of(context).brightness == Brightness.dark
                ? const Color(0xFF1E293B)
                : const Color(0xFFF1F5F9),
            alignment: Alignment.center,
            child: const Icon(Icons.broken_image_rounded, size: 24, color: Colors.grey),
          );
    }

    return Image.network(
      _signedUrl!,
      fit: widget.fit,
      width: widget.width,
      height: widget.height,
      errorBuilder: (context, error, stackTrace) {
        return widget.errorBuilder?.call(context) ??
            Container(
              width: widget.width,
              height: widget.height,
              color: Theme.of(context).brightness == Brightness.dark
                  ? const Color(0xFF1E293B)
                  : const Color(0xFFF1F5F9),
              alignment: Alignment.center,
              child: const Icon(Icons.broken_image_rounded, size: 24, color: Colors.grey),
            );
      },
    );
  }
}
