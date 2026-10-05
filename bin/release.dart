import 'dart:io';

import 'package:args/args.dart';
import 'package:native_prebuilt/src/cli.dart';
import 'package:native_prebuilt/src/publisher.dart';
import 'package:native_prebuilt/src/release_tool.dart';

Future<void> main(List<String> arguments) => runCommand(
  arguments,
  ArgParser()
    ..addOption('package', defaultsTo: '.')
    ..addOption('repo', help: 'owner/name. Default: GITHUB_REPOSITORY.')
    ..addOption('staging', help: 'Directory for the .gz assets.')
    ..addFlag('dry-run', help: 'Write the manifest, upload nothing.'),
  'dart run native_prebuilt:release [options] <build output dirs...>\n'
  'Uploads the files of native_prebuilt:build and writes prebuilt.json.',
  (args) async {
    if (args.rest.isEmpty)
      throw StateError('Pass the build output directories.');
    await releaseTargets(
      packageRoot: packageRootOf(args),
      targetDirectories: args.rest.map(Directory.new).toList(),
      repository: repositoryOf(args),
      staging: await stagingOf(args, 'native_release_'),
      publisher: args.flag('dry-run') ? null : GhPublisher(log: log),
      log: log,
    );
    return 0;
  },
);
