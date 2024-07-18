# 1.2 Snowshoe goals

The second lsystem release must include multiple improvements for both compiler and runtime that could enable a developer to write a proper program with reasonable comfort. The compiler includes new validations to make sure no invalid arguments are provided. Includes new instructions to jump according to the state of the IO flag, and new instructions to send and receive large buffers from and to devices instead of doing it byte per byte. This runtime version also has better benchmark example programs and performance optimizations.

## Compiler

  * Support for inline comments in code using #
  * Improved parsing prevents crashes due to invalid characters
  * Extra argument validations
    * SS and IP are considered read-only and compiler should validate that they are not modified
    * OUT must support all types of parameters but bitsize validation should still be performed.
    * IN does not admit literals as first parameter
  * Support for char literals such as '*'
  * Binary must include metadata such as author, name and description
  * Support for byte, word, long and char variables and arrays

## Runtime

  * IP must be reset to zero if changes are made to CS
  * CC now has a system error flag that is set to one when a CPU panic occurs (stack overflow, division by zero)
    * new JERR instruction jumps if the system error flag is set
    * any successful instruction sets the flag to zero
    * a CPU panic resets IP to 0
    * when the system error flag is set, EAX contains the error code that describes the cause
  * Support for JSON system configuration files
    * defines how much memory the system has
    * defines the size of the stack
    * defines the devices that are connected to the bus
    * enables/disables silent mode
    * enables/disables auto restart 
  * Command line improvements
    * each configuration setting must have a corresponding command line equivalent
  * When silent mode is off, displays metadata before running program if this info is available
  * Performance optimizations by converting strategic functions to assembly or unrolling cycles if possible
  * Include examples for future benchmarking
  * Data section in binaries should be supported.

# 1.3 goals

  * Prevent the "jump to 0 on CPU panic" behavior by using another flag and a instruction that disables it only for the next instruction
  * Allow for importing code from other files
  * Monochrome bitmap video display device
  * Redirect echo device output to file instead of the standard output
