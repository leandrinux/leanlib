{
  utrender Unit
  Text renderer. Manages justification, kerning, line-height, word-wrapping,
  cursor position, text bounds...
  2022 LRT
}
unit
  utrender;

interface

  uses
    consts, utils, uexc, uclasses, types, locale, ascii, math,
    uobject, ubitmap, ufont, utfont, usysfont, ucanvas;

  type
    PTextRenderer = ^TTextRenderer;
    TTextRenderer = object (TObject)
    public
      constructor init;
      destructor done; virtual;
      procedure write(str: string);
      procedure writeln(str: string);
      procedure setFont(font: PFont);
      procedure setScale(scale: byte);
      procedure setCanvas(canvas: PCanvas);
      procedure setCursor(x, y: word);
      procedure getCursor(var x, y: word);
      procedure setCharSpacing(charSpacing: byte);
      procedure setLineSpacing(lineSpacing: byte);
      procedure setBounds(x, y, w, h: word);
      procedure getBounds(var x, y, w, h: word);
      procedure resetBounds;
      procedure getTextSize(str: string; size: PSize);
      function getCharSpacing: byte;
      function getLineSpacing: byte;
      function getFont: PFont;
      function getScale: byte;
      function getCanvas: PCanvas;
      function getClassName: string; virtual;
      function getClassId: word; virtual;
    private
      _font: PFont;
      _lineHeight: byte;
      _lineSpacing: byte;
      _charSpacing: byte;
      _canvas: PCanvas;
      _scale: byte;
      _cursor: TPoint;
      _bounds: TFrame;
      procedure updateLineHeight;
    end;

implementation

  const
    C_LINE_HEIGHT_REFERENCE_CHAR = 'T';

  { TTextRenderer public }

  constructor TTextRenderer.init;
  begin
    inherited init;
    _font := nil;
    _canvas := nil;
    _scale := 1;
    _cursor.x := 0;
    _cursor.y := 0;
    _charSpacing := 1;
    _lineSpacing := 1;
  end;

  destructor TTextRenderer.done;
  begin
    if _font <> nil then _font^.release;
    if _canvas <> nil then _canvas^.release;
    inherited done;
  end;

  procedure TTextRenderer.write(str: string);
  var
    x, y, w, h: word;
    ch: char;
    i: byte;
  begin
    iassert(_font <> nil, @self, 0, S_ERR_FONT_NOT_SET);
    iassert(_canvas <> nil, @self, 0, S_ERR_CANVAS_NOT_SET);
    x := _cursor.x;
    y := _cursor.y;
    for i := 1 to length(str) do
    begin
      ch := str[i];

      if ch = C_CR then { Carry Return }
      begin
        inc(y, _lineHeight);
        inc(y, _lineSpacing);
        x := _bounds.point.x;
      end else begin { other characters }
        _font^.getCharSize(ch, _scale, w, h);
        if (w > 0) then
        begin
          _font^.drawChar(ch, _scale, x, y, _canvas);
          inc(x, w + 1);
        end;
      end;

    end;
    _cursor.x := x;
    _cursor.y := y;
  end;

  procedure TTextRenderer.writeln(str: string);
  begin
    write(str);
    write(C_CR);
  end;

  procedure TTextRenderer.setFont(font: PFont);
  begin
    if _font <> nil then _font^.release;
    _font := font;
    _font^.retain;
    updateLineHeight;
  end;

  procedure TTextRenderer.setScale(scale: byte);
  begin
    _scale := scale;
    updateLineHeight;
  end;

  procedure TTextRenderer.setCanvas(canvas: PCanvas);
  begin
    if _canvas <> nil then _canvas^.release;
    _canvas := canvas;
    canvas^.retain;
    resetBounds;
  end;

  procedure TTextRenderer.setCursor(x, y: word);
  begin
    _cursor.x := x;
    _cursor.y := y;
  end;

  procedure TTextRenderer.setCharSpacing(charSpacing: byte);
  begin
    _charSpacing := charSpacing;
  end;

  procedure TTextRenderer.setLineSpacing(lineSpacing: byte);
  begin
    _lineSpacing := lineSpacing;
  end;

  procedure TTextRenderer.setBounds(x, y, w, h: word);
  begin
    _bounds.point.x := x;
    _bounds.point.y := y;
    _bounds.size.width := w;
    _bounds.size.height := h;
  end;

  procedure TTextRenderer.getBounds(var x, y, w, h: word);
  begin
    x := _bounds.point.x;
    y := _bounds.point.y;
    w := _bounds.size.width;
    h := _bounds.size.height;
  end;

  procedure TTextRenderer.resetBounds;
  begin
    _bounds.point.x := 0;
    _bounds.point.y := 0;
    _bounds.size.width := _canvas^.getBitmap^.getWidth;
    _bounds.size.height := _canvas^.getBitmap^.getHeight;
  end;

  procedure TTextRenderer.getTextSize(str: string; size: PSize);
  var
    cw, ch, w, h: word;
    i: byte;
    c: char;
  begin
    iassert(_font <> nil, @self, 0, S_ERR_FONT_NOT_SET);
    { warning! does not support multiline texts }
    w := 0;
    h := 0;
    for i := 1 to length(str) do
    begin
      c := str[i];
      _font^.getCharSize(c, _scale, cw, ch);
      h := maxword(h, ch);
      inc(w, cw + _charSpacing);
    end;
    dec(w, _charSpacing);
    size^.width := w;
    size^.height := h;
  end;

  function TTextRenderer.getCharSpacing: byte;
  begin
    getCharSpacing := _charSpacing;
  end;

  function TTextRenderer.getLineSpacing: byte;
  begin
    getLineSpacing := _lineSpacing;
  end;

  procedure TTextRenderer.getCursor(var x, y: word);
  begin
    x := _cursor.x;
    y := _cursor.y;
  end;

  function TTextRenderer.getFont: PFont;
  begin
    getFont := _font;
  end;

  function TTextRenderer.getScale: byte;
  begin
    getScale := _scale;
  end;

  function TTextRenderer.getCanvas: PCanvas;
  begin
    getCanvas := _canvas;
  end;

  function TTextRenderer.getClassName: string;
  begin
    getClassName := 'TTextRenderer';
  end;

  function TTextRenderer.getClassId: word;
  begin
    getClassId := C_CLASS_ID_TextRenderer;
  end;

  { TTextRenderer private }

  procedure TTextRenderer.updateLineHeight;
  var
    w, h: word;
  begin
    _font^.getCharSize(C_LINE_HEIGHT_REFERENCE_CHAR, _scale, w, h);
    _lineHeight := h;
  end;

  { Other }

end.