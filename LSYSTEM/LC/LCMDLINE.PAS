{
  this unit handles the compiler command line arguments
}
unit lcmdline;

interface

  const
    C_SOURCE_EXTENSION = '.asm';
    C_BINARY_EXTENSION = '.bin';

  type
    TCommandLine = record
      sourceFilename: string;
      targetFilename: string;
    end;

  var
    commandLine: TCommandLine;

implementation

  procedure parseCommandLine;
  var
    count, i: byte;
  begin
    count := paramCount;
    fillChar(commandLine, sizeof(commandLine), 0);
    if count = 0 then exit;
    with commandLine do 
    begin
      sourceFilename := paramStr(1);
      if pos('.', sourceFilename) = 0 then sourceFilename := sourceFilename + C_SOURCE_EXTENSION;
      if count>1 then
      begin
        targetFilename := paramStr(2);
        if pos('.', sourceFilename) = 0 then sourceFilename := sourceFilename + C_BINARY_EXTENSION;
      end else begin
        i := pos('.', sourceFilename);
        if i = 0 then
          targetFilename := sourceFilename + C_BINARY_EXTENSION
        else
          targetFilename := copy(sourceFilename, 1, i-1) + C_BINARY_EXTENSION;
      end;
    end;

  end;

begin
  parseCommandLine;
end.