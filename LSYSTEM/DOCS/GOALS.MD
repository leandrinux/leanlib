# 1.0 Ragamuffin goals

Ragamuffin is the first release of the lsystem and it must be a complete functioning system, a proper language compiler and interpreter that can solve any issue.

## Compiler

  * Builds basic programs
  * Support for definitions and labels
  * Validation over the arguments provided for each instruction, such as number and type of arguments.
  * Support for binary, decimal, octal, hexadecimal literals that can include spaces by using an underscore

## Runtime

  * Must runs all programs that can be built with this release compiler
  * The entire instruction set is implemented, including condition codes.
  * Implements a simple bus that enables programmers to interact with devices
  * An echo device must display on screen the info sent to it
  * 8087 support should be optional, which means it should run in XT computers or 386 without numeric coprocessor.
  * Includes simple command line options

# 1.1 Snowshoe goals

The second lsystem release must include multiple improvements for both compiler and runtime that could enable a developer to write a proper program with reasonable comfort. The compiler includes new validations to make sure no invalid arguments are provided. Includes new instructions to jump according to the state of the IO flag, and new instructions to send and receive large buffers from and to devices instead of doing it byte per byte. This runtime version also has better benchmark example programs and performance optimizations.

## Compiler

  * Support for comments in code
  * Fix crashes after certain combinations of spaces and line endings
  * Extra validations
    * SS and IP are considered read-only and compiler should validate that they are not modified
    * OUT must support all types of parameters but bitsize validation should still be performed.
    * IN does not admit literals as first parameter
  * Support for char literals such as '*'
  * Binary includes metadata
  * Support for byte, word, long and char variables and arrays

## Runtime

  * IP must be reset to zero if changes are made to CS
  * Support for JSON system configuration files
  * Usable command line allows to set silent mode
  * Displays metadata before running program if this info is available
  * Performance optimizations
  * Include examples for benchmarking
  * Data section in binaries should be supported.
