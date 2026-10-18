import 'dart:math' as math;

import 'package:cupertino_ui/cupertino_ui.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/scheduler.dart';

/// PageView that sizes itself to the natural height of its pages.
///
/// PageView forces every laid-out page to match the viewport size, and it lays
/// out neighbouring pages while swiping. This widget therefore lays out an
/// offstage copy of every page (at the same width but with unbounded height)
/// and constrains the PageView to the tallest of them — otherwise switching
/// back from a short tab to a tall one would overflow it. This lets the
/// widget live inside a page-level scroll view.
class AutoSizedPageView extends StatefulWidget {
  const AutoSizedPageView({
    super.key,
    required this.controller,
    required this.children,
    this.onPageChanged,
  });

  final PageController controller;
  final List<Widget> children;
  final ValueChanged<int>? onPageChanged;

  @override
  State<AutoSizedPageView> createState() => _AutoSizedPageViewState();
}

class _AutoSizedPageViewState extends State<AutoSizedPageView> {
  final Map<int, double> _pageHeights = <int, double>{};

  double get _height {
    if (_pageHeights.isEmpty) return 0;
    return _pageHeights.values.reduce(math.max);
  }

  @override
  void didUpdateWidget(covariant AutoSizedPageView oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.children.length < oldWidget.children.length) {
      _pageHeights.removeWhere((index, _) => index >= widget.children.length);
    }
  }

  void _setPageHeight(int index, double height) {
    if (!mounted || _pageHeights[index] == height) return;
    setState(() => _pageHeights[index] = height);
  }

  void _handlePageChanged(int index) => widget.onPageChanged?.call(index);

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return Stack(
          children: [
            Offstage(
              offstage: true,
              child: SizedBox(
                width: constraints.maxWidth,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    for (var i = 0; i < widget.children.length; i++)
                      _MeasureSize(
                        onChange: (size) => _setPageHeight(i, size.height),
                        child: widget.children[i],
                      ),
                  ],
                ),
              ),
            ),
            SizedBox(
              height: _height,
              child: PageView(
                controller: widget.controller,
                onPageChanged: _handlePageChanged,
                children: [
                  for (final child in widget.children)
                    // Pages lay out at their natural height even while the
                    // measured height is still catching up, so a page that
                    // just grew cannot overflow the viewport for a frame.
                    ClipRect(
                      child: OverflowBox(
                        alignment: Alignment.topCenter,
                        minHeight: 0,
                        maxHeight: double.infinity,
                        child: child,
                      ),
                    ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }
}

class _MeasureSize extends SingleChildRenderObjectWidget {
  const _MeasureSize({required this.onChange, required super.child});

  final ValueChanged<Size> onChange;

  @override
  RenderObject createRenderObject(BuildContext context) {
    return _RenderMeasureSize(onChange);
  }

  @override
  void updateRenderObject(
    BuildContext context,
    covariant _RenderMeasureSize renderObject,
  ) {
    renderObject.onChange = onChange;
  }
}

class _RenderMeasureSize extends RenderProxyBox {
  _RenderMeasureSize(this.onChange);

  ValueChanged<Size> onChange;
  Size? _lastSize;

  @override
  void performLayout() {
    super.performLayout();
    final size = child?.size;
    if (size == null || size == _lastSize) {
      return;
    }
    _lastSize = size;
    final callback = onChange;
    SchedulerBinding.instance.addPostFrameCallback((_) => callback(size));
  }
}
