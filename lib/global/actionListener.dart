import 'package:flutter/material.dart';

@Deprecated("Use [GlobalLeftScroll] Instead")
class LeftScrollGlobalListener {}

class GlobalLeftScroll {
  // 工厂模式
  factory GlobalLeftScroll() => _getInstance();
  static GlobalLeftScroll get instance => _getInstance();
  static GlobalLeftScroll? _instance;
  GlobalLeftScroll._internal() {
    // 初始化
  }
  static GlobalLeftScroll _getInstance() {
    if (_instance == null) {
      _instance = GlobalLeftScroll._internal();
    }
    return _instance!;
  }

  Map<LeftScrollCloseTag?, Map<Key?, LeftScrollStatusCtrl>> map = {};

  bool removeListener(LeftScrollCloseTag tag) {
    if (map[tag] != null) {
      map.remove(tag);
      return true;
    }
    return false;
  }

  LeftScrollStatusCtrl? targetStatus(
    LeftScrollCloseTag? tag,
    Key? key,
  ) =>
      map[tag]?[key];

  // 需要关闭同Tag的Row
  needCloseOtherRowOfTag(LeftScrollCloseTag? tag, Key? key) {
    if (tag == null) return;
    if (map[tag] == null) return;
    for (var otherKey in map[tag]!.keys) {
      if (otherKey == key) continue;
      if (map[tag]![otherKey]!.value == LeftScrollStatus.open) {
        map[tag]![otherKey]!.value = LeftScrollStatus.close;
      }
    }
  }

  /// 删除目标行，带有动画
  Future<void> removeRowAsync(
    LeftScrollCloseTag? tag,
    Key? key, {
    Future<bool?> Function()? onRemove,
  }) async {
    if (tag == null) return;
    if (map[tag] == null) return;
    // targetStatus(tag, key)?.value = LeftScrollStatus.close;
    targetStatus(tag, key)?.value = LeftScrollStatus.removing;
    await Future.delayed(Duration(milliseconds: 300));
    final removeResult = onRemove?.call();
    if (removeResult == true) {
      targetStatus(tag, key)?.value = LeftScrollStatus.removed;
    } else {
      targetStatus(tag, key)?.value = LeftScrollStatus.close;
    }
  }

  /// 删除目标行，带有动画
  Future<void> removeRowWithAnimation(
    LeftScrollCloseTag? tag,
    Key? key, {
    required Function onRemove,
  }) async {
    if (tag == null) return;
    if (map[tag] == null) return;
    targetStatus(tag, key)?.value = LeftScrollStatus.removing;
    await Future.delayed(Duration(milliseconds: 300));
    onRemove.call();
    targetStatus(tag, key)?.value = LeftScrollStatus.removed;
  }
}

class LeftScrollController {
  final LeftScrollCloseTag tag;
  final Key key;

  LeftScrollController({required this.tag, required this.key});

  LeftScrollStatusCtrl? get status =>
      GlobalLeftScroll.instance.targetStatus(tag, key);

  to(LeftScrollStatus newStatus) {
    status?.value = newStatus;
  }

  /// 删除目标行，带有动画
  Future<void> open(
    Future<bool?> Function()? onRemove,
  ) async {
    final targetCtrl = GlobalLeftScroll.instance.targetStatus(tag, key);
    targetCtrl?.value = LeftScrollStatus.open;
  }

  /// 删除目标行，带有动画
  Future<void> close(
    Future<bool?> Function()? onRemove,
  ) async {
    final targetCtrl = GlobalLeftScroll.instance.targetStatus(tag, key);
    targetCtrl?.value = LeftScrollStatus.close;
  }

  /// 删除目标行，带有动画
  Future<void> remove(
    Future<bool?> Function()? onRemove,
  ) async {
    return GlobalLeftScroll.instance.removeRowAsync(
      tag,
      key,
      onRemove: onRemove,
    );
  }
}

// 为了更短的调用
class LSTag extends LeftScrollCloseTag {
  LSTag(String tag) : super(tag);
}

class LeftScrollCloseTag {
  final String tag;
  const LeftScrollCloseTag(this.tag);

  LeftScrollController of(Key key) => LeftScrollController(
        tag: this,
        key: key,
      );

  @override
  int get hashCode => tag.hashCode;

  operator ==(Object other) {
    if (other is LeftScrollCloseTag) {
      if (other.tag == tag) {
        return true;
      }
    }
    return false;
  }
}

enum LeftScrollStatus {
  close,
  open,
  removing,
  removed,
}

/// 左滑的状态控制器
class LeftScrollStatusCtrl extends ValueNotifier<LeftScrollStatus> {
  LeftScrollStatusCtrl() : super(LeftScrollStatus.close);
  bool get isClose => value == LeftScrollStatus.close;
  bool get isOpen => value == LeftScrollStatus.open;
  bool get isRemove => value == LeftScrollStatus.removing;
}
