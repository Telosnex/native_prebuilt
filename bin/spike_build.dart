// Spike for ADR 005 step 1: run a package's build hook with no Flutter app.
import 'dart:convert';
import 'dart:io';

import 'package:code_assets/code_assets.dart';
import 'package:hooks/hooks.dart';

Future<void> main(List<String> args) async {
  final packageRoot = Directory(args[0]).absolute.uri;
  final os = OS.fromString(args[1]);
  final arch = Architecture.fromString(args[2]);
  final work = await Directory.systemTemp.createTemp('native_prebuilt_');
  final outShared = work.uri.resolve('out_shared/');
  await Directory.fromUri(outShared).create();

  final builder = BuildInputBuilder()
    ..setupShared(
      packageRoot: packageRoot,
      packageName: 'webcrypto',
      outputFile: work.uri.resolve('output.json'),
      outputDirectoryShared: outShared,
      userDefines: PackageUserDefines(
        workspacePubspec: PackageUserDefinesSource(
          defines: {'native_build': 'source', 'native_release': true},
          basePath: packageRoot,
        ),
      ),
    )
    ..setupBuildInput()
    ..config.setupBuild(linkingEnabled: false);
  CodeAssetExtension(
    linkModePreference: LinkModePreference.dynamic,
    targetArchitecture: arch,
    targetOS: os,
    macOS: os == OS.macOS ? MacOSCodeConfig(targetVersion: 13) : null,
    iOS: os == OS.iOS
        ? IOSCodeConfig(targetSdk: IOSSdk.iPhoneOS, targetVersion: 13)
        : null,
  ).setupBuildInput(builder);
  final input = builder.build();
  final inputFile = File.fromUri(work.uri.resolve('input.json'))
    ..writeAsStringSync(jsonEncode(input.json));

  final sw = Stopwatch()..start();
  final result = await Process.run(Platform.resolvedExecutable, [
    'run',
    'hook/build.dart',
    '--config=${inputFile.path}',
  ], workingDirectory: Directory.fromUri(packageRoot).path);
  stdout.writeln('exit ${result.exitCode} in ${sw.elapsed}');
  stderr.write(result.stderr);
  final output = BuildOutput(
    jsonDecode(File.fromUri(input.outputFile).readAsStringSync())
        as Map<String, Object?>,
  );
  final errors = [
    ...await ProtocolBase.validateBuildOutput(input, output),
  ];
  stdout.writeln('validation errors: $errors');
  for (final asset in output.assets.code) {
    stdout.writeln('${asset.id} ${asset.linkMode} ${asset.file}');
  }
  stdout.writeln('work: ${work.path}');
}
