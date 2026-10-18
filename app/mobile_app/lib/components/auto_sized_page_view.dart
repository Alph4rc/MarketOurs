import 'package:cupertino_ui/cupertino_ui.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/scheduler.dart';

/// PageView that sizes itself to the natural height of the active page.
///
/// PageView forces its children to match the viewport size, so this widget
/// also lays out an offstage copy of the active page (at the same width but
/// with unbounded height) and reports that height back to constrain the
/// PageView. This lets it live inside a page-level scroll view.
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
  double _height = 0;
  late int _index;

  @override
  void initState() {
    super.initState();
    _index = widget.controller.initialPage.clamp(0, widget.children.length - 1);
  }

  void _handlePageChanged(int index) {
    setState(() => _index = index);
    widget.onPageChanged?.call(index);
  }

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
                child: _MeasureSize(
                  onChange: (size) {
                    if (mounted && size.height != _height) {
                      setState(() => _height = size.height);
                    }
                  },
                  child: widget.children[_index],
                ),
              ),
            ),
            SizedBox(
              height: _height,
              child: PageView(
                controller: widget.controller,
                onPageChanged: _handlePageChanged,
                children: widget.children,
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
