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

  /// 删除目标行
  Future<void> removeRowWithAnimation(
    LeftScrollCloseTag? tag,
    Key? key, {
    Function? onRemove,
  }) async {
    if (tag == null) return;
    if (map[tag] == null) return;
    // targetStatus(tag, key)?.value = LeftScrollStatus.close;
    targetStatus(tag, key)?.value = LeftScrollStatus.remove;
    await Future.delayed(Duration(milliseconds: 300));
    onRemove?.call();
    targetStatus(tag, key)?.value = LeftScrollStatus.removed;
  }
}

class LeftScrollCloseTag {
  final String tag;
  const LeftScrollCloseTag(this.tag);

  @override
  int get hashCode => tag.hashCode;

  operator ==(dynamic other) {
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
  remove,
  removed,
}

/// 左滑的状态控制器
class LeftScrollStatusCtrl extends ValueNotifier<LeftScrollStatus> {
  LeftScrollStatusCtrl() : super(LeftScrollStatus.close);
  bool get isClose => value == LeftScrollStatus.close;
  bool get isOpen => value == LeftScrollStatus.open;
  bool get isRemove => value == LeftScrollStatus.remove;
}
