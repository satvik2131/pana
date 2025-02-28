// Copyright (c) 2017, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:cli_util/cli_util.dart' as cli;
import 'package:path/path.dart' as p;
import 'package:pub_semver/pub_semver.dart';

import 'analysis_options.dart';
import 'internal_model.dart';
import 'logging.dart';
import 'model.dart' show PanaRuntimeInfo;
import 'package_analyzer.dart' show InspectOptions;
import 'pubspec_io.dart';
import 'utils.dart';
import 'version.dart';

const _dartfmtTimeout = Duration(minutes: 5);

class ToolEnvironment {
  final String? dartSdkDir;
  final String? flutterSdkDir;
  final String? pubCacheDir;
  final String? _futureFlutterSdkDir;
  final List<String> _dartCmd;
  final List<String> _pubCmd;
  final List<String> _dartAnalyzerCmd;
  final List<String> _dartdocCmd;
  final List<String> _flutterCmd;
  // TODO: remove this after flutter analyze gets machine-readable output.
  // https://github.com/flutter/flutter/issues/23664
  final List<String> _flutterDartAnalyzerCmd;
  final List<String> _futureDartAnalyzeCmd;
  final List<String> _futureFlutterDartAnalyzeCmd;
  final Map<String, String> _environment;
  PanaRuntimeInfo? _runtimeInfo;
  final bool _useGlobalDartdoc;

  ToolEnvironment._(
    this.dartSdkDir,
    this.flutterSdkDir,
    this.pubCacheDir,
    this._futureFlutterSdkDir,
    this._dartCmd,
    this._pubCmd,
    this._dartAnalyzerCmd,
    this._dartdocCmd,
    this._flutterCmd,
    this._flutterDartAnalyzerCmd,
    this._futureDartAnalyzeCmd,
    this._futureFlutterDartAnalyzeCmd,
    this._environment,
    this._useGlobalDartdoc,
  );

  ToolEnvironment.fake({
    this.dartSdkDir,
    this.flutterSdkDir,
    this.pubCacheDir,
    String? futureFlutterSdkDir,
    List<String> dartCmd = const <String>[],
    List<String> pubCmd = const <String>[],
    List<String> dartAnalyzerCmd = const <String>[],
    List<String> dartdocCmd = const <String>[],
    List<String> flutterCmd = const <String>[],
    List<String> flutterDartAnalyzerCmd = const <String>[],
    List<String> futureDartAnalyzeCmd = const <String>[],
    List<String> futureFlutterDartAnalyzeCmd = const <String>[],
    Map<String, String> environment = const <String, String>{},
    bool useGlobalDartdoc = false,
    required PanaRuntimeInfo runtimeInfo,
  })  : _futureFlutterSdkDir = futureFlutterSdkDir,
        _dartCmd = dartCmd,
        _pubCmd = pubCmd,
        _dartAnalyzerCmd = dartAnalyzerCmd,
        _dartdocCmd = dartdocCmd,
        _flutterCmd = flutterCmd,
        _flutterDartAnalyzerCmd = flutterDartAnalyzerCmd,
        _futureDartAnalyzeCmd = futureDartAnalyzeCmd,
        _futureFlutterDartAnalyzeCmd = futureFlutterDartAnalyzeCmd,
        _environment = environment,
        _useGlobalDartdoc = useGlobalDartdoc,
        _runtimeInfo = runtimeInfo;

  Map<String, String> get environment => _environment;

  PanaRuntimeInfo get runtimeInfo => _runtimeInfo!;

  Future _init() async {
    final dartVersionResult = _handleProcessErrors(
        await runProc([..._dartCmd, '--version'], environment: _environment));
    final dartSdkInfo = DartSdkInfo.parse(dartVersionResult.asJoinedOutput);
    Map<String, dynamic>? flutterVersions;
    try {
      flutterVersions = await getFlutterVersion();
    } catch (e) {
      log.warning('Unable to detect Flutter version.', e);
    }
    _runtimeInfo = PanaRuntimeInfo(
      panaVersion: packageVersion,
      sdkVersion: dartSdkInfo.version.toString(),
      flutterVersions: flutterVersions,
    );
  }

  static Future<ToolEnvironment> create({
    String? dartSdkDir,
    String? flutterSdkDir,
    String? pubCacheDir,
    Map<String, String>? environment,
    bool useGlobalDartdoc = false,

    /// NOTE: this is an experimental option, do not rely on it.
    String? futureDartSdkDir,

    /// NOTE: this is an experimental option, do not rely on it.
    String? futureFlutterSdkDir,
  }) async {
    Future<String?> resolve(String? dir) async {
      if (dir == null) return null;
      return Directory(dir).resolveSymbolicLinks();
    }

    dartSdkDir ??= cli.getSdkPath();
    final resolvedDartSdk = await resolve(dartSdkDir);
    final resolvedFlutterSdk = await resolve(flutterSdkDir);
    final resolvedPubCache = await resolve(pubCacheDir);
    final resolvedFutureDartSdk = await resolve(futureDartSdkDir);
    final resolvedFutureFlutterSdk = await resolve(futureFlutterSdkDir);
    final env = <String, String>{};
    env.addAll(environment ?? const {});

    if (resolvedPubCache != null) {
      env[_pubCacheKey] = resolvedPubCache;
    }

    final pubEnvValues = <String>[];
    final origPubEnvValue = Platform.environment[_pubEnvironmentKey] ?? '';
    pubEnvValues.addAll(origPubEnvValue
        .split(':')
        .map((s) => s.trim())
        .where((s) => s.isNotEmpty));
    pubEnvValues.add('bot.pkg_pana');
    env[_pubEnvironmentKey] = pubEnvValues.join(':');

    // Flutter stores its internal SDK in its bin/cache/dart-sdk directory.
    // We can use that directory only if Flutter SDK path was specified,
    // TODO: remove this after flutter analyze gets machine-readable output.
    // https://github.com/flutter/flutter/issues/23664
    final flutterDartSdkDir = resolvedFlutterSdk == null
        ? resolvedDartSdk
        : p.join(resolvedFlutterSdk, 'bin', 'cache', 'dart-sdk');
    if (flutterDartSdkDir == null) {
      log.warning(
          'Flutter SDK path was not specified, pana will use the default '
          'Dart SDK to run `dart analyze` on Flutter packages.');
    }
    final resolvedFutureFlutterDartSdkDir = resolvedFutureFlutterSdk == null
        ? null
        : p.join(resolvedFutureFlutterSdk, 'bin', 'cache', 'dart-sdk');

    final toolEnv = ToolEnvironment._(
      resolvedDartSdk,
      resolvedFlutterSdk,
      resolvedPubCache,
      resolvedFutureFlutterSdk,
      [_join(resolvedDartSdk, 'bin', 'dart')],
      [_join(resolvedDartSdk, 'bin', 'dart'), 'pub'],
      [_join(resolvedDartSdk, 'bin', 'dart'), 'analyze'],
      [_join(resolvedDartSdk, 'bin', 'dart'), 'doc'],
      [_join(resolvedFlutterSdk, 'bin', 'flutter'), '--no-version-check'],
      [_join(flutterDartSdkDir, 'bin', 'dart'), 'analyze'],
      [_join(resolvedFutureDartSdk, 'bin', 'dart'), 'analyze'],
      [_join(resolvedFutureFlutterDartSdkDir, 'bin', 'dart'), 'analyze'],
      env,
      useGlobalDartdoc,
    );
    await toolEnv._init();
    return toolEnv;
  }

  Map<String, String> _extendedEnv({
    required bool usesFlutter,
    String? flutterRoot,
  }) {
    flutterRoot ??= flutterSdkDir;
    return {
      if (usesFlutter && flutterRoot != null) 'FLUTTER_ROOT': flutterRoot,
      ..._environment,
    };
  }

  Future<String> runAnalyzer(
    String packageDir,
    String dir,
    bool usesFlutter, {
    required InspectOptions inspectOptions,

    /// NOTE: this is an experimental option, do not rely on it.
    bool useFutureSdk = false,
  }) async {
    final command = useFutureSdk
        ? (usesFlutter ? _futureFlutterDartAnalyzeCmd : _futureDartAnalyzeCmd)
        : (usesFlutter ? _flutterDartAnalyzerCmd : _dartAnalyzerCmd);
    final environment = _extendedEnv(
      usesFlutter: usesFlutter,
      flutterRoot: useFutureSdk ? _futureFlutterSdkDir : flutterSdkDir,
    );

    final analysisOptionsFile =
        File(p.join(packageDir, 'analysis_options.yaml'));
    String? originalOptions;
    if (await analysisOptionsFile.exists()) {
      originalOptions = await analysisOptionsFile.readAsString();
    }
    final rawOptionsContent = inspectOptions.analysisOptionsYaml ??
        await getDefaultAnalysisOptionsYaml(
          usesFlutter: usesFlutter,
          flutterSdkDir: flutterSdkDir,
        );
    final customOptionsContent = updatePassthroughOptions(
        original: originalOptions, custom: rawOptionsContent);
    try {
      await analysisOptionsFile.writeAsString(customOptionsContent);
      final proc = await runProc(
        [...command, '--format', 'machine', dir],
        environment: environment,
        workingDirectory: packageDir,
        timeout: const Duration(minutes: 5),
      );
      if (proc.wasOutputExceeded) {
        throw ToolException(
            'Running `dart analyze` produced too large output.', proc.stderr);
      }
      final output = proc.asJoinedOutput;
      if (proc.wasTimeout) {
        throw ToolException('Running `dart analyze` timed out.', proc.stderr);
      }
      if ('\n$output'.contains('\nUnhandled exception:\n')) {
        if (output.contains('No dart files found at: .')) {
          log.warning('`dart analyze` found no files to analyze.');
        } else {
          log.severe('Bad input?: $output');
        }
        var errorMessage =
            '\n$output'.split('\nUnhandled exception:\n')[1].split('\n').first;
        throw ToolException(
            'dart analyze exception: $errorMessage', proc.stderr);
      }
      return output;
    } finally {
      if (originalOptions == null) {
        await analysisOptionsFile.delete();
      } else {
        await analysisOptionsFile.writeAsString(originalOptions);
      }
    }
  }

  Future<List<String>> filesNeedingFormat(String packageDir, bool usesFlutter,
      {int? lineLength}) async {
    final dirs = await listFocusDirs(packageDir);
    if (dirs.isEmpty) {
      return const [];
    }
    final environment = _extendedEnv(usesFlutter: usesFlutter);
    final files = <String>{};
    for (final dir in dirs) {
      final fullPath = p.join(packageDir, dir);

      final params = <String>[
        'format',
        '--output=none',
        '--set-exit-if-changed',
      ];
      if (lineLength != null && lineLength > 0) {
        params.addAll(<String>['--line-length', lineLength.toString()]);
      }
      params.add(fullPath);

      final result = await runProc(
        [...usesFlutter ? _flutterCmd : _dartCmd, ...params],
        environment: environment,
        timeout: _dartfmtTimeout,
      );
      if (result.exitCode == 0) {
        continue;
      }

      final dirPrefix = packageDir.endsWith('/') ? packageDir : '$packageDir/';
      final output = result.asJoinedOutput;
      final lines = LineSplitter.split(result.asJoinedOutput)
          .where((l) => l.startsWith('Changed'))
          .map((l) => l.substring(8).replaceAll(dirPrefix, '').trim())
          .toList();

      // `dartfmt` exits with code = 1, `flutter format` exits with code = 127
      if (result.exitCode == 1 || result.exitCode == 127) {
        assert(lines.isNotEmpty);
        files.addAll(lines);
        continue;
      }

      final errorMsg = LineSplitter.split(output).take(10).join('\n');
      final isUserProblem = output.contains(
              'Could not format because the source could not be parsed') ||
          output.contains('The formatter produced unexpected output.');
      if (!isUserProblem) {
        throw Exception(
          'dartfmt on $dir/ failed with exit code ${result.exitCode}\n$output',
        );
      }
      throw ToolException(errorMsg, result.stderr);
    }
    return files.toList()..sort();
  }

  Future<Map<String, dynamic>> getFlutterVersion() async {
    final result = _handleProcessErrors(
        await runProc([..._flutterCmd, '--version', '--machine']));
    final waitingForString = 'Waiting for another flutter';
    return result.parseJson(transform: (content) {
      if (content.contains(waitingForString)) {
        return content
            .split('\n')
            .where((e) => !e.contains(waitingForString))
            .join('\n');
      } else {
        return content;
      }
    });
  }

  Future<bool> detectFlutterUse(String packageDir) async {
    try {
      final pubspec = pubspecFromDir(packageDir);
      return pubspec.usesFlutter;
    } catch (e, st) {
      log.info('Unable to read pubspec.yaml', e, st);
    }
    return false;
  }

  Future<PanaProcessResult> runUpgrade(String packageDir, bool usesFlutter,
      {int retryCount = 3}) async {
    final environment = _extendedEnv(usesFlutter: usesFlutter);
    return await _withStripAndAugmentPubspecYaml(packageDir, () async {
      return await _retryProc(() async {
        if (usesFlutter) {
          return await runProc(
            [
              ..._flutterCmd,
              'packages',
              'pub',
              'upgrade',
              '--verbose',
            ],
            workingDirectory: packageDir,
            environment: environment,
          );
        } else {
          return await runProc(
            [..._pubCmd, 'upgrade', '--verbose'],
            workingDirectory: packageDir,
            environment: environment,
          );
        }
      }, shouldRetry: (result) {
        if (result.exitCode == 0) return false;
        final errOutput = result.stderr.asString;
        // find cases where retrying is not going to help – and short-circuit
        if (errOutput.contains('Could not get versions for flutter from sdk')) {
          return false;
        }
        if (errOutput.contains('FINE: Exception type: NoVersionException')) {
          return false;
        }
        return true;
      });
    });
  }

  Future<Outdated> runPubOutdated(
    String packageDir, {
    List<String> args = const [],
    required bool usesFlutter,
  }) async {
    final pubCmd = usesFlutter
        ?
        // Use `flutter pub pub` to get the 'raw' pub command. This avoids
        // issues with `flutter pub get` running in the example directory,
        // argument parsing differing and other misalignments between `dart pub`
        // and `flutter pub` (see https://github.com/dart-lang/pub/issues/2971).
        [..._flutterCmd, 'pub', 'pub']
        : [..._dartCmd, 'pub'];
    final cmdLabel = usesFlutter ? 'flutter' : 'dart';
    final environment = _extendedEnv(usesFlutter: usesFlutter);
    return await _withStripAndAugmentPubspecYaml(packageDir, () async {
      Future<PanaProcessResult> runPubGet() async {
        final pr = await runProc(
          [...pubCmd, 'get', '--no-example'],
          environment: environment,
          workingDirectory: packageDir,
        );
        return pr;
      }

      final firstPubGet = await runPubGet();
      // Flutter on CI may download additional assets, which will change
      // the output and won't match the expected on in the golden files.
      // Running a second `pub get` will make sure that the output is consistent.
      final secondPubGet = usesFlutter ? await runPubGet() : firstPubGet;
      if (secondPubGet.exitCode != 0) {
        // Stripping extra verbose log lines which make Flutter differ on different environment.
        final stderr = ProcessOutput.from(
          secondPubGet.stderr.asString
              .split('---- Log transcript ----\n')
              .first
              .split('pub get failed (1;')
              .first,
        );
        final pr = secondPubGet.change(stderr: stderr);
        throw ToolException(
          '`$cmdLabel pub get` failed:\n\n```\n${pr.asTrimmedOutput}\n```',
          stderr,
        );
      }

      final result = await runProc(
        [
          ...pubCmd,
          'outdated',
          ...args,
        ],
        environment: environment,
        workingDirectory: packageDir,
      );
      if (result.exitCode != 0) {
        throw ToolException(
          '`$cmdLabel pub outdated` failed:\n\n```\n${result.asTrimmedOutput}\n```',
          result.stderr,
        );
      } else {
        return Outdated.fromJson(result.parseJson());
      }
    });
  }

  Map<String, String> _globalDartdocEnv() {
    final env = Map<String, String>.from(_environment);
    if (pubCacheDir != null) {
      env.remove(_pubCacheKey);
    }
    return env;
  }

  Future<DartdocResult> dartdoc(
    String packageDir,
    String outputDir, {
    String? hostedUrl,
    String? canonicalPrefix,
    bool validateLinks = true,
    bool linkToRemote = false,
    Duration? timeout,
    List<String>? excludedLibs,
  }) async {
    ProcessResult pr;
    final args = [
      '--output',
      outputDir,
    ];
    if (excludedLibs != null && excludedLibs.isNotEmpty) {
      args.addAll(['--exclude', excludedLibs.join(',')]);
    }
    if (hostedUrl != null) {
      args.addAll(['--hosted-url', hostedUrl]);
    }
    if (canonicalPrefix != null) {
      args.addAll(['--rel-canonical-prefix', canonicalPrefix]);
    }
    if (!validateLinks) {
      args.add('--no-validate-links');
    }
    if (linkToRemote) {
      args.add('--link-to-remote');
    }
    if (_useGlobalDartdoc) {
      pr = await runProc(
        [..._pubCmd, 'global', 'run', 'dartdoc', ...args],
        workingDirectory: packageDir,
        environment: _globalDartdocEnv(),
        timeout: timeout,
      );
    } else {
      pr = await runProc(
        [..._dartdocCmd, ...args],
        workingDirectory: packageDir,
        environment: _environment,
        timeout: timeout,
      );
    }
    final hasIndexHtml = await File(p.join(outputDir, 'index.html')).exists();
    final hasIndexJson = await File(p.join(outputDir, 'index.json')).exists();
    return DartdocResult(pr, pr.exitCode == 15, hasIndexHtml, hasIndexJson);
  }

  /// Removes the `dev_dependencies` from the `pubspec.yaml`,
  /// and also removes `pubspec_overrides.yaml`.
  ///
  /// Adds lower-bound minimal SDK constraint - if missing.
  ///
  /// Returns the result of the inner function, and restores the
  /// original content upon return.
  Future<R> _withStripAndAugmentPubspecYaml<R>(
    String packageDir,
    FutureOr<R> Function() fn,
  ) async {
    final now = DateTime.now();
    final pubspecBackup = await _stripAndAugmentPubspecYaml(packageDir);

    // backup of pubspec_overrides.yaml
    final poyamlFile = File(p.join(packageDir, 'pubspec_overrides.yaml'));
    File? poyamlBackup;
    if (await poyamlFile.exists()) {
      final path = p.join(
        packageDir,
        'pana-${now.millisecondsSinceEpoch}-pubspec_overrides.yaml',
      );
      poyamlBackup = await poyamlFile.rename(path);
    }

    try {
      return await fn();
    } finally {
      await poyamlBackup?.rename(poyamlFile.path);
      await pubspecBackup.rename(p.join(packageDir, 'pubspec.yaml'));
    }
  }

  /// Removes the dev_dependencies from the pubspec.yaml
  /// Adds lower-bound minimal SDK constraint - if missing.
  /// Returns the backup file with the original content.
  Future<File> _stripAndAugmentPubspecYaml(String packageDir) async {
    final now = DateTime.now();
    final backup = File(
        p.join(packageDir, 'pana-${now.millisecondsSinceEpoch}-pubspec.yaml'));

    final pubspec = File(p.join(packageDir, 'pubspec.yaml'));
    final original = await pubspec.readAsString();
    final parsed = yamlToJson(original) ?? <String, dynamic>{};
    parsed.remove('dev_dependencies');
    parsed.remove('dependency_overrides');

    // `pub` client checks if pubspec.yaml has no lower-bound SDK constraint,
    // and throws an exception if it is missing. While we no longer accept
    // new packages without such constraint, the old versions are still valid
    // and should be analyzed.
    final environment = parsed.putIfAbsent('environment', () => {});
    if (environment is Map) {
      VersionConstraint? vc;
      if (environment['sdk'] is String) {
        try {
          vc = VersionConstraint.parse(environment['sdk'] as String);
        } catch (_) {}
      }
      final range = vc is VersionRange ? vc : null;
      if (range != null &&
          range.min != null &&
          !range.min!.isAny &&
          !range.min!.isEmpty) {
        // looks good
      } else {
        final maxValue = range?.max == null
            ? '<=${_runtimeInfo!.sdkVersion}'
            : '${range!.includeMax ? '<=' : '<'}${range.max}';
        environment['sdk'] = '>=1.0.0 $maxValue';
      }
    }

    await pubspec.rename(backup.path);
    await pubspec.writeAsString(json.encode(parsed));

    return backup;
  }
}

class DartdocResult {
  final ProcessResult processResult;
  final bool wasTimeout;
  final bool hasIndexHtml;
  final bool hasIndexJson;

  DartdocResult(this.processResult, this.wasTimeout, this.hasIndexHtml,
      this.hasIndexJson);

  bool get wasSuccessful =>
      processResult.exitCode == 0 && hasIndexHtml && hasIndexJson;
}

class DartSdkInfo {
  static final _sdkRegexp = RegExp(
    r'Dart \w+ version:\s([^\s]+)(?:\s\((?:[^\)]+)\))?\s\(([^\)]+)\) on "(\w+)"',
  );

  // TODO: parse an actual `DateTime` here. Likely requires using pkg/intl
  final String? dateString;
  final String? platform;
  final Version version;

  DartSdkInfo._(this.version, this.dateString, this.platform);

  factory DartSdkInfo.parse(String versionOutput) {
    final match = _sdkRegexp.firstMatch(versionOutput);
    if (match == null) {
      throw FormatException('Couldn\'t parse Dart SDK version: $versionOutput');
    }
    final version = Version.parse(match[1]!);
    final dateString = match[2];
    final platform = match[3];

    return DartSdkInfo._(version, dateString, platform);
  }
}

const _pubCacheKey = 'PUB_CACHE';
const _pubEnvironmentKey = 'PUB_ENVIRONMENT';

String _join(String? path, String binDir, String executable) {
  var cmd = path == null ? executable : p.join(path, binDir, executable);
  if (Platform.isWindows) {
    final ext = executable == 'dart' ? 'exe' : 'bat';
    cmd = '$cmd.$ext';
  }
  return cmd;
}

class ToolException implements Exception {
  final String message;
  final ProcessOutput? stderr;
  ToolException(this.message, [this.stderr]);

  @override
  String toString() {
    return 'Exception: $message';
  }
}

PanaProcessResult _handleProcessErrors(PanaProcessResult result) {
  if (result.exitCode != 0) {
    if (result.exitCode == 69) {
      // could be a pub error. Let's try to parse!
      var lines = LineSplitter.split(result.stderr.asString)
          .where((l) => l.startsWith('ERR '))
          .join('\n');
      if (lines.isNotEmpty) {
        throw Exception(lines);
      }
    }

    final fullOutput = [
      result.exitCode.toString(),
      result.stdout.asString,
      result.stderr.asString,
    ].map((e) => e.trim()).join('<***>');
    throw Exception('Problem running proc: exit code - $fullOutput');
  }
  return result;
}

/// Executes [body] and returns with the first clean or the last failure result.
Future<PanaProcessResult> _retryProc(
  Future<PanaProcessResult> Function() body, {
  required bool Function(PanaProcessResult pr) shouldRetry,
  int maxAttempt = 3,
  Duration sleep = const Duration(seconds: 1),
}) async {
  PanaProcessResult? result;
  for (var i = 1; i <= maxAttempt; i++) {
    try {
      result = await body();
      if (!shouldRetry(result)) {
        break;
      }
    } catch (e, st) {
      if (i < maxAttempt) {
        log.info('Async operation failed (attempt: $i of $maxAttempt).', e, st);
        await Future.delayed(sleep);
        continue;
      }
      rethrow;
    }
  }
  return result!;
}
