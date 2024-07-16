{
  this unit is in charge of keeping track of the symbols list
}
unit
  lsymbols;

interface

  uses
    consts, utils, uclasses, types, locale, strings,
    uobject, uexc, ulist, ltexts,
    lcommon, lcbase;

  const
    C_CLASS_ID_SYMBOLS = $F013;

  type
    PSymbols = ^TSymbols;
    TSymbols = object (TObject)
    public
      constructor init;
      destructor done; virtual;
      function getClassName: string; virtual;
      function getClassId: word; virtual;
      procedure addValue(const name: TString30; value: TUInt32);
      procedure addUnknownValue(const name: TString30; reference: PUInt32);
      function getValue(const name: TString30; var value: TUInt32): boolean;
      function getUnknownCount: word;
      function getFirstUnknownName: TString30;
    private
      _known: PList;
      _unknown: PList;
      procedure replaceUnknown(const name: TString30; value: TUInt32);
    end;

    PUnknownSymbol = ^TUnknownSymbol;
    TUnknownSymbol = object (TObject)
      name: TString30;
      reference: PUInt32;
    end;

implementation

  { TSymbols public }

  constructor TSymbols.init;
  begin
    inherited init;
    _known := new(PList, init);
    _unknown := new(PList, init);
  end;

  destructor TSymbols.done;
  begin
    _known^.release;
    _unknown^.release;
    inherited done;
  end;

  function TSymbols.getClassName: string;
  begin
    getClassName := 'TSymbols';
  end;

  function TSymbols.getClassId: word;
  begin
    getClassId := C_CLASS_ID_SYMBOLS;
  end;

  procedure TSymbols.addValue(const name: TString30; value: TUInt32);
  var
    symbol: PSymbol; 
  begin
    symbol := new(PSymbol, init);
    symbol^.name := name;
    symbol^.value := value;
    _known^.addObject(symbol);
    symbol^.release;
    replaceUnknown(name, value);
  end;

  function TSymbols.getValue(const name: TString30; var value: TUInt32): boolean;
  var
    symbol: PSymbol;
  begin
    _known^.moveToStart;
    symbol := PSymbol(_known^.getObjectAtCursor);
    while (symbol<>nil) and (symbol^.name <> name) do 
    begin
      _known^.moveForward;
      symbol := PSymbol(_known^.getObjectAtCursor);
    end;
    if symbol <> nil then
    begin
      getValue := true;
      value := symbol^.value;
    end else begin
      getValue := false;
      value := 0;
    end;
  end;

  procedure TSymbols.addUnknownValue(const name: TString30; reference: PUInt32);
  var
    symbol: PUnknownSymbol;
  begin
    symbol := new(PUnknownSymbol, init);
    symbol^.name := name;
    symbol^.reference := reference;
    _unknown^.addObject(symbol);
    symbol^.release;
  end;

  function TSymbols.getUnknownCount: word;
  var
    symbol: PUnknownSymbol;
  begin
    _unknown^.moveToStart;
    symbol := PUnknownSymbol(_unknown^.getObjectAtCursor);
    while symbol <> nil do
    begin
      _unknown^.moveForward;
      symbol := PUnknownSymbol(_unknown^.getObjectAtCursor);
    end;

    getUnknownCount := _unknown^.getCount;
  end;

  function TSymbols.getFirstUnknownName: TString30;
  var
    UnknownSymbol: PUnknownSymbol;
  begin
    UnknownSymbol := PUnknownSymbol(_unknown^.getFirst);
    if UnknownSymbol <> nil then 
      getFirstUnknownName := UnknownSymbol^.name
    else
      getFirstUnknownName := '';
  end;

  procedure TSymbols.replaceUnknown(const name: TString30; value: TUInt32);
  var
    symbol: PUnknownSymbol;
  begin
    _unknown^.moveToStart;
    symbol := PUnknownSymbol(_unknown^.getObjectAtCursor);
    while symbol <> nil do
    begin
      if symbol^.name = name then
      begin
        symbol^.reference^ := value;
        _unknown^.removeObjectAtCursor;
      end else
        _unknown^.moveForward;
      symbol := PUnknownSymbol(_unknown^.getObjectAtCursor);
    end;    
  end;

  { TSymbols private }

  { Other }

end.
