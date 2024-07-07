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
    C_CLASS_ID_known = $F013;

  type
    PSymbols = ^TSymbols;
    TSymbols = object (TObject)
    public
      constructor init;
      destructor done; virtual;
      function getClassName: string; virtual;
      function getClassId: word; virtual;
      procedure addValue(var name: TString30; value: TUInt32);
      procedure addUnknownValue(const name: TString30; const value: TUInt32);
      function getValue(const name: TString30; var value: TUInt32): boolean;
      function getUnknownCount: word;
      function getFirstUnknownName: TString30;
    private
      _known: PList;
      _unknown: PList;
      procedure replaceUnknown(var name: TString30; value: TUInt32);
    end;

    PKnownSymbol = ^TKnownSymbol;
    TKnownSymbol = object (TObject)
      name: TString30;
      value: TUInt32;
    end;

    PUnknownSymbol = ^TUnknownSymbol;
    TUnknownSymbol = object (TObject)
      name: TString30;
      reference: ^TUInt32;
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
    getClassId := C_CLASS_ID_known;
  end;

  procedure TSymbols.addValue(var name: TString30; value: TUInt32);
  var
    pair: PKnownSymbol; 
  begin
    pair := new (PKnownSymbol, init);
    pair^.name := name;
    pair^.value := value;
    _known^.addObject(pair);
    pair^.release;
    message(strformatn(C_STR_SYMBOL_ADDED, name + #0 + intToStr(value)));
    replaceUnknown(name, value);
  end;

  function TSymbols.getValue(const name: TString30; var value: TUInt32): boolean;
  var
    pair: PKnownSymbol;
  begin
    _known^.moveToStart;
    pair := PKnownSymbol(_known^.getObjectAtCursor);
    while (pair<>nil) and (pair^.name <> name) do 
    begin
      _known^.moveForward;
      pair := PKnownSymbol(_known^.getObjectAtCursor);
    end;
    if pair <> nil then
    begin
      getValue := true;
      value := pair^.value;
    end else begin
      getValue := false;
      value := 0;
    end;
  end;

  procedure TSymbols.addUnknownValue(const name: TString30; const value: TUInt32);
  var
    pair: PUnknownSymbol;
  begin
    pair := new(PUnknownSymbol, init);
    pair^.name := name;
    pair^.reference := @value;
    _unknown^.addObject(pair);
    pair^.release;
  end;

  function TSymbols.getUnknownCount: word;
  begin
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

  procedure TSymbols.replaceUnknown(var name: TString30; value: TUInt32);
  begin
    _unknown^.moveToStart;
    { CONTINUE HERE }
    
  end;

  { TSymbols private }

  { Other }

end.
