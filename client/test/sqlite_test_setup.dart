import 'dart:ffi';
import 'dart:io';

import 'package:sqlite3/open.dart';

void setupSqliteForTests() {
  if (Platform.isLinux) {
    open.overrideFor(OperatingSystem.linux, () {
      return DynamicLibrary.open('libsqlite3.so.0');
    });
  }
}
