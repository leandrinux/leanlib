{
  upalette Unit
  Color palette of up to 256 entries, usually included with 256-color bitmaps
  2022 LRT
}
unit
  upalette;

interface

  uses
    consts, utils, uexc, uclasses, types, locale, uobject, math;

  type
    PColorPalette = ^TColorPalette;
    TColorPalette = object (TObject)
    public
      constructor initWithSize(count: byte; fromIndex: byte);
      constructor initWithColors(colors: PRGBColor; count: word; fromIndex: byte);
      destructor done; virtual;
      procedure getColors(var colors: PRGBColor; var count: word; var fromIndex: byte);
      procedure setColor(color: PRGBColor; index: byte);
      function getColor(index: byte): PRGBColor;
      function getColorCount: word;
      function getClassName: string; virtual;
      function getClassId: word; virtual;
    private
      _fromIndex: byte;
      _count: word;
      _size: word;
      _colors: PRGBColor;
    end;

implementation

  { TColorPalette public }

  constructor TColorPalette.initWithSize(count: byte; fromIndex: byte);
  begin
    inherited init;
    _fromIndex := fromIndex;
    _count := count;
    _size := _count shl 2;
    getMem(_colors, _size);
    fillChar(_colors^, _size, 0);
  end;

  constructor TColorPalette.initWithColors(colors: PRGBColor; count: word; fromIndex: byte);
  begin
    inherited init;
    _fromIndex := fromIndex;
    _count := count;
    _size := _count * sizeOf(TRGBColor);
    getMem(_colors, _size);
    move(colors^, _colors^, _size);
  end;

  destructor TColorPalette.done;
  begin
    freeMem(_colors, _size);
    inherited done;
  end;

  procedure TColorPalette.getColors(var colors: PRGBColor; var count: word; var fromIndex: byte);
  begin
    colors := _colors;
    count := _count;
    fromIndex := _fromIndex;
  end;

  procedure TColorPalette.setColor(color: PRGBColor; index: byte);
  var p: PRGBColor;
  begin
    p := _colors;
    inc(p, _fromIndex + index);
    p^ := color^;
  end;

  function TColorPalette.getColor(index: byte): PRGBColor;
  var p: PRGBColor;
  begin
    p := _colors;
    inc(p, _fromIndex + index);
    getColor := p;
  end;

  function TColorPalette.getColorCount: word;
  begin
    getColorCount := _count;
  end;

  function TColorPalette.getClassName: string;
  begin
    getClassName := 'TColorPalette';
  end;

  function TColorPalette.getClassId: word;
  begin
    getClassId := C_CLASS_ID_ColorPalette;
  end;

  { TColorPalette private }

  { Other }

end.