import 'package:flutter/material.dart';

class ParallaxFlowDelegate extends FlowDelegate {
  ParallaxFlowDelegate({
    required this.scrollable,
    required this.listItemContext,
    required this.backgroundImageKey,
    this.isHorizontal = false,
  }): super(repaint: scrollable.position);

  final ScrollableState scrollable;
  final BuildContext listItemContext;
  final GlobalKey backgroundImageKey;
  final bool isHorizontal;

@override
BoxConstraints getConstraintsForChild(int i, BoxConstraints constraints) {
  if(isHorizontal){
    return BoxConstraints.tightFor(
    height: constraints.maxHeight,
  );
  }
  return BoxConstraints.tightFor(
    width: constraints.maxWidth,
  );
}
  @override
  void paintChildren(FlowPaintingContext context) {
    // Calculate the position of this list item within the viewport.
    final scrollableBox = scrollable.context.findRenderObject() as RenderBox;
    final listItemBox = listItemContext.findRenderObject() as RenderBox;
    final listItemOffset = listItemBox.localToGlobal(
        listItemBox.size.centerLeft(Offset.zero),
        ancestor: scrollableBox);

    // Determine the percent position of this list item within the
    // scrollable area.
    final viewportDimension = scrollable.position.viewportDimension;
    final scrollFraction = isHorizontal ? (listItemOffset.dx / viewportDimension).clamp(-2.0, 2.0):
        (listItemOffset.dy / viewportDimension).clamp(-1.0, 2.0);

    // Calculate the vertical alignment of the background
    // based on the scroll percent.
    final verticalAlignment = isHorizontal ? Alignment( scrollFraction * 2,0.0) : Alignment(0.0, scrollFraction * 2 -1);

    // Convert the background alignment into a pixel offset for
    // painting purposes.
    final backgroundSize =
        (backgroundImageKey.currentContext!.findRenderObject() as RenderBox)
            .size;
    final listItemSize = context.size;
    final childRect =
        verticalAlignment.inscribe(backgroundSize, Offset.zero & listItemSize);

    // Paint the background.
    context.paintChild(
      0,
      transform:
         isHorizontal ? Transform.translate(offset: Offset(childRect.left,0.0)).transform : Transform.translate(offset: Offset(0.0, childRect.top)).transform,
    );
  }

@override
bool shouldRepaint(ParallaxFlowDelegate oldDelegate) {
  return scrollable != oldDelegate.scrollable ||
      listItemContext != oldDelegate.listItemContext ||
      backgroundImageKey != oldDelegate.backgroundImageKey;
}
}