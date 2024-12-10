import 'package:my_readme_updater/my_readme_updater.dart';

void main(List<String> args) {
  if (args.contains('--setup')) {
    setupPreCommitHook();
  } else {
    updateReadme();
  }
}
