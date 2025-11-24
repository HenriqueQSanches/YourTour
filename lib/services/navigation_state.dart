import 'package:flutter/foundation.dart';

class NavigationState {
  NavigationState._();
  static final ValueNotifier<int> currentTabIndex = ValueNotifier<int>(0);
}

