{
  UBitmap Unit
  Abstract class representing a bitmap, that is, a matrix of pixels
  2022 LRT
}
unit
  ubitmap;

interface

  uses
    uexc, uclasses, types, locale, uobject, palette, math, upalette;

  type
    PBitmap = ^TBitmap;
    TBitmap = object (TObject)
    public
      constructor initWithSize(width, height: word);
      destructor done; virtual;
      procedure setPixel(x, y: word; color: TColor); virtual;
      procedure setPixelBlock(x1, y1, x2, y2: word; color: TColor); virtual;
      procedure clear(color: TColor); virtual;
      procedure merge(src: PBitmap; x, y: word); virtual;
      procedure mergeT(src: PBitmap; x, y: word; transparent:TColor);
      procedure setPalette(pal: PColorPalette);
      function getPixel(x, y: word): TColor; virtual;
      function getWidth: word;
      function getHeight: word;
      function getPresetColor(color: EColor): TColor;
      function getColorCount: longint; virtual;
      function getBitsPerPixel: byte; virtual;
      function getPalette: PColorPalette;
      function getRawPixels: pointer; virtual;
      function getClassName: string; virtual;
      function getClassId: word; virtual;
    private
      _width, _height: word;
      _palette: PColorPalette;
    end;

implementation

  { TBitmap }

  constructor TBitmap.initWithSize(width, height: word);
  begin
    inherited init;
    iassert(getClassId<>C_CLASS_ID_Bitmap, @self, 0, S_ERR_ABSTRACT_CLASS);
    _width := width;
    _height := height;
    _palette := nil;
  end;

  destructor TBitmap.done;
  begin
    if _palette <> nil then _palette^.release;
    inherited done;
  end;

  procedure TBitmap.setPixel(x, y: word; color: TColor); begin end;

  procedure TBitmap.setPixelBlock(x1, y1, x2, y2: word; color: TColor);
  var x, y: word;
  begin
    for y := y2 downto y1 do
      for x := x2 downto x1 do
        setPixel(x, y, color);
  end;

  procedure TBitmap.clear(color: TColor); begin end;

  procedure TBitmap.merge(src: PBitmap; x, y: word);
  var
    w, h: word;
    px, py: word;
  begin
    if (x >= _width) or (y >= _height) then exit;
    w := minword(_width - x, src^.getWidth) - 1;
    h := minword(_height - y, src^.getHeight) - 1;
    for py := h downto 0 do
      for px := w downto 0 do
        setPixel(x+px, y+py, src^.getPixel(px, py));
  end;

  procedure TBitmap.mergeT(src: PBitmap; x, y: word; transparent:TColor);
  var
    w, h: word;
    px, py: word;
    color: longint;
  begin
    if (x >= _width) or (y >= _height) then exit;
    w := minword(_width - x, src^.getWidth) - 1;
    h := minword(_height - y, src^.getHeight) - 1;
    for py := h downto 0 do
      for px := w downto 0 do
      begin
        color := src^.getPixel(px, py);
        if color <> transparent then setPixel(x+px, y+py, color);
      end;
  end;

  procedure TBitmap.setPalette(pal: PColorPalette);
  begin
    if _palette <> nil then _palette^.release;
    _palette := pal;
    _palette^.retain;
  end;

  function TBitmap.getPixel(x, y: word): TColor;
  begin
    getPixel := 0;
  end;

  function TBitmap.getWidth: word;
  begin
    getWidth := _width;
  end;

  function TBitmap.getHeight: word;
  begin
    getHeight := _height;
  end;

  function TBitmap.getPresetColor(color: EColor): TColor;
  begin
    getPresetColor := palette.getColor(color, getBitsPerPixel);
  end;

  function TBitmap.getColorCount: longint;
  begin
    getColorCount := 0;
  end;

  function TBitmap.getBitsPerPixel: byte;
  begin
    getBitsPerPixel := 0;
  end;

  function TBitmap.getPalette: PColorPalette;
  begin
    getPalette := _palette;
  end;

  function TBitmap.getRawPixels: pointer;
  begin
    getRawPixels := nil;
  end;

  function TBitmap.getClassName: string;
  begin
    getClassName := 'TBitmap';
  end;

  function TBitmap.getClassId: word;
  begin
    getClassId := C_CLASS_ID_Bitmap;
  end;

  { Other }

end.