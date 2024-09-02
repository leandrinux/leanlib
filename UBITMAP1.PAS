{
  UBitmap1 Unit
  1-bit color (monochrome) bitmap implementation
  2022 LRT
}
unit
  ubitmap1;

interface

  uses
    uexc, uclasses, types, locale, uobject, ubitmap, math;

  type
    PBitmap1 = ^TBitmap1;
    TBitmap1 = object (TBitmap)
    public
      constructor initWithSize(width, height: word);
      destructor done; virtual;
      procedure setPixel(x, y: word; color: TColor); virtual;
      procedure clear(color: TColor); virtual;
      function getPixel(x, y: word): TColor; virtual;
      function getColorCount: longint; virtual;
      function getBitsPerPixel: byte; virtual;
      function getClassName: string; virtual;
      function getClassId: word; virtual;
    private
      _map: pbyte;
      _mapSize: word;
    end;

implementation

  { TBitmap1 public }

  constructor TBitmap1.initWithSize(width, height: word);
  begin
    inherited initWithSize(width, height);
    _mapSize := 1 + (width * height) shr 3;
    getMem(_map, _mapSize);
    fillChar(_map^, _mapSize, 0);
  end;

  destructor TBitmap1.done;
  begin
    if _map <> nil then freeMem(_map, _mapSize);
    inherited done;
  end;

  procedure TBitmap1.setPixel(x, y: word; color: TColor);
  var
    pixeln: word;
    p: pbyte;
    m: byte;
  begin
    if (x>getWidth) or (y>getHeight) then exit;
    pixeln := (y * getWidth) + x;
    p := incptr(_map, pixeln shr 3);
    m := 1 shl ( 7 - (pixeln mod 8));
    if color = 0 then
      p^ := p^ and not m
    else
      p^ := p^ or m;
  end;

  procedure TBitmap1.clear(color: TColor);
  begin
    if color = 0 then
      fillChar(_map^, _mapSize, 0)
    else
      fillChar(_map^, _mapSize, $FF);
  end;

  function TBitmap1.getPixel(x, y: word): TColor;
  var
    pixeln: word;
    p: pbyte;
    m: byte;
  begin
    getPixel := 0;
    if (x>getWidth) or (y>getHeight) then exit;
    pixeln := (y * getWidth) + x;
    p := incptr(_map, pixeln shr 3);
    m := 1 shl ( 7 - (pixeln mod 8));
    if (p^ and m) <> 0 then getPixel := 1;
  end;

  function TBitmap1.getColorCount: longint;
  begin
    getColorCount := 1;
  end;

  function TBitmap1.getBitsPerPixel: byte;
  begin
    getBitsPerPixel := 1;
  end;

  function TBitmap1.getClassName: string;
  begin
    getClassName := 'TBitmap1';
  end;

  function TBitmap1.getClassId: word;
  begin
    getClassId := C_CLASS_ID_Bitmap1;
  end;

  { TBitmap1 private }

  { Other }

end.