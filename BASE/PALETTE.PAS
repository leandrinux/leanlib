{
  Palette Unit
  All about color palettes!
  2022 LRT
}
unit
  palette;

interface

  uses
    types;

  const
    C_RGB_COLORS: array [EColor] of TColor = (
      $000000FF, $0000AAFF, $00AA00FF, $00AAAAFF,
      $AA0000FF, $AA00AAFF, $AA5555FF, $AAAAAAFF,
      $555555FF, $0055FFFF, $00FF55FF, $00FFFFFF,
      $FF0000FF, $FF00FFFF, $FFFF00FF, $FFFFFFFF
    );

  type
    TColorFunc = function(color: EColor): TColor;

  var
    pColor: TColorFunc;

  function getColor(color: EColor; bitsPerPixel: byte): TColor;
  procedure pSetColorDepth(bitsPerPixel: byte);
  function pColor1(color: EColor): TColor; far;
  function pColor8(color: EColor): TColor; far;
  function pColor32(color: EColor): TColor; far;

implementation

  function getColor(color: EColor; bitsPerPixel: byte): TColor;
  begin
    case bitsPerPixel of
      1: if color = EBlack then getColor := 0 else getColor := 1;
      8: getColor := ord(color);
      32: getColor := C_RGB_COLORS[color];
    else
      getColor := 0;
    end;
  end;

  procedure pSetColorDepth(bitsPerPixel: byte);
  begin
    case bitsPerPixel of
      8: pColor := pColor8;
      32: pColor := pColor32;
    else
      pColor := pColor1;
    end;
  end;

  function pColor1(color: EColor): TColor;
  begin
    if color = EBlack then pColor1 := 1 else pColor1 := 0;
  end;

  function pColor8(color: EColor): TColor;
  begin
    pColor8 := ord(color);
  end;

  function pColor32(color: EColor): TColor;
  begin
    pColor32 := C_RGB_COLORS[color];
  end;

begin
  pColor := pColor8;
end.