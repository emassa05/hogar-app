import 'dart:io';

Future<void> main() async {
  final process = await Process.start(
    'dart',
    ['run', 'build_runner', 'build', '--delete-conflicting-outputs'],
    runInShell: true,
    mode: ProcessStartMode.inheritStdio,
  );
  final status = await process.exitCode;
  if (status != 0) exit(status);
  for (final file in Directory(
    'lib',
  ).listSync(recursive: true).whereType<File>()) {
    if (!file.path.endsWith('.g.dart') &&
        !file.path.endsWith('.freezed.dart')) {
      continue;
    }
    final source = await file.readAsString();
    final withoutBlocks = source.replaceAll(RegExp(r'/\*[\s\S]*?\*/'), '');
    final clean = withoutBlocks
        .split('\n')
        .where((line) => !line.trimLeft().startsWith('//'))
        .map((line) => line.replaceFirst(RegExp(r'\s+//.*$'), ''))
        .join('\n');
    await file.writeAsString(clean);
  }
}
