{
  umbitmap Unit

  2022 LRT
}
unit
  umbitmap;

interface

  uses
    consts, utils, uexc, uclasses, types, locale, uobject, ubitmap;

  type
    PMaskBitmap = ^TMaskBitmap;
    TMaskBitmap = object (TBitmap)
    public
      constructor initWithBitmap(bitmap, mask: PBitmap);
      destructor done; virtual;
      function getPixel(x, y: word): TColor; virtual;
      function getColorCount: longint; virtual;
      function getBitsPerPixel: byte; virtual;
      procedure setMaskColor(color: TColor);
      procedure setTransparentColor(color: TColor);
      function getClassName: string; virtual;
      function getClassId: word; virtual;
    private
      _bitmap: PBitmap;
      _mask: PBitmap;
      _maskColor, _transparentColor: TColor;
    end;

implementation

  { TMaskBitmap public }

  constructor TMaskBitmap.initWithBitmap(bitmap, mask: PBitmap);
  begin
    _bitmap := bitmap;
    _bitmap^.retain;
    _mask := mask;
    _mask^.retain;
    _maskColor := 1;
    _transparentColor := $FF;
    inherited initWithSize(_bitmap^.getWidth, _bitmap^.getHeight);
  end;

  destructor TMaskBitmap.done;
  begin
    _bitmap^.release;
    _mask^.release;
    inherited done;
  end;

  function TMaskBitmap.getPixel(x, y: word): TColor;
  begin
    if _mask^.getPixel(x, y) = _maskColor then
      getPixel := _bitmap^.getPixel(x, y)
    else
      getPixel := _transparentColor;
  end;

  function TMaskBitmap.getColorCount: longint;
  begin
    getColorCount := _bitmap^.getColorCount;
  end;

  function TMaskBitmap.getBitsPerPixel: byte;
  begin
    getBitsPerPixel := _bitmap^.getBitsPerPixel;
  end;

  procedure TMaskBitmap.setMaskColor(color: TColor);
  begin
    _maskColor := color;
  end;

  procedure TMaskBitmap.setTransparentColor(color: TColor);
  begin
    _transparentColor := color;
  end;

  function TMaskBitmap.getClassName: string;
  begin
    getClassName := 'TMaskBitmap';
  end;

  function TMaskBitmap.getClassId: word;
  begin
    getClassId := C_CLASS_ID_MaskBitmap;
  end;

  { TMaskBitmap private }

  { Other }

end.