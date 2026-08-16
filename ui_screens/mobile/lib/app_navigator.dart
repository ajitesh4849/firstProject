import 'package:flutter/material.dart';

/// Global navigator for auth redirects (e.g. 401 → login).
final GlobalKey<NavigatorState> appNavigatorKey = GlobalKey<NavigatorState>();
