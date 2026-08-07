import 'dart:io' show Platform;

import 'package:flutter/foundation.dart';

bool get isFirebaseSupportedPlatform =>
    !kIsWeb &&
    (Platform.isAndroid ||
        Platform.isIOS ||
        Platform.isMacOS ||
        Platform.isWindows);
