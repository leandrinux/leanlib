{
  usbitmap Unit
  A subbitmap is a portion of another bitmap, like a window into it
  2022 LRT
}
unit
  usbitmap;

interface

  uses
    consts, utils, uexc, uclasses, types, locale, uobject, ubitmap;

  type
    PSubBitmap = ^TSubBitmap;
    TSubBitmap = object (TBitmap)
    public
      constructor initWithBitmap(bitmap: PBitmap; width, height: word);
      constructor initWithSize(width, height: word);
      destructor done; virtual;
      procedure setPixel(x, y: word; color: TColor); virtual;
      procedure clear(color: TColor); virtual;
      function getPixel(x, y: word): TColor; virtual;
      function getColorCount: longint; virtual;
      function getBitsPerPixel: byte; virtual;
      procedure move(x, y: word);
      procedure rmove(x, y: integer);
      procedure setBitmap(bitmap: PBitmap);
      function getClassName: string; virtual;
      function getClassId: word; virtual;
    private
      _bitmap: PBitmap;
      _x, _y: word;
      _bmWidth, _bmHeight: word;
    end;

implementation

  { TSubBitmap public }

  constructor TSubBitmap.initWithBitmap(bitmap: PBitmap; width, height: word);
  begin
    inherited initWithSize(width, height);
    _bitmap := nil;
    setBitmap(bitmap);
    _x := 0;
    _y := 0;
  end;

  constructor TSubBitmap.initWithSize(width, height: word);
  begin
    inherited initWithSize(width, height);
    _bitmap := nil;
    _x := 0;
    _y := 0;
  end;

  destructor TSubBitmap.done;
  begin
    if _bitmap <> nil then _bitmap^.release;
    inherited done;
  end;

  procedure TSubBitmap.setPixel(x, y: word; color: TColor);
  var
    px, py: word;
  begin
    px := _x + x;
    py := _y + y;
    if (px >= _bmWidth) or (py >= _bmHeight) then exit;
    _bitmap^.setPixel(px, py, color);
  end;

  procedure TSubBitmap.clear(color: TColor);
  begin
  end;

  function TSubBitmap.getPixel(x, y: word): TColor;
  var
    px, py: word;
  begin
    px := _x + x;
    py := _y + y;
    if (px >= _bmWidth) or (py >= _bmHeight) then
      getPixel := 0
    else
      getPixel := _bitmap^.getPixel(px, py);
  end;

  function TSubBitmap.getColorCount: longint;
  begin
    getColorCount := _bitmap^.getColorCount;
  end;

  function TSubBitmap.getBitsPerPixel: byte;
  begin
    getBitsPerPixel := _bitmap^.getBitsPerPixel;
  end;

  procedure TSubBitmap.move(x, y: word);
  begin
    _x := x;
    _y := y;
  end;

  procedure TSubBitmap.rmove(x, y: integer);
  var
    ix, iy: word;
  begin
    ix := _x + x;
    iy := _y + y;
    if ix < 0 then _x := 0 else _x := ix;
    if iy < 0 then _y := 0 else _y := iy;
  end;

  procedure TSubBitmap.setBitmap(bitmap: PBitmap);
  begin
    if _bitmap <> nil then _bitmap^.release;
    _bitmap := bitmap;
    _bitmap^.retain;
    _bmWidth := _bitmap^.getWidth;
    _bmHeight := _bitmap^.getHeight;
  end;

  function TSubBitmap.getClassName: string;
  begin
    getClassName := 'TSubBitmap';
  end;

  function TSubBitmap.getClassId: word;
  begin
    getClassId := C_CLASS_ID_SubBitmap;
  end;

  { TSubBitmap private }

  { Other }

end.