// SPDX-FileCopyrightText: 2023 Iconica
//
// SPDX-License-Identifier: BSD-3-Clause

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

/// Builds a screen with a fade transition.
///
/// [context]: The build context.
/// [state]: The state of the GoRouter.
/// [child]: The child widget to be displayed.
CustomTransitionPage buildScreenWithFadeTransition<T>({
  required BuildContext context,
  required GoRouterState state,
  required Widget child,
}) =>
    CustomTransitionPage<T>(
      key: state.pageKey,
      child: child,
      transitionsBuilder: (context, animation, secondaryAnimation, child) =>
          FadeTransition(opacity: animation, child: child),
    );

/// Builds a screen without any transition.
///
/// [context]: The build context.
/// [state]: The state of the GoRouter.
/// [child]: The child widget to be displayed.
CustomTransitionPage buildScreenWithoutTransition<T>({
  required BuildContext context,
  required GoRouterState state,
  required Widget child,
}) =>
    CustomTransitionPage<T>(
      key: state.pageKey,
      child: child,
      transitionsBuilder: (context, animation, secondaryAnimation, child) =>
          child,
    );
