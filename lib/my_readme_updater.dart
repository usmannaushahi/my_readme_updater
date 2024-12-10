import 'dart:io';
import 'package:process_run/shell.dart';

Future<void> run(List<String> arguments) async {
  final setup = arguments.contains('--setup');
  if (setup) {
    await setupPreCommitHook();
  } else {
    await updateReadme();
  }
}

/// Sets up a Git pre-commit hook to automatically update the README.md file.
///
/// This function writes a script to `.git/hooks/pre-commit` that runs
/// the `my_readme_updater` package each time a commit is made.
///
/// Throws a [ShellException] if the script cannot be written or executed.

Future<void> setupPreCommitHook() async {
  final shell = Shell();

  try {
    final hookPath = '.git/hooks/pre-commit';
    await File(hookPath).writeAsString('''
#!/bin/bash
dart run my_readme_updater
''');
    await shell.run('chmod +x $hookPath');
    print('Pre-commit hook set up successfully.');
  } catch (e) {
    print('Failed to set up pre-commit hook: $e');
  }
}

String generateTreeStructure(String directory) {
  final dir = Directory(directory);
  if (!dir.existsSync()) {
    throw Exception('Directory $directory does not exist.');
  }

  final buffer = StringBuffer();

  void writeTree(Directory dir, String indent, bool isLast) {
    final dirName = dir.path.split(Platform.pathSeparator).last;
    buffer.writeln('$indent${isLast ? '└─' : '├─'} $dirName');
    final entities = dir.listSync();
    for (var i = 0; i < entities.length; i++) {
      final entity = entities[i];
      final isLastEntity = i == entities.length - 1;
      if (entity is Directory) {
        writeTree(entity, '$indent${isLast ? '   ' : '│  '}', isLastEntity);
      } else if (entity is File) {
        final fileName = entity.uri.pathSegments.last;
        buffer.writeln(
            '$indent${isLast ? '   ' : '│  '}${isLastEntity ? '└─' : '├─'} $fileName');
      }
    }
  }

  writeTree(dir, '', true);
  return buffer.toString();
}

/// Updates the `README.md` file with the current project structure.
///
/// This function scans the `lib/` directory to generate a tree-like structure
/// and replaces the relevant section in the `README.md` file.
///
/// Throws a [FileSystemException] if the `README.md` file is not found.

Future<void> updateReadme() async {
  const startMarker = "<!-- BEGIN PROJECT STRUCTURE -->";
  const endMarker = "<!-- END PROJECT STRUCTURE -->";
  final readmeFile = File('README.md');

  if (!readmeFile.existsSync()) {
    print('README.md not found! Creating a new one.');
    readmeFile.writeAsStringSync(
        '## Project Structure\n\n$startMarker\n\n$endMarker\n');
  }

  final readmeContent = readmeFile.readAsLinesSync();
  final tempContent = StringBuffer();

  bool foundStart = false, foundEnd = false;

  for (var line in readmeContent) {
    if (line == startMarker) {
      foundStart = true;
      tempContent.writeln(line);

      // Insert the updated tree structure
      tempContent.writeln('```');
      try {
        final treeContent = generateTreeStructure('lib');
        tempContent.writeln(treeContent);
      } catch (e) {
        print('Failed to generate project structure: $e');
        return;
      }
      tempContent.writeln('```');
    } else if (line == endMarker) {
      foundEnd = true;
    }

    if (!foundStart || foundEnd) {
      tempContent.writeln(line);
    }
  }

  if (!foundStart) {
    print('Start marker missing. Adding it.');
    tempContent.writeln(startMarker);
    tempContent.writeln('```');
    try {
      final treeContent = generateTreeStructure('lib');
      tempContent.writeln(treeContent);
    } catch (e) {
      print('Failed to generate project structure: $e');
      return;
    }
    tempContent.writeln('```');
  }

  if (!foundEnd) {
    print('End marker missing. Adding it.');
    tempContent.writeln(endMarker);
  }

  readmeFile.writeAsStringSync(tempContent.toString());
  print('README updated successfully.');
}
