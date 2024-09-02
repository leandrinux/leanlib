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

  function getColor(color: EColor; bitsPerPixel: byte): TColor;

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

end.