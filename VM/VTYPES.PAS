unit
  vtypes;

interface

  uses
    types;

  type
    TAssemblyInstructionName = string[4];

    TOpcode = byte;

    TAssemblyInstruction = packed record
      name: TAssemblyInstructionName;
      opcode: TOpcode;
    end;

implementation

end.