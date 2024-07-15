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

# 1.1 Snowshoe goals

The second lsystem release must include multiple improvements for both compiler and runtime that could enable a developer to write a proper program with reasonable comfort. It should also lower the requirements from a 386 with numeric coprocessor down to a XT-compatible system.

## Compiler

  * Support for comments in code
  * Fix crashes after certain combinations of spaces and line endings
  * SS and IP are considered read-only and compiler should validate that they are not modified
  * OUT must support all types of parameters but bitsize validation should still be performed.
  * Support for char literals such as '*'
  * Support for metadata
  * 8087 support should be optional, which means it should run in XT computers or 386 without numeric coprocessor.
  * Support for byte, word, long and char variables
  * Binary should include flags which state information such as whether it requires floating point instructions.

## Runtime

  * IP must be reset to zero if changes are made to CS
  * Support for JSON system configuration files
  * Usable command line
  * Displays metadata before running program if this info is available
  * Performance optimizations
  * Include examples for benchmarking
  * 8087 must be optional. Floating point operations are optional.
  * Data section in binaries should be supported.
