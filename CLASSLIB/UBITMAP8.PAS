{
  UBitmap8 Unit
  An 8-bit indexed color implementation of a bitmap
  2022 LRT
}
unit
  ubitmap8;

interface

  uses
    uexc, uclasses, types, locale, uobject, ubitmap, math;

  type
    PBitmap8 = ^TBitmap8;
    TBitmap8 = object (TBitmap)
    public
      constructor initWithSize(width, height: word);
      destructor done; virtual;
      procedure setPixel(x, y: word; color: TColor); virtual;
      function getPixel(x, y: word): TColor; virtual;
      procedure clear(color: TColor); virtual;
      function getColorCount: longint; virtual;
      function getBitsPerPixel: byte; virtual;
      function getRawPixels: pointer; virtual;
      function getClassName: string; virtual;
      function getClassId: word; virtual;
    private
      _pixels: pbyte;
      _size: longint;
    end;

implementation

  { TBitmap8 public }

  constructor TBitmap8.initWithSize(width, height: word);
  begin
    inherited initWithSize(width, height);
    _size := width * height;
    GetMem(_pixels, _size);
    clear(0);
  end;

  destructor TBitmap8.done;
  begin
    FreeMem(_pixels, _size);
    inherited done;
  end;

  procedure TBitmap8.setPixel(x, y: word; color: TColor);
  begin
    pbyte(incptr(_pixels, x + y * getWidth))^ := color;
  end;

  function TBitmap8.getPixel(x, y: word): TColor;
  begin
    getPixel := pbyte(incptr(_pixels, x + y * getWidth))^;
  end;

  procedure TBitmap8.clear(color: TColor);
  begin
    fillchar(_pixels^, _size, color);
  end;

  function TBitmap8.getColorCount: longint;
  begin
    getColorCount := 256;
  end;

  function TBitmap8.getBitsPerPixel: byte;
  begin
    getBitsPerPixel := 8;
  end;

  function TBitmap8.getRawPixels: pointer;
  begin
    getRawPixels := _pixels;
  end;

  function TBitmap8.getClassName: string;
  begin
    getClassName := 'TBitmap8';
  end;

  function TBitmap8.getClassId: word;
  begin
    getClassId := C_CLASS_ID_Bitmap8;
  end;

  { TBitmap8 private }

  { Other }

end.