{
  this unit contains all the localized texts of the lsystem assembly compiler
}
unit 
  ltexts;

interface

  const
    C_STR_BANNER = 'LASMC lsystem assembly compiler version %0';
    C_STR_BUILD_TS = 'Built on %0 at %1';
    C_STR_NO_SOURCE_FILE = 'No source file specified!';
    C_STR_BUILDING = 'Building...';
    C_STR_READ_ERROR = 'Could not read source code!';
    C_STR_SENTENCES_PROC = '%0 sentences read';
    C_STR_SENTENCE_OPERATION = 'operation %0 (%1)';
    C_STR_SENTENCE_PARAMETER = '   param %0 (%1)';
    C_STR_MAKING = 'making object file';
    C_STR_SAVING = 'saving object file';
    C_STR_UNRECOGNIZED_OPERATION = 'unrecognized operation at line %0';
    C_STR_OPERATION_EXPECTS_N_PARAM = 'operation expects %0 parameters';
    C_STR_1ST_LITERAL_UNSUPPORTED = 'operation %0 does not support a literal as first parameter';
    C_STR_2ND_LITERAL_UNSUPPORTED = 'operation %0 does not support a literal as second parameter';
    C_STR_REGISTER_CANT_FIT = 'register in first parameter cannot fit literal or register on the second parameter';
    C_STR_OUT_EXPECTS_8BIT = 'OUT expects an 8-bit register as second parameter';
    C_STR_INVALID_POINTER_CONSTANT = 'Invalid pointer constant';
    C_STR_INVALID_POINTER_CONSTANT_RANGE = 'Pointer constant must be between -32768 and 32767';

implementation

end.