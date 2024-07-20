# LSystem full specs document 1.0

This document describes the lsystem virtual architecture, defining the instruction set, the available registers and how memory is managed. It also provides a detailed description of the lsystem assembly language and its syntax.

This architecture was based on an initial work by Leandro Tami and Alejandra Pautasso for the 2003 and 2004 courses of Computer Architectures at FASTA University, Mar del Plata, Argentina.

The lsystem architecture is little-endian 32-bit. CPU registers are all 32-bit. The minimum addressable memory unit is a byte. The CPU can address 4294967296 bytes (4 GB max).

## Virtual CPU Registers

|Register|Code|Description|
|--------|----|-----------|
|SP|$10|Stack pointer|
|BP|$20|Base pointer|
|IP|$30|Instruction pointer|
|CC|$40|Condition codes (flags)|
|EAX|$50|General use register (32 bit)|
|AX|$51|General use register (low 16 bit of EAX)|
|AH|$52|General use register (high 8 bit of AX)|
|AL|$53|General use register (low 8 bit of AX)|
|EBX|$60|General use register (32 bit)|
|BX|$61|General use register (low 16 bit of EBX)|
|BH|$62|General use register (high 8 bit of BX)|
|BL|$63|General use register (low 8 bit of BX)|
|ECX|$70|General use register (32 bit)|
|CX|$71|General use register (low 16 bit of ECX)|
|CH|$72|General use register (high 8 bit of CX)|
|CL|$73|General use register (low 8 bit of CX)|
|EDX|$80|General use register (32 bit)|
|DX|$81|General use register (low 16 bit of EDX)|
|DH|$82|General use register (high 8 bit of DX)|
|DL|$83|General use register (low 8 bit of DX)|
|CS|$A0|Code segment|
|DS|$A1|Data segment|
|SS|$A2|Stack segment|

The CC register is affected by certain instructions and has three meaningful bits. 

|Bit number|Name|Meaning|
|----------|----|-------|
|0|Zero flag|1 if the last operation produced a zero value, 0 if it produced a non-zero value|
|1|Sign flag|1 if the last operation produced a negative value, 0 if it produced a positive value|
|2|IO flag|1 if the last IO operation failed, 0 if succeeded|
|3..30|Unused|Bits reserved for future use|
|31|CPU flag|1 if the last operation caused a CPU error (divide by zero, stack overflow, other)|

## Instructions

A lsystem virtual CPU instruction is made of three components: a header and two arguments. The header is 16 bit in size, while the parameter info is 32 bit. This makes the whole instruction 10 bytes long. 

     |--------------|--------------|--------------|
     |    Header    |    Param0    |    Param1    |
     |--------------|--------------|--------------|
     80             48             16             0

Instruction sizes are fixed, so instructions like `MOV` that take two arguments and others like `RET` that take none require the same space in memory. Instructions are placed in the code segment, with starts at position 0 of the memory space. 

The 32-bit header field is made of two parts: the first byte which contains the opcode of the instruction that must be performed by the CPU, and the final byte which contain extra information such as the type of each parameter.
    
    |------------------------|-----------|-----------|
    |        Opcode          | Param0    | Param1    |
    |------------------------|-----------|-----------|
    15                       8           4           0

    0 - 3   : Param0 type
    4 - 7   : Param1 type
    8 .. 15 : 8-bit operation code

The 4-bit parameter type values are defined as follows:

|Value|Meaning|
|----|-----|
|0|Inmediate / Literal|
|1|Register|
|2|Address|
|3|Pointer|
|4..15|Not used / Reserved|

When a parameter is a literal, the full 32 bit of the parameter field represent the value.

When a parameter is a register, the value stored in the parameter field is a code representing that register. Check the registers table previously defined to see the codes for each register.

When a parameter is an address, the full 32 bit value stored in the parameter field is a memory address.

When a parameter is pointer, the parameter value is formed as follows:

    |--------------------------|---------------|-----------------|
    |    Constant              |   Unused      |    Register     |
    |     offset               |               |      code       |
    |--------------------------|---------------|-----------------|
     31                     16  15            8  7              0          

The last 16 bits are a signed constant, therefore defined in the -32768..32767 range. The register code field contains the same 8-bit value from the register table previously defined. The constant is an offset that is added to the address contained in the register before the indirection. For instance, if `AX` equals 10, then `[AX]` represents the value in memory position 10, `[AX+2]` represents the value in memory position 12 and `[AX-3]` represents the value in memory position 7.

## Instruction set 

The lsystem instruction set consists of 33 instructions or operations divided in multiple groups

* math
* flow control
* binary algebra 
* stack operations 
* input/output
* extended features

### Math

The math group of instructions is made of all the basic 4 math operations and also moving data and performing bit shifts, which essentially are the same as multiplying or dividing a value by 2. The four basic mathematical operations are handled by ADD, SUB, MUL and DIV for integer values, and FADD, FSUB, FMUL and FDIV for floating point values.

|Instruction|Opcode|Args|Affects CC|Description|
|-----------|------|----|----------|-----------|
|MOV|0x01|2|No|Moves the value in $2 to $1|
|ADD|0x02|2|Yes|$1 becomes $1 + $2|
|SUB|0x03|2|Yes|$1 becomes $1 - $2|
|MUL|0x04|2|Yes|$1 becomes $1 * $2|
|DIV|0x05|2|Yes|$1 becomes $1 / $2|
|CMP|0x06|2|Yes|Substracts $2 from $1 without changing $1 but affecting the condition codes (CC) register|

### Flow control

Flow control consists of different kinds of branching or jumping which are used to alter the flow of execution of the program. `JMP` is an unconditional jump, which means it will always change flow execution to the specified line. All other jumps are conditional and based on different criteria such as the sign bit, the zero bit or the result of a comparison with another value.

|Instruction|Opcode|Args|Affects CC|Description|
|-----------|------|----|----------|-----------|
|JMP|0x21|1|No|assigns $1 to IP causing a jump|
|JE|0x22|2|No|jumps to $2 if $1 is equal to EAX|
|JG|0x23|2|No|jumps to $2 if $1 is greater than EAX|
|JL|0x24|2|No|jumps to $2 if $1 is less than EAX|
|JZ|0x25|1|No|jumps to $1 if CC zero bit is 1|
|JP|0x26|1|No|jumps to $1 if CC sign bit is 0|
|JN|0x27|1|No|jumps to $1 if CC sign bit is 1|
|JNZ|0x28|1|No|jumps to $1 if CC zero bit is 0|
|JERR|0x29|1|No|jumps to $1 if CC CPU error bit is 1|
|CALL|0x45|1|No|Performs subroutine call (pushes current instruction address plus one, then jumps to specified address)|
|RET|0x46|0|No|Pops the address from the stack and resumes execution from there|

### Binary algebra

The binary algebra group includes the 4 basic logical operations plus others like shifting bits to the left or right.

|Instruction|Opcode|Args|Affects CC|Description|
|-----------|------|----|----------|-----------|
|AND|0x31|2|Yes|$1 becomes $1 and $2|
|OR|0x32|2|Yes|$1 becomes $1 or $2|
|NOT|0x33|1|Yes|$1 becomes not $1|
|XOR|0x34|2|Yes|$1 becomes $1 xor $2|
|SHL|0x07|2|Yes|Shifts $1 to the left by $2 bits|
|SHR|0x08|2|Yes|Shifts $1 to the right by $2 bits|

### Stack operations

The stack operations are 7 instructions allowing for stack access such as adding or removing values to it, and most importantly, enables the ability to call subroutines.

|Instruction|Opcode|Args|Affects CC|Description|
|-----------|------|----|----------|-----------|
|PUSH|0x41|1|No|Pushes a value to the stack|
|POP|0x42|1|No|Pops a value from the stack|
|PUSHA|0x43|0|No|Pushes all registers to the stack|
|POPA|0x44|0|No|Pops all registers to the stack|

### Input / output

The CPU can communicate with other devices by using a bus. Each device has an id. Some devices can be the RAM module or optional I/O devices.
You can either read and write a single byte to/from a device id.

|Instruction|Opcode|Args|Affects CC|Description|
|-----------|------|----|----------|-----------|
|OUT|0x51|2|No|Sends the lower byte of $2 to the device number $1|
|IN|0x52|1|No|Receives one byte from the device number $1 into AL|

### Extended features

This group consists of floating point operations and other features which may not be available in all lsystem implementations.

|Instruction|Opcode|Args|Affects CC|Description|
|-----------|------|----|----------|-----------|
|FADD|0x09|2|Yes|$1 becomes $1 + $2 (floating point operation)|
|FSUB|0x0A|2|Yes|$1 becomes $1 - $2 (floating point operation)|
|FMUL|0x0B|2|Yes|$1 becomes $1 * $2 (floating point operation)|
|FDIV|0x0C|2|Yes|$1 becomes $1 / $2 (floating point operation)|

## Parameter validation per instruction

Instructions can take between none and two parameters. These parameters have four different types. But not all combinations of parameter types are valid. The following tables show the different valid combinations for each instruction. The rows represent the first parameter and the columns represent the second.

As general rule, the left parameter cannot have a smaller bit size than the right parameter

#### CMP

|P0\P1|Literal|Register|Address|Pointer
|-|-|-|-|-|
|Literal|✅|✅|✅|✅|
|Register|✅|✅|✅|✅|
|Address|✅|✅|✅|✅|
|Pointer|✅|✅|✅|✅|

#### MOV, ADD, SUB, MUL, DIV, SHL, SHR, FADD, FSUB, FMUL, FDIV, AND, OR, NOT, XOR

|P0\P1|Literal|Register|Address|Pointer
|-|-|-|-|-|
|Literal|❌|✅|✅|✅|
|Register|❌|✅|✅|✅|
|Address|❌|✅|✅|✅|
|Pointer|❌|✅|✅|✅|

#### JE, JG, JL

|P0\P1|Literal|Register|Address|Pointer
|-|-|-|-|-|
|Literal|❌|❌|❌|❌|
|Register|✅|✅|✅|✅|
|Address|✅|✅|✅|✅|
|Pointer|✅|✅|✅|✅|

#### JMP, JZ, JP, JN, JNZ, CALL

|P0||
|-|-|
|Literal|❌|
|Register|✅|
|Address|✅|
|Pointer|✅|

#### PUSH, POP

|P0||
|-|-|
|Literal|✅|
|Register|✅|
|Address|✅|
|Pointer|✅|

#### PUSHA, POPA, RET

These instructions take no arguments

## Memory map

The memory size is user configurable. It is divided in three sections: code, data and stack. 
By default, the stack is 200 words in size, but this is user configurable as well. The stack segment is located at the end of the memory space.

          |-----------------| 
        0 | reserved        |
        1 | area            |
       ..
          |-----------------|
          | code            |  <- CS points here
          | segment         |
      ...
          |-----------------|
          | data            |  <- DS points here
          | segment         |
      ...
          |                 |
          |-----------------|
          | stack           |  <- SS points here
          | segment         |
      ...
          |                 |
          |-----------------|

When the system starts, IP (instruction pointer) and CS are initialized with a value that depends on the system (by default it is 1024 but it could be something else or even 0), then execution starts from that position. The reserved area is intended for multiple uses such as storing information about the hardware, data buffers and the interrupt table. By default the interrupt table starts at position 100 and usually it's no more than 256 bytes in size.

## lsystem assembly language

The basic assembly program structure is as follows:

    # comments are preceded by hash symbols
    .code
    
       mov ax, 1
       mov bx, 2
       add ax, bx  # comments can go here as well
       mov 1, ax
       
       # you can also skip lines
       out 1, 1

    end:
       jmp end

### Instructions and arguments

Identifiers like instruction names, register names or literal base prefixes are case sensitive. There are different types of arguments that an instruction can take.

* Literal values
* Memory references
* Registers
* Pointer values

#### Literal values

Supported literal values are

* 8-bit ASCII chars: represented between quotes. For instance 'a' which represents the 8-bit number 97.
* Integer constants: represented as 1, #2, \$3 and 0x4. No prefix means it's a decimal constant, # means it's octal and $ or 0x means it's hexadecimal. Decimal literals can have a minus sign  (-) for convenience to represent negative numbers.
* 32-bit floating point numbers: always in decimal and containing a dot. 3.1415 is a float literal. 3.0 is a float value, but plain 3 is an integer.

#### Memory references

You can operate with information in main memory by using memory references. They are stated as a numerical constant between brackets. Numerical constants can be decimal, octal or hexadecimal.
For instance, to move the number 0xEE to the memory position 1332 you would write `MOV [1332], 0xEE` 

#### Registers

There are several registers that you can use together with instructions. For a full list, check the table at the beginning of this document. 

#### Pointer values

Pointer values are memory references, but instead of defining them as fixed values, we can use the value stored in a register. This allows registers to function as pointers. For instance, `[AX]` represents the value stored in memory at the position pointed by the AX register. You can use any register except DS or SS.

You can also add a constant that will be substracted or added to the memory location specified by that register. To do this just add it next to it. For instance `[AX+2]` is a memory reference that is 2 words ahead from the position specified by AX.

Pointer values only work with registers. If you want to use the address located in a memory position you first need to load that memory position into a register, then use the register.

### Labels

You can use labels to create subroutines. Labels are defined before an instruction, but not necessarily in the same line. Labels are case sensitive

    .code

      main:
        call doSomething
    
      loop:
        jmp loop

      doSomething: 
        mov ax, 1
        mov bx, 2
        add ax, bx
        mov 1, ax
        ret

## The data section 

The data section is the first part of a valid lsystem program. It starts with the `.data` reserved word and contains definitions, constants and variables.

### Definitions

Definitions are labels that are substituted during the compilation process by a numeric value. Definitions are preceded by the keyword `define` and their names cannot be duplicates or reserved words such as register names. They are case sensitive.

    .data
    
      define value 0xCAFE
    
    .code

	main:
        mov ax, value
        
### Constants

### Interacting with devices
