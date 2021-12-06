# Mutanus
Command line tool written in Swift dedicated to perform Mutation Testing of your Swift project.
Inspired by [Muter](https://github.com/muter-mutation-testing/muter)

# Usage

 ```
 mutanus -c <path-to-config>
 ```
## Configuration file

- Required parameters

  - **executable** - used for builing your project 
  - **arguments** - array of executable arguments to run tests of your project
 
- Required parameters

  - **project_root** - path to the root of your project. Current directory is used if not present
  - **source_files** - array of relative to **project_root** paths  of files or/and folders. Listed sources are used for mutants search. All files in **project_root** are used if not present

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
  "source_files": [ 
    "<path-to-first-file>",
    "<path-to-second-file>",
    "<path-to-folder>",
  ],
  "excluded_files": [
    "<first-exclude-rule>",
    "<second-exclude-rule>",
  ]
}
```
