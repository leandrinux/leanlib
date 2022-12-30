{
  uffont Unit
  A font implementation that uses 32 bit ints to store glyph data,
  using only 1KB to store the entire charset
  2022 LRT
}
unit
  utfont;

interface

  uses
    consts, utils, uexc, uclasses, types, locale,
    uobject, ufont, ucanvas;

  type
    PSymbolArray = ^TSymbolArray;
    TSymbolArray = array[0..255] of longint;

  type
    PTinyFont = ^TTinyFont;
    TTinyFont = object (TFont)
    public
      constructor init;
      constructor initWithData(fromChar, toChar: char; symbolArray: PSymbolArray);
      destructor done; virtual;
      procedure getCharSize(ch: char; scale: byte; var width, height: word); virtual;
      procedure drawChar(ch: char; scale: byte; x, y: word; canvas: PCanvas); virtual;
      function getGlyph(ch: char): longint;
      function getClassName: string; virtual;
      function getClassId: word; virtual;
    private
      _name: string32;
      _fromChar, _toChar: char;
      _mustFreeMem: boolean;
      _symbolArray: PSymbolArray;
    end;

implementation

  const
    C_CHAR_WIDTH  = 5;
    C_CHAR_HEIGHT = 6;

  { TTinyFont public }

  constructor TTinyFont.init;
  begin
    inherited init;
    _name := '';
    _fromChar := #0;
    _toChar := #255;
    _mustFreeMem := true;
    getMem(_symbolArray, sizeof(TSymbolArray));
    fillChar(_symbolArray^, sizeof(TSymbolArray), 0);
  end;

  constructor TTinyFont.initWithData(fromChar, toChar: char; symbolArray: PSymbolArray);
  begin
    inherited init;
    _name := '';
    _fromChar := fromChar;
    _toChar := toChar;
    _mustFreeMem := false;
    _symbolArray := symbolArray;
  end;

  destructor TTinyFont.done;
  begin
    if _mustFreeMem then freeMem(_symbolArray, sizeOf(TSymbolArray));
    inherited done;
  end;

  procedure TTinyFont.getCharSize(ch: char; scale: byte; var width, height: word);
  begin
    if (ch >= _fromChar) and (ch <= _toChar) then
    begin
      width := C_CHAR_WIDTH * scale;
      height := C_CHAR_HEIGHT * scale;
    end else begin
      width := 0;
      height := 0;
    end;
  end;

  procedure TTinyFont.drawChar(ch: char; scale: byte; x, y: word; canvas: PCanvas);
  var
    cx, cy: word;
    glyph: longint;
    brush: PBrush;
    previousFillColor: TColor;
  begin
    if (ch < _fromChar) or (ch > _toChar) then exit;
    glyph := _symbolArray^[ord(ch) - ord(_fromChar)] shr 2;
    if glyph <> 0 then
    begin
      previousFillColor := canvas^.getFillBrush^.color;
      brush := canvas^.getStrokeBrush;
      canvas^.getFillBrush^.color := brush^.color;
      for cy := C_CHAR_HEIGHT - 1 downto 0 do
        for cx := C_CHAR_WIDTH - 1 downto 0 do
        begin
          if (glyph and 1) <> 0 then
            if scale = 1 then
              canvas^.setPixel(cx + x, cy + y, brush)
            else
              canvas^.frect(x+(cx*scale), y+(cy*scale), scale, scale);
          glyph := glyph shr 1;
        end;
      canvas^.getFillBrush^.color := previousFillColor;
    end;
  end;

  function TTinyFont.getGlyph(ch: char): longint;
  begin
    getGlyph := _symbolArray^[ord(ch)];
  end;

  function TTinyFont.getClassName: string;
  begin
    getClassName := 'TTinyFont';
  end;

  function TTinyFont.getClassId: word;
  begin
    getClassId := C_CLASS_ID_TinyFont;
  end;
  
  { TTinyFont private }

  { Other }

end.