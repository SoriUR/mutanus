Command line tool written in Swift dedicated to perform Mutation Testing of your Swift project.
Inspired by [Muter](https://github.com/muter-mutation-testing/muter)

# Installation

```
brew install soriur/brew/mutanus
```

# Usage

```
mutanus run -c <path-to-config>
```

# Configuration file

Mutanus retrieves necessary information from the configuration file

You can create configuration file yourself or use the following command
```
mutanus config -p <path>
```

- Required parameters

  - **executable** - used for builing your project 
  - **arguments** - array of executable arguments to run tests of your project
 
- Optional parameters

  - **project_root** - path to the root of your project. Current directory is used if not present
  - **included_files** - exact paths to files or folders that should be included
  - **included_rules** - ICU-compatible reg exps that should match included files
  - **excluded_files** - exact paths to files or folders that should be excluded
  - **excluded_rules** - ICU-compatible reg exps that should match excluded files
  
- Including/Excluding rules

Excluding parameters take priority over including parameters. In other words, if a file matches both including and excluding parameter, it will be excluded.
If both **included_files** and **included_rules** are empty or missing, all files at **project_root** are used

```json
{ 
  "executable": "/usr/bin/xcodebuild",
  "arguments": [
    "test",
    "-workspace",
    "MyWorkspace.xcworkspace",
    "-scheme",
    "MyScheme",
    "-destination",
    "platform=iOS Simulator,name=iPhone 8",
    "SWIFT_TREAT_WARNINGS_AS_ERRORS=NO",
    "GCC_TREAT_WARNINGS_AS_ERRORS=NO"
  ],
  "project_root": "<path-to-project>",
  "included_files": [ 
    "<path-to-first-file>",
    "<path-to-second-file>",
    "<path-to-folder>",
  ],
  "included_rules": [
    "<first-including-rule>",
    "<second-including-rule>",
  ],
  "excluded_files": [
    "<first-exclude-rule>",
    "<second-exclude-rule>",
  ],
  "excluded_rules": [
    "<first-excluding-rule>",
    "<second-excluding-rule>",
  ]
}
```
