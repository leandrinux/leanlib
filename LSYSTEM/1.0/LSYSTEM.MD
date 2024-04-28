# LSystem full specs document 1.0

This document describes the lsystem virtual architecture, defining the instruction set, the available registers and how memory is managed. It also provides a detailed description of the lsystem assembly language and its syntax.

This architecture was based on an initial work by Leandro Tami and Alejandra Pautasso for the 2003 and 2004 courses of Computer Architectures at FASTA University, Mar del Plata, Argentina.

The lsystem architecture is little-endian 32-bit. CPU registers are all 32-bit. The minimum addressable memory unit is a byte. The CPU can address 4294967296 bytes (4 GB max).

## Virtual CPU Registers

|Register|Code|Description|
|--------|----|-----------|
|SP|6|Stack pointer|
|BP|7|Base pointer|
|IP|8|Instruction pointer|
|CC|9|Condition codes (flags)|
|AX|10|General use register|
|BX|11|General use register|
|CX|12|General use register|
|DX|13|General use register|
|DS||Data segment|
|SS||Stack segment|

The CC register is affected by certain instructions. It has two meaningful bits: the zero bit and the sign bit. 

The DS and SS registers cannot be modified by code, they are fixed during execution.

## Instructions

A lsystem virtual CPU instruction is made of three components: a header and two arguments. Each component is 32 bit in size, therefore the whole instruction is 12 bytes long. 

     |--------------|--------------|--------------|
     |    Header    |    Param0    |    Param1    |
     |--------------|--------------|--------------|
     0              32             64             96

Instruction sizes are fixed, so instructions like `MOV` that take two arguments and others like `RET` that take none require the same space in memory. Instructions are placed in the code segment, with starts at position 0 of the memory space. 

The 32-bit header field is made of two parts: the first 16 bits which contains the opcode of the instruction that must be performed by the CPU, and the final 16 bits which contain extra information such as the type of each parameter.
    
    0                      15          28  29   30  31     
    |------------------------|------------------------|
    |        Opcode          |  N/A | Param0 | Param1 |
    |------------------------|------------------------|

    0 .. 15  : 8-bit operation code
    16 .. 27 : Reserved / Not applicable
    28 - 29 : Param0 type
    30 - 31 : Param1 type

The 2-bit parameter type values are defined as follows:

|Type|Value|
|-|-|
|0|Inmediate / Literal|
|1|Register|
|2|Address|
|3|Indirect|

When a parameter is a literal, the full 32 bit of the parameter field represent the value.

When a parameter is a register, the value stored in the parameter field is a code representing that register. Check the registers table previously defined to see the codes for each register.

When a parameter is an address, the full 32 bit value stored in the parameter field is a memory address.

When a parameter is indirect, the parameter value is formed as follows:

     0                                         27 28  29  30  31  	
    |--------------------------------------------|--------------|
    |           Constant                         |   Register   |
    |            offset                          |     code     |
    |--------------------------------------------|--------------|

The first 28 bits are a signed integer constant, therefore defined in the -67108864..67108863 range. The register code is the same value from the register table previously defined. The constant is an offset that is added to the address contained in the register before the indirection. For instance, if `AX` equals 10, then `[AX]` represents the value in memory position 10, `[AX]+2` represents the value in memory position 12 and `[AX]-3` represents the value in memory position 7.

## Instruction set 

The lsystem instruction set consists of 32 instructions divided in 5 groups: math, jumps, binary algebra and stack operations.

### Math

The math group of instructions is made of 12 instructions, including all from the basic 4 math operations to moving data and performing bit shifts, which essentially are the same as multiplying or dividing a value by 2. The four basic mathematical operations are handled by ADD, SUB, MUL and DIV for integer values, and FADD, FSUB, FMUL and FDIV for floating point values.

|Instruction|Opcode|Args|Affects CC|Description|
|-----------|------|----|----------|-----------|
|MOV|0x01|2|No|Moves the value in $2 to $1|
|ADD|0x02|2|Yes|$1 becomes $1 + $2|
|SUB|0x03|2|Yes|$1 becomes $1 - $2|
|MUL|0x04|2|Yes|$1 becomes $1 * $2|
|DIV|0x05|2|Yes|$1 becomes $1 / $2|
|CMP|0x06|2|Yes|Does $1 - $2 without changing $1|
|SHL|0x07|2|Yes|Shifts $1 to the left by $2 bits|
|SHR|0x08|2|Yes|Shifts $1 to the right by $2 bits|
|FADD|0x09|2|Yes|$1 becomes $1 + $2 (floating point)|
|FSUB|0x0A|2|Yes|$1 becomes $1 - $2 (floating point)|
|FMUL|0x0B|2|Yes|$1 becomes $1 * $2 (floating point)|
|FDIV|0x0C|2|Yes|$1 becomes $1 / $2 (floating point)|

### Jumps

This group is made of 8 instructions. Jumps are used to alter the flow of execution of the program. `JMP` is an unconditional jump, which means it will always change flow execution to the specified line. All other jumps are conditional and based on different criteria such as the sign bit, the zero bit or the result of a comparison with another value.

|Instruction|Opcode|Args|Affects CC|Description|
|-----------|------|----|----------|-----------|
|JMP|0x21|1|No|assigns $1 to IP causing a jump|
|JE|0x22|2|No|jumps to $2 if $1 is equal to AX|
|JG|0x23|2|No|jumps to $2 if $1 is greater than AX|
|JL|0x24|2|No|jumps to $2 if $1 is less than AX|
|JZ|0x25|1|No|jumps to $1 if CC zero bit is 1|
|JP|0x26|1|No|jumps to $1 if CC sign bit is 0|
|JN|0x27|1|No|jumps to $1 if CC sign bit is 1|
|JNZ|0x28|1|No|jumps to $1 if CC zero bit is 0|

### Binary algebra

The binary algebra group includes the 4 basic logical operations.

|Instruction|Opcode|Args|Affects CC|Description|
|-----------|------|----|----------|-----------|
|AND|0x31|2|Yes|$1 becomes $1 and $2|
|OR|0x32|2|Yes|$1 becomes $1 or $2|
|NOT|0x33|1|Yes|$1 becomes not $1|
|XOR|0x34|2|Yes|$1 becomes $1 xor $2|

### Stack operations

The stack operations are 4 instructions allowing for stack access such as adding or removing values to it, and most importantly, enables the ability to call subroutines.

|Instruction|Opcode|Args|Affects CC|Description|
|-----------|------|----|----------|-----------|
|PUSH|0x41|1|No|Pushes a value to the stack|
|POP|0x42|1|No|Pops a value from the stack|
|CALL|0x43|1|No|Performs subroutine call (pushes current instruction address plus one, then jumps to specified address)|
|RET|0x44|0|No|Pops the address from the stack and resumes execution from there|

## Memory map

The memory size is fixed to 2000 16-bit words (total size is 4K).
By default, the stack is 200 words in size. The stack segment is located at the end of the memory space.

          |-----------------| 
        0 | code            |
        1 | segment         |
      ...
          |-----------------|
          | data            |  <- DS points here
          | segment         |
      ...
     1799 |                 |
          |-----------------|
     1800 | stack           |  <- SS points here
     1801 | segment         |
      ...
     1999 |                 |
          |-----------------|

## lsystem assembly language

The basic assembly program structure is as follows:

    * comments are preceded by asterisks
    \\ASM
       mov ax, #1
       mov bx, #2
       add ax, bx
       mov 1, ax
       write 1, 1
       stop

You can specify a custom size for the stack by adding STACK=(size) next to the `\\ASM` header. 

    \\ASM STACK=100

### Instructions and arguments

Instructions are case insensitive. They can have 1 or 2 arguments, or none at all. There are different types of arguments

* Literal values
* Memory references
* Registers
* Indirect values

#### Literal values

The only supported literals are integer numbers. No chars and no strings are supported. Literals can be written in decimal, octal or hexadecimal format. Decimals must be preceded by `#`, octals are preceded by `@` and hexadecimals are preceded by `$`. Beware that plain numbers without this identification will be treated as memory references.

#### Memory references

You can operate with information in main memory by using memory references. They are simply stated as plain numbers, for instance, to move the number 23 to the memory position 1332 you would write `MOV 1332, #23` 

#### Registers

There are several registers that you can use together with instructions. For a full list, check the beginning of this document. You cannot change or access in any way the values stored in the DS or SS registers.

#### Indirect values

Indirect values are memory references, but instead of defining them as fixed values, we can use the value stored in a register. This allows registers to function as pointers. For instance, `[AX]` represents the value stored in memory at the position pointed by the AX register. You can use any register except DS or SS.

You can also add a constant that will be substracted or added to the memory location specified by that register. To do this just add it next to it. For instance `[AX]+2` is a memory reference that is 2 words ahead from the position specified by AX.

Indirect values only work with registers. If you want to use the address located in a memory position you first need to load that memory position into a register, then use the register.

### Constants and labels

You can use labels to create subroutines. Labels are defined right before an instruction.

    \\ASM STACK=100
                 call doSomething
                 stop

    doSomething: mov ax, #1
                 mov bx, #2
                 add ax, bx
                 mov 1, ax
                 write 1, 1

You can also define constants before the `\\ASM` header, and then use them instead of literal values.

    NUMBER EQU #16
    \\ASM
        mov ax, NUMBER