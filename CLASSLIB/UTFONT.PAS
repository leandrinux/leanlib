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
    PTinyFontData = ^TTinyFontData;
    TTinyFontData = packed record
      name: string32;
      fromChar, toChar: char;
      symbols: plong;
    end;

    TTinyFontSymbols = array[0..255] of longint;

  type
    PTinyFont = ^TTinyFont;
    TTinyFont = object (TFont)
    public
      constructor initWithData(fontData: PTinyFontData);
      destructor done; virtual;
      procedure getCharSize(ch: char; scale: byte; var width, height: word); virtual;
      procedure drawChar(ch: char; scale: byte; x, y: word; canvas: PCanvas); virtual;
      function getName: string; virtual;
      function getClassName: string; virtual;
      function getClassId: word; virtual;
      function getFontData: PTinyFontData;
    private
      _mustFreeMem: boolean;
      _fontData: PTinyFontData;
    end;

implementation

  const
    C_CHAR_WIDTH  = 5;
    C_CHAR_HEIGHT = 6;

  { TTinyFont public }

  constructor TTinyFont.initWithData(fontData: PTinyFontData);
  begin
    inherited init;
    _mustFreeMem := false;
    _fontData := fontData;
  end;

  destructor TTinyFont.done;
  begin
    if _mustFreeMem then FreeMem(_fontData, sizeOf(TTinyFontData));
    inherited done;
  end;

  procedure TTinyFont.getCharSize(ch: char; scale: byte; var width, height: word);
  begin
    if ch in [_fontData^.fromChar.._fontData^.toChar] then
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
    symbol: longint;
    cx, cy: word;
    p: plong;
    brush: PBrush;
    previousFillColor: TColor;
  begin
    with _fontData^ do
    begin
      if not (ch in [fromChar..toChar]) then exit;
      p := symbols;
      inc(p, ord(ch)- ord(fromChar));
    end;
    previousFillColor := canvas^.getFillBrush^.color;
    brush := canvas^.getStrokeBrush;
    canvas^.getFillBrush^.color := brush^.color;
    symbol := p^ shr 2;
    if symbol <> 0 then 
      for cy := C_CHAR_HEIGHT - 1 downto 0 do
        for cx := C_CHAR_WIDTH - 1 downto 0 do
        begin
          if (symbol and 1) <> 0 then
            if scale = 1 then
              canvas^.setPixel(cx + x, cy + y, brush)
            else
              canvas^.frect(x+(cx*scale), y+(cy*scale), scale, scale);
          symbol := symbol shr 1;
        end;
    canvas^.getFillBrush^.color := previousFillColor;
  end;

  function TTinyFont.getName: string;
  begin
    if _fontData <> nil then
      getName := _fontData^.name
    else
      getName := '';
  end;

  function TTinyFont.getClassName: string;
  begin
    getClassName := 'TTinyFont';
  end;

  function TTinyFont.getClassId: word;
  begin
    getClassId := C_CLASS_ID_TinyFont;
  end;

  function TTinyFont.getFontData: PTinyFontData;
  begin
    getFontData := _fontData;
  end;
  
  { TTinyFont private }

  { Other }

end.