import 'package:flutter/material.dart';

class ReadOnlyPreviewScope extends InheritedWidget {
  final bool readOnly;

  const ReadOnlyPreviewScope({
    super.key,
    required this.readOnly,
    required super.child,
  });

  static bool isReadOnly(BuildContext context) {
    return context
            .dependOnInheritedWidgetOfExactType<ReadOnlyPreviewScope>()
            ?.readOnly ??
        false;
  }

  static Widget blockActions(BuildContext context, Widget child) {
    return isReadOnly(context) ? AbsorbPointer(child: child) : child;
  }

  static Widget allowNavigation(Widget child) {
    return _ReadOnlyNavigation(child: child);
  }

  static Widget blockScrollableActions(BuildContext context, Widget child) {
    if (!isReadOnly(context)) return child;
    if (child is _ReadOnlyNavigation) return child.child;
    if (child is Scaffold) {
      return Scaffold(
        key: child.key,
        appBar: child.appBar,
        body: blockScrollableActions(context, child.body ?? const SizedBox()),
        floatingActionButton: child.floatingActionButton,
        floatingActionButtonLocation: child.floatingActionButtonLocation,
        floatingActionButtonAnimator: child.floatingActionButtonAnimator,
        persistentFooterButtons: child.persistentFooterButtons,
        drawer: child.drawer,
        onDrawerChanged: child.onDrawerChanged,
        endDrawer: child.endDrawer,
        onEndDrawerChanged: child.onEndDrawerChanged,
        bottomNavigationBar: child.bottomNavigationBar,
        bottomSheet: child.bottomSheet,
        backgroundColor: child.backgroundColor,
        resizeToAvoidBottomInset: child.resizeToAvoidBottomInset,
        primary: child.primary,
        drawerDragStartBehavior: child.drawerDragStartBehavior,
        extendBody: child.extendBody,
        extendBodyBehindAppBar: child.extendBodyBehindAppBar,
        drawerScrimColor: child.drawerScrimColor,
        drawerEdgeDragWidth: child.drawerEdgeDragWidth,
        drawerEnableOpenDragGesture: child.drawerEnableOpenDragGesture,
        endDrawerEnableOpenDragGesture: child.endDrawerEnableOpenDragGesture,
        restorationId: child.restorationId,
      );
    }
    if (child is Positioned) {
      return Positioned(
        key: child.key,
        left: child.left,
        top: child.top,
        right: child.right,
        bottom: child.bottom,
        width: child.width,
        height: child.height,
        child: blockScrollableActions(context, child.child),
      );
    }
    if (child is Stack) {
      return Stack(
        key: child.key,
        alignment: child.alignment,
        textDirection: child.textDirection,
        fit: child.fit,
        clipBehavior: child.clipBehavior,
        children: child.children
            .map((item) => blockScrollableActions(context, item))
            .toList(),
      );
    }
    if (child is Flex) {
      return Flex(
        key: child.key,
        direction: child.direction,
        mainAxisAlignment: child.mainAxisAlignment,
        mainAxisSize: child.mainAxisSize,
        crossAxisAlignment: child.crossAxisAlignment,
        textDirection: child.textDirection,
        verticalDirection: child.verticalDirection,
        textBaseline: child.textBaseline,
        clipBehavior: child.clipBehavior,
        children: child.children
            .map((item) => blockScrollableActions(context, item))
            .toList(),
      );
    }
    if (child is Flexible) {
      return Flexible(
        key: child.key,
        flex: child.flex,
        fit: child.fit,
        child: blockScrollableActions(context, child.child),
      );
    }
    if (child is Padding) {
      return Padding(
        key: child.key,
        padding: child.padding,
        child: blockScrollableActions(context, child.child!),
      );
    }
    if (child is Align) {
      return Align(
        key: child.key,
        alignment: child.alignment,
        widthFactor: child.widthFactor,
        heightFactor: child.heightFactor,
        child: blockScrollableActions(context, child.child!),
      );
    }
    if (child is Container) {
      return Container(
        key: child.key,
        alignment: child.alignment,
        padding: child.padding,
        color: child.color,
        isAntiAlias: child.isAntiAlias,
        decoration: child.decoration,
        foregroundDecoration: child.foregroundDecoration,
        constraints: child.constraints,
        margin: child.margin,
        transform: child.transform,
        transformAlignment: child.transformAlignment,
        clipBehavior: child.clipBehavior,
        child: child.child == null
            ? null
            : blockScrollableActions(context, child.child!),
      );
    }
    if (child is SizedBox) {
      return SizedBox(
        key: child.key,
        width: child.width,
        height: child.height,
        child: child.child == null
            ? null
            : blockScrollableActions(context, child.child!),
      );
    }
    if (child is SafeArea) {
      return SafeArea(
        key: child.key,
        left: child.left,
        top: child.top,
        right: child.right,
        bottom: child.bottom,
        minimum: child.minimum,
        maintainBottomViewPadding: child.maintainBottomViewPadding,
        child: blockScrollableActions(context, child.child),
      );
    }
    if (child is! SingleChildScrollView) {
      return AbsorbPointer(child: child);
    }

    return SingleChildScrollView(
      key: child.key,
      scrollDirection: child.scrollDirection,
      reverse: child.reverse,
      padding: child.padding,
      controller: child.controller,
      primary: child.primary,
      physics: child.physics,
      dragStartBehavior: child.dragStartBehavior,
      clipBehavior: child.clipBehavior,
      restorationId: child.restorationId,
      keyboardDismissBehavior: child.keyboardDismissBehavior,
      child: AbsorbPointer(child: child.child),
    );
  }

  @override
  bool updateShouldNotify(ReadOnlyPreviewScope oldWidget) {
    return readOnly != oldWidget.readOnly;
  }
}

class _ReadOnlyNavigation extends StatelessWidget {
  final Widget child;

  const _ReadOnlyNavigation({required this.child});

  @override
  Widget build(BuildContext context) => child;
}
