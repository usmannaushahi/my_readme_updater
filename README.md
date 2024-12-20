# My Readme Updater

[![pub package](https://img.shields.io/pub/v/my_readme_updater.svg)](https://pub.dev/packages/my_readme_updater)

A Dart package that automatically updates the project structure in your `README.md` file by running a simple `git commit`. It also supports setting up a pre-commit hook to keep the `README.md` always updated with the latest project structure.

## Features

- Automatically updates the project structure in your `README.md`.
- Adds the project structure between specified markers (`<!-- BEGIN PROJECT STRUCTURE -->` and `<!-- END PROJECT STRUCTURE -->`).
- Can be integrated with Git pre-commit hooks to ensure the `README.md` is always updated before every commit.

## Installation

Add this to your `pubspec.yaml` file:

```yaml
dependencies:
  my_readme_updater: ^1.0.11
```

To automatically update the README.md file before every commit, you can set up a Git pre-commit hook using the following command:

```
dart run my_readme_updater --setup
```

You can manually update the README.md by running the following command:

```
dart run my_readme_updater
```


To remove the package completely, remove it from the pubspec.yaml file. 
Make sure to remove the pre-commit by running the following command:

```
cat .git/hooks/pre-commit
```

```
rm .git/hooks/pre-commit
```

## Additional Notes
Ensure that your project structure in the lib/ directory is correct before running the tool.
This package works best for projects that maintain a clean folder structure and want to have it documented automatically.
<!-- BEGIN PROJECT STRUCTURE -->
```
└─ lib
   └─ my_readme_updater.dart

```
<!-- END PROJECT STRUCTURE -->
