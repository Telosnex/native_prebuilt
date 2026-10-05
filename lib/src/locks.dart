import 'dart:async';
import 'dart:io';

final _inProcess = <String, Future<void>>{};

/// Runs [action] while this process holds an exclusive lock on [lockFile].
///
/// File locks exclude other processes only. An in-process queue per path
/// also excludes other callers in this process.
Future<T> withFileLock<T>(File lockFile, Future<T> Function() action) async {
  final key = lockFile.absolute.path;
  final previous = _inProcess[key] ?? Future<void>.value();
  final done = Completer<void>();
  _inProcess[key] = done.future;
  try {
    await previous;
    await lockFile.parent.create(recursive: true);
    final handle = await lockFile.open(mode: FileMode.append);
    try {
      await handle.lock(FileLock.blockingExclusive);
      try {
        return await action();
      } finally {
        await handle.unlock();
      }
    } finally {
      await handle.close();
    }
  } finally {
    done.complete();
    if (identical(_inProcess[key], done.future)) _inProcess.remove(key);
  }
}
