{
  GColors Unit
  2022 LRT
}
unit
  GColors;

interface

  uses
    consts, utils, uclasses, types, locale, palette,
    uobject, uexc, udisplay,
    gclasses, gtypes;

  type
    PColorArray = ^TColorArray;
    TColorArray = array [EColorKey] of TColor;

    PColorScheme = ^TColorScheme;
    TColorScheme = object (TObject)
    public
      { constructors and destructors}
      constructor init;
      destructor done; virtual;
      { extended methods }
      function getClassName: string; virtual;
      function getClassId: word; virtual;
      { methods }
      function getColor(key: EColorKey): TColor;
    private
      _colorArray: TColorArray;
    end;

  function DefaultColorScheme: PColorScheme;

implementation

  var
    ColorScheme: PColorScheme;

  { TColorScheme public }

  constructor TColorScheme.init;
  begin
    inherited init;
    pSetColorDepth(DisplayAdapter^.getCanvas^.getBitmap^.getBitsPerPixel);
    _ColorArray[ECKPanelBorderRaised] := pColor(EWhite);
    _ColorArray[ECKPanelBorderLowered] := pColor(EDarkgray);
    _ColorArray[ECKPanelBackground] := pColor(ELightgray);
    _ColorArray[ECKCheckboxSymbol] := pColor(EBlue);
    _ColorArray[ECKLabelText] := pColor(EBlack);
    _ColorArray[ECKButtonText] := pColor(EBlack);
    _ColorArray[ECKControlFocus] := pColor(EBlue);
    _ColorArray[ECKTextCursor] := pColor(EBlue);
    _ColorArray[ECKTextDisabled] := pColor(EDarkgray);
    _ColorArray[ECKTextPlaceholder] := pColor(EDarkgray);
  end;

  destructor TColorScheme.done;
  begin
    inherited done;
  end;

  function TColorScheme.getClassName: string;
  begin
    getClassName := 'TColorScheme';
  end;

  function TColorScheme.getClassId: word;
  begin
    getClassId := C_CLASS_ID_ColorScheme;
  end;

  function TColorScheme.getColor(key: EColorKey): TColor;
  begin
    getColor := _ColorArray[key];
  end;

  { TColorScheme private }

  { Other }

  function DefaultColorScheme: PColorScheme;
  begin
    if ColorScheme = nil then ColorScheme := new(PColorScheme, init);
    DefaultColorScheme := ColorScheme;
  end;

begin
  ColorScheme := nil;
end.
