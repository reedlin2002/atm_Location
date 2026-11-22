import 'package:atmfinder/design/app_theme.dart';
import 'package:flutter/material.dart';

/// 品牌色：與 Android／iOS 圖示和 Play 商店素材一致（方案 B「出鈔口」）。
abstract final class BrandColors {
  static const green = AppTheme.seedColor;
  static const mint = Color(0xFF89F8C7);
  static const slot = Color(0xFFFFFFFF);
  static const slotShadow = Color(0xFF004D36);
}

enum BrandMarkShape { rounded, circle, square }

/// 向量繪製的 App 圖示，任何尺寸都清楚，不需要點陣圖資產。
///
/// 預設視為裝飾，不進入 TalkBack；需要時傳入 [semanticLabel]。
class BrandMark extends StatelessWidget {
  const BrandMark({
    this.size = 48,
    this.shape = BrandMarkShape.rounded,
    this.semanticLabel,
    super.key,
  });

  final double size;
  final BrandMarkShape shape;
  final String? semanticLabel;

  @override
  Widget build(BuildContext context) {
    final mark = CustomPaint(
      size: Size.square(size),
      painter: BrandMarkPainter(shape: shape),
    );
    final label = semanticLabel;
    if (label == null) {
      return ExcludeSemantics(child: mark);
    }
    return Semantics(image: true, label: label, child: mark);
  }
}

class BrandMarkPainter extends CustomPainter {
  const BrandMarkPainter({this.shape = BrandMarkShape.rounded});

  final BrandMarkShape shape;

  /// 圖示以 100×100 的設計座標繪製。
  static const double designSize = 100;

  @override
  void paint(Canvas canvas, Size size) {
    final scale = size.shortestSide / designSize;
    canvas.save();
    canvas.scale(scale);

    const bounds = Rect.fromLTWH(0, 0, designSize, designSize);
    final clip = switch (shape) {
      BrandMarkShape.rounded => RRect.fromRectAndRadius(
        bounds,
        const Radius.circular(22),
      ),
      BrandMarkShape.circle => RRect.fromRectAndRadius(
        bounds,
        const Radius.circular(designSize / 2),
      ),
      BrandMarkShape.square => RRect.fromRectAndRadius(bounds, Radius.zero),
    };
    canvas.clipRRect(clip);

    final paint = Paint()..isAntiAlias = true;
    canvas.drawRect(bounds, paint..color = BrandColors.green);

    // 鈔票
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        const Rect.fromLTWH(30, 35, 40, 38),
        const Radius.circular(4.5),
      ),
      paint..color = BrandColors.mint,
    );

    // 鈔票上的定位點
    final pin = Path()
      ..moveTo(50, 66.5)
      ..cubicTo(45.6, 61.6, 41.5, 57.8, 41.5, 52.6)
      ..arcToPoint(
        const Offset(58.5, 52.6),
        radius: const Radius.circular(8.5),
      )
      ..cubicTo(58.5, 57.8, 54.4, 61.6, 50, 66.5)
      ..close();
    canvas.drawPath(pin, paint..color = BrandColors.green);
    canvas.drawCircle(
      const Offset(50, 52.6),
      3.2,
      paint..color = BrandColors.mint,
    );

    // 出鈔口的陰影與出鈔口
    canvas.drawRect(
      const Rect.fromLTWH(30, 38.5, 40, 3),
      paint..color = BrandColors.slotShadow.withValues(alpha: 0.35),
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        const Rect.fromLTWH(21, 29, 58, 10),
        const Radius.circular(5),
      ),
      paint..color = BrandColors.slot,
    );

    canvas.restore();
  }

  @override
  bool shouldRepaint(BrandMarkPainter oldDelegate) =>
      oldDelegate.shape != shape;
}
