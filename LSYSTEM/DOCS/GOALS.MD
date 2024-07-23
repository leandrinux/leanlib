# 1.2 Snowshoe goals

The second lsystem release must include multiple improvements for both compiler and runtime that could enable a developer to write a proper program with reasonable comfort. The compiler includes new validations to make sure no invalid arguments are provided. Includes new instructions to jump according to the state of the IO flag, and new instructions to send and receive large buffers from and to devices instead of doing it byte per byte. This runtime version also has better benchmark example programs and performance optimizations.

## Compiler

  * Support for inline comments in code using #
  * Improved parsing prevents crashes due to invalid characters
  * Extra argument validations
    * SS, IP and CC are considered read-only and compiler should validate that they are not modified
    * CS can only be modified with MOV
    * OUT must support all types of parameters but bitsize validation should still be performed.
    * All compiler errors should include the line number
  * Support for char literals such as '*'
  * Update to IN
    * Currently IN takes one parameter, the device id, and reads one byte into AL. If there's nothing to read, the IO flag gets set.
    * IN should be changed to take a second parameter. This parameter will be a register (32, 16 or 8 bit in size) and it should be able to read in a single instruction a 16-bit or 32-bit value as well, behaving the same way by setting the IO flag to 1 if there's no enough data (8, 16 or 32 bits) to be read from the device.

  * Support for byte, word, long and char variables and arrays
  * Binary must include metadata such as author, name and description

## Runtime

  * IP must be reset to zero if changes are made to CS
  * CC now has a system error flag that is set to one when a CPU panic occurs (stack overflow, division by zero, invalid instruction)
    * new JERR instruction jumps if the system error flag is set
    * any successful instruction sets the flag to zero
    * a CPU panic resets IP to 0
    * when the system error flag is set, EAX contains the error code that describes the cause
  * Include examples for future benchmarking

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
  * Data section in binaries should be supported.

# 1.3 Minuet goals

  * Prevent the "jump to 0 on CPU panic" behavior by using another flag and a instruction that disables it only for the next instruction
  * Monochrome bitmap video display device
    * A command should turn on and off the device
    * A command should take a value to change the state of bits on the screen. 
    * screen size should be 128x128
    * one pixel per bit. 4 bytes per row. 512 bytes total video memory
  * Keyboard device support
  * System clock device support
  * Beeper device to generate sounds
    * A command should take a frequency value of 0 to silence the beeper
    * Any other frequency value generates a persistent tone
  * Storage device to save data persistently
  * Redirect echo device output to file instead of the standard output
  * All devices should be discoverable by reacting to a command
   * AX becomes 0 if a device is not available
   * AX becomes the device identifier if a device is available
  * RAM device should report the total size through a command

# 1.4 Sphynx goals

* Allow for importing code from other files
* The interpreter and its devices should run in a simulated/cooperative multitasking architecture, the CPU and each device running as a process, each process alternating in a round robin fashion. This will allow running multiple contexts simultaneously
* the project should be buildable with the TPBUILD tool
* Pointing device support
* There should be a BIOS included which contains utility functions such as:
  * printing null terminated strings throw the echo device
  * printing numbers
  * services accessible via a interrupt table
  * using the monochrome bitmap video display
  * using the beeper device
  * using the human interface device
  * saving and loading data from the storage device
* After running the BIOS should use the storage device to read the boot program, then run it.

# 1.5 Ragdoll goals

* A demo boot program consisting on a simple shell
* C-like language transpiler to lsystem assembly
* Simple JS lsystem interpreter
