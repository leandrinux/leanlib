{
  ustring Unit
  TObject wrapper for pascal strings
  2022 LRT
}
unit
  ustring;

interface

  uses
    uexc, uclasses, types, locale, uobject;

  type
    PString = ^TString;
    TString = object (TObject)
    public
      constructor init;
      constructor initWithValue(value: string);
      destructor done; virtual;
      procedure setValue(value: string);
      function getValue: string;
      function getClassName: string; virtual;
      function getClassId: word; virtual;
    private
      _value: ^string;
    end;

implementation

  { TString public }

  constructor TString.init;
  begin
    inherited init;
    _value := nil;
 end;

  constructor TString.initWithValue(value: string);
  begin
    inherited init;
    _value := nil;
    setValue(value);
 end;

  destructor TString.done;
  begin
    if _value <> nil then FreeMem(_value, length(_value^) + 1);
    inherited done;
  end;

  procedure TString.setValue(value: string);
  begin
    if _value <> nil then FreeMem(_value, length(_value^) + 1);
    GetMem(_value, length(value) + 1);
    Move(value, _value^, length(value) + 1);
  end;

  function TString.getValue: string;
  begin
    getValue := _value^;
  end;

  function TString.getClassName: string;
  begin
    getClassName := 'TString';
  end;

  function TString.getClassId: word;
  begin
    getClassId := C_CLASS_ID_String;
  end;

  { TString private }

  { Other }

end.