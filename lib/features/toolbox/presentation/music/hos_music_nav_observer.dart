import 'package:flutter/material.dart';

typedef SHOMusicRouteSyncCallback = void Function();

class SHOMusicNavigatorObserver extends NavigatorObserver {
  SHOMusicNavigatorObserver(this._onRouteChanged);

  final SHOMusicRouteSyncCallback _onRouteChanged;

  void _scheduleSync() {
    WidgetsBinding.instance.addPostFrameCallback((_) => _onRouteChanged());
  }

  @override
  void didPush(Route<dynamic> route, Route<dynamic>? previousRoute) {
    super.didPush(route, previousRoute);
    _scheduleSync();
  }

  @override
  void didPop(Route<dynamic> route, Route<dynamic>? previousRoute) {
    super.didPop(route, previousRoute);
    _scheduleSync();
  }

  @override
  void didReplace({Route<dynamic>? newRoute, Route<dynamic>? oldRoute}) {
    super.didReplace(newRoute: newRoute, oldRoute: oldRoute);
    _scheduleSync();
  }

  @override
  void didRemove(Route<dynamic> route, Route<dynamic>? previousRoute) {
    super.didRemove(route, previousRoute);
    _scheduleSync();
  }
}
