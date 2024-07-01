{
  this unit is in charge of keeping track of the symbols list
}
unit
  lsymbols;

interface

  uses
    consts, utils, uclasses, types, locale,
    uobject, uexc;

  const
    C_CLASS_ID_Symbols = $F013;

  type
    TSymbol = string[12];

  type
    PSymbols = ^TSymbols;
    TSymbols = object (TObject)
    public
      constructor init;
      destructor done; virtual;
      function getClassName: string; virtual;
      function getClassId: word; virtual;
      procedure addValue(var symbol: TSymbol; value: longint);
      procedure replaceSymbols(var sentence: TSentence);
    private
      _symbols: PList;
      _pending: PList;
    end;

implementation

  { TSymbols public }

  constructor TSymbols.init;
  begin
    inherited init;
    _symbols := new(PList, init);
    _pending := new(PList, init);
  end;

  destructor TSymbols.done;
  begin
    _symbols^.release;
    _pending^.release;
    inherited done;
  end;

  function TSymbols.getClassName: string;
  begin
    getClassName := 'TSymbols';
  end;

  function TSymbols.getClassId: word;
  begin
    getClassId := C_CLASS_ID_Symbols;
  end;

  procedure TSymbols.addValue(var symbol: TSymbol; value: longint);
  begin
  end;

  procedure TSymbols.replaceSymbols(var sentence: TSentence);
  begin
  end;

  { TSymbols private }

  { Other }

end.
