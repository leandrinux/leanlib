{
  unumber Unit
  TObject wrapper for 32-bit signed int (longint)
  2022 LRT
}
unit
  unumber;

interface

  uses
    uexc, uclasses, types, locale, uobject, utils;

  type
    PNumber = ^TNumber;
    TNumber = object (TObject)
    public
      constructor init;
      constructor initWithValue(value: longint);
      destructor done; virtual;
      procedure setValue(value: longint);
      function getValue: longint;
      function getBoolValue: boolean;
      function getClassName: string; virtual;
      function getClassId: word; virtual;
      function getHumanReadableString: string; virtual;
    private
      _value: longint;
    end;

implementation

  { TNumber public }

  constructor TNumber.init;
  begin
    inherited init;
  end;

  constructor TNumber.initWithValue(value: longint);
  begin
    inherited init;
    setValue(value);
  end;

  destructor TNumber.done;
  begin
    inherited done;
  end;

  procedure TNumber.setValue(value: longint);
  begin
    _value := value;
  end;

  function TNumber.getValue: longint;
  begin
    getValue := _value;
  end;

  function TNumber.getBoolValue: boolean;
  begin
    getBoolValue := _value <> 0;
  end;

  function TNumber.getClassName: string;
  begin
    getClassName := 'TNumber';
  end;

  function TNumber.getClassId: word;
  begin
    getClassId := C_CLASS_ID_Number;
  end;

  function TNumber.getHumanReadableString: string;
  begin
    getHumanReadableString := longtostr(_value);
  end;

  { TNumber private }

  { Other }

end.