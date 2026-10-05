import 'dart:io';

import 'package:args/args.dart';
import 'package:native_prebuilt/native_prebuilt.dart';
import 'package:native_prebuilt/src/cli.dart';
import 'package:native_prebuilt/src/release_tool.dart';

Future<void> main(List<String> arguments) => runCommand(
  arguments,
  ArgParser()
    ..addOption('target', mandatory: true, help: 'For example windows-x64.')
    ..addOption('out', mandatory: true, help: 'Directory for the files.')
    ..addOption('package', defaultsTo: '.')
    ..addOption('repo', help: 'owner/name. Default: GITHUB_REPOSITORY.')
    ..addOption(
      'runner',
      help: 'Default: ImageOS and ImageVersion, or "local".',
    )
    ..addOption('toolchain', defaultsTo: '')
    ..addOption('macos-version', defaultsTo: '$defaultMacOSVersion')
    ..addOption('ios-version', defaultsTo: '$defaultIOSVersion')
    ..addOption('android-api', defaultsTo: '$defaultAndroidApi'),
  'dart run native_prebuilt:build --target <target> --out <dir>\n'
  'Runs hook/build.dart with native_build: source and native_release.',
  (args) async {
    final env = Platform.environment;
    final image = [env['ImageOS'], env['ImageVersion']].nonNulls.join(' ');
    await buildTarget(
      packageRoot: packageRootOf(args),
      target: TargetName.parse(args.option('target')!),
      out: Directory(args.option('out')!),
      repository: repositoryOf(args),
      runner: args.option('runner') ?? (image.isEmpty ? 'local' : image),
      toolchain: args.option('toolchain')!,
      macOSVersion: int.parse(args.option('macos-version')!),
      iOSVersion: int.parse(args.option('ios-version')!),
      androidApi: int.parse(args.option('android-api')!),
      log: log,
    );
    return 0;
  },
);
