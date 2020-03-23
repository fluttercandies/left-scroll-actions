import 'dart:math';

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:left_scroll_actions/global/actionListener.dart';

/// 弹性配置
class BounceStyle {
  final double distance;
  final double k;

  BounceStyle({
    this.distance,
    this.k,
  });
  BounceStyle.normal()
      : this(
          distance: 80,
          k: 0.7,
        );
  BounceStyle.disable()
      : this(
          distance: 0,
          k: double.infinity,
        );
}

class BounceCupertinoLeftScroll extends StatefulWidget {
  final Key key;
  final Widget child;
  final LeftScrollCloseTag closeTag;
  final bool closeOnPop;
  final bool opacityChange;
  final VoidCallback onTap;
  final double buttonWidth;
  final List<Widget> buttons;

  final bool bounce;
  final BounceStyle bounceStyle;

  BounceStyle get _bounceStyle =>
      bounceStyle ?? (bounce ? BounceStyle.normal() : BounceStyle.disable());

  BounceCupertinoLeftScroll({
    this.key,
    @required this.child,
    @required this.buttons,
    this.closeTag,
    this.onTap,
    this.buttonWidth: 80.0,
    this.closeOnPop: true,
    this.opacityChange,
    this.bounce: false,
    this.bounceStyle,
  }) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return BounceCupertinoLeftScrollState();
  }
}

class BounceCupertinoLeftScrollState extends State<BounceCupertinoLeftScroll>
    with TickerProviderStateMixin {
  /// 手指滑动的坐标值
  double translateX = 0;

  /// 弹性处理后的坐标变化
  double get bounceTranslate {
    if (widget._bounceStyle.distance == 0) {
      return translateX.clamp(-maxDragDistance, 0.0);
    }
    var resultTranslate = translateX;
    // 超伸状态
    if (resultTranslate < -maxDragDistance) {
      var moreDistance = resultTranslate + maxDragDistance;
      resultTranslate -= moreDistance * widget._bounceStyle.k;
    }
    return min(
        0,
        resultTranslate.clamp(
            -maxDragDistance - widget._bounceStyle.distance, 0.0));
  }

  /// 最远滑动距离
  double get maxDragDistance => widget.buttonWidth * widget.buttons.length;

  /// 滑动进度，在有弹性时会大于1
  double get progress => bounceTranslate / maxDragDistance * -1;

  final Map<Type, GestureRecognizerFactory> gestures =
      <Type, GestureRecognizerFactory>{};

  AnimationController animationController;

  Map<LeftScrollCloseTag, Map<Key, LeftScrollStatus>> get globalMap =>
      LeftScrollGlobalListener.instance.map;

  LeftScrollStatus get _ct => globalMap[widget.closeTag][widget.key];

  setCloseListener() {
    if (widget.closeTag == null) return;
    if (globalMap[widget.closeTag] == null) {
      globalMap[widget.closeTag] = {};
    }
    var _controller = LeftScrollStatus();
    globalMap[widget.closeTag][widget.key] = _controller;
    globalMap[widget.closeTag][widget.key].addListener(handleChange);
  }

  handleChange() {
    if (globalMap[widget.closeTag][widget.key]?.value == true) {
      open();
    } else {
      close();
    }
  }

  @override
  void initState() {
    super.initState();
    setCloseListener();
    gestures[HorizontalDragGestureRecognizer] =
        GestureRecognizerFactoryWithHandlers<HorizontalDragGestureRecognizer>(
      () => HorizontalDragGestureRecognizer(debugOwner: this),
      (HorizontalDragGestureRecognizer instance) {
        instance
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
        value: 0,
        lowerBound: -maxDragDistance - widget._bounceStyle.distance,
        upperBound: 0,
        vsync: this,
        duration: Duration(milliseconds: 300))
      ..addListener(() {
        translateX = animationController.value;
        setState(() {});
      });
  }

  @override
  void didUpdateWidget(BounceCupertinoLeftScroll oldWidget) {
    if (oldWidget.buttons.length != widget.buttons.length) {
      translateX = 0;
    }
    super.didUpdateWidget(oldWidget);
  }

  @override
  Widget build(BuildContext context) {
    Widget body = Stack(
      alignment: Alignment.centerRight,
      children: <Widget>[
        Positioned.fill(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: <Widget>[
              Container(
                width: widget.buttonWidth * widget.buttons.length +
                    widget._bounceStyle.distance,
                child: _WxStyleButtonGroup(
                  opaChange: widget.opacityChange,
                  buttonWidth: widget.buttonWidth,
                  bounceDistance: widget._bounceStyle.distance,
                  progress: progress,
                  children: widget.buttons ?? [],
                ),
              ),
            ],
          ),
        ),
        RawGestureDetector(
          gestures: gestures,
          child: Transform.translate(
            offset: Offset(bounceTranslate, 0),
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

  void onHorizontalDragDown(DragDownDetails details) {}

  void onHorizontalDragUpdate(DragUpdateDetails details) {
    translateX += details.delta.dx;

    // translateX = translateX.clamp(-maxDragDistance - 80, 0.0);
    setState(() {});
  }

  void onHorizontalDragEnd(DragEndDetails details) {
    animationController.value = translateX;
    if (details.velocity.pixelsPerSecond.dx > 200) {
      close();
    } else if (details.velocity.pixelsPerSecond.dx < -200) {
      // TODO: 弹出动画
      open(details.velocity.pixelsPerSecond.dx);
    } else {
      if (bounceTranslate.abs() > maxDragDistance / 2) {
        open();
      } else {
        close();
      }
    }
  }

  // 打开
  void open([double v = 0]) async {
    print('open');
    if (v < 0) {
      v = v.clamp(-300.0, 0.0);
      await animationController.animateTo(
        -maxDragDistance + v,
        duration: Duration(milliseconds: 1000),
        curve: Curves.easeInOutCubic,
      );
      setState(() {});
    }
    animationController.animateTo(
      -maxDragDistance,
      duration: Duration(milliseconds: 1000),
    );
    if (widget.closeTag == null) return;
    if (_ct.value == false) {
      LeftScrollGlobalListener.instance
          .needCloseOtherRowOfTag(widget.closeTag, widget.key);
      _ct.value = true;
    }
  }

  // 关闭
  void close() {
    if (translateX != 0) {
      animationController.animateTo(0);
    }
    if (widget.closeTag == null) return;
    if (_ct.value == true) {
      _ct.value = false;
    }
  }

  @override
  void dispose() {
    animationController.dispose();
    super.dispose();
  }
}

class _WxStyleButtonGroup extends StatelessWidget {
  final List<Widget> children;
  final bool opaChange;
  final double buttonWidth;

  /// 允许拉伸的最大范围
  final double bounceDistance;

  /// 拉伸进度
  final double progress;

  const _WxStyleButtonGroup({
    Key key,
    this.children,
    this.buttonWidth: 80,
    this.progress: 0,
    this.opaChange,
    this.bounceDistance,
  }) : super(key: key);

  /// 超伸状态
  bool get isOverBounce => progress > 1;

  /// 应当变化���偏移量
  double get offset => buttonWidth * progress;

  double get eachWidthOffset =>
      (buttonWidth * children.length + bounceDistance) /
      children.length *
      progress;

  @override
  Widget build(BuildContext context) {
    List<Widget> l = [];

    for (var i = 0; i < children.length; i++) {
      Widget btn = Container(
        width: buttonWidth * progress,
        child: OverflowBox(
          minWidth: buttonWidth,
          maxWidth: double.infinity,
          alignment: Alignment.centerLeft,
          child: Container(
            width: isOverBounce ? buttonWidth * progress : buttonWidth,
            child: children[i],
          ),
        ),
      );

      btn = Padding(
        padding: EdgeInsets.only(
          right: offset * i,
        ),
        child: btn,
      );

      if (opaChange == true) {
        btn = Opacity(
          opacity: progress,
          child: btn,
        );
      }
      l.add(btn);
    }
    return OverflowBox(
      alignment: Alignment.centerLeft,
      minWidth: buttonWidth * children.length + bounceDistance,
      maxWidth: buttonWidth * children.length + bounceDistance,
      child: Container(
        color: Colors.purple,
        child: Stack(
          alignment: Alignment.centerRight,
          children: l.reversed.toList(),
        ),
      ),
    );
  }
}
