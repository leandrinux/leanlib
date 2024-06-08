unit
  lregs;

interface

  uses
    lcommon,
    lcbase;

  function getRegisterDataByName(const name:TRegisterName; var code, bitSize: byte): boolean;

implementation

  function getRegisterDataByName(const name:TRegisterName; var code, bitSize: byte): boolean;
  var
    i: byte;
  begin
    getRegisterDataByName := false;
    i := 0;
    while (i<C_REGISTER_COUNT) and (C_REGISTER_INFO[i].name <> name) do inc(i);
    if C_REGISTER_INFO[i].name <> name then exit;
    code := C_REGISTER_INFO[i].code;
    bitSize := C_REGISTER_INFO[i].bitSize;
    getRegisterDataByName := true;
  end;

end.