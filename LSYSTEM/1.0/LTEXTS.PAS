{
  this unit contains all the localized texts of the lsystem assembly compiler
}
unit 
  ltexts;

interface

  const
    C_STR_BANNER = 'LC lsystem compiler version %0 (%1)';
    C_STR_LSYSTEM_VERSION = '1.0';
    C_STR_LSYSTEM_CODENAME = 'Ragamuffin';
    C_STR_BUILD_TS = 'Build date: %0 %1';
    C_STR_NO_SOURCE_FILE = 'No source file specified!';
    C_STR_BUILDING = 'Reading source...';
    C_STR_READ_ERROR = 'Could not read source code!';
    C_STR_SENTENCES_PROC = '%0 sentences read';
    C_STR_MAKING = 'Making object file...';
    C_STR_SAVING = 'Saving...';
    C_STR_UNRECOGNIZED_OPERATION = 'unrecognized operation at line %0';
    C_STR_OPERATION_EXPECTS_N_PARAM = 'operation expects %0 parameters';
    C_STR_1ST_LITERAL_UNSUPPORTED = 'operation %0 does not support a literal as first parameter';
    C_STR_2ND_LITERAL_UNSUPPORTED = 'operation %0 does not support a literal as second parameter';
    C_STR_REGISTER_CANT_FIT = 'register in first parameter cannot fit literal or register on the second parameter';
    C_STR_OUT_EXPECTS_8BIT = 'OUT expects an 8-bit register as second parameter';
    C_STR_INVALID_POINTER_CONSTANT = 'Invalid pointer constant (%0)';
    C_STR_INVALID_POINTER_CONSTANT_RANGE = 'Pointer constant must be between -32768 and 32767';
    C_STR_UNRECOGNIZABLE_ARGUMENT = 'Unrecognizable argument "%0"';
    C_STR_SOURCE_NOT_SET = 'Source stream not set';
    C_STR_TARGET_NOT_SET = 'Target stream not set';
    C_STR_SYMBOL_ADDED = 'Added symbol "%0" with value %1';
    C_STR_UNDEFINED_SYMBOL = 'Undefined symbol "%0"';

implementation

end.