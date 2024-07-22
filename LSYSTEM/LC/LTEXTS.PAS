{
  this unit contains all the localized texts of the lsystem assembly compiler
}
unit 
  ltexts;

interface

  const
    C_STR_BANNER = 'LC lean system compiler version %0 (%1)';
    C_STR_BUILD_TS = 'Build date: %0 %1';
    C_STR_NO_SOURCE_FILE = 'No source file specified!';
    C_STR_BUILDING = 'Reading source...';
    C_STR_READ_ERROR = 'Could not read source code!';
    C_STR_SENTENCES_PROC = '%0 sentences processed';
    C_STR_MAKING = 'Making object file...';
    C_STR_SAVING = 'Saving...';
    C_STR_INVALID_POINTER_CONSTANT = 'Invalid pointer constant (%0)';
    C_STR_INVALID_POINTER_CONSTANT_RANGE = 'Pointer constant must be between -32768 and 32767';
    C_STR_UNRECOGNIZABLE_ARGUMENT = 'Unrecognizable argument "%0"';
    C_STR_SOURCE_NOT_SET = 'Source stream not set';
    C_STR_TARGET_NOT_SET = 'Target stream not set';
    C_STR_BUILD_SUCCESSFUL = 'Build successful :)';
    C_STR_EXPECTED_DATA = 'Expected .data at %0';

    { data parser errors }
    C_STR_ERR_UNRECOGNIZED_DATA_ELEMENT = '(%0) Unrecognized data section element "%1"';
    C_STR_ERR_UNRECOGNIZABLE_SYMBOL = '(%0) Unrecognizable argument "%1"';
    C_STR_ERR_EXPECTED_EQUAL = '(%0) expected "="';
    
    { code parser errors }
    C_STR_ERR_UNRECOGNIZED_OPERATION = '(%0) unrecognized operation "%1"';
    C_STR_ERR_OPERATION_EXPECTS_N_PARAM = '(%0) operation "%1" expects %2 parameters';
    C_STR_ERR_1ST_PARAM_UNSUPPORTED = '(%0) operation "%1" does not support "%2" as first parameter';
    C_STR_ERR_2ND_PARAM_UNSUPPORTED = '(%0) operation "%1" does not support "%2" as second parameter';
    C_STR_ERR_REGISTER_CANT_FIT = '(%0) register "%1" is not large enough for "%2"';
    C_STR_ERR_OUT_EXPECTS_8BIT = '(%0) OUT parameter "%1" must be 8-bit in size';
    C_STR_ERR_REGISTER_IS_READONLY = '(%0) Register %1 is read-only';
    C_STR_ERR_CS_CAN_ONLY_BE_MODIFIED = '(%0) CS can only be modified with MOV';
    C_STR_ERR_IN_REQUIRES_REGISTER = '(%0) IN only takes registers as second argument';

    { binary generator errors }
    C_STR_ERR_UNDEFINED_SYMBOL = 'Symbol "%0" was used but never defined';

implementation

end.