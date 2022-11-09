unit
  vconst;

interface

  uses
    vtypes;

  const
    C_INSTRUCTION_SET_SIZE = 26;
    
    C_INSTRUCTION_SET : array [0 .. C_INSTRUCTION_SET_SIZE-1] of TAssemblyInstruction = (
        (name: 'ADD';    opcode: 0),
        (name: 'AND';    opcode: 1),
        (name: 'CALL';   opcode: 2),
        (name: 'CMP';    opcode: 3),
        (name: 'DIV';    opcode: 4),
        (name: 'IN';     opcode: 5),
        (name: 'INT';    opcode: 6),
        (name: 'JG';     opcode: 7),
        (name: 'JL';     opcode: 8),
        (name: 'JMP';    opcode: 9),
        (name: 'JNZ';    opcode: 10),
        (name: 'JZ';     opcode: 11),
        (name: 'MOV';    opcode: 12),
        (name: 'MUL';    opcode: 13),
        (name: 'NOT';    opcode: 14),
        (name: 'OR';     opcode: 15),
        (name: 'OUT';    opcode: 16),
        (name: 'POP';    opcode: 17),
        (name: 'POPA';   opcode: 18),
        (name: 'PUSH';   opcode: 19),
        (name: 'PUSHA';  opcode: 20),
        (name: 'RET';    opcode: 21),
        (name: 'SHL';    opcode: 22),
        (name: 'SHR';    opcode: 23),
        (name: 'SUB';    opcode: 24),
        (name: 'XOR';    opcode: 25)
    );

implementation

end.