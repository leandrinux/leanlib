{
  ubmlayer Unit
  A layer is used to represent a bitmap within the context of a composition
  2022 LRT
}
unit
  ubmlayer;

interface

  uses
    consts, utils, uexc, uclasses, types, locale, uobject, ubitmap;

  const
    C_DEFAULT_TRANSPARENT_COLOR = 0;

  type
    PBitmapLayer = ^TBitmapLayer;
    TBitmapLayer = object (TObject)
    public
      constructor initWithBitmap(bitmap: PBitmap);
      destructor done; virtual;
      procedure setPosition(x, y: integer);
      procedure getPosition(var x, y: integer);
      procedure setChanged(value: boolean);
      procedure setHidden(value: boolean);
      procedure setTransparent(state: boolean; color: TColor);
      function getBitmap: PBitmap;
      function getPixel(absX, absY: word): TColor;
      function isValidPixel(absX, absY: word): boolean;
      function isHidden: boolean;
      function isChanged: boolean;
      function getClassName: string; virtual;
      function getClassId: word; virtual;
    private
      _bitmap: PBitmap;
      _x, _y: integer;
      _w, _h: word;
      _hidden: boolean;
      _changed: boolean;
      _transparentColor: TColor;
      _isTransparent: boolean;
    end;

implementation

  { TBitmapLayer public }

  constructor TBitmapLayer.initWithBitmap(bitmap: PBitmap);
  begin
    inherited init;
    _bitmap := bitmap;
    _bitmap^.retain;
    _x := 0;
    _y := 0;
    _w := bitmap^.getWidth;
    _h := bitmap^.getHeight;
    _changed := false;
    _hidden := false;
    _transparentColor := C_DEFAULT_TRANSPARENT_COLOR;
    _isTransparent := false;
  end;

  destructor TBitmapLayer.done;
  begin
    _bitmap^.release;
    inherited done;
  end;

  procedure TBitmapLayer.setPosition(x, y: integer);
  begin
    _x := x;
    _y := y;
  end;

  procedure TBitmapLayer.getPosition(var x, y: integer);
  begin
    x := _x;
    y := _y;
  end;

  procedure TBitmapLayer.setChanged(value: boolean);
  begin
    _changed := value;
  end;

  procedure TBitmapLayer.setHidden(value: boolean);
  begin
    _hidden := value;
  end;

  function TBitmapLayer.isHidden: boolean;
  begin
    isHidden := _hidden;
  end;

  function TBitmapLayer.getBitmap: PBitmap;
  begin
    getBitmap := _bitmap;
  end;

  function TBitmapLayer.getPixel(absX, absY: word): TColor;
  begin
    getPixel := _bitmap^.getPixel(absX - _x, absY - _y);
  end;

  function TBitmapLayer.isValidPixel(absX, absY: word): boolean;
  var
    maxX, maxY: integer;
    x, y: word;
  begin
    x := absX - _x;
    y := absY - _y;
    maxX := _x + _w - 1;
    maxY := _y + _h - 1;
    isValidPixel :=
      (not _isTransparent or (_bitmap^.getPixel(x, y) <> _transparentColor)) and
      (absX >= _x) and
      (absX <= maxX) and
      (absY >= _y) and
      (absY <= maxY);
  end;

  function TBitmapLayer.isChanged: boolean;
  begin
    isChanged := _changed;
  end;

  procedure TBitmapLayer.setTransparent(state: boolean; color: TColor);
  begin
    _isTransparent := state;
    _transparentColor := color;
  end;

  function TBitmapLayer.getClassName: string;
  begin
    getClassName := 'TBitmapLayer';
  end;

  function TBitmapLayer.getClassId: word;
  begin
    getClassId := C_CLASS_ID_BitmapLayer;
  end;

  { TBitmapLayer private }

  { Other }

end.