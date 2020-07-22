import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

/// 左滑列表的描述对象（不是widget）
@deprecated
class LeftScrollListItem {
  final String key;
  final Widget child;
  final List<Widget> buttons;
  final Function onTap;
  LeftScrollListItem({
    @required this.key,
    @required this.child,
    @required this.buttons,
    @required this.onTap,
  });
}

/// 左滑列表，只有一个可以打开
@deprecated
class LeftScrollList extends StatefulWidget {
  final int count;
  final LeftScrollListItem Function(BuildContext, int) builder;
  final bool closeOnPop;
  final double buttonWidth;

  /// listview的属性，抄了一遍
  final Axis scrollDirection;
  final bool reverse;
  final ScrollController controller;
  final bool primary;
  final ScrollPhysics physics;
  final bool shrinkWrap;
  final EdgeInsetsGeometry padding;
  final double itemExtent;
  final bool addAutomaticKeepAlives;
  final bool addRepaintBoundaries;
  final bool addSemanticIndexes;
  final double cacheExtent;
  final int semanticChildCount;
  final DragStartBehavior dragStartBehavior = DragStartBehavior.start;

  const LeftScrollList.builder({
    Key key,
    this.count,
    this.buttonWidth: 80,
    this.builder,
    this.controller,
    this.primary,
    this.physics,
    this.padding,
    this.itemExtent,
    this.cacheExtent,
    this.semanticChildCount,
    this.reverse: false,
    this.shrinkWrap: false,
    this.addAutomaticKeepAlives: true,
    this.addRepaintBoundaries: true,
    this.addSemanticIndexes: true,
    this.scrollDirection: Axis.vertical,
    this.closeOnPop,
  }) : super(key: key);

  @override
  _LeftScrollListState createState() => _LeftScrollListState();
}

@deprecated
class _LeftScrollListState extends State<LeftScrollList> {
  Map<String, bool> _markMap = {};
  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      physics: widget.physics,
      padding: widget.padding,
      reverse: widget.reverse,
      itemCount: widget.count,
      controller: widget.controller,
      primary: widget.primary,
      itemExtent: widget.itemExtent,
      cacheExtent: widget.cacheExtent,
      semanticChildCount: widget.semanticChildCount,
      shrinkWrap: widget.shrinkWrap,
      addAutomaticKeepAlives: widget.addAutomaticKeepAlives,
      addRepaintBoundaries: widget.addRepaintBoundaries,
      addSemanticIndexes: widget.addSemanticIndexes,
      scrollDirection: widget.scrollDirection,
      itemBuilder: (ctx, index) {
        var item = widget.builder?.call(ctx, index);
        return ClosableLeftScroll(
          isClose: _markMap[item.key] ?? true,
          closeOnPop: widget.closeOnPop ?? true,
          key: Key(item.key), // Note:Important,Must add key;
          onTouch: () {
            var currentkey = item.key;
            _markMap[currentkey] = false;
            for (var key in _markMap.keys) {
              _markMap[key] = true;
            }
            setState(() {});
          },
          onSlideStarted: () {
            var currentkey = item.key;
            _markMap[currentkey] = false;
            for (var key in _markMap.keys) {
              if (key == currentkey) {
                continue;
              }
              _markMap[key] = true;
            }
            setState(() {});
          },
          buttonWidth: widget.buttonWidth,
          child: item.child,
          buttons: item.buttons,
          onTap: () {
            item.onTap?.call();
          },
        );
      },
    );
  }
}

@deprecated
class ClosableLeftScroll extends StatefulWidget {
  final Key key;

  final bool isClose;

  final bool closeOnPop;
  final Widget child;
  final VoidCallback onTap;
  final double buttonWidth;
  final List<Widget> buttons;

  final Function(double) onScroll;

  final VoidCallback onTouch;
  final VoidCallback onSlideStarted;

  final VoidCallback onSlideCompleted;

  final VoidCallback onSlideCanceled;
  final VoidCallback onEnd;

  ClosableLeftScroll({
    this.key,
    @required this.child,
    @required this.buttons,
    this.onSlideStarted,
    this.onSlideCompleted,
    this.onSlideCanceled,
    this.onTap,
    this.buttonWidth: 80.0,
    this.onScroll,
    this.closeOnPop: true,
    this.isClose,
    this.onEnd,
    this.onTouch,
  }) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return ClosableLeftScrollState();
  }
}

@deprecated
class ClosableLeftScrollState extends State<ClosableLeftScroll>
    with TickerProviderStateMixin {
  double translateX = 0;
  double maxDragDistance;
  final Map<Type, GestureRecognizerFactory> gestures =
      <Type, GestureRecognizerFactory>{};

  AnimationController animationController;

  @override
  void didUpdateWidget(ClosableLeftScroll oldWidget) {
    if (_isHold == false) {
      if (widget.isClose == true) {
        close();
      }
      if (widget.isClose == false) {
        open();
      }
    }
    super.didUpdateWidget(oldWidget);
  }

  @override
  void initState() {
    super.initState();
    maxDragDistance = widget.buttonWidth * widget.buttons.length;
    gestures[HorizontalDragGestureRecognizer] =
        GestureRecognizerFactoryWithHandlers<HorizontalDragGestureRecognizer>(
      () => HorizontalDragGestureRecognizer(debugOwner: this),
      (HorizontalDragGestureRecognizer instance) {
        instance
          ..onStart = onHorizontalDragStart
          ..onDown = onHorizontalDragDown
          ..onUpdate = onHorizontalDragUpdate
          ..onEnd = onHorizontalDragEnd;
      },
    );

    gestures[TapGestureRecognizer] =
        GestureRecognizerFactoryWithHandlers<TapGestureRecognizer>(
      () => TapGestureRecognizer(debugOwner: this),
      (TapGestureRecognizer instance) {
        instance..onTap = widget.onTap;
      },
    );

    animationController = AnimationController(
        lowerBound: -maxDragDistance,
        upperBound: 0,
        vsync: this,
        duration: Duration(milliseconds: 300))
      ..addListener(() {
        translateX = animationController.value;
        setState(() {});
      });
  }

  @override
  Widget build(BuildContext context) {
    var children = widget.buttons
        .map<Widget>((button) => Container(
              child: button,
              width: widget.buttonWidth,
            ))
        .toList();
    Widget body = Stack(
      children: <Widget>[
        Positioned.fill(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: children.reversed.toList(),
          ),
        ),
        RawGestureDetector(
          gestures: gestures,
          child: Transform.translate(
            offset: Offset(translateX, 0),
            child: Row(
              children: <Widget>[
                Expanded(
                  flex: 1,
                  child: widget.child,
                )
              ],
            ),
          ),
        )
      ],
    );
    return widget.closeOnPop
        ? WillPopScope(
            child: body,
            onWillPop: () async {
              if (translateX != 0) {
                close();
                return false;
              }
              return true;
            })
        : body;
  }

  void onHorizontalDragStart(DragStartDetails details) {
    // widget.onSlideStarted?.call();
    _isHold = true;
  }

  void onHorizontalDragDown(DragDownDetails details) {
    widget.onTouch?.call();
  }

  bool _isHold = false;
  bool _hasCall = false;

  void onHorizontalDragUpdate(DragUpdateDetails details) {
    translateX = (translateX + details.delta.dx).clamp(-maxDragDistance, 0.0);
    if (!_hasCall && details.primaryDelta < 0) {
      widget.onSlideStarted?.call();
      _hasCall = true;
    }
    widget.onScroll?.call(
      translateX / maxDragDistance * -1,
    );

    setState(() {});
  }

  void onHorizontalDragEnd(DragEndDetails details) {
    animationController.value = translateX;
    _hasCall = false;
    _isHold = false;
    if (details.velocity.pixelsPerSecond.dx > 200) {
      close();
    } else if (details.velocity.pixelsPerSecond.dx < -200) {
      open();
    } else {
      if (translateX.abs() > maxDragDistance / 2) {
        open();
      } else {
        close();
      }
    }
  }

  void open() {
    widget.onEnd?.call();
    if (translateX != -maxDragDistance)
      animationController.animateTo(-maxDragDistance).then((_) {
        if (widget.onSlideCompleted != null) widget.onSlideCompleted.call();
      });
  }

  void close() {
    if (translateX != 0)
      animationController.animateTo(0).then((_) {
        if (widget.onSlideCanceled != null) widget.onSlideCanceled.call();
      });
  }

  @override
  void dispose() {
    animationController.dispose();
    super.dispose();
  }
}
