import 'dart:io';
import 'package:process_run/shell.dart';

void main(List<String> arguments) async {
  final setup = arguments.contains('--setup');
  if (setup) {
    await setupPreCommitHook();
  } else {
    await updateReadme();
  }
}

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

Future<void> updateReadme() async {
  final startMarker = "<!-- BEGIN PROJECT STRUCTURE -->";
  final endMarker = "<!-- END PROJECT STRUCTURE -->";
  final readmeFile = File('README.md');

  // Ensure README.md exists, or create it
  if (!readmeFile.existsSync()) {
    print('README.md not found! Creating a new one.');
    readmeFile.writeAsStringSync('## Project Structure\n\n$startMarker\n\n$endMarker\n');
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
      final shell = Shell();
      try {
        final result = await shell.run('tree lib');
        tempContent.writeln(result.outText.replaceAll('\u00A0', ' '));
      } catch (e) {
        print('Failed to generate project structure: $e');
        return;
      }
      tempContent.writeln('```');
    } else if (line == endMarker) {
      foundEnd = true;
    }

    // Keep writing lines that are outside the markers
    if (!foundStart || foundEnd) {
      tempContent.writeln(line);
    }
  }

  // Add markers if they are missing
  if (!foundStart) {
    print('Start marker missing. Adding it.');
    tempContent.writeln(startMarker);
    tempContent.writeln('```');
    final shell = Shell();
    try {
      final result = await shell.run('tree lib');
      tempContent.writeln(result.outText.replaceAll('\u00A0', ' '));
    } catch (e) {
      print('Failed to generate project structure: $e');
      return;
    }
    tempContent.writeln('```');
    tempContent.writeln(endMarker);
  }

  if (!foundEnd) {
    print('End marker missing. Adding it.');
    tempContent.writeln(endMarker);
  }

  // Update the README file
  readmeFile.writeAsStringSync(tempContent.toString());
  print('README updated successfully.');
}
