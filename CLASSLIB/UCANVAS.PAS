{
  UCanvas Unit
  Implements drawing primitives over a bitmap
  2022 LRT

  Bresenham's circle integer algorithm code from
  http://computer-programming-forum.com/29-pascal/0861975eb598093a.htm

  Bresenham's line integer algorithm code adapted from SWAG library,
  Graphics subsection, posted by Allyn Cross
}
unit
  ucanvas;

interface

  uses
    uexc, uclasses, types, locale, uobject, ubitmap, ubitmap1;

  const
    C_DEFAULT_STROKE_COLOR = EWhite;
    C_DEFAULT_FILL_COLOR = EBlack;

  type
    EStandardDrawPattern = (
      ESolid,
      EDots,
      EBlocks,
      ECheckers,
      EZig
    );

    PDrawPattern = ^TDrawPattern;
    TDrawPattern = array[0..7] of byte;

    PBrush = ^TBrush;
    TBrush = packed record
      color: TColor;
      pattern: TDrawPattern;
      patternScale: byte;
      patternOffsetX, patternOffsetY: byte;
      isSolid: boolean;
    end;

    PCanvas = ^TCanvas;
    TCanvas = object (TObject)
    public
      constructor initWithBitmap(bitmap: PBitmap);
      destructor done; virtual;
      procedure setPixel(x, y: word; brush: PBrush);
      procedure hline(x1, x2, y: word);
      procedure vline(y1, y2, x: word);
      procedure line(x1, y1, x2, y2: integer);
      procedure rect(x, y, width, height: word);
      procedure frect(x, y, width, height: word);
      procedure circle(x, y, radius: word);
      procedure grid(x, y, columns, rows, colWidth, rowHeight: word);
      procedure ffill(x, y: word);
      procedure clear;
      procedure setPattern(pattern: EStandardDrawPattern; brush: PBrush);
      procedure setPatternAuxFillColor(enabled: boolean; color: TColor);
      function getPresetColor(color: EColor): TColor;
      function getPixel(x, y: word): TColor;
      function getBitmap: PBitmap;
      function getStrokeBrush: PBrush;
      function getFillBrush: PBrush;
      function getClassName: string; virtual;
      function getClassId: word; virtual;
    private
      _bitmap: PBitmap;
      _stroke, _fill: TBrush;
      _enableAuxFillColor: boolean;
      _auxFillColor: TColor;
    end;

implementation

  const
    C_PATTERNS: array[EDots..EZig] of TDrawPattern = (
      ($AA, $55, $AA, $55, $AA, $55, $AA, $55), (* Dots *)
      ($CC, $CC, $33, $33, $CC, $CC, $33, $33), (* Blocks *)
      ($F0, $F0, $F0, $F0, $0F, $0F, $0F, $0F), (* Checkers *)
      ($18, $24, $42, $81, $18, $24, $42, $81)  (* Zig *)
    );

  { TCanvas }

  constructor TCanvas.initWithBitmap(bitmap: PBitmap);
  begin
    inherited init;
    _bitmap := bitmap;
    _bitmap^.retain;
    with _stroke do
    begin
      fillchar(_stroke, sizeOf(TBrush), 0);
      color := bitmap^.getPresetColor(C_DEFAULT_STROKE_COLOR);
      FillChar(pattern, 0, sizeOf(TDrawPattern));
      isSolid := true;
    end;
    with _fill do
    begin
      fillchar(_fill, sizeOf(TBrush), 0);
      color := bitmap^.getPresetColor(C_DEFAULT_FILL_COLOR);
      FillChar(pattern, 0, sizeOf(TDrawPattern));
      isSolid := true;
    end;
    _enableAuxFillColor := false;
  end;

  destructor TCanvas.done;
  begin
    _bitmap^.release;
    inherited done;
  end;

  procedure TCanvas.setPixel(x, y: word; brush: PBrush);
  begin
    with brush^ do
      if isSolid then
        _bitmap^.setPixel(x, y, color)
      else
        if ((pattern[(patternOffsetY + (y shr patternScale)) and 7]
             shl ((patternOffsetX + (x shr patternScale)) and 7)) and $80 <> 0) then
          _bitmap^.setPixel(x, y, color)
        else
          if _enableAuxFillColor then
            _bitmap^.setPixel(x, y, _auxFillColor);
  end;

  procedure TCanvas.line(x1, y1, x2, y2: integer);

    function sign(a:integer): integer;
    begin
      if a>0 then sign:=+1 else if a<0 then sign:=-1 else sign:=0;
    end;

  var
    d1x, d1y, d2x, d2y:integer;
    u, v, m, n, s, i: integer;

  begin
     u:= x2 - x1;
     v:= y2 - y1;
     d1x:= sign(u);
     d1y:= sign(v);
     d2x:= sign(u);
     d2y:= 0;
     m := abs(u);
     n := abs(v);
     if not (m>n) then
     begin
       d2x := 0 ;
       d2y := sign(v);
       m := abs(v);
       n := abs(u);
     end;
     s := m shr 1;
     for i := 0 to m do
     begin
       setPixel(x1, y1, @_stroke);
       s := s + n;
       if not (s<m) then
       begin
         s := s - m;
         x1 := x1 + round(d1x);
         y1 := y1 + round(d1y);
       end else
       begin
         x1 := x1 + round(d2x);
         y1 := y1 + round(d2y);
       end;
     end;
  end;

  procedure TCanvas.hline(x1, x2, y: word);
  var x: word;
  begin
    for x := x2 downto x1 do setPixel(x, y, @_stroke);
  end;

  procedure TCanvas.vline(y1, y2, x: word);
  var y: word;
  begin
    for y := y2 downto y1 do setPixel(x, y, @_stroke);
  end;

  procedure TCanvas.rect(x, y, width, height: word);
  var i: word;
  begin
    for i := x + width - 1 downto x do
    begin
      setPixel(i, y, @_stroke);
      setPixel(i, y+height-1, @_stroke);
    end;
    for i := y + height - 1 downto y do
    begin
      setPixel(x, i, @_stroke);
      setPixel(x+width-1, i, @_stroke);
    end;
  end;

  procedure TCanvas.frect(x, y, width, height: word);
  var px, py: word;
  begin
    rect(x, y, width, height);
    for px := x + width - 2 downto x+1 do
      for py := y + height - 2 downto y+1 do
        setPixel(px, py, @_fill);
  end;

  procedure TCanvas.circle(x, y, radius: word);
  var
    px, py, d: integer;
    dE, dSE: integer;
  begin
    px := 0;
    py := radius;
    d := 1 - radius;
    dE := 3;
    dSE := -(radius shl 1) + 5;
    setPixel(x, y-py, @_stroke);
    setPixel(x, y+py, @_stroke);
    setPixel(x+py, y-px, @_stroke);
    setPixel(x-py, y+px, @_stroke);
    while py>px do
    begin
      if d<0 then
      begin
        d := d + dE;
        dE := dE + 2;
        dSE := dSE + 2;
        px := px + 1;
      end else
      begin
        d := d + dSE;
        dE := dE + 2;
        dSE := dSE + 4;
        px := px + 1;
        py := py - 1;
      end;
      setPixel(x+px, y-py, @_stroke);
      setPixel(x-px, y+py, @_stroke);
      setPixel(x-px, y-py, @_stroke);
      setPixel(x+px, y+py, @_stroke);
      setPixel(x+py, y-px, @_stroke);
      setPixel(x-py, y+px, @_stroke);
      setPixel(x-py, y-px, @_stroke);
      setPixel(x+py, y+px, @_stroke);
    end;
  end;

  procedure TCanvas.grid(x, y, columns, rows, colWidth, rowHeight: word);
  var
    w, h: word;
    i: byte;
  begin
    w := (columns*colWidth) + columns;
    h := (rows*rowHeight) + rows;
    for i:=1 to rows-1 do
      hline(x+1, x+w-2, y+i*(rowHeight+1));
    for i:=1 to columns-1 do
      vline(y+1, y+h-2, x+i*(colWidth+1));
  end;

  procedure TCanvas.ffill(x, y: word);
  var
    mask: PBitmap;   { the control mask of painted pixels }
    base: TColor;    { the color that will be replaced by the flood fill }
    w, h: word;      { size of the bitmap in pixels }
    bw, bh: word;    { size of the bitmap in blocks }
      procedure fillBlock(x, y: word);
      var
        bx, by: word; { coordinates of the current block }
        x1, y1, x2, y2: word; { bounds of the current block }
        i: word; { needed to iterate over borders }
        procedure fillPixel(x, y: word);
        begin
          if (mask^.getPixel(x,y)>0) or (x<x1) or (x>x2) or (y<y1) or (y>y2) then exit;
          setPixel(x, y, @_fill);
          mask^.setPixel(x, y, 1);
          if _bitmap^.getPixel(x+1, y) = base then fillPixel(x+1, y);
          if _bitmap^.getPixel(x-1, y) = base then fillPixel(x-1, y);
          if _bitmap^.getPixel(x, y+1) = base then fillPixel(x, y+1);
          if _bitmap^.getPixel(x, y-1) = base then fillPixel(x, y-1);
        end;
      begin
        bx := x shr 4;
        by := y shr 4;
        x1 := bx shl 4;
        y1 := by shl 4;
        x2 := x1 + 15;
        y2 := y1 + 15;
        fillPixel(x, y);
        if (bx>0) then
          for i := y2 downto y1 do
            if (mask^.getPixel(x1, i) > 0) and (_bitmap^.getPixel(x1-1, i) = base) then
              fillBlock(x1-1, i);
        if (bx<bw) then
          for i := y2 downto y1 do
            if (mask^.getPixel(x2, i) > 0) and (_bitmap^.getPixel(x2+1, i) = base) then
              fillBlock(x2+1, i);
        if (by>0) then
          for i := x2 downto x1 do
            if (mask^.getPixel(i, y1) > 0) and (_bitmap^.getPixel(i, y1-1) = base) then
              fillBlock(i, y1-1);
        if (by<bh) then
          for i := x2 downto x1 do
            if (mask^.getPixel(i, y2) > 0) and (_bitmap^.getPixel(i, y2+1) = base) then
              fillBlock(i, y2+1);
      end;
  begin
    base := _bitmap^.getPixel(x, y);
    if base = _fill.color then exit;
    w := _bitmap^.getWidth;
    h := _bitmap^.getHeight;
    bw := w shr 4;
    bh := h shr 4;
    mask := new(PBitmap1, initWithSize(w, h));
    fillBlock(x, y);
    mask^.release;
  end;

  procedure TCanvas.clear;
  begin
    _bitmap^.clear(_fill.color);
  end;

  procedure TCanvas.setPattern(pattern: EStandardDrawPattern; brush: PBrush);
  begin
    if pattern = ESolid then
      brush^.isSolid := true
    else
    begin
      Move(C_PATTERNS[pattern], brush^.pattern, sizeOf(TDrawPattern));
      brush^.isSolid := false;
    end;
  end;

  procedure TCanvas.setPatternAuxFillColor(enabled: boolean; color: TColor);
  begin
    _enableAuxFillColor := enabled;
    _auxFillColor := color;
  end;

  function TCanvas.getPresetColor(color: EColor): TColor;
  begin
    getPresetColor := _bitmap^.getPresetColor(color);
  end;

  function TCanvas.getPixel(x, y: word): TColor;
  begin
    getPixel := _bitmap^.getPixel(x, y);
  end;

  function TCanvas.getBitmap: PBitmap;
  begin
    getBitmap := _bitmap;
  end;

  function TCanvas.getStrokeBrush: PBrush;
  begin
    getStrokeBrush := @_stroke;
  end;

  function TCanvas.getFillBrush: PBrush;
  begin
    getFillBrush := @_fill;
  end;

  function TCanvas.getClassName: string;
  begin
    getClassName := 'TCanvas';
  end;

  function TCanvas.getClassId: word;
  begin
    getClassId := C_CLASS_ID_Canvas;
  end;

  { Other }

end.